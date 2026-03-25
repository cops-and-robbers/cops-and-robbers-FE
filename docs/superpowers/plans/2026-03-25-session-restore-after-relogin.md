# 재로그인 시 세션 복원 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 재로그인 시 활성 세션(대기실/게임)으로 자동 복귀하도록 수정

**Architecture:** 로그인 성공 후, auth state를 설정하기 전에 `getMyActiveGame()` API를 호출하여 활성 게임 여부를 확인한다. 결과를 `postLoginDestinationProvider`에 저장하고, GoRouter redirect에서 이 값을 읽어 적절한 화면으로 라우팅한다. Splash의 기존 세션 복원 로직은 앱 콜드스타트용으로 그대로 유지한다.

**Tech Stack:** Flutter, Riverpod, GoRouter

**관련 이슈:** #187

---

## 핵심 원리

현재 문제: `signInWithGoogle()` → `state = AsyncValue.data(result)` → GoRouter redirect → `/home` (세션 체크 없음)

해결 전략: `signInWithGoogle()` → 토큰 저장 완료 → `getMyActiveGame()` API 호출 → 목적지 결정 → `state = AsyncValue.data(result)` → GoRouter redirect → 목적지로 이동

**타이밍 포인트:** `useCase.execute()` 완료 시점에서 JWT 토큰은 이미 SecureStorage에 저장되어 있으므로, auth state 설정 전에도 인증이 필요한 API 호출이 가능하다.

---

## 파일 구조

| 파일 | 변경 | 역할 |
|------|------|------|
| `lib/features/auth/presentation/providers/auth_provider.dart` | 수정 | `postLoginDestinationProvider` 추가, signIn 메서드에 활성 게임 체크 로직 추가 |
| `lib/router/app_router.dart` | 수정 | redirect에서 `postLoginDestinationProvider` 확인 후 분기 |

---

### Task 1: `postLoginDestinationProvider` 추가 및 signIn 수정

**Files:**
- Modify: `lib/features/auth/presentation/providers/auth_provider.dart`

- [ ] **Step 1: `postLoginDestinationProvider` 추가**

`auth_provider.dart` 상단(import 아래, 기존 provider들 근처)에 추가:

```dart
/// 로그인 성공 후 이동할 목적지 (활성 게임 복원용, 1회성)
///
/// 로그인 성공 시 활성 게임이 있으면 해당 경로를 저장하고,
/// GoRouter redirect에서 소비한 뒤 null로 초기화합니다.
final postLoginDestinationProvider = StateProvider<String?>((ref) => null);
```

- [ ] **Step 2: `_resolvePostLoginDestination()` 헬퍼 메서드 추가**

`AuthNotifier` 클래스 내부에 private 메서드 추가:

```dart
/// 활성 게임 상태를 조회하여 로그인 후 목적지를 결정합니다.
///
/// - WAITING → 대기실 경로
/// - IN_PROGRESS → 게임 경로 (team, pid 포함)
/// - 참여 중인 게임 없음 또는 API 실패 → null (홈 fallback)
Future<void> _resolvePostLoginDestination() async {
  try {
    final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
    if (!status.isParticipating || status.participationInfo == null) return;

    final info = status.participationInfo!;
    final destination = switch (info.gameStatus) {
      'WAITING' => RoutePaths.waitingRoomWithId(info.gameId.toString()),
      'IN_PROGRESS' =>
        '${RoutePaths.gameWithId(info.gameId.toString())}'
        '?team=${info.team}&pid=${info.participantId}',
      _ => null,
    };

    if (destination != null) {
      ref.read(postLoginDestinationProvider.notifier).state = destination;
      debugPrint('🎯 AuthNotifier: 로그인 후 목적지 설정 → $destination');
    }
  } catch (e) {
    debugPrint('⚠️ AuthNotifier: 활성 게임 조회 실패 (홈 fallback) - $e');
  }
}
```

- [ ] **Step 3: `signInWithGoogle()`에 활성 게임 체크 삽입**

`signInWithGoogle()` 메서드에서 `state = AsyncValue.data(result)` 직전에 호출 추가:

