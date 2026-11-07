# #429 AdMob 전면 광고 + Firebase Analytics 연동

## 📌 작업 개요

게임 종료 시점 전면 광고 1지점 삽입과 Firebase Analytics 퍼널 측정을 연동한 수익화/분석 기반 구축 작업.
UX를 해치지 않는 **fail-open** 원칙을 설계 중심에 두어, 광고·분석 실패가 게임 이탈 흐름을 절대 막지 않도록 구현.
Remote Config `ads_enabled`(기본 false) kill switch로 서버 사이드 롤아웃 제어 가능.

---

## 🎯 구현 목표

- 게임 종료(GAME_OVER) 이후 홈으로/한 번 더 선택 시 전면 광고 1회 노출
- 로그인 → 닉네임 → 방 생성/참가 → 게임 시작 → 게임 종료 → 이탈 선택 퍼널 전체 Analytics 계측
- google_mobile_ads SDK를 시스템 경계 인터페이스 뒤에 격리하여 단위 테스트 가능한 구조 확보

---

## ✅ 구현 내용

### AdService — SDK 경계 격리 및 fail-open 설계

- **파일**: `lib/core/services/ads/ad_service.dart`
- **변경 내용**: `LoadedInterstitial` / `InterstitialLoader` / `SdkInitializer` 세 인터페이스로 google_mobile_ads SDK를 격리. `AdService` 클래스가 이 경계만 의존하므로 테스트에서 fake 주입으로 SDK 없이 검증 가능
- **이유**: fail-open 원칙 구현 — 초기화·로드·표시 중 어느 단계가 실패해도 `onComplete`를 즉시 호출하여 라우팅이 블로킹되지 않음. UMP 동의 플로우(EEA 대상)와 Mobile Ads SDK 초기화를 `initialize()` 한 곳에서 처리

**특이사항**:
- `showGameEndInterstitial()`은 광고를 **1회 소비**(`_gameEndAd = null` 선행 처리)하여 같은 로드로 두 번 표시되는 경우를 구조적으로 차단
- SDK 콜백 중복 호출 방어를 위해 `completed` 플래그로 `onComplete`를 정확히 1회만 실행

### AdUnitIds — 디버그/릴리스 단위 ID 관리

- **파일**: `lib/core/services/ads/ad_unit_ids.dart`
- **변경 내용**: `kDebugMode` 분기로 디버그 빌드에서는 구글 공식 테스트 ID를 강제 사용
- **이유**: 개발 중 실제 ID로 노출/클릭 시 AdMob 무효 트래픽 정책 위반(계정 정지 사유) 방지. AdMob 단위 ID는 출시 바이너리에서 추출 가능한 공개 식별자이므로 코드에 직접 포함

### AnalyticsService — Firebase Analytics 래퍼 (no-op 안전)

- **파일**: `lib/core/services/analytics/analytics_service.dart`
- **변경 내용**: Firebase 미초기화(앱 main fail-open 패턴) 시 `analytics: null`로 생성되어 전체 no-op 동작. 9종 이벤트 메서드 제공
- **이유**: Analytics 실패가 앱 흐름에 영향을 주지 않도록 모든 메서드를 try-catch로 감쌈

**이벤트 목록**:

| 이벤트 | 메서드 | 퍼널 위치 |
|---|---|---|
| `login` (GA4 표준) | `logLogin(method)` | Google/Apple 로그인 성공 |
| `nickname_change` | `logNicknameChange()` | 닉네임 설정 완료 |
| `game_create` | `logGameCreate(...)` | 방 생성 완료 |
| `game_join` | `logGameJoin(method)` | 방 입장 (코드/딥링크) |
| `game_start` | `logGameStart(...)` | GAME_START 수신 |
| `game_over` | `logGameOver(...)` | GAME_OVER 수신 |
| `game_exit_choice` | `logGameExitChoice(choice)` | 홈/한번더 선택 |
| `tutorial_complete` | `logTutorialComplete()` | 인게임 튜토리얼 완료 |
| `ad_interstitial_result` | `logAdInterstitialResult(status)` | 광고 표시 결과 (shown/not_loaded/failed) |

### Remote Config — ads_enabled kill switch

- **파일**: `lib/core/services/remote_config/remote_config_service.dart`
- **변경 내용**: `ads_enabled` 파라미터 추가 (기본값 `false`), `adsEnabled` getter 노출
- **이유**: 출시 후 문제 발생 시 서버에서 즉시 광고 비활성화 가능한 롤아웃 스위치 확보

### game_page.dart — 광고 프리로드 + 이탈 처리 통합

- **파일**: `lib/features/game/presentation/pages/game_page.dart`
- **변경 내용**:
  - `_showGameOverDialog()` 진입 직후(결과 확인 중 광고 로드 시간 확보) `preloadGameEndInterstitial()` 비동기 호출
  - `_exitGameAfterAd()` 메서드 신규 — 홈으로/한 번 더 4개 버튼 탭 핸들러를 공통 경로로 통합
  - `_exitTriggered` 플래그로 연타 시 중복 이벤트 기록 및 `context.go` 재호출 방어
  - `game_over` / `game_exit_choice` / `ad_interstitial_result` 이벤트 삽입
- **이유**: 광고가 표시되는 동안 GamePage는 네이티브 오버레이 아래에 살아있으므로 닫힘 콜백에서 `mounted` 재확인 후 라우팅

### splash_page.dart — AdMob SDK 초기화 시점

