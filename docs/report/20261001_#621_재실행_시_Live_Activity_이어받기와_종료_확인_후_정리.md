### 📌 작업 개요
iOS에서 앱을 다시 실행해도 **같은 게임·같은 라운드의 Live Activity(잠금 화면 카드)를 이어받고, 게임 종료가 확인됐을 때만 정리**하도록 변경. 실행 시 모든 Activity를 닫던 `endAll()`을 `restore()`(종료 시각이 지난 Activity만 정리)로 바꾸고, 정리 시점을 "서버가 진행 중 게임 없음을 확인한 때"로 옮김.

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
| 상태 조회 실패 | — | 종료로 보지 않음 |

### 🔍 문제 분석
`AppDelegate`가 실행할 때마다 `endAll()`로 모든 Activity를 닫았음. 강제 종료 뒤 이전 게임 카드가 남는 것을 막으려던 처리였으나, 게임 중 재실행에서도 카드가 사라짐. iOS는 백그라운드에서 Live Activity를 새로 시작할 수 없어(`ActivityAuthorizationError.visibility`) 앱을 앞으로 가져오기 전까지 표시가 비어 있었음.

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

### 🔧 주요 변경사항 상세

#### GameStatusActivityManager.update 흐름
1. 이전 값과 `gameId` 또는 `startAt`이 다르면 추적 상태(`currentActivityID`, `endedExternally`)를 초기화
2. `endAt`이 지났으면 `stop()` 후 종료
3. 이미 외부에서 닫힌 라운드(`endedExternally`)면 아무것도 하지 않음
4. `gameId`+`startAt`이 같은 Activity가 있으면 채택(`active`/`stale`일 때만), 없으면 새로 요청
5. 채택하지 않은 Activity는 모두 종료

**특이사항**:
- 이어받기에 실패하면 "닫고 새로 만들기"로 동작하며, 백그라운드에서는 시작이 막혀 앱이 앞으로 올 때까지 표시가 없을 수 있음
- `AppDelegate`의 `update`·`stop`은 `Task` 예약 없이 `MainActor.assumeIsolated`로 즉시 실행(기존 방식 유지). 순서가 뒤바뀌어 끝난 게임의 Activity가 되살아나는 것을 막기 위함

### 🧪 테스트 및 검증
- **Dart**: `test/core/services/background/method_channel_background_service_test.dart` 12개 테스트 통과 확인
  - 재시작 직후 `stop()`이 네이티브까지 전달되고 이후 반복 호출은 무시되는지
  - `update`에 `gameId`가 실리는지
  - 시작 전 `update`는 보관했다가 시작 직후 한 번 전송되는지
- **Swift `ios/RunnerTests/RunnerTests.swift`**: 아래 5개 시나리오 작성. **미실행**
  - 매니저 재생성 후에도 기존 Activity ID 유지(이어받기)
  - 종료 시각이 지난 라운드는 Activity를 만들지 않음
  - 같은 게임의 다른 라운드(`startAt` 불일치)는 기존 Activity를 종료하고 교체
  - 재실행 후 `stop()`이 남은 Activity를 제거
  - 앱 밖에서 닫힌 Activity는 같은 라운드에서 다시 만들지 않음
- **실기기**: 미실행. 아래 위험 항목은 실기기 확인 전까지 가정 상태

### ⚠️ 알려진 위험
- **`startAt` 밀리초 일치**: 처음 만든 카드는 STOMP START의 `startTime`, 재실행 뒤에는 REST `gameStartTime`을 사용. 두 값의 포맷·정밀도가 밀리초까지 같지 않으면 이어받지 못하고 "닫고 새로 만들기"로 동작. 이 경우 백그라운드 재실행에서는 카드가 비는 기존 증상이 남음
- **`authUser == null` 경로**: 스플래시의 `authUser == null`이 일시적 오프라인이나 토큰 갱신 실패로도 발생하는지 미확인. 그렇다면 진행 중인 게임의 카드가 닫힘
- **닫힘 상태가 프로세스 수명**: 사용자가 밀어서 닫은 카드의 `endedExternally`는 프로세스 메모리에만 있어, 앱 재실행 시 다시 만들어짐. 이번 범위에서 제외

### 📌 참고사항
- 관련: #618(잠금 화면 게임 현황 표시), DEC-0089(서버 푸시 없음)
- 범위 제외: 닫힘 상태의 재실행 간 보존
- 후속 확인 항목: Swift `RunnerTests` 실행, 실기기에서 `startAt` 일치와 재실행 이어받기 확인
