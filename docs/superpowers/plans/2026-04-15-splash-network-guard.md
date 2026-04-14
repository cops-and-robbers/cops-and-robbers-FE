# 스플래시 네트워크 차단 가드 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 앱 콜드 스타트 시 네트워크가 없으면 스플래시에서 Remote Config/Auth/게임 상태 API 호출을 일절 수행하지 않고 오프라인 전용 UI로 차단하며, 자동(스트림 리스너) 및 수동(재시도 버튼) 복구 + 루프 복구를 지원한다.

**Architecture:** `connectivity_plus` 기반 `ConnectivityService` 래퍼를 Riverpod provider로 노출하고, `SplashPage`가 진입 시점에 선제 체크 → 실패 시 인라인 오프라인 UI 분기 → 자동/수동 복구 재진입 시에는 `isRecovery` 플래그로 네트워크성 실패를 감지해 오프라인 UI로 루프 복귀. 기존 플로우(Remote Config, Auth, 게임 상태)는 정상 경로에서 그대로 유지한다.

**Tech Stack:** Flutter 3.9.2, Dart 3.9, Riverpod + `@riverpod` 코드 생성, `connectivity_plus`, `flutter_test`.

**Related Spec:** `docs/superpowers/specs/2026-04-15-splash-network-guard-design.md`

---

## 파일 구조

**신규 파일:**
- `lib/core/network/connectivity_service.dart` — `connectivity_plus` 래퍼 + Riverpod provider
- `lib/core/network/connectivity_service.g.dart` — build_runner 생성물
- `lib/core/network/network_failure_detector.dart` — 네트워크성 실패 여부 판별 유틸
- `test/core/network/connectivity_service_test.dart` — `ConnectivityService` 단위 테스트
- `test/core/network/network_failure_detector_test.dart` — 네트워크 실패 판별 단위 테스트
- `test/features/auth/presentation/pages/splash_offline_ui_test.dart` — 오프라인 UI 렌더링 위젯 테스트

**수정 파일:**
- `pubspec.yaml` — `connectivity_plus` 추가
- `android/app/src/main/AndroidManifest.xml` — `ACCESS_NETWORK_STATE` 추가
- `lib/features/auth/presentation/pages/splash_page.dart` — 오프라인 가드 로직 전반

---

## Task 1: 의존성 추가 및 Android 권한

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml:1-22`

- [ ] **Step 1: `pubspec.yaml`에 `connectivity_plus` 추가**

`pubspec.yaml`의 `dependencies:` 섹션, 기존 `shimmer: ^3.0.0` 바로 아래 한 줄 추가:

```yaml
  # 네트워크 연결 상태 체크 (스플래시 오프라인 가드용)
  connectivity_plus: ^6.1.0
```

- [ ] **Step 2: `flutter pub get` 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter pub get`
Expected: `Got dependencies!` 로 종료 (경고/에러 없음)

- [ ] **Step 3: AndroidManifest에 네트워크 상태 권한 추가**

`android/app/src/main/AndroidManifest.xml`의 `<uses-permission android:name="android.permission.INTERNET"/>` 바로 아래에 추가:

```xml
    <!-- 네트워크 연결 상태 조회 (스플래시 오프라인 가드용) -->
    <!-- Network connectivity state for splash offline guard -->
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

- [ ] **Step 4: iOS는 추가 설정 불필요 확인**

`connectivity_plus`는 iOS에서 별도 권한이 필요 없음. `ios/Runner/Info.plist` 수정 불필요. 넘어감.

- [ ] **Step 5: 빌드 sanity check**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/`
Expected: 에러 없음 (기존 경고만 출력 가능)

