### 📌 작업 개요
iOS에서 앱을 다시 실행해도 **같은 게임·같은 라운드의 Live Activity(잠금 화면 카드)를 이어받고, 게임 만료·종료 또는 인증 종료가 확인되면 정리**하도록 변경. 실행 시 모든 Activity를 닫던 `endAll()`을 `restore()`(종료 시각이 지난 Activity만 정리)로 바꾸고, 종료 예정 카드의 재선택과 로그아웃 후 카드 잔존도 방지.

**보고서 파일**: `docs/report/20261001_#621_재실행_시_Live_Activity_이어받기와_종료_확인_후_정리.md`

### 🎯 구현 목표
- 게임 중 앱 재실행 시 잠금 화면 카드를 없애지 않고 유지
- 이어받을 대상은 `gameId` + `startAt`이 모두 같은 Activity (같은 방의 새 라운드와 구분)
- 종료 시각이 지난 Activity는 실행 시 정리
- 서버가 "진행 중 게임 없음"으로 확인하거나 비로그인이면 `stop()`
- 상태 조회 실패는 종료로 보지 않고 그대로 둠

| 상황 | 변경 전 | 변경 후 |
|---|---|---|
| 게임 중 앱 재실행 | 실행 즉시 모든 Activity 종료 후 새로 생성 | Activity 유지, 게임 복원 후 첫 `update`가 이어받음 |
| 이어받을 대상 판별 | 없음 | `gameId` + `startAt` 일치 |
| 종료 시각이 지난 Activity | 실행 때 일괄 종료 | 실행 때 `restore()`로 종료 |
| 서버가 진행 중 게임 없음 확인 | 처리 없음 | 스플래시·홈에서 `stop()` |
| 비로그인 | 처리 없음 | 스플래시에서 `stop()` |
| 로그아웃·인증 만료·회원 탈퇴 | 게임 화면 이탈에 의존 | 인증 정리 경로에서도 `stop()` |
| 종료 직후 같은 라운드 재진입 | 종료 예정 카드를 다시 선택할 수 있음 | 종료 예정 카드를 제외하고 새 카드 생성 |
| 상태 조회 실패 | — | 종료로 보지 않음 |

### 🔍 문제 분석
`AppDelegate`가 실행할 때마다 `endAll()`로 모든 Activity를 닫았음. 강제 종료 뒤 이전 게임 카드가 남는 것을 막으려던 처리였으나, 게임 중 재실행에서도 카드를 제거하는 경로였음. 백그라운드에서 새 Live Activity 요청이 거부되면(`ActivityAuthorizationError.visibility`) 앱을 앞으로 가져오기 전까지 표시가 비어 있을 수 있음.

위 설명은 코드에서 확인한 제거 경로다. 최초 제보의 잠금 해제 시점에 콜드 스타트가 발생했는지는 실기기 로그로 확인하지 못했다. 후속 리뷰의 `stop()` 직후 같은 라운드 `update()` 경쟁은 iOS 18.1 시뮬레이터에서 별도로 재현했다.

### ✅ 구현 내용

#### iOS - 실행 시 정리 범위 축소
- **파일**: `ios/Runner/AppDelegate.swift`
- **변경 내용**: `didFinishLaunching`에서 `endAll()` 대신 `restore()` 호출. `update` 채널 인자에서 `gameId`(0 이하면 무시)를 받아 `GameStatusAttributes`에 전달
- **이유**: 게임 중 재실행을 게임 종료로 보지 않기 위해

#### iOS - 게임 식별자 추가
- **파일**: `ios/Runner/GameStatusAttributes.swift`
- **변경 내용**: `gameId: Int? = nil` 추가
- **이유**: 재실행 뒤 남아 있는 Activity가 현재 게임의 것인지 대조. optional로 두어 이전 버전이 만든 Activity도 디코딩 가능

