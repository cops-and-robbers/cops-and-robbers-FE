# CodeRabbit PR #109 리뷰 반영 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CodeRabbit 리뷰에서 지적된 실질적 보안/안정성 이슈 5건을 수정한다.

**Architecture:** GoRouter redirect 로직 강화 (디버그 라우트 가드, 신규회원 우회 방지, catch 안전 처리), arrestRobber 재진입 방어, AuthNotifier dispose 시 콜백 해제

**Tech Stack:** Flutter, GoRouter, Riverpod, STOMP

---

## 제외 항목 (과도하거나 불필요)

| 이슈 | 제외 이유 |
|------|----------|
| `_isHandlingError` race (chat/lobby) | 401 처리 중 비-401 에러가 동시 도착하는 극단적 케이스. 현재 패턴으로 충분히 동작하며, 상태 머신 도입은 과도함 |
| 마크다운 헤딩 레벨/표 포맷 (docs/) | 계획 문서의 포맷팅. 코드 아님 |

---

## Task 1: 디버그 라우트 릴리스 빌드 차단

**심각도:** Critical — 딥링크로 릴리스 빌드에서 개발자 도구 접근 가능

**Files:**
- Modify: `lib/router/app_router.dart:105-110` (publicPaths), `lib/router/app_router.dart:293-300` (route 등록)

**Step 1: publicPaths에서 lifecycleTest를 kDebugMode 조건부로 변경**

`lib/router/app_router.dart` 상단에 `import 'package:flutter/foundation.dart';` 추가 (kDebugMode용).

redirect 함수 내 publicPaths 정의 수정 (line 105-110):

```dart
// 인증이 불필요한 공개 경로 (Splash, Login)
final publicPaths = [
  RoutePaths.splash,
  RoutePaths.login,
  if (kDebugMode) RoutePaths.lifecycleTest,
];
```

**Step 2: GoRoute 등록도 kDebugMode 조건부로 변경**

routes 리스트 내 lifecycleTest GoRoute (line 296-300):

```dart
// ====================================================================
// Developer Tools (개발/테스트용 — 디버그 빌드에서만 등록)
// ====================================================================
if (kDebugMode)
  GoRoute(
    path: RoutePaths.lifecycleTest,
    name: RoutePaths.lifecycleTestName,
    builder: (context, state) => const LifecycleTestPage(),
  ),
```

**Step 3: flutter analyze 실행**

Run: `flutter analyze lib/router/app_router.dart`
Expected: No issues

**Step 4: 커밋**

```bash
git add lib/router/app_router.dart
git commit -m "fix : 릴리스 빌드에서 디버그 라우트 접근 차단 #108"
```

---

## Task 2: redirect catch 블록에서 로그인으로 리다이렉트

**심각도:** Major — 예외 발생 시 null 반환으로 보호 경로 우회 가능

**Files:**
- Modify: `lib/router/app_router.dart:139-143`

**Step 1: catch 블록 수정**

```dart
      } catch (e, stack) {
        debugPrint('🚨 [GoRouter redirect] 예외 발생: $e');
        debugPrint('🚨 [GoRouter redirect] 스택: $stack');
        // 안전 실패: 보호 경로 우회 방지를 위해 로그인으로 리다이렉트
        return RoutePaths.login;
      }
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze lib/router/app_router.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/router/app_router.dart
git commit -m "fix : redirect 예외 시 로그인으로 안전 리다이렉트 #108"
```

---

## Task 3: 신규 회원 닉네임 설정 우회 방지

**심각도:** Major — 신규 회원이 딥링크로 /home 등에 직접 접근 가능

**Files:**
- Modify: `lib/router/app_router.dart:124-138`

**Step 1: 인증된 사용자 분기 수정**

기존 코드 (line 124-138)를 다음으로 교체:

```dart
        // ====================================================================
        // 2. 신규 회원 → 닉네임 설정 페이지만 허용
        // ====================================================================
        if (authUser.isNewUser) {
          if (currentPath == RoutePaths.nicknameSetup) {
            return null;
          }
          final encodedNickname = Uri.encodeComponent(authUser.nickname);
          return '${RoutePaths.nicknameSetup}?nickname=$encodedNickname';
        }

        // ====================================================================
        // 3. 기존 회원이 로그인/스플래시/닉네임설정 접근 시 → 홈으로
        // ====================================================================
        if (currentPath == RoutePaths.login ||
            currentPath == RoutePaths.splash ||
            currentPath == RoutePaths.nicknameSetup) {
          return RoutePaths.home;
        }
```

