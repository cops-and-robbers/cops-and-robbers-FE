# 재연결 모달 종료 후 구역 이탈 팝업 복구 설계

> **작성일**: 2026-04-19
> **이슈**: `.issues/20260419_버그_게임스크린_팝업_중첩_사라짐.md`
> **브랜치**: `20260419_#268_재연결_팝업이_닫힐_때_플레이그라운드_이탈_팝업도_함께_사라짐`

---

## 1. 문제 정의

### 현상

게임 화면에서 플레이그라운드를 벗어나면 `AppPopup`으로 "플레이그라운드를 벗어났어요!" 경고 팝업이 표시된다.

이 경고 팝업이 떠 있는 상태에서 웹소켓 연결이 끊기면 `ReconnectModal`이 스택 위로 올라오는데, 재연결 성공 등으로 `ReconnectModal`이 닫히면 **유저가 여전히 구역 밖인데도 이탈 경고 팝업이 복구되지 않는다**.

### 기대 동작

재연결 모달이 닫힌 시점에 유저가 여전히 플레이그라운드 밖이면 이탈 경고 팝업이 다시 표시되어야 한다. 구역으로 복귀한 상태라면 아무 팝업도 뜨지 않아야 한다.

---

## 2. 원인 분석

`lib/features/game/presentation/pages/game_page.dart` 의 현재 흐름:

1. `_showReconnectModalIfNeeded()` 진입 시, 스택 충돌 방지를 위해 `_dismissZoneExitPopup()` 으로 이탈 팝업을 강제로 닫는다.
2. `ZoneExitDetector`는 상태 **전환**(안→밖, 밖→안) 시에만 콜백을 발화한다. 이미 밖인 상태는 재감지되지 않는다.
3. 재연결 모달 종료 후 `_processPendingZoneExit()`이 실행되지만, 이 함수는 `_pendingZoneExit` 플래그가 `true`일 때만 팝업을 복구한다.
4. `_pendingZoneExit` 는 "재연결 모달이 떠 있는 동안 **새로** 이탈한 경우"에만 세팅된다. "이미 이탈 중이었는데 모달이 떠서 강제로 닫힌 경우"에는 세팅되지 않는다.

결과적으로 모달 종료 후 복구 경로가 끊긴다.

---

## 3. 해결 설계 (Option A)

### 3.1 변경 지점

`_showReconnectModalIfNeeded()` 에서 `_dismissZoneExitPopup()` 을 호출하기 직전에, **이탈 팝업이 현재 표시 중**이거나 **Detector가 `isOutside` 상태**라면 `_pendingZoneExit = true` 로 세팅한다.

### 3.2 로직 흐름

```
_showReconnectModalIfNeeded()
  ├─ (조기 반환: 이미 모달 표시 중 / 게임 종료 / 연결 정상)
  ├─ [추가] if (_isZoneExitPopupShown || _zoneExitDetector.isOutside)
  │         _pendingZoneExit = true
  ├─ _dismissZoneExitPopup()
  └─ ReconnectModal.show(...).then((_) {
       _isReconnectModalShown = false
       _showReconnectModalIfNeeded()  // 재귀
     })

ReconnectModal 종료 후 재귀 진입 시:
  └─ 연결 정상이면 _processPendingZoneExit() 실행
      └─ _pendingZoneExit == true && isOutside == true
         → 진동 + _showZoneExitPopup()
```

### 3.3 보류 플래그 의미 확장

기존:
- `_pendingZoneExit`: "재연결 모달 중 **새로 이탈한 이벤트**가 있었음"

변경 후:
- `_pendingZoneExit`: "재연결 모달 종료 시점에 **이탈 팝업을 복구해야 함**"
  - 기존 케이스(모달 중 새 이탈)도 포함
  - 신규 케이스(모달 진입 시점에 이미 이탈 중)도 포함

의미 확장이 자연스럽고, 기존 `_processPendingZoneExit()` 의 검사 로직 (`_pendingZoneExit && _zoneExitDetector.isOutside`) 은 변경 없이 그대로 재사용된다.

---

## 4. 영향 범위

### 수정 파일

- `lib/features/game/presentation/pages/game_page.dart`
  - `_showReconnectModalIfNeeded()` 메서드 내부 한 줄 추가
  - 주석 업데이트 (`_pendingZoneExit` 변수 설명)

### 테스트 파일

- 신규: 재연결 모달 종료 후 이탈 팝업 복구를 검증하는 위젯 테스트 또는 단위 테스트
- 기존: `test/core/widgets/dialogs/zone_exit_popup_dismiss_test.dart` 는 영향 없음

### 영향 없는 영역

- `ZoneExitDetector` 내부 로직 (변경 없음)
- `ReconnectModal`, `AppPopup` 위젯 (변경 없음)
- 게임 종료/체포/경찰 이동 시작 등 다른 이벤트 처리 경로 (변경 없음)

---

## 5. 엣지 케이스