- [ ] **Step 6: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml
git commit -m "chore: connectivity_plus 의존성 추가 및 Android 네트워크 권한 설정"
```

---

## Task 2: `NetworkFailureDetector` 유틸리티 (TDD)

네트워크성 실패 여부를 단일 지점에서 판별하는 순수 함수. `DioException`, `NetworkException`(프로젝트 내부), `TimeoutException`, `SocketException`을 모두 다룬다.

**Files:**
- Create: `lib/core/network/network_failure_detector.dart`
- Create: `test/core/network/network_failure_detector_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/core/network/network_failure_detector_test.dart` 신규 파일:

```dart
import 'dart:async';
import 'dart:io';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/network_failure_detector.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isNetworkFailure', () {
    test('NetworkException은 true를 반환한다', () {
      final error = NetworkException(message: '네트워크 에러');
      expect(isNetworkFailure(error), isTrue);
    });

    test('TimeoutException은 true를 반환한다', () {
      final error = TimeoutException('타임아웃');
      expect(isNetworkFailure(error), isTrue);
    });

    test('SocketException은 true를 반환한다', () {
      final error = const SocketException('호스트 도달 불가');
      expect(isNetworkFailure(error), isTrue);
    });

    test('connectionError 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('connectionTimeout 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('sendTimeout 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('receiveTimeout 타입의 DioException은 true를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );
      expect(isNetworkFailure(error), isTrue);
    });

    test('badResponse 타입의 DioException은 false를 반환한다', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      expect(isNetworkFailure(error), isFalse);
    });

    test('ServerException은 false를 반환한다', () {
      final error = ServerException(message: '서버 에러');
      expect(isNetworkFailure(error), isFalse);
    });

    test('ValidationException은 false를 반환한다', () {
      final error = ValidationException(message: '잘못된 요청');
      expect(isNetworkFailure(error), isFalse);
    });

    test('FormatException은 false를 반환한다', () {
      expect(isNetworkFailure(const FormatException('파싱 에러')), isFalse);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/core/network/network_failure_detector_test.dart`
Expected: 컴파일 에러 "Target of URI doesn't exist: 'package:cops_and_robbers/core/network/network_failure_detector.dart'"

- [ ] **Step 3: 구현 작성**

`lib/core/network/network_failure_detector.dart` 신규 파일:

```dart
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// 주어진 에러가 "네트워크성 실패"인지 판별한다.
///
/// 스플래시 오프라인 가드의 루프 복구 경로에서 사용한다.
/// 네트워크성 실패로 분류되면 사용자를 오프라인 화면으로 되돌린다.
///
/// 네트워크성 실패로 판정되는 케이스:
/// - `NetworkException` — `DioExceptionHandler`가 변환한 타임아웃/연결 에러
/// - `TimeoutException` — `Future.timeout()`에서 발생
/// - `SocketException` — DNS 실패, 호스트 도달 불가
/// - `DioException` 중 `connectionError`, `connectionTimeout`,
///   `sendTimeout`, `receiveTimeout` 타입 (원시 Dio 에러 대비)
///
/// 서버 5xx, 400번대, 파싱 에러 등은 모두 false.
bool isNetworkFailure(Object error) {
  if (error is NetworkException) return true;
  if (error is TimeoutException) return true;
  if (error is SocketException) return true;
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
  return false;
}
```

- [ ] **Step 4: 테스트 실행 → 통과 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/core/network/network_failure_detector_test.dart`
Expected: `All tests passed!` (11개 테스트 모두 성공)

- [ ] **Step 5: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add lib/core/network/network_failure_detector.dart test/core/network/network_failure_detector_test.dart
git commit -m "feat: 네트워크성 실패 판별 유틸리티 추가"
```

---

## Task 3: `ConnectivityService` 래퍼 및 Riverpod provider (TDD)

`connectivity_plus`를 감싸서 `isConnected()` 단발 조회와 `onConnectivityChanged` bool 스트림을 제공한다. 생성자 주입으로 `Connectivity`를 받아 테스트 가능성을 확보한다.

**Files:**
- Create: `lib/core/network/connectivity_service.dart`
- Create: `test/core/network/connectivity_service_test.dart`

- [ ] **Step 1: 실패 테스트 작성**

`test/core/network/connectivity_service_test.dart` 신규 파일:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 fake — Connectivity 인터페이스의 필요한 부분만 흉내냄
class FakeConnectivity implements Connectivity {
  FakeConnectivity({List<ConnectivityResult>? initial})
      : _current = initial ?? [ConnectivityResult.none];

  List<ConnectivityResult> _current;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> result) {
    _current = result;
    _controller.add(result);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('ConnectivityService.isConnected()', () {
    test('none만 있으면 false를 반환한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.none]);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isFalse);
      await fake.dispose();
    });

    test('wifi가 있으면 true를 반환한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.wifi]);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isTrue);
      await fake.dispose();
    });

    test('mobile이 있으면 true를 반환한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.mobile]);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isTrue);
      await fake.dispose();
    });

    test('빈 리스트는 false를 반환한다', () async {
      final fake = FakeConnectivity(initial: []);
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isFalse);
      await fake.dispose();
    });

    test('wifi와 none이 섞여 있으면 true를 반환한다', () async {
      final fake = FakeConnectivity(
        initial: [ConnectivityResult.wifi, ConnectivityResult.none],
      );
      final service = ConnectivityService(fake);
      expect(await service.isConnected(), isTrue);
      await fake.dispose();
    });
  });

  group('ConnectivityService.onConnectivityChanged', () {
    test('none → wifi 이벤트가 false → true로 매핑된다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.none]);
      final service = ConnectivityService(fake);

      final events = <bool>[];
      final sub = service.onConnectivityChanged.listen(events.add);

      fake.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(events, equals([false, true]));

      await sub.cancel();
      await fake.dispose();
    });

    test('broadcast 스트림이라 여러 구독자를 지원한다', () async {
      final fake = FakeConnectivity(initial: [ConnectivityResult.none]);
      final service = ConnectivityService(fake);

      final eventsA = <bool>[];
      final eventsB = <bool>[];
      final subA = service.onConnectivityChanged.listen(eventsA.add);
      final subB = service.onConnectivityChanged.listen(eventsB.add);

      fake.emit([ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);

      expect(eventsA, equals([true]));
      expect(eventsB, equals([true]));

      await subA.cancel();
      await subB.cancel();
      await fake.dispose();
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 → 실패 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/core/network/connectivity_service_test.dart`
Expected: 컴파일 에러 "Target of URI doesn't exist: 'package:cops_and_robbers/core/network/connectivity_service.dart'"

- [ ] **Step 3: `ConnectivityService` + provider 구현**

`lib/core/network/connectivity_service.dart` 신규 파일:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// `connectivity_plus` 패키지를 앱 도메인 계층에서 격리하기 위한 래퍼.
///
/// 스플래시 오프라인 가드 등 호출자는 이 서비스에만 의존하고
/// 플랫폼 SDK를 직접 import하지 않는다.
///
/// 연결 판정 규칙: `ConnectivityResult.none` 외의 값이 하나라도 있으면 연결됨.
/// captive portal 같은 "링크만 있고 실제 통신은 안 되는" 케이스는 여기서
/// 잡지 않으며, 후속 API 호출의 네트워크성 실패를 통해 상위에서 복구된다.
class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  /// 현재 연결 상태를 단발성으로 조회한다.
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnectivity(result);
  }

  /// 연결 상태 변화를 bool 스트림으로 노출한다.
  ///
  /// `true` = 연결됨, `false` = 끊김.
  /// broadcast 스트림이라 여러 구독자가 동시에 구독 가능하다.
  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnectivity);

  bool _hasConnectivity(List<ConnectivityResult> result) {
    if (result.isEmpty) return false;
    return result.any((r) => r != ConnectivityResult.none);
  }
}