**핵심 변경:**
- 신규 회원: `/nickname-setup`만 허용, 나머지 모든 경로 → 닉네임 설정으로 강제
- 기존 회원: 닉네임 설정 페이지 접근도 차단 → 홈으로

**Step 2: flutter analyze 실행**

Run: `flutter analyze lib/router/app_router.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/router/app_router.dart
git commit -m "fix : 신규 회원 닉네임 설정 우회 방지 + 기존 회원 닉네임 페이지 차단 #108"
```

---

## Task 4: arrestRobber 재진입 방어

**심각도:** Major — 동시 체포 요청 시 _pendingArrestId 덮어쓰기로 상태 오염

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart:286-326`

**Step 1: 재진입 가드 추가**

arrestRobber 메서드 시작부 (line 286-288) 수정:

```dart
  Future<void> arrestRobber(int gameId, int robberParticipantId) async {
    // 재진입 방어: 이전 체포 요청 처리 중이면 무시
    if (_pendingArrestId != null) {
      debugPrint(
        '[GameEventNotifier] ⚠️ 체포 요청 무시 — '
        '이미 $_pendingArrestId 처리 중',
      );
      return;
    }

    // race condition 방어: API 호출 중인 체포 대상 추적
    _pendingArrestId = robberParticipantId;
```

**Step 2: flutter analyze 실행**

Run: `flutter analyze lib/features/game/presentation/providers/game_event_provider.dart`
Expected: No issues

**Step 3: 커밋**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart
git commit -m "fix : arrestRobber 재진입 방어 — 중복 체포 요청 무시 #108"
```

---

## Task 5: AuthNotifier dispose 시 강제 로그아웃 콜백 해제

**심각도:** Major — auto-dispose 후에도 keepAlive 콜백이 죽은 ref에 접근 가능

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart:99-110`
- Modify: `lib/core/network/dio_client.dart` (unregister 메서드 추가 필요 확인)

**Step 1: ForceLogoutCallbackNotifier에 unregister 메서드 확인**

`lib/core/network/dio_client.dart`에서 `ForceLogoutCallbackNotifier`를 확인하고, `unregister()` 메서드가 없으면 추가:

```dart
void unregister() {
  _callback = null;
}
```

**Step 2: build()에서 ref.onDispose 추가**

`lib/features/auth/presentation/providers/auth_provider.dart` line 110 이후에:

```dart
    Future.microtask(() {
      ref.read(forceLogoutCallbackNotifierProvider.notifier).register(() async {
        final firebaseDataSource = ref.read(firebaseAuthDataSourceProvider);
        await firebaseDataSource.signOut();
        await ref.read(secureTokenStorageProvider).clearTokens();
        forceLogout();
        debugPrint('🚨 강제 로그아웃 완료 (토큰 만료/재발급 실패)');
      });
    });

    // auto-dispose 시 keepAlive 콜백 해제 — 죽은 ref 접근 방지
    ref.onDispose(() {
      ref.read(forceLogoutCallbackNotifierProvider.notifier).unregister();
    });
```

**Step 3: flutter analyze 실행**

Run: `flutter analyze lib/features/auth/presentation/providers/auth_provider.dart lib/core/network/dio_client.dart`
Expected: No issues

**Step 4: build_runner 실행** (auth_provider hash 변경)

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

**Step 5: 커밋**

```bash
git add lib/core/network/dio_client.dart lib/core/network/dio_client.g.dart \
        lib/features/auth/presentation/providers/auth_provider.dart \
        lib/features/auth/presentation/providers/auth_provider.g.dart
git commit -m "fix : AuthNotifier dispose 시 강제 로그아웃 콜백 해제 #108"
```

---

## 요약

| # | Task | 심각도 | 복잡도 |
|---|------|--------|--------|
| 1 | 디버그 라우트 릴리스 빌드 차단 | Critical | 하 |
| 2 | redirect catch → 로그인 리다이렉트 | Major | 하 |
| 3 | 신규 회원 닉네임 설정 우회 방지 | Major | 하 |
| 4 | arrestRobber 재진입 방어 | Major | 하 |
| 5 | AuthNotifier dispose 콜백 해제 | Major | 하 |
