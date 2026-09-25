### 📌 작업 개요

WebSocket 재연결 후 경찰 대기시간이 지났는데도 체포 불가로 판정되는 버그 수정. STOMP 이벤트 기반 판단에 시간 비교 fallback을 추가하여 재연결 여부와 관계없이 정확한 체포 가능 판단 보장

### 🔍 문제 분석

게임 중 앱을 백그라운드로 전환하거나 화면을 끄면 WebSocket이 끊김. 복귀 시 재연결되지만 서버가 과거 `POLICE_MOVE_START` 이벤트를 재전송하지 않음. 기존 체포 판단 로직은 이 이벤트 수신 여부(`isPoliceMoving`)에만 의존했기 때문에, 재연결 후에는 `isPoliceMoving = false`로 남아 체포 불가로 판정됨

**기존 로직:**
- `canArrest = isPoliceMoving || policeWaitMinutes == 0`
- 이벤트 미수신 시 항상 `false` → 체포 불가

### 🎯 구현 목표

- STOMP 이벤트 + 시간 기반 판단을 병행하여 재연결 시에도 정확한 체포 가능 판단
- 게임 종료 미감지 원인 조사를 위한 디버그 로그 추가

### ✅ 구현 내용

#### 1. 체포 가능 판단에 시간 기반 fallback 추가
- **파일**: `lib/features/game/presentation/widgets/participant_overlay.dart`
- **변경 내용**: 기존 `isPoliceMoving` 이벤트 판단에 `gameStartTime + policeWaitMinutes` 시간 비교 조건 추가. `gameStartTime`은 STOMP 이벤트 값 우선, 없으면 API 응답의 `participantInfo.gameStartTime` 사용
- **이유**: 재연결 시 STOMP 이벤트를 못 받아도 서버에서 받은 게임 시작 시각과 대기 시간으로 정확하게 판단 가능

**변경된 판단 로직:**
- 1차: `isPoliceMoving` (STOMP 이벤트 수신 시 즉시 판단)
- 2차: `DateTime.now() >= gameStartTime + policeWaitMinutes` (시간 기반 fallback)
- 3차: `policeWaitMinutes == 0` (대기시간 없는 경우)

#### 2. 시간 비교 경계값 보정
- **파일**: `lib/features/game/presentation/widgets/participant_overlay.dart`
- **변경 내용**: `isAfter` → `!isBefore`로 변경
- **이유**: 대기시간 종료 정각에도 체포 가능하도록 경계값 포함 (`>=` 의미)

#### 3. 게임 종료 감지 디버그 로그 추가
- **파일**: `lib/features/game/presentation/pages/game_page.dart`
- **변경 내용**: `_checkGameStatusOnResume()` 메서드에 각 분기별 디버그 로그 추가 (함수 진입, API 응답, 분기 결과, 에러)
- **이유**: 백그라운드 복귀 시 게임 종료 미감지 문제의 원인 조사. 기존 `catch(_)`가 에러를 무시하고 있어 실패 원인 파악 불가했음

### 🔧 주요 변경사항 상세

#### participant_overlay.dart — 체포 판단 로직
기존에는 `gameEventNotifierProvider`의 `isPoliceMoving`만 확인했으나, 추가로 `gameParticipantNotifierProvider`의 `gameStartTime`과 `policeWaitMinutes`를 읽어 시간 비교 수행. STOMP 이벤트의 `gameStartTime`을 우선 사용하고, 없으면 API에서 받은 문자열을 파싱하여 fallback

**특이사항**:
- `gameStartTime`은 두 소스(STOMP 이벤트 / API 응답)에서 가져올 수 있으며, STOMP 이벤트 값이 우선
- 서버 타임스탬프에 `+09:00` KST 오프셋이 포함되어 있어 `DateTime.parse`로 올바르게 처리됨

#### game_page.dart — 디버그 로그
`_checkGameStatusOnResume` 내 모든 분기에 `debugPrint`로 상태 출력. 콘솔에서 `[GamePage]` 접두어로 필터링 가능

### 📌 참고사항

- **게임 종료 미감지**: `_checkGameStatusOnResume()`이 이미 구현되어 있으나 실제 동작 여부 미확인 상태. 디버그 로그로 원인 파악 후 후속 조치 예정
- **백그라운드 위치 추적**: iOS 앱 심사 제약으로 백그라운드 모드는 현재 적용하지 않음. 복귀 시 재연결 구조 유지
- **디버그 로그**: 원인 파악 완료 후 제거 예정
