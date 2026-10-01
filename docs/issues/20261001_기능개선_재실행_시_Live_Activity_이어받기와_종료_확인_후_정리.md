# 🚀 [기능개선][iOS][잠금화면] 재실행 시 Live Activity 이어받기와 종료 확인 후 정리

## 🔥 구현 기능

앱을 다시 실행해도 **같은 게임·같은 라운드의 Live Activity를 이어받고, 게임 종료가 확인됐을 때만 정리**한다.

| 상황 | 지금 | 변경 후 |
|---|---|---|
| 게임 중 앱 재실행 | 실행 즉시 모든 Activity를 닫고 새로 만든다 | 진행 중인 Activity를 남기고, 게임 복원 후 첫 `update`가 이어받는다 |
| 이어받을 대상 판별 | 없음 | `gameId` + `startAt`이 모두 같은 Activity (같은 방의 새 라운드와 구분) |
| 종료 시각이 지난 Activity | 실행 때 일괄 종료 | 실행 때 종료 (`restore()`) |
| 서버가 "진행 중 게임 없음"으로 확인 | 처리 없음 | 스플래시·홈에서 `stop()` |
| 비로그인 상태 | 처리 없음 | 스플래시에서 `stop()` |
| 상태 조회 실패 | — | 종료로 보지 않고 그대로 둔다 |

<br>

## 📝 현재 문제점

`AppDelegate`가 실행할 때마다 `GameStatusActivityManager.endAll()`로 모든 Activity를 닫는다(`ios/Runner/AppDelegate.swift:25-28`). 강제 종료 뒤 이전 게임 카드가 남는 것을 막으려던 것인데, 게임 중에 앱이 재실행돼도 잠금 화면 카드가 사라지고 앱을 앞으로 가져와야 다시 만들어진다. iOS는 백그라운드에서 Live Activity를 새로 시작할 수 없어(`ActivityAuthorizationError.visibility`) 그동안 표시가 없다.

<br>

## 🛠️ 해결 방안

| 영역 | 변경 |
|---|---|
| iOS `AppDelegate` | `endAll()` 대신 `restore()` — `endAt`이 지난 Activity만 닫는다 |
| iOS `GameStatusAttributes` | `gameId: Int?` 추가 (옛 버전 Activity도 디코딩되도록 optional) |
| iOS `GameStatusActivityManager` | `update()`가 `gameId`+`startAt`이 같은 Activity를 채택해 닫힘 감시를 붙이고 갱신, 나머지는 종료. `endAt`이 지났으면 `stop()`. `dismissedByUser` → `endedExternally` (ActivityKit은 사용자·시스템 제거를 구분하지 않음) |
| Dart `MethodChannelBackgroundService` | `_isRunning`을 `bool?`로 — 재시작 직후(`null`)에는 OS에 이전 Activity가 남아 있을 수 있어 `stop()`이 네이티브까지 전달된다. `update`에 `gameId`를 싣는다 |
| Dart 스플래시·홈 | 비로그인이거나 서버가 진행 중 게임이 없다고 확인한 경우에만 `stop()` |

> [!IMPORTANT]
> `startAt`이 밀리초 단위까지 같아야 이어받는다. 처음 만든 카드는 STOMP START의 `startTime`, 재실행 뒤에는 REST `gameStartTime`을 쓰므로 두 값이 같은지 실기기 확인이 필요하다. 다르면 이어받기 대신 "닫고 새로 만들기"가 된다.

<br>

## ❓ 확인 필요

- STOMP START `startTime`과 REST `gameStartTime`의 포맷·정밀도 일치 (실기기)
- 스플래시의 `authUser == null`이 일시적 오프라인·토큰 갱신 실패로도 생기는지 — 그렇다면 진행 중인 카드가 닫힌다
- 사용자가 밀어서 닫은 카드는 앱 재실행 시 다시 만들어진다(닫힘 기억은 프로세스 수명) — 이번 범위 밖

<br>

## 📌 참고

- 관련: #618 (잠금 화면 게임 현황 표시), 방침 DEC-0089 (서버 푸시 없음 — 앱이 꺼진 채 끝난 게임의 카드는 다음 실행 때 정리)
- 범위 제외: 닫힘 상태의 재실행 간 보존
