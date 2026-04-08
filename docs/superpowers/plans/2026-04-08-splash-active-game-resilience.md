# 스플래시 활성 게임 자동 복귀 안정성 개선 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 콜드 스타트 네트워크 에러로 인한 활성 게임 복귀 실패를 재시도 + 홈 안전망으로 해결한다.

**Architecture:** 스플래시의 `getMyActiveGame` 호출에 DioException 한정 재시도 로직을 추가하고, 홈 화면에 백그라운드 활성 게임 체크를 넣어 2중 안전망을 구성한다. AuthInterceptor의 잠재적 데드락도 함께 수정한다.

**Tech Stack:** Flutter, Riverpod, Dio, GoRouter

---

## 변경 대상 파일

| 파일 | 작업 | 역할 |
|------|------|------|
| `lib/core/network/auth_interceptor.dart:219` | Modify | `_dio` → `_plainDio` (1줄) |
| `lib/features/auth/presentation/pages/splash_page.dart` | Modify | 재시도 로직 추가 |
| `lib/features/session/presentation/pages/home_page.dart` | Modify | 활성 게임 안전망 추가 |

---

### Task 1: AuthInterceptor 재시도 데드락 방지

**Files:**
- Modify: `lib/core/network/auth_interceptor.dart:219`

- [ ] **Step 1: `_dio.fetch()` → `_plainDio.fetch()` 변경**

`_retryRequest` 메서드에서 `_dio`를 `_plainDio`로 교체한다. `QueuedInterceptor` 큐를 우회하여 잠재적 교착 상태를 방지한다. `_plainDio`는 인터셉터가 없지만, 이미 수동으로 Authorization 헤더를 설정하므로 문제없다.

```dart
  /// 원래 요청을 새 토큰으로 재시도
  ///
  /// [_isRetry] extra 플래그를 설정하여 재시도 요청이
  /// 다시 401을 받을 경우 무한 루프를 방지합니다.
  /// [_plainDio]를 사용하여 QueuedInterceptor 큐 교착 상태를 방지합니다.
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    requestOptions.extra['_isRetry'] = true;
    return await _plainDio.fetch(requestOptions);
  }
```

- [ ] **Step 2: 변경 확인**

Run: `grep "_plainDio.fetch" lib/core/network/auth_interceptor.dart`
Expected: `return await _plainDio.fetch(requestOptions);`

- [ ] **Step 3: 커밋**

```bash
git add lib/core/network/auth_interceptor.dart
git commit -m "fix: AuthInterceptor 토큰 재발급 후 재시도 시 QueuedInterceptor 데드락 방지 #228"
```

---