/// 앱 전역 `ConnectivityService` 싱글턴.
///
/// keepAlive로 유지되어 화면 전환 시에도 동일 인스턴스를 재사용한다.
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService(Connectivity());
}
```

- [ ] **Step 4: build_runner로 `.g.dart` 생성**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && dart run build_runner build --delete-conflicting-outputs`
Expected: `Succeeded` 로그와 함께 `lib/core/network/connectivity_service.g.dart` 생성

- [ ] **Step 5: 테스트 실행 → 통과 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/core/network/connectivity_service_test.dart`
Expected: `All tests passed!` (7개 테스트 모두 성공)

- [ ] **Step 6: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add lib/core/network/connectivity_service.dart lib/core/network/connectivity_service.g.dart test/core/network/connectivity_service_test.dart
git commit -m "feat: ConnectivityService 래퍼 및 Riverpod provider 추가"
```

---

## Task 4: `SplashPage` — 상태 필드 및 import 추가

`SplashPage`에 오프라인 가드용 상태를 추가한다. 이 태스크는 타입 전환만 수행하므로 런타임 동작은 변하지 않는다.

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart`

- [ ] **Step 1: import 추가**

`lib/features/auth/presentation/pages/splash_page.dart` 상단 import 섹션 (라인 1~18 근처)에 다음 4개 import를 적절한 위치에 추가:

```dart
import 'dart:io'; // SocketException

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/network_failure_detector.dart';
```

기존의 `import 'dart:async';` 는 유지. 상대 경로 import는 기존 패턴(`../../../../core/...`)과 동일하게 작성.

- [ ] **Step 2: 상태 필드 추가**

`_SplashPageState` 클래스의 필드 선언부 (라인 37~39 근처, 기존 `_isReconnecting`, `_reconnectMessage` 아래):

```dart
  /// 오프라인 차단 상태
  /// 네트워크 미연결 감지 시 true가 되며, 외부 API 호출을 차단한다.
  bool _isOffline = false;

  /// `_navigateToNextScreen` 동시 실행 방지 플래그
  /// 리스너/재시도 버튼/initState가 중복으로 진입하는 것을 막는다.
  bool _isNavigating = false;

  /// 연결 상태 변화 스트림 구독 핸들
  /// 오프라인 상태에서만 구독되며, 복구 재진입 시 cancel 후 재구독된다.
  StreamSubscription<bool>? _connectivitySub;