| # | 시나리오 | 동작 |
|---|---------|------|
| 1 | 구역 안 → 웹소켓 끊김 → 재연결 성공 | 모달만 닫힘, 이탈 팝업 없음 (기존과 동일) |
| 2 | 구역 안 → 모달 중 이탈 → 재연결 성공 | 모달 닫힘 후 이탈 팝업 표시 + 진동 (기존과 동일) |
| 3 | **구역 밖(이탈 팝업 표시 중) → 웹소켓 끊김 → 재연결 성공** | **모달 닫힘 후 이탈 팝업 복구 + 진동 (이번 수정의 목표)** |
| 4 | 구역 밖(이탈 팝업 표시 중) → 웹소켓 끊김 → 구역 복귀 → 재연결 성공 | 복귀 시점에 `onEnterZone` 콜백이 `_pendingZoneExit = false`로 리셋 → 모달 닫힘 후 아무 팝업 없음 (기존 로직으로 처리됨) |
| 5 | 재연결 실패 → 여러 번 재시도 | `_showReconnectModalIfNeeded()` 재귀 호출로 모달 유지, `_pendingZoneExit` 플래그는 유지됨. 최종 재연결 성공 시 이탈 팝업 복구 |
| 6 | 게임 종료 중 재연결 모달 닫힘 | `_gameOverDialogShown || isGameOver` 체크로 조기 반환, 이탈 팝업 복구하지 않음 (기존과 동일) |
| 7 | 체포 상태에서 구역 밖 | `_checkZoneExit()` 에서 체포된 참가자는 조기 반환 → detector `isOutside` 갱신 안 됨. 그러나 이미 팝업이 떠 있었다면 `_isZoneExitPopupShown` 체크로 보류 플래그 세팅됨. 체포 상태는 팝업을 복구해도 무방 (이탈 경고는 체포 여부와 무관한 정보) |

엣지 케이스 #4 는 타이밍 의존성이 있다:
- 위치 스트림이 구역 복귀를 감지 → `onEnterZone` 콜백 → `_pendingZoneExit = false`
- 이 콜백은 재연결 모달과 무관하게 동작하므로 보류 플래그가 정확히 리셋된다.

엣지 케이스 #7 은 현재 구현의 한계이며, 이번 변경 범위에서는 추가 처리하지 않는다 (별도 이슈 후보).

---

## 6. 검증 방법

### 수동 테스트

1. 게임 화면 진입
2. 플레이그라운드 밖으로 이동 → 이탈 경고 팝업 확인
3. (시뮬레이터/실기기에서) 네트워크 일시 차단 → 재연결 모달 확인
4. 네트워크 복구 → 재연결 모달 닫힘
5. **이탈 경고 팝업이 다시 표시되는지 확인** (기대)
6. 구역으로 복귀 → 이탈 팝업 자동 닫힘 확인

### 자동화 테스트

`_pendingZoneExit` 는 private 필드이므로 직접 검증하기 어렵다. 대신 `_showReconnectModalIfNeeded` 진입 시의 조건 분기 로직을 단위 테스트로 추출하거나, 위젯 테스트에서 팝업 복구를 검증한다.

- **위젯 테스트 (권장)**: `GamePage` 마운트 → 이탈 상태 주입 → 연결 상태를 `disconnected` 로 변경 → 모달 표시 확인 → `connected` 로 복구 → 이탈 팝업 재표시 확인
- 기존 테스트 `test/core/widgets/dialogs/zone_exit_popup_dismiss_test.dart` 와 유사한 스타일로 작성

---

## 7. 리스크

| 리스크 | 완화 방법 |
|--------|----------|
| 보류 플래그 세팅 조건 오판 → 의도치 않게 팝업 복구 | 엣지 케이스 테스트로 검증. `_processPendingZoneExit()` 내부의 `isOutside` 재확인으로 이중 방어 |
| 재연결 모달 종료 후 즉시 구역 복귀 시 타이밍 이슈 | `onEnterZone` 이 `_pendingZoneExit = false` 로 리셋하므로 안전 |
| 진동이 사용자에게 과도하게 발생 | `_processPendingZoneExit` 에서 진동은 팝업 복구 시점에만 한 번 발화 — 기존 동작과 동일 |

---

## 8. 범위 외 (Out of Scope)

- `ZoneExitDetector` 리팩토링 (forceReevaluate 등)
- 재연결 모달의 다른 UX 개선
- 체포 상태에서의 구역 이탈 처리 개선
- 이탈 팝업 자체의 디자인 변경

---

## 9. 요약

`_showReconnectModalIfNeeded()` 진입 시점에 이탈 팝업이 표시 중이거나 Detector가 `isOutside` 상태라면 `_pendingZoneExit = true` 로 세팅하여, 재연결 모달 종료 후 `_processPendingZoneExit()` 이 이탈 팝업을 복구하도록 한다. 변경은 단일 조건문 추가와 주석 업데이트로 끝나며, 기존 플래그 의미를 자연스럽게 확장한다.