### Task 2: 스플래시 getMyActiveGame 재시도 로직

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart`

- [ ] **Step 1: 재시도 헬퍼 메서드 추가**

`_SplashPageState` 클래스에 `_fetchActiveGameWithRetry` 메서드를 추가한다. 기존 `_navigateToNextScreen`의 try-catch 블록 안에 있던 API 호출 부분을 이 메서드로 추출한다.

`splash_page.dart`의 `_waitRemaining` 메서드 뒤 (line 148 부근)에 다음을 추가:

```dart
  /// 활성 게임 조회 (DioException 시 최대 [maxRetries]회 재시도)
  ///
  /// 콜드 스타트 시 네트워크 스택이 아직 준비되지 않아
  /// 첫 번째 API 호출이 실패할 수 있으므로 재시도로 보완합니다.
  Future<UserGameStatusEntity> _fetchActiveGameWithRetry({
    int maxRetries = 2,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await ref.read(getMyActiveGameUsecaseProvider).execute();
      } on DioException catch (e) {
        attempt++;
        if (attempt > maxRetries) rethrow;
        debugPrint(
          '⚠️ SplashPage: 게임 상태 조회 실패 ($attempt/$maxRetries), '
          '1초 후 재시도 - ${e.type}',
        );
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
```

- [ ] **Step 2: import 추가**

파일 상단 import 블록에 DioException을 위한 import를 추가:

```dart
import 'package:dio/dio.dart';
```

그리고 `UserGameStatusEntity`를 위한 import도 추가:

```dart
import '../../../session/domain/entities/user_game_status_entity.dart';
```

- [ ] **Step 3: `_navigateToNextScreen`에서 재시도 메서드 사용**

기존 코드 (line 91~138):

```dart
    // 인증 확인 → 게임 상태 API 호출과 남은 딜레이를 병렬 실행
    try {
      final statusFuture = ref.read(getMyActiveGameUsecaseProvider).execute();
      await _waitRemaining(startTime, minDelay);
      final status = await statusFuture;
```

변경:

```dart
    // 인증 확인 → 게임 상태 API 호출(재시도 포함)과 남은 딜레이를 병렬 실행
    try {
      final statusFuture = _fetchActiveGameWithRetry();
      await _waitRemaining(startTime, minDelay);
      final status = await statusFuture;
```

변경은 1줄: `ref.read(getMyActiveGameUsecaseProvider).execute()` → `_fetchActiveGameWithRetry()`

- [ ] **Step 4: 변경 확인**

Run: `grep "_fetchActiveGameWithRetry" lib/features/auth/presentation/pages/splash_page.dart`
Expected: 2개 (메서드 정의 1, 호출 1)

Run: `flutter analyze lib/features/auth/presentation/pages/splash_page.dart`
Expected: No issues found

- [ ] **Step 5: 커밋**

```bash
git add lib/features/auth/presentation/pages/splash_page.dart
git commit -m "fix: 스플래시 getMyActiveGame 콜드 스타트 네트워크 에러 대비 재시도 로직 추가 #228"
```

---

### Task 3: 홈 화면 활성 게임 안전망

**Files:**
- Modify: `lib/features/session/presentation/pages/home_page.dart`

- [ ] **Step 1: import 추가**

`home_page.dart` 상단 import 블록에 다음을 추가:

```dart
import '../../../../core/services/loading_message_service.dart';
import '../../../../core/widgets/loading/loading_page.dart';
```

이미 있는 import인지 확인 후 중복이면 생략한다.

- [ ] **Step 2: static 플래그 및 안전망 메서드 추가**

`HomePage` 클래스 내부, 기존 `static bool _safetyNoticeShown = false;` 줄 아래에 추가:

```dart
  /// 홈 진입 시 활성 게임 체크 완료 여부 (세션당 1회)
  static bool _activeGameChecked = false;

  /// 활성 게임 체크 상태 초기화 (로그아웃/강제 로그아웃 시 호출)
  static void resetActiveGameCheck() {
    _activeGameChecked = false;
  }
```

- [ ] **Step 3: 활성 게임 체크 메서드 추가**

`_showSafetyNoticeIfNeeded` 메서드 뒤에 다음 메서드를 추가:

```dart
  /// 활성 게임 존재 시 자동 리다이렉트 (스플래시 실패 안전망)
  Future<void> _checkActiveGameAndRedirect(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (_activeGameChecked) return;
    _activeGameChecked = true;

    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();

      if (!context.mounted) return;
      if (!status.isParticipating || status.participationInfo == null) return;

      final info = status.participationInfo!;

      if (info.gameStatus == 'WAITING') {
        context.go(RoutePaths.waitingRoomWithId(info.gameId.toString()));
        return;
      }

      if (info.gameStatus == 'IN_PROGRESS') {
        context.go(
          '${RoutePaths.gameWithId(info.gameId.toString())}'
          '?team=${info.team}&pid=${info.participantId}',
        );
        return;
      }
    } catch (e) {
      debugPrint('⚠️ HomePage: 활성 게임 체크 실패 (홈 유지) - $e');
    }
  }
```

- [ ] **Step 4: build()에서 안전망 호출**

`build()` 메서드의 기존 `addPostFrameCallback` 블록 뒤에 활성 게임 체크를 추가:

기존 코드 (line 360~365):

```dart
    // 홈 진입 시 안전 안내 다이얼로그 표시 (static flag로 1회만 등록)
    if (!_safetyNoticeShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _showSafetyNoticeIfNeeded(context);
      });
    }
```

그 바로 아래에 추가:

```dart
    // 활성 게임 안전망: 스플래시 실패 시 홈에서 재확인 (세션당 1회)
    if (!_activeGameChecked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _checkActiveGameAndRedirect(context, ref);
      });
    }
```

- [ ] **Step 5: resetSafetyNotice에 resetActiveGameCheck 연동**

기존 `resetSafetyNotice` 메서드에서 활성 게임 체크도 함께 초기화:

기존 코드:

```dart
  static Future<void> resetSafetyNotice() async {
    _safetyNoticeShown = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_safetyNoticePrefKey);
  }
```

변경:

```dart
  static Future<void> resetSafetyNotice() async {
    _safetyNoticeShown = false;
    _activeGameChecked = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_safetyNoticePrefKey);
  }
```

- [ ] **Step 6: import 확인 및 누락분 추가**

`home_page.dart`에 다음 import가 필요한지 확인하고 없으면 추가:

```dart
import '../../../../router/route_paths.dart';
import 'package:go_router/go_router.dart';
```

(이미 있을 가능성 높음 — `context.go()` 사용처가 이미 있으므로)

- [ ] **Step 7: 변경 확인**

Run: `grep "_activeGameChecked\|_checkActiveGameAndRedirect\|resetActiveGameCheck" lib/features/session/presentation/pages/home_page.dart`
Expected: 6개 이상 (플래그 선언, 체크 메서드, build 호출, reset 2곳, resetActiveGameCheck)

Run: `flutter analyze lib/features/session/presentation/pages/home_page.dart`
Expected: No issues found

- [ ] **Step 8: 커밋**

```bash
git add lib/features/session/presentation/pages/home_page.dart
git commit -m "feat: 홈 화면 활성 게임 안전망 추가 — 스플래시 실패 시 백그라운드 체크로 자동 복귀 #228"
```

---

### Task 4: 전체 빌드 검증

- [ ] **Step 1: 코드 생성 확인**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 생성 완료 (변경된 파일에 어노테이션 추가 없으므로 빠르게 완료)

- [ ] **Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: 테스트**

Run: `flutter test`
Expected: All tests passed