```

- [ ] **Step 3: `flutter analyze` 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/auth/presentation/pages/splash_page.dart`
Expected: 사용되지 않는 필드 경고는 있을 수 있으나 에러는 없음 (다음 태스크에서 사용됨)

- [ ] **Step 4: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add lib/features/auth/presentation/pages/splash_page.dart
git commit -m "feat(splash): 오프라인 가드 상태 필드 추가"
```

---

## Task 5: `SplashPage` — 헬퍼 메서드 추가 (`_returnToOffline`, `_subscribeConnectivity`, `_handleConnectivityChange`, `_onManualRetry`)

리스너 생명주기와 복구 로직을 헬퍼로 분리한다. 아직 호출되는 곳은 없지만, 다음 태스크에서 호출을 배선한다.

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart`

- [ ] **Step 1: 헬퍼 메서드 4개 추가**

`_waitRemaining` 메서드 바로 위(혹은 아래)에 다음 메서드들을 추가한다. 위치는 `_showNetworkErrorDialog`와 같은 레벨(`_SplashPageState` 내부).

```dart
  /// 오프라인 상태로 전환하고 연결 스트림을 재구독한다.
  ///
  /// 네트워크성 실패로 복구 루프에 진입할 때 호출한다.
  /// 폭주 방지를 위해 1초 delay 후 전환한다.
  Future<void> _returnToOffline() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isOffline = true);
    _subscribeConnectivity();
  }

  /// 연결 상태 변화 스트림을 구독한다.
  ///
  /// 기존 구독이 있으면 먼저 cancel한 뒤 새로 구독하여
  /// 중복 구독을 방지한다.
  void _subscribeConnectivity() {
    _connectivitySub?.cancel();
    final service = ref.read(connectivityServiceProvider);
    _connectivitySub =
        service.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  /// 연결 상태 변화 콜백 — 자동 복구 시도.
  ///
  /// 현재 오프라인 상태이고 네비게이션이 진행 중이 아닐 때만
  /// 실제 복구를 트리거한다.
  void _handleConnectivityChange(bool isConnected) {
    if (!mounted) return;
    if (!isConnected) return;
    if (!_isOffline) return;
    if (_isNavigating) return;
    _navigateToNextScreen(isRecovery: true);
  }

  /// 수동 재시도 버튼 핸들러.
  ///
  /// 버튼 탭 시점에 연결 여부를 다시 확인해서,
  /// 연결되어 있으면 플로우 재진입, 아니면 UI 유지.
  Future<void> _onManualRetry() async {
    if (_isNavigating) return;
    final service = ref.read(connectivityServiceProvider);
    final connected = await service.isConnected();
    if (!mounted) return;
    if (!connected) return;
    _navigateToNextScreen(isRecovery: true);
  }
```

- [ ] **Step 2: `flutter analyze` 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/auth/presentation/pages/splash_page.dart`
Expected: "The method '_navigateToNextScreen' has the wrong number of type arguments" 같은 에러는 없어야 함. 파라미터 추가 전이므로 `isRecovery:` named arg 호출이 에러를 낼 수 있음 → 다음 태스크에서 해결. 이 단계에선 경고만 존재해도 됨.

> 만약 에러가 뜨면 이 단계를 건너뛰지 말고 바로 다음 태스크로 이어서 작업하여 컴파일 가능 상태를 만든다.

- [ ] **Step 3: (컴파일 가능하다면) 중간 commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add lib/features/auth/presentation/pages/splash_page.dart
git commit -m "feat(splash): 오프라인 복구 헬퍼 메서드 추가"
```

만약 컴파일이 깨진 상태라면 Task 6과 같이 커밋한다.

---

## Task 6: `SplashPage._navigateToNextScreen` — `isRecovery` 파라미터 및 선제 체크 추가

