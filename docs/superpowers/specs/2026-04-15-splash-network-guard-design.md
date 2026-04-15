# 스플래시 네트워크 차단 가드 설계

**작성일:** 2026-04-15
**관련 이슈:** `.issues/20260415_기능추가_스플래시_네트워크_연결_확인.md`
**대상 파일:** `lib/features/auth/presentation/pages/splash_page.dart`

---

## 1. 배경 및 문제

### 현재 상태

`SplashPage._navigateToNextScreen()`은 콜드 스타트 시 다음 순서로 외부 의존성을 호출한다.

1. `RemoteConfigService.initialize()` + `AppVersionChecker.check()`
2. `authNotifierProvider.future` (5초 타임아웃)
3. `getMyActiveGameUsecaseProvider.execute()` (DioException 시 2회 재시도)

각 단계는 독립적으로 실패 처리가 있다.

- Remote Config 실패: try-catch로 `fail-open` 진행
- Auth 타임아웃: 로그인 화면으로 이동
- 게임 상태 `DioException`: `_showNetworkErrorDialog()` 재시도 모달

### 문제

앱 콜드 스타트 시점에 네트워크 연결이 없을 경우, 위 단계들이 일관되지 않게 동작한다.

- Remote Config는 조용히 fail-open → 이후 단계가 네트워크 없이 진입
- Auth는 5초 타임아웃까지 사용자가 빈 "Splash" 화면을 응시해야 함 → 결국 로그인 화면으로 이동해도 거기서 또 실패
- 게임 상태 API는 재시도 모달이 있지만, 그 이전 단계에서 이미 엉뚱한 화면으로 이동했을 수 있음

즉 "네트워크 없을 때 앱 진입을 차단"이라는 방어 로직이 스플래시 전체에 걸쳐 존재하지 않는다. 사용자 입장에선 왜 로그인이 안 되는지, 왜 스플래시가 오래 뜨는지 파악할 수 없다.

---

## 2. 목표 및 비목표

### 목표

- 앱 콜드 스타트 시 네트워크 연결이 없으면, 외부 API 호출을 일절 수행하지 않고 사용자에게 오프라인 상태를 명확히 안내한다.
- 연결 복구 시 사용자의 수동 조작 없이 자동으로 원래 플로우로 복귀한다.
- 자동 복구가 실패하거나 "연결됐지만 실제 통신은 안 되는" 케이스(플래핑, captive portal)에서도 무한 복구 시도 가능하되 리소스 폭주 없이 동작한다.

### 비목표

- 앱 전역 네트워크 모니터링 (이번 스코프는 `SplashPage` 콜드 스타트 한정)
- 기존 `_showNetworkErrorDialog()` 교체 (플로우 중간 API 실패 처리는 그대로 유지)
- 백그라운드 → 포그라운드 복귀 시의 재연결 처리 (스플래시는 진입 지점이라 해당 없음)

---

## 3. 접근 방식

하이브리드 방식을 채택한다.

1. 콜드 스타트 진입 즉시 `connectivity_plus` 기반 선제 체크 (`isConnected()`)로 명백한 오프라인을 즉시 거른다.
2. 선제 체크 통과 시 기존 플로우(Remote Config → Auth → 게임 상태)를 그대로 실행한다.
3. 오프라인 감지 시 네이티브 연결 이벤트 스트림을 구독해 자동 복구를 시도한다. 사용자가 직접 누를 수 있는 재시도 버튼도 함께 제공한다.
4. 복구 후 기존 플로우 진입 중 네트워크성 실패(DioException, SocketException, 타임아웃)가 발생하면 다시 오프라인 상태로 복귀하고 리스너를 재구독한다 (루프 복구).

### 배제한 대안

- **순수 Dart `InternetAddress.lookup` 프로브**: 의존성은 제로지만 네이티브 연결 이벤트 구독이 불가능해 자동 복구를 폴링으로 흉내내야 한다. "자동 + 수동 복구 둘 다" 요구와 결이 맞지 않아 배제.
- **앞단 선제 체크 없는 반응적 처리만**: 오프라인일 때도 타임아웃까지 대기해야 하고, 진입 체감 속도가 느려 배제.

---

## 4. 컴포넌트 설계

### 4.1 `ConnectivityService` (신규)

**위치:** `lib/core/network/connectivity_service.dart`