#### iOS - Activity 이어받기와 정리
- **파일**: `ios/Runner/GameStatusActivityManager.swift`
- **변경 내용**:
  - `update()`: 기존 Activity 중 `gameId`와 `startAt`이 모두 같은 것을 채택해 닫힘 감시를 붙이고 내용만 갱신. 나머지 Activity는 종료. 일치하는 것이 없으면 새로 요청. `endAt`이 지났으면 `stop()`
  - `restore()` 추가: `endAt`이 지난 Activity만 종료. 종료 작업 `Task`를 반환(테스트에서 완료 대기용)
  - `dismissedByUser` → `endedExternally`로 개명
  - `end()`가 Task 예약 전에 종료 예정 ID를 기록하고 완료 후 제거. `update()`의 선택 대상과 중복 종료 대상에서 제외해, 종료 예약된 카드를 다시 이어받지 않음
- **이유**: ActivityKit은 사용자가 밀어서 닫은 것과 시스템이 제거한 것을 구분하지 않으므로 이름을 실제 의미에 맞춤

#### Dart - 재시작 직후 `stop()` 전달
- **파일**: `lib/core/services/background/method_channel_background_service.dart`, `lib/core/services/background/background_service.dart`
- **변경 내용**: `_isRunning`을 `bool?`로 변경. `null`은 "Dart가 재시작돼 OS 상태를 모름". `isRunning`은 `_isRunning == true`, `stop()`은 `_isRunning == false`일 때만 건너뜀. `update`에 `gameId`를 함께 전송. 문서 주석에 `gameId`의 용도 명시
- **이유**: 재시작 직후 `stop()`이 "이미 멈춤"으로 무시되면 OS에 남은 Activity를 닫을 수 없음

#### Dart - 종료 확인 시 정리
- **파일**: `lib/features/auth/presentation/pages/splash_page.dart`, `lib/features/session/presentation/pages/home_page.dart`
- **변경 내용**:
  - 스플래시: `authUser == null`이면 `stop()`. 활성 게임 조회가 성공했고 참여 중이 아니거나 `inProgress`가 아니면 `stop()`
  - 홈: 활성 게임 조회 성공 후 같은 조건이면 `stop()`
- **이유**: 서버 푸시가 없는 방침(DEC-0089)상 앱이 꺼진 채 끝난 게임의 카드는 다음 실행 때 정리해야 함. 조회 예외는 `catch` 경로로 빠지므로 `stop()`에 도달하지 않음

#### Dart - 인증 종료 시 정리
- **파일**: `lib/features/auth/presentation/providers/auth_provider.dart`
- 일반 로그아웃 성공 후 기존 `forceLogout()`의 공통 정리를 사용하고, 여기서 백그라운드 서비스를 중지
- 회원 탈퇴 후에는 Firebase 정리 성공 여부와 관계없이 카드를 먼저 정리. 화면 이동과 인증 상태 변경 순서는 유지

#### 백엔드 - 시작 시각 정밀도 통일
- **별도 저장소**: `cops_and_robbers-BE`
- `game/game/domain/Game.java`: `startGame()`에서 시작 시각을 밀리초로 절단해 저장
- `play/lobby/application/LobbyService.java`: STOMP에도 `game.getStartedAt()`을 전달. REST가 읽는 값과 같은 원본을 사용
- PostgreSQL 드라이버의 마이크로초 반올림으로 밀리초 경계를 넘는 문제를 방지. **백엔드 배포 후 시작하는 라운드부터 적용**하며, 이미 시작한 라운드나 기존 카드의 시각은 소급 변경하지 않음

#### Android - 상태 표시줄 안내 조건 명시
- **파일**: `docs/release-note/v3.1.20.md`
- 한국어·영어·일본어 안내에 Android 16 이상에서 실시간 업데이트 표시가 허용된 경우라는 조건을 추가
- 알림 승격 요청이 상태 표시줄 표시를 항상 보장하지 않는 점을 반영. Android 네이티브 동작 변경은 없음

### 🔧 주요 변경사항 상세

#### GameStatusActivityManager.update 흐름
1. 이전 값과 `gameId` 또는 `startAt`이 다르면 추적 상태(`currentActivityID`, `endedExternally`)를 초기화
2. `endAt`이 지났으면 `stop()` 후 종료
3. 이미 외부에서 닫힌 라운드(`endedExternally`)면 아무것도 하지 않음
4. 종료 예정 Activity를 제외하고 `gameId`+`startAt`이 같은 Activity가 있으면 채택(`active`/`stale`일 때만), 없으면 새로 요청
5. 채택하지 않은 Activity는 종료. 이미 종료 중인 ID는 중복 예약하지 않음