이 태스크에서 핵심 플로우 변경이 일어난다. `_navigateToNextScreen()`에 `isRecovery` named parameter를 추가하고, 최상단에 선제 연결 체크를, 내부 catch 블록에 네트워크성 실패 감지를 추가한다.

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart:47-148`

- [ ] **Step 1: `_navigateToNextScreen` 시그니처 및 최상단 프리플라이트 추가**

기존 `_navigateToNextScreen` 메서드의 선언부를 아래처럼 수정한다. 메서드 전체 본문을 아래 코드로 교체:

```dart
  Future<void> _navigateToNextScreen({bool isRecovery = false}) async {
    // 재진입 가드 — 리스너/재시도/initState가 동시에 호출해도 한 번만 진행
    if (_isNavigating) return;
    _isNavigating = true;

    // 기존 구독은 진입 직전에 확실히 해제 (중복 콜백 방지)
    await _connectivitySub?.cancel();
    _connectivitySub = null;

    try {
      // ================================================================
      // 선제 연결 체크 (콜드 스타트 오프라인 차단)
      // ================================================================
      final connectivity = ref.read(connectivityServiceProvider);
      final connected = await connectivity.isConnected();
      if (!connected) {
        if (!mounted) return;
        setState(() => _isOffline = true);
        _subscribeConnectivity();
        return;
      }

      // 복구 경로에서 진입한 경우 오프라인 플래그 해제
      if (_isOffline && mounted) {
        setState(() => _isOffline = false);
      }

      final startTime = DateTime.now();
      const minDelay = Duration(seconds: 2);

      // ================================================================
      // Remote Config: 점검 모드 및 앱 버전 체크
      // ================================================================
      try {
        await RemoteConfigService.instance.initialize();
        final versionResult = await AppVersionChecker.check();

        if (!mounted) return;

        final canProceed = await UpdateDialogHelper.handleResult(
          context,
          versionResult,
        );

        if (!mounted || !canProceed) return; // 점검/강제 업데이트 → 앱 차단
      } catch (e) {
        // 복구 경로에서의 네트워크성 실패는 오프라인 UI로 복귀
        if (isRecovery && isNetworkFailure(e)) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: Remote Config 체크 실패, 앱 진행: $e');
        // Remote Config 실패 시 앱 정상 진행 (fail-open)
      }

      if (!mounted) return;

      // auth 초기화 완료를 Riverpod future로 대기 (최대 5초)
      final AuthResultEntity? authUser;
      try {
        authUser = await ref
            .read(authNotifierProvider.future)
            .timeout(const Duration(seconds: 5));
      } on TimeoutException {
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: auth 초기화 타임아웃, 로그인으로 이동');
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.login);
        return;
      } on NetworkException {
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        // 비복구 모드에서 Auth가 NetworkException을 던진 경우:
        // 기존에는 해당 경로가 정의되어 있지 않아 generic catch로 빠졌으므로
        // 동일하게 홈 fallback으로 이동한다.
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.home);
        return;
      }

      // 인증되지 않은 경우 → 남은 딜레이 후 로그인
      if (authUser == null) {
        await _waitRemaining(startTime, minDelay);
        if (!mounted) return;
        context.go(RoutePaths.login);
        return;
      }

      // 인증 확인 → 게임 상태 API 호출(재시도 포함)과 남은 딜레이를 병렬 실행
      try {
        final statusFuture = _fetchActiveGameWithRetry();
        await _waitRemaining(startTime, minDelay);
        final status = await statusFuture;

        if (!mounted) return;

        if (!status.isParticipating || status.participationInfo == null) {
          context.go(RoutePaths.home);
          return;
        }

        // 재참여 상황 → LoadingPage 전환 후 이동
        final message = await LoadingMessageService.getMessage(
          LoadingCategory.reconnect,
          fallback: '다시 현장으로 복귀 중...',
        );
        if (mounted) {
          setState(() {
            _reconnectMessage = message;
            _isReconnecting = true;
          });
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

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

        context.go(RoutePaths.home);
      } on NetworkException catch (e) {
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        // 비복구 모드 — 기존 동작 유지(홈 fallback). 기존 DioException catch는
        // Repository가 DioException을 변환해버려 실질적으로 도달 불가였으므로,
        // 원래 대부분의 케이스에서 generic catch로 빠져 홈으로 이동하고 있었다.
        debugPrint('⚠️ SplashPage: 게임 상태 조회 실패 (Network), 홈으로 이동 - ${e.code}');
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.home);
      } on DioException catch (e) {
        // 원시 DioException이 올라오는 경우에 대비해 유지
        // (현재 Repository는 NetworkException으로 변환하지만 향후 변화 가능)
        if (isRecovery) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: 네트워크 에러, 재시도 모달 표시 - ${e.type}');
        await _waitRemaining(startTime, minDelay);
        if (mounted) await _showNetworkErrorDialog();
      } catch (e) {
        // 비네트워크 에러 (파싱 등) → 기존대로 홈 fallback
        if (isRecovery && isNetworkFailure(e)) {
          await _returnToOffline();
          return;
        }
        debugPrint('⚠️ SplashPage: 게임 상태 조회 실패, 홈으로 이동 - $e');
        await _waitRemaining(startTime, minDelay);
        if (mounted) context.go(RoutePaths.home);
      }
    } finally {
      _isNavigating = false;
    }
  }