**역할:** `connectivity_plus` 래퍼. 호출자(스플래시, 미래의 다른 화면)가 이 인터페이스에만 의존하도록 플랫폼 구현을 격리.

**공개 API (개념):**

- `Future<bool> isConnected()` — 현재 연결 상태를 단발성으로 조회
- `Stream<bool> onConnectivityChanged` — 연결 상태 변화 스트림 (`true` = 연결됨, `false` = 끊김)

**내부 규칙:**

- `ConnectivityResult.none`은 `false`, 그 외(`wifi`, `mobile`, `ethernet`, `vpn`, `bluetooth`)는 모두 `true`로 단순화
- 스트림은 broadcast로 노출 (여러 구독자 허용)
- 테스트 가능성을 위해 `connectivity_plus`의 `Connectivity` 인스턴스를 생성자 주입으로 받음

**Riverpod 노출:**

- `connectivityServiceProvider` — keepAlive 싱글턴
- 동일 파일에 `@riverpod` 선언

### 4.2 `SplashPage` 수정

**신규 상태:**

- `bool _isOffline` — 오프라인 차단 상태 플래그
- `bool _isNavigating` — `_navigateToNextScreen()` 동시 실행 방지 플래그
- `StreamSubscription<bool>? _connectivitySub` — 자동 복구용 스트림 구독 핸들

**플로우 변경 (`_navigateToNextScreen()` 최상단 추가):**

1. `_isNavigating = true` 설정
2. 기존 리스너가 있으면 `_connectivitySub?.cancel()` 후 `null`로 초기화 (재진입 안전성)
3. `ref.read(connectivityServiceProvider).isConnected()` 호출
4. `false`면:
   - `setState(_isOffline = true)`
   - 리스너 구독 (`_connectivitySub = ...onConnectivityChanged.listen(_handleConnectivityChange)`)
   - `_isNavigating = false` 후 `return` (Remote Config/Auth 호출 없음)
5. `true`면 기존 플로우 진행 (Remote Config → Auth → 게임 상태)

**플로우 내 네트워크성 실패 처리:**

- `_navigateToNextScreen()` 내부의 catch 블록에서 `_isNetworkFailure(error)` 헬퍼로 네트워크성 실패 여부 판별
- 네트워크성 실패 시:
  - 폭주 방지용 `await Future.delayed(Duration(seconds: 1))`
  - `setState(_isOffline = true)`
  - 리스너 재구독
  - `return`
- 비네트워크성 실패는 기존 로직 유지 (fail-open, 로그인 이동, 재시도 모달)

**`_isNetworkFailure(error)` 헬퍼:**

다음 중 하나면 `true`:

- `DioException`이고 `type`이 `connectionError`, `connectionTimeout`, `sendTimeout`, `receiveTimeout`
- `SocketException`
- `TimeoutException`

**`_handleConnectivityChange(bool isConnected)` 콜백:**

- `_isOffline == true && _isNavigating == false && isConnected == true`일 때만 실행
- 조건 충족 시 `_connectivitySub?.cancel()` → `_connectivitySub = null` → `setState(_isOffline = false)` → `_navigateToNextScreen()` 재호출

**재시도 버튼 핸들러 `_onManualRetry()`:**

- `ref.read(connectivityServiceProvider).isConnected()` 조회
- `true`면 리스너 cancel 후 `_navigateToNextScreen()` 재호출
- `false`면 상태 유지 (아무 동작 없음)

**`dispose()` 신설:**

- `_connectivitySub?.cancel()`
- `super.dispose()`

### 4.3 오프라인 UI (인라인)

**위치:** `SplashPage.build()` 내부 분기

```
if (_isOffline) → 오프라인 Column 반환
else if (_isReconnecting) → LoadingPage (기존)
else → 기본 스플래시 (기존)
```

**구성 요소:**

- 중앙 정렬 오프라인 아이콘 (예: `Icons.wifi_off`)
- 타이틀: "인터넷 연결이 필요합니다"
- 서브 텍스트: "연결 상태를 확인한 후\n다시 시도해주세요"
- `AppButton`을 활용한 "다시 시도" CTA
- `AppColors`, `AppTextStyles`, `AppSpacing`, `AppPadding` 등 기존 디자인 상수 재사용
- 신규 별도 위젯 파일 생성 없음 (스플래시 전용이므로 인라인으로 충분)

---

## 5. 데이터 흐름

### 5.1 정상 연결