**특이사항**:
- 이어받기에 실패하면 "닫고 새로 만들기"로 동작하며, 백그라운드에서는 시작이 막혀 앱이 앞으로 올 때까지 표시가 없을 수 있음
- `AppDelegate`의 `update`·`stop`은 `Task` 예약 없이 `MainActor.assumeIsolated`로 즉시 실행(기존 방식 유지). 순서가 뒤바뀌어 끝난 게임의 Activity가 되살아나는 것을 막기 위함

### 🧪 테스트 및 검증
- **Dart**: `test/core/services/background/method_channel_background_service_test.dart` 12개 테스트 통과 확인
  - 재시작 직후 `stop()`이 네이티브까지 전달되고 이후 반복 호출은 무시되는지
  - `update`에 `gameId`가 실리는지
  - 시작 전 `update`는 보관했다가 시작 직후 한 번 전송되는지
- **Swift `ios/RunnerTests/RunnerTests.swift`**: iOS 18.1 시뮬레이터에서 아래 **6개 통과**
  - 매니저 재생성 후에도 기존 Activity ID 유지(이어받기)
  - 종료 시각이 지난 라운드는 Activity를 만들지 않음
  - 같은 게임의 다른 라운드(`startAt` 불일치)는 기존 Activity를 종료하고 교체
  - 재실행 후 `stop()`이 남은 Activity를 제거
  - 앱 밖에서 닫힌 Activity는 같은 라운드에서 다시 만들지 않음
  - 반복 `stop()` 직후 같은 라운드를 갱신해도 새 카드가 유지됨 (수정 전 카드 0개로 실패, 수정 후 통과)
- **인증 정리 회귀 테스트**: `auth_notifier_background_cleanup_test.dart` 3개 통과. 일반 로그아웃, 강제 로그아웃, Firebase 정리에 실패한 회원 탈퇴를 실제 Notifier·채널 서비스와 플랫폼 경계 모의 처리로 검증. 세 경우 모두 수정 전 실패 확인
- **백엔드**: `LobbyStartTimeTest`, `LobbyServiceTest`, `GameResultServiceTest` 총 53개 통과. 소수점 경계값 3개 중 2개는 수정 전 실패. DB 접근만 모의 처리하고 실제 게임 시작 로직·STOMP 생성·REST 매핑을 검증했으며, 운영 DB 왕복 검증은 미실행
- **Flutter 전체**: `flutter test` 1,395개 통과. `flutter analyze lib test` 문제 없음
- **실기기**: 잠금·해제, 강제 종료 후 재실행, 오프라인 재실행 시 카드 유지 여부는 미검증

### ⚠️ 알려진 위험
- **백엔드 배포 전 라운드**: 시작 시각 통일 변경을 배포하기 전 생성된 카드에서는 DB 반올림으로 `startAt`이 어긋날 가능성이 남음. 앱 변경만 배포해서는 이 정밀도 문제가 해결되지 않음
- **오프라인 실기기 확인**: 현재 인증 코드에서 약관·프로필 조회 실패는 내부에서 처리하고, 토큰 재발급의 일시적 네트워크 실패는 토큰을 보존함. 오프라인 재실행 중 카드 유지 여부는 실기기에서 추가 확인 필요
- **닫힘 상태가 프로세스 수명**: 사용자가 밀어서 닫은 카드의 `endedExternally`는 프로세스 메모리에만 있어, 앱 재실행 시 다시 만들어짐. 이번 범위에서 제외

### 📌 참고사항
- 관련: #618(잠금 화면 게임 현황 표시), DEC-0089(서버 푸시 없음)
- 범위 제외: 닫힘 상태의 재실행 간 보존
- 후속 확인 항목: 백엔드 시작 시각 통일 변경 배포, 실기기에서 `startAt` 일치·재실행 이어받기·오프라인 유지 확인