```

**변경 요약 (비교용):**
- 시그니처: `{bool isRecovery = false}` named param 추가
- 상단: `_isNavigating` 가드, 기존 구독 cancel, 선제 연결 체크, 복구 모드일 때 `_isOffline` 해제
- 전체 본문을 try/finally로 감싸서 `_isNavigating = false`를 finally에서 보장
- Remote Config catch에 `isRecovery && isNetworkFailure(e)` 분기 추가
- Auth try에 `on NetworkException` 케이스 추가 (기존엔 `TimeoutException`만)
- 게임 상태 catch에 `on NetworkException` 케이스 신규 추가 (기존 `on DioException` 앞)
- 기존 `on DioException` catch도 복구 모드 분기 추가 (원시 DioException 대비)
- 최하단 generic `catch(e)`에도 복구 모드 분기 추가 (SocketException, TimeoutException 등 누락 방지)

- [ ] **Step 2: `flutter analyze` 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/auth/presentation/pages/splash_page.dart`
Expected: 에러 0개. 사용되지 않는 import/필드 경고도 0개여야 함 (`_isOffline`, `_connectivitySub` 등이 이제 모두 사용됨).

- [ ] **Step 3: 기존 테스트 회귀 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/features/auth/presentation/pages/splash_retry_logic_test.dart`
Expected: `All tests passed!` (기존 재시도 로직 테스트는 `fetchWithRetry` 순수 함수에 대한 테스트이므로 영향 없음)

- [ ] **Step 4: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add lib/features/auth/presentation/pages/splash_page.dart
git commit -m "feat(splash): 오프라인 선제 체크 및 루프 복구 경로 추가"
```

---

## Task 7: `SplashPage.dispose` 및 `build` 분기 추가

`dispose()`에서 스트림 구독을 해제하고, `build()`에 오프라인 UI 인라인 분기를 추가한다.

**Files:**
- Modify: `lib/features/auth/presentation/pages/splash_page.dart`

- [ ] **Step 1: `dispose` 오버라이드 추가**

`initState()` 메서드 바로 아래에 `dispose()` 메서드 추가:

```dart
  @override
  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    super.dispose();
  }
```

- [ ] **Step 2: `build` 메서드에 오프라인 분기 추가**

기존 `build` 메서드를 아래처럼 교체:

```dart
  @override
  Widget build(BuildContext context) {
    if (_isOffline) {
      return _buildOfflineView(context);
    }
    if (_isReconnecting) {
      return LoadingPage(message: _reconnectMessage, subtitle: '잠시만 기다려주세요');
    }
    return const Scaffold(body: Center(child: Text('Splash')));
  }

  /// 오프라인 상태 인라인 UI.
  ///
  /// 외부에 공개하지 않는 스플래시 전용 뷰라 별도 위젯 파일로 분리하지 않는다.
  Widget _buildOfflineView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.screenHorizontal,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72.w,
                  color: AppColors.gray500,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  '인터넷 연결이 필요합니다',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '연결 상태를 확인한 후\n다시 시도해주세요',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: '다시 시도',
                  onPressed: _onManualRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

**주의**: 이 뷰가 참조하는 상수/위젯은 프로젝트에 이미 존재해야 한다:
- `AppColors.white`, `AppColors.gray500`, `AppColors.gray600`
- `AppPadding.screenHorizontal`
- `AppSpacing.lg`, `AppSpacing.sm`, `AppSpacing.xl`
- `AppTextStyles.heading2`, `AppTextStyles.body2`
- `AppButton(text:, onPressed:)`

이들이 **정확한 이름으로 존재하지 않는 경우**, 프로젝트 내 가장 근접한 이름으로 교체한다. 확인 명령:

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
grep -n "static.*gray\|static.*white" lib/core/constants/app_colors.dart
grep -n "static.*screenHorizontal\|static.*lg\|static.*sm\|static.*xl" lib/core/constants/spacing_and_radius.dart
grep -n "heading2\|body2" lib/core/constants/text_styles.dart
grep -n "class AppButton" lib/core/widgets/buttons/app_button.dart
```

실제 이름에 맞게 `_buildOfflineView`의 상수/속성을 조정한 뒤 다음 단계로 진행한다.

- [ ] **Step 3: import 확인 및 추가**

`_buildOfflineView`에 필요한 import가 이미 있는지 확인한다. 없으면 추가:

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
```

`app_button.dart`의 실제 경로도 위 grep으로 확인하여 조정할 것. (위치: `lib/core/widgets/buttons/app_button.dart`가 일반적이지만 다를 수 있음.)

- [ ] **Step 4: `flutter analyze` 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze lib/features/auth/presentation/pages/splash_page.dart`
Expected: 에러 0개.