```
앱 시작 → SplashPage.initState() → _navigateToNextScreen()
  → isConnected() == true
  → [기존 플로우]
    RemoteConfig → AuthChecker → Auth future → 게임 상태 API
  → 목적지 라우팅 (login/home/waiting/game)
```

변경 없음. 선제 체크만 1회 추가.

### 5.2 콜드 스타트 오프라인

```
앱 시작 → _navigateToNextScreen()
  → isConnected() == false
  → setState(_isOffline = true) + 리스너 구독
  → return (외부 API 호출 없음)
  → build() → 오프라인 UI
```

### 5.3 자동 복구 (정상 케이스)

```
[오프라인 UI 표시 중]
  → OS 네트워크 복구
  → connectivity_plus 이벤트 → onConnectivityChanged(true)
  → _handleConnectivityChange(true)
    → 리스너 cancel, _isOffline = false
    → _navigateToNextScreen() 재호출
  → isConnected() == true → 기존 플로우 진행 → 라우팅 성공
  → dispose() 시 구독 해제 확인 (null이므로 no-op)
```

### 5.4 자동 복구 실패 → 루프 복구

```
[오프라인 UI] → 복구 이벤트 → 재시도 → 플로우 진입
  → Auth API 호출 중 DioException(connectionError)
  → catch 블록에서 _isNetworkFailure() == true
  → await Future.delayed(1초)
  → setState(_isOffline = true) + 리스너 재구독
  → return
  → build() → 오프라인 UI (다시 표시)
  → 다음 복구 이벤트 대기
```

### 5.5 수동 재시도 (연결됨)

```
[오프라인 UI] → "다시 시도" 탭 → _onManualRetry()
  → isConnected() == true → 리스너 cancel → _navigateToNextScreen()
```

### 5.6 수동 재시도 (여전히 오프라인)

```
[오프라인 UI] → "다시 시도" 탭 → _onManualRetry()
  → isConnected() == false → 아무 동작 없음 (오프라인 UI 유지)
```

### 5.7 플래핑 방지 — 동시 실행 가드

```
[네비게이션 진행 중]
  → 리스너가 true 이벤트 수신
  → _handleConnectivityChange(true)
  → 조건 체크: _isNavigating == true → 무시
```

리스너는 진입 시 즉시 cancel되므로 이 경로는 발생하지 않는 것이 정상이지만, 이중 안전장치로 `_isNavigating` 플래그를 둔다.

---

## 6. 생명주기 요약

```
초기: _connectivitySub == null

콜드 스타트 오프라인 감지
  → 구독 시작 → _connectivitySub != null

[자동 or 수동] 복구 → 재진입 직전
  → _connectivitySub.cancel() + null 대입

재진입 중 네트워크성 실패
  → 1초 delay → 다시 구독 → _connectivitySub != null

위젯 dispose
  → _connectivitySub?.cancel()
  → super.dispose()
```

리스너가 **중복 구독 없이 정확히 1개만 유지**되도록 재진입 시점마다 `cancel() + null` 시퀀스를 보장한다.

---

## 7. 엣지 케이스

### 7.1 플로우 진행 중 네트워크 끊김

이번 스코프는 "콜드 스타트"에 한정된다. 플로우 진입 후 중간에 끊긴 경우는 기존 fallback이 처리한다.

- Remote Config: fail-open (기존 유지)
- Auth 타임아웃: 로그인 이동 (기존 유지)
- 게임 상태 `DioException`: 기존 재시도 모달 (기존 유지)

단, 루프 복구 과정에서 네트워크성 실패는 포착해 다시 오프라인 화면으로 복귀시킨다.

### 7.2 Captive Portal / Wi-Fi는 잡혔지만 인터넷 없음

`connectivity_plus`는 링크 레벨만 감지하므로 "connected"라고 보고한다. 이땐 선제 체크를 통과해 기존 플로우로 진입하지만, Remote Config/Auth/게임 상태 API 호출에서 네트워크성 실패가 발생해 루프 복구 경로(5.4)로 빠져 오프라인 UI로 돌아온다.

### 7.3 네트워크 플래핑

`_isNavigating` 플래그 + 재진입 시 `cancel() + null` 시퀀스 + 재시도 간 1초 delay로 배터리·API 폭주를 막는다.

### 7.4 `mounted` 체크

기존 코드는 이미 비동기 후 `if (!mounted) return` 패턴을 사용한다. 새로 추가하는 `setState`, `_navigateToNextScreen` 재호출, `dispose`에도 동일 원칙 적용.