```dart
Future<void> signInWithGoogle() async {
  state = const AsyncValue.loading();
  try {
    final useCase = ref.read(signInWithGoogleUseCaseProvider);
    final result = await useCase.execute();

    // 기존 회원: 활성 게임 체크 → 목적지 결정 (state 설정 전)
    if (!result.isNewUser) {
      await _resolvePostLoginDestination();
    }

    state = AsyncValue.data(result);
  } on FirebaseAuthException catch (e) {
    // ... 기존 에러 처리 유지
  }
}
```

- [ ] **Step 4: `signInWithApple()`에도 동일하게 적용**

`signInWithApple()` 메서드에서도 `state = AsyncValue.data(result)` 직전에 동일한 호출 추가:

```dart
// 기존 회원: 활성 게임 체크 → 목적지 결정 (state 설정 전)
if (!result.isNewUser) {
  await _resolvePostLoginDestination();
}
```

- [ ] **Step 5: import 추가**

`auth_provider.dart` 상단에 필요한 import 추가:

```dart
// NOTE: Cross-feature dependency — 로그인 후 활성 게임 복원을 위해 session provider 참조
// (splash_page.dart와 동일한 패턴)
import '../../../session/presentation/providers/session_provider.dart';
import '../../../../router/route_paths.dart';
```

- [ ] **Step 6: 커밋**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart
git commit -m "feat: 로그인 성공 시 활성 게임 상태 체크 및 목적지 결정 로직 추가 #187"
```

---

### Task 2: GoRouter redirect에서 목적지 분기 처리

**Files:**
- Modify: `lib/router/app_router.dart`

- [ ] **Step 1: `postLoginDestinationProvider` import 추가**

```dart
import '../features/auth/presentation/providers/auth_provider.dart';
```

> 이미 `authNotifierProvider`를 위해 import되어 있으므로, `postLoginDestinationProvider`는 추가 import 없이 접근 가능. 확인만 하면 됨.

- [ ] **Step 2: redirect의 로그인 분기 수정**

`app_router.dart`의 redirect 함수에서 기존 코드:

```dart
// 3. 기존 회원이 로그인 접근 시 → 홈으로
if (currentPath == RoutePaths.login) {
  return RoutePaths.home;
}
```

를 다음으로 변경:

```dart
// 3. 기존 회원이 로그인 접근 시 → 활성 게임 목적지 또는 홈으로
if (currentPath == RoutePaths.login) {
  final destination = ref.read(postLoginDestinationProvider);
  if (destination != null) {
    debugPrint('🎯 [GoRouter redirect] postLoginDestination 소비: $destination');
    ref.read(postLoginDestinationProvider.notifier).state = null;
    return destination;
  }
  return RoutePaths.home;
}
```

- [ ] **Step 3: 주석 업데이트**

해당 섹션의 주석을 수정:

```dart
// ====================================================================
// 3. 기존 회원이 로그인 접근 시 → 활성 게임 복귀 또는 홈으로
//    로그인 성공 시 활성 게임이 있으면 대기실/게임으로 직접 이동
//    (닉네임설정은 설정 페이지에서 닉네임 변경 시 접근 가능)
// ====================================================================
```

- [ ] **Step 4: 커밋**

```bash
git add lib/router/app_router.dart
git commit -m "feat: 라우터 redirect에서 로그인 후 활성 게임 목적지 분기 처리 #187"
```

---

### Task 3: 검증

- [ ] **Step 1: 빌드 확인**

```bash
flutter analyze
```

- [ ] **Step 2: 수동 테스트 시나리오**

| # | 시나리오 | 예상 결과 |
|---|---------|----------|
| 1 | 대기실에 있는 상태 → 로그아웃 → 재로그인 | 대기실로 자동 복귀 |
| 2 | 게임 진행 중 → 로그아웃 → 재로그인 | 게임 화면으로 자동 복귀 (team, pid 유지) |
| 3 | 참여 중인 게임 없음 → 로그아웃 → 재로그인 | 홈 화면으로 이동 (기존과 동일) |
| 4 | 신규 회원 로그인 | 닉네임 설정 화면으로 이동 (기존과 동일) |
| 5 | 앱 콜드스타트 (활성 게임 있음) | Splash에서 정상 복귀 (기존과 동일) |
| 6 | 로그인 중 네트워크 에러 | 홈 화면 fallback |

- [ ] **Step 3: 검증 완료 후 커밋 (필요 시)**

```bash
git add lib/features/auth/presentation/providers/auth_provider.dart lib/router/app_router.dart
git commit -m "fix: 검증 중 발견된 이슈 수정 #187"
```