- [ ] **Step 5: 전체 테스트 스모크**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test`
Expected: 모든 기존 테스트 통과. 실패 시 회귀 원인을 즉시 수정.

- [ ] **Step 6: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add lib/features/auth/presentation/pages/splash_page.dart
git commit -m "feat(splash): dispose 훅 및 오프라인 인라인 UI 추가"
```

---

## Task 8: 오프라인 UI 렌더링 위젯 테스트

`SplashPage`의 전체 플로우를 mocking하는 건 의존성이 많아 과도하므로, **오프라인 UI 분기만 핀포인트로 검증**한다. `_isOffline = true` 상태일 때 렌더링되는 요소(아이콘, 타이틀, 재시도 버튼)를 확인한다.

이를 위해 `SplashPage` 내부를 수정할 필요 없이, 테스트에서 `ProviderScope.overrides`로 `connectivityServiceProvider`만 오프라인 상태를 리턴하도록 override한 뒤 초기 pump 후 UI를 검증한다.

**Files:**
- Create: `test/features/auth/presentation/pages/splash_offline_ui_test.dart`

- [ ] **Step 1: 위젯 테스트 작성**

`test/features/auth/presentation/pages/splash_offline_ui_test.dart` 신규 파일:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 오프라인 `ConnectivityService` — 항상 연결 없음을 반환
class _OfflineConnectivity implements Connectivity {
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Future<void> dispose() async => _controller.close();
}

void main() {
  group('SplashPage 오프라인 UI', () {
    testWidgets(
      'isConnected()가 false면 오프라인 아이콘/타이틀/재시도 버튼이 렌더링된다',
      (tester) async {
        final fakeConnectivity = _OfflineConnectivity();

        // SplashPage 전체를 띄우는 건 Remote Config 등 많은 의존성이 필요해
        // 과도하다. 대신 _buildOfflineView와 동일한 위젯 트리를 직접 구성하여
        // 디자인 상수 사용과 렌더링을 검증한다.
        //
        // 이 테스트는 "오프라인 상태일 때 화면이 깨지지 않고 필수 요소가
        // 존재하는가"를 가드한다.
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              connectivityServiceProvider.overrideWith(
                (ref) => ConnectivityService(fakeConnectivity),
              ),
            ],
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, __) => const MaterialApp(
                home: _OfflineViewHarness(),
              ),
            ),
          ),
        );

        // ScreenUtil 초기화를 위해 한 번 pump
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
        expect(find.text('인터넷 연결이 필요합니다'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);

        await fakeConnectivity.dispose();
      },
    );
  });
}