---

## 8. 테스트 전략

### 8.1 단위 테스트

**파일:** `test/core/network/connectivity_service_test.dart`

- `checkConnectivity()`가 `ConnectivityResult.none` → `isConnected()` false
- `checkConnectivity()`가 `wifi` / `mobile` / `ethernet` → `isConnected()` true
- `onConnectivityChanged` 스트림이 `none → wifi` 순서로 이벤트 발생 → 래퍼 스트림이 `false → true` 발행
- 여러 구독자가 동일 스트림을 받음 (broadcast 검증)

**Mock:** `connectivity_plus`의 `Connectivity` 인스턴스를 생성자 주입으로 받도록 설계 → `MockConnectivity` 주입.

### 8.2 위젯 테스트

**파일:** `test/features/auth/presentation/pages/splash_page_test.dart`

기존 dependencies(`authNotifierProvider`, `getMyActiveGameUsecaseProvider`, `RemoteConfigService`)는 정상 동작 mock으로 override.

**케이스:**

1. 정상 연결: `isConnected()` → true, 기존 플로우 통과, 오프라인 UI 렌더링되지 않음
2. 콜드 스타트 오프라인: `isConnected()` → false, 오프라인 UI 렌더링, Remote Config/Auth mock이 호출되지 않음 (`verifyNever`)
3. 자동 복구: 오프라인 상태에서 스트림 `true` 이벤트 → 오프라인 UI 사라지고 기존 플로우 진입
4. 수동 재시도 (연결됨): 버튼 탭 → 기존 플로우 진입
5. 수동 재시도 (여전히 오프라인): 버튼 탭 → UI 유지, 아무 동작 없음
6. 루프 복구: 복구 → 플로우 진입 → `DioException(connectionError)` → 다시 오프라인 UI + 리스너 재구독 (pump으로 1초 delay 소비 후 검증)
7. `dispose` 시 구독 해제: 위젯 제거 후 스트림에 이벤트 뿌려도 콜백 호출 없음 (구독 누수 검증)

### 8.3 수동 QA 시나리오

1. 기내 모드 ON 상태에서 앱 콜드 스타트 → 오프라인 화면 표시
2. 그 상태에서 기내 모드 OFF → 자동으로 스플래시 플로우 이어짐
3. 오프라인 상태에서 "다시 시도" 탭 → 아무 변화 없음
4. 오프라인 → 재시도 타이밍에 맞춰 기내 모드 OFF → 플로우 진입
5. 네트워크 플래핑 시뮬레이션: 앱이 일관되게 오프라인/온라인 사이 전환하고 크래시나 중복 네비게이션 없음

---

## 9. 의존성 및 빌드 영향

- `pubspec.yaml`에 `connectivity_plus` 추가 (최신 안정 버전 기준)
- Android: `AndroidManifest.xml`에 `ACCESS_NETWORK_STATE` 권한 추가 필요 (대부분의 프로젝트엔 이미 있음, 확인 필요)
- iOS: 추가 설정 불필요
- `flutter pub get`
- 코드 생성이 필요한 annotation은 `@riverpod`뿐 — `dart run build_runner build --delete-conflicting-outputs` 실행

---

## 10. 체크리스트

- [ ] `pubspec.yaml`에 `connectivity_plus` 추가 및 `flutter pub get`
- [ ] Android `ACCESS_NETWORK_STATE` 권한 확인
- [ ] `ConnectivityService` 구현 (`lib/core/network/connectivity_service.dart`)
- [ ] `connectivityServiceProvider` 정의 및 코드 생성
- [ ] `ConnectivityService` 단위 테스트
- [ ] `SplashPage` 상태 추가 (`_isOffline`, `_isNavigating`, `_connectivitySub`)
- [ ] `_navigateToNextScreen()` 최상단 선제 체크 로직 추가
- [ ] `_isNetworkFailure()` 헬퍼 추가
- [ ] 네트워크성 실패 시 루프 복구 경로 구현
- [ ] `_handleConnectivityChange()`, `_onManualRetry()` 구현
- [ ] `dispose()` 오버라이드 추가
- [ ] `build()`에 오프라인 UI 인라인 분기 추가
- [ ] `SplashPage` 위젯 테스트 작성
- [ ] 수동 QA (기내 모드 토글 시나리오)
- [ ] 기존 재시도 모달(`_showNetworkErrorDialog`) 회귀 확인