- **파일**: `lib/features/auth/presentation/pages/splash_page.dart`
- **변경 내용**: `adServiceProvider.initialize()` 비동기 호출 추가
- **이유**: UMP 동의 폼은 첫 프레임 이후에만 표시 가능하므로 `main()`이 아닌 스플래시에서 수행. `unawaited`로 호출하여 스플래시 완료 시간을 지연시키지 않음

### app_router.dart — Analytics 화면 추적

- **파일**: `lib/router/app_router.dart`
- **변경 내용**: `navigatorObservers`에 `FirebaseAnalyticsObserver` 추가
- **이유**: 별도 이벤트 없이 GA4 자동 화면 이동 추적 활성화

### 퍼널 이벤트 삽입 (7지점)

| 파일 | 이벤트 |
|---|---|
| `lib/features/auth/presentation/providers/auth_provider.dart` | `logLogin` (Google/Apple) |
| `lib/features/auth/presentation/pages/nickname_setup_page.dart` | `logNicknameChange` |
| `lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart` | `logTutorialComplete` |
| `lib/features/session/presentation/pages/session_creation_flow_page.dart` | `logGameCreate` |
| `lib/features/session/presentation/pages/home_page.dart` | `logGameJoin(method: 'code')` |
| `lib/features/session/presentation/pages/deeplink_join_page.dart` | `logGameJoin(method: 'deeplink')` |
| `lib/features/session/presentation/pages/waiting_room_page.dart` | `logGameStart` |

**특이사항**: `in_game_tutorial_page.dart`는 `analyticsServiceProvider` 참조를 위해 `StatelessWidget → ConsumerStatefulWidget`으로 전환

### 플랫폼 설정

- **Android** `AndroidManifest.xml`: AdMob 앱 ID (`com.google.android.gms.ads.APPLICATION_ID`) 메타데이터 추가
- **iOS** `Info.plist`: `GADApplicationIdentifier` 키 추가, SKAdNetworkItems 50개 등록
- **iOS** `Podfile.lock`: FlutterFire 업그레이드에 따른 Firebase iOS SDK 12.9.0 → 12.14.0 pod update

---

## 🔧 주요 변경사항 상세

### fail-open 전파 경로

```text
GAME_OVER 수신
  → preloadGameEndInterstitial()  [백그라운드, 실패 무시]
       ↓ (결과 다이얼로그 확인 후)
홈으로/한 번 더 탭
  → _exitTriggered 체크 (연타 방지)
  → logGameExitChoice()
  → showGameEndInterstitial(onComplete: context.go(destination))
       ├── 광고 로드됨 → 광고 표시 → 닫힘 콜백 → mounted 확인 → 이동
       └── 광고 없음/실패 → onComplete() 즉시 호출 → 이동
  → logAdInterstitialResult(status)
```

### UMP + SDK 초기화 순서

```text
스플래시 첫 프레임 이후
  → adService.initialize()  [unawaited]
       → _gatherConsent()   [EEA만 폼 표시]
       → canRequestAds() 확인
       → MobileAds.initialize()
```

동의 거부(EEA)로 `canRequestAds() == false`이면 SDK 초기화를 건너뛰고 `_sdkInitialized = false` 유지 → 이후 preload가 자동으로 스킵됨

---

## 📦 의존성 변경

```yaml
# pubspec.yaml 추가
google_mobile_ads: ^7.0.0     # AdMob 전면 광고
firebase_analytics: ^12.4.2   # 사용자 행동 분석
```

---

## 🧪 테스트 및 검증

**신규 테스트 10개** (기존 362개 포함 전체 통과):

- `test/core/services/ads/ad_service_test.dart` — 7개
  - `ads_enabled: false`일 때 로더 미호출 확인
  - SDK 초기화 실패 시 로더 미호출 확인
  - 광고 미로드 시 `notLoaded` 즉시 통과 (fail-open)
  - 광고 표시 → 닫힘 콜백 전달 확인
  - 1회 소비 후 두 번째 표시 시 `notLoaded` 폴백 확인
  - 표시 중 예외 시 `failed` 반환 + fail-open 확인
  - 중복 preload 시 로더 1회만 호출 확인

- `test/core/services/analytics/analytics_service_test.dart` — 3개
  - `logGameOver` 파라미터 snake_case 검증
  - Firebase 미초기화(`analytics: null`) 시 전체 no-op 확인
  - SDK 예외 시 호출자 에러 전파 없음 확인

**검증**:
- `flutter analyze` 신규 이슈 0
- Android APK debug 빌드 성공
- iOS 시뮬레이터 빌드 성공
- 최종 코드 리뷰 APPROVE (CRITICAL/HIGH 0)

---

## 📌 참고사항

**출시 전 운영 작업 (미완료)**:

- Firebase 콘솔 Remote Config에 `ads_enabled` 파라미터 생성 필요 (기본값 `false` 유지, 준비 완료 시 `true`로 단계적 롤아웃)
- AdMob 대시보드에서 Firebase 프로젝트와 AdMob 앱 연동 설정 필요
- AdMob 앱-스토어 목록(App Store / Play Store) 연결 필요
- 실기기에서 광고 로드 → 표시 → 닫힘 후 라우팅 흐름 수동 검증 필요

**설계 문서**:
- `docs/superpowers/specs/2026-06-12-admob-interstitial-analytics-design.md`
- `docs/superpowers/plans/2026-06-12-admob-interstitial-analytics.md`