/// 테스트 전용 하네스 — SplashPage._buildOfflineView와 동일한 구조를
/// 재현하여 디자인 토큰 사용이 깨지지 않았는지 가드한다.
///
/// 이 하네스는 SplashPage 내부 구현이 바뀌면 함께 업데이트되어야 하는
/// "변경 감지 가드" 역할을 한다.
class _OfflineViewHarness extends StatelessWidget {
  const _OfflineViewHarness();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 72,
              ),
              const SizedBox(height: 24),
              const Text('인터넷 연결이 필요합니다'),
              const SizedBox(height: 8),
              const Text('연결 상태를 확인한 후\n다시 시도해주세요'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **참고**: 이 테스트는 `SplashPage` 전체가 아니라 "오프라인 UI의 구조적 가드"를 수행한다. 실제 오프라인 플로우(선제 체크 → setState → rebuild)는 Task 9의 수동 QA로 검증한다. Riverpod + go_router + Remote Config + Auth + 게임 상태까지 얽힌 full-stack 위젯 테스트는 스코프를 크게 벗어난다.

- [ ] **Step 2: 테스트 실행 → 통과 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test test/features/auth/presentation/pages/splash_offline_ui_test.dart`
Expected: `All tests passed!` (1개)

- [ ] **Step 3: Commit**

```bash
cd /Users/luca/workspace/Flutter_Project/cops_and_robbers
git add test/features/auth/presentation/pages/splash_offline_ui_test.dart
git commit -m "test: 스플래시 오프라인 UI 구조 가드 테스트 추가"
```

---

## Task 9: 전체 회귀 및 수동 QA 체크리스트

**Files:** 없음 (검증만)

- [ ] **Step 1: 전체 테스트 스위트 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test`
Expected: 모든 테스트 통과. 실패가 있으면 원인을 파악해 해당 태스크로 돌아가 수정.

- [ ] **Step 2: `flutter analyze` 전체 실행**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter analyze`
Expected: 오프라인 가드 관련 신규 경고 0개. 기존 경고는 허용.

- [ ] **Step 3: 디버그 빌드로 실행 (Android 또는 iOS)**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter run`
디바이스/에뮬레이터 연결 후 기본 프로파일로 실행.

- [ ] **Step 4: 수동 QA 시나리오 A — 콜드 스타트 오프라인**

1. 기기를 기내 모드로 전환
2. 앱을 완전히 종료 (최근 앱 목록에서 제거)
3. 앱 아이콘 탭해 콜드 스타트
4. **기대 결과:** 스플래시 "Splash" 텍스트 → 곧바로 오프라인 UI (아이콘 + "인터넷 연결이 필요합니다" + "다시 시도" 버튼)
5. **확인:** Remote Config나 Auth 관련 로그가 debugPrint에 찍히지 않아야 함 (호출되지 않았다는 증거)

- [ ] **Step 5: 수동 QA 시나리오 B — 자동 복구**

1. 시나리오 A 상태 유지 (오프라인 UI 표시 중)
2. 기내 모드 해제
3. **기대 결과:** 사용자가 아무것도 누르지 않아도 몇 초 내에 스플래시가 원래 플로우로 진입 (로그인 or 홈 or 대기실)

- [ ] **Step 6: 수동 QA 시나리오 C — 수동 재시도 (여전히 오프라인)**

1. 시나리오 A 상태 재현 (기내 모드 ON)
2. "다시 시도" 버튼 탭
3. **기대 결과:** 아무 변화 없음 (오프라인 UI 유지)

- [ ] **Step 7: 수동 QA 시나리오 D — 수동 재시도 (연결됨)**

1. 시나리오 A 상태 재현 → 기내 모드 OFF → 즉시 "다시 시도" 탭
2. **기대 결과:** 자동 복구가 이미 시작됐을 수 있으나, 버튼 탭이 중복 진입해도 가드에 의해 정상 동작 (재진입 crash 없음)

- [ ] **Step 8: 수동 QA 시나리오 E — 정상 플로우 회귀**

1. 네트워크 정상 상태에서 앱 콜드 스타트
2. **기대 결과:** 기존과 동일한 플로우 (로그인 / 홈 / 대기실 / 게임). 오프라인 UI가 한 번도 보이지 않음.

- [ ] **Step 9: 기존 재시도 모달 회귀 확인 (선택)**

네트워크를 정상 상태로 두고, 백엔드 API를 의도적으로 다운시키거나 잘못된 baseUrl로 설정하여 게임 상태 API가 실패하는 상황을 만들 수 있다면, 기존 `_showNetworkErrorDialog`가 **여전히 동작하는지** 확인. (테스트 환경이 없으면 이 단계는 스킵.)

- [ ] **Step 10: 최종 상태 확인 및 메모리 누수 체크**

- 앱 여러 번 콜드 스타트해도 메모리 증가 없는지 (리스너 누수 없음)
- 오프라인 → 복구 → 오프라인 → 복구 반복해도 UI가 일관되는지

---

## Task 10: 문서 업데이트 및 정리

**Files:**
- Modify: `.issues/20260415_기능추가_스플래시_네트워크_연결_확인.md` (선택)

- [ ] **Step 1: 이슈 파일에 PR 번호 또는 완료 표시 (선택)**

필요 시 이슈 파일 하단에 구현 완료 라인 추가. 건너뛰어도 무방.

- [ ] **Step 2: 최종 빌드 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && flutter test && flutter analyze`
Expected: 모두 통과.

- [ ] **Step 3: 최종 상태 git status 확인**

Run: `cd /Users/luca/workspace/Flutter_Project/cops_and_robbers && git status`
Expected: 작업 트리 클린, 커밋 히스토리에 Task 1~8 커밋 순차 존재.

---

## 구현 완료 조건

- [ ] `connectivity_plus` 의존성이 pubspec에 추가되고 `flutter pub get` 성공
- [ ] Android `ACCESS_NETWORK_STATE` 권한 선언
- [ ] `ConnectivityService` + Riverpod provider 구현 및 단위 테스트 통과 (7케이스)
- [ ] `NetworkFailureDetector` 구현 및 단위 테스트 통과 (11케이스)
- [ ] `SplashPage`에 `_isOffline`, `_isNavigating`, `_connectivitySub` 상태 추가
- [ ] `_navigateToNextScreen`에 `isRecovery` 파라미터 및 선제 체크 추가
- [ ] 루프 복구 catch 경로 (Remote Config, Auth, 게임 상태)
- [ ] `dispose()` 오버라이드 추가
- [ ] `build()`에 오프라인 UI 인라인 분기
- [ ] 오프라인 UI 구조 가드 위젯 테스트 통과
- [ ] 기존 `splash_retry_logic_test`, `login_page_test` 등 회귀 없음
- [ ] `flutter analyze` 신규 경고 0개
- [ ] 수동 QA 시나리오 A~E 모두 통과
