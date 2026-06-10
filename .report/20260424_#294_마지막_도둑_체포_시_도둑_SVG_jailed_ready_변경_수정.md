# #294 마지막 도둑 체포 시 도둑 캐릭터 SVG가 jailed → ready 로 바뀌는 문제 수정

### 📌 작업 개요

경찰이 마지막 도둑을 체포하여 게임이 종료되는 순간, 참가자 목록 오버레이의 도둑 아바타가 jailed.svg 로 바뀌었다가 곧바로 ready.svg 로 되돌아간 채 결과 다이얼로그가 닫힐 때까지 유지되는 UI 버그를 수정.

`GameEventNotifier.disconnect()` 가 state 를 통째로 리셋하면서 `arrestedParticipantIds` 가 비워지고, 그 순간 stale 한 참가자 데이터와 결합되어 도둑 상태가 ALIVE 로 잘못 계산되던 문제를 해결.

### 🔍 문제 분석

#### 증상

1. 참가자 목록 오버레이를 연 상태에서 마지막 도둑 체포
2. 낙관적 업데이트로 도둑 아바타가 jailed.svg 로 전환 ✅
3. STOMP `GAME_OVER` 수신 → `_showGameOverDialog` 호출
4. `disconnect()` 내부의 `state = const GameEventState()` 가 `arrestedParticipantIds` 를 빈 집합으로 초기화
5. 오버레이 리빌드 시 `_effectiveRobberStatus` 가 ALIVE 로 계산 → ready.svg 렌더링
6. 결과 다이얼로그 종료까지 복구되지 않음

#### 근본 원인

`disconnect()` 가 STOMP 구독 해제와 동시에 시각 상태(체포·탈옥·위치 등)까지 리셋한다. 게임 오버 팝업 시퀀스 동안 `ParticipantOverlay` 가 여전히 마운트 상태이므로, 비워진 `arrestedParticipantIds` 와 API 응답이 반영되기 전의 `_participants` 가 조합되어 JAILED → ALIVE 오판정을 유발.

### ✅ 구현 내용

#### GameEventNotifier.disconnect() 동작 변경

- **파일**: `lib/features/game/presentation/providers/game_event_provider.dart`
- **변경 내용**: `state = const GameEventState()` 를 `state.copyWith(connectionState: disconnected, errorMessage: null)` 로 교체. 시각 상태(`arrestedParticipantIds`·`escapedParticipantIds`·`robberLocations` 등) 보존.
- **이유**: 게임 종료 시퀀스에서 참가자 목록 오버레이가 마지막 체포 스냅샷을 유지하도록 하기 위함. 전체 상태 초기화는 provider autoDispose 에 위임 (페이지 dispose 시 자동 정리).

#### game_page.dart 의 stale 주석 정리

- **파일**: `lib/features/game/presentation/pages/game_page.dart`
- **변경 내용**: `_showGameOverDialog` 내부의 "disconnect() 가 state 를 리셋하므로 gameResultId 를 먼저 읽어야 한다" 주석 제거. 새 동작(시각 상태 보존) 을 설명하는 주석으로 교체.
- **이유**: 순서 제약이 사라졌으므로 잘못된 경고가 남지 않도록 현행화.

### 🔧 주요 변경사항 상세

#### GameEventNotifier.disconnect()

기존에는 STOMP 관련 리소스 정리 후 `state = const GameEventState()` 로 전체를 초기화. 이제는 다음 한 줄로 대체.

```dart
state = state.copyWith(
  connectionState: StompConnectionState.disconnected,
  errorMessage: null,
);
```

타이머·구독·내부 플래그(_gameId, _pendingArrestId 등) 정리는 기존과 동일하게 수행. STOMP 소켓은 `gameEventStompDatasourceProvider.disconnect()` 로 끊는다.

**특이사항**:

- 이 메서드의 호출처는 `game_page.dart:1011` 의 `_showGameOverDialog` 한 곳뿐 (dispose 경로는 datasource 를 직접 참조). 따라서 동작 변경의 영향 범위가 좁음.
- autoDispose provider 특성상 `game_page` 를 벗어나면 상태가 자동 정리되므로 다음 게임 진입 시 누수 위험 없음.

#### game_page.dart `_showGameOverDialog`

```dart
// 변경 전: "disconnect() 가 state 리셋하므로 먼저 읽기" 경고 주석
// 변경 후: "disconnect() 는 시각 상태 보존, 오버레이가 마지막 체포 스냅샷 유지" 설명
```

`ref.invalidate(chatNotificationEnabledProvider)` 호출 흐름도 순서 제약이 사라져 의미 명확화.

### 📦 의존성 변경

없음. 코드 생성 어노테이션이나 Freezed 클래스 정의 수정 없음 → `build_runner` 재실행 불필요.

### 🧪 테스트 및 검증

- `flutter analyze lib/features/game/presentation/providers/game_event_provider.dart lib/features/game/presentation/pages/game_page.dart` → `No issues found!`
- 기존 `GameEventNotifier` 단위 테스트는 존재하지 않음. 수동 시나리오 검증 필요.

#### 수동 검증 시나리오

1. 경찰 2명·도둑 1명 매칭
2. 경찰 플레이어가 참가자 목록(사람 아이콘) 오버레이를 연 상태 유지
3. 마지막 도둑 체포 (QR 스캔 또는 디버그 카드 탭)
4. 체포 직후 도둑 아바타가 `jailed.svg` 로 바뀌는지 확인
5. "게임 종료!" 팝업이 뜨는 동안 배경 오버레이의 도둑 아바타가 **jailed 상태를 유지**하는지 확인 (핵심 회귀 확인 포인트)
6. 결과 다이얼로그 "홈으로" → 페이지 dispose 후 재진입 시 오버레이 초기 상태 정상 확인

### 📌 참고사항

- 부가 효과: 이전에는 disconnect() 시 `robberLocations` 도 함께 비워져 지도 위 마지막 reveal 위치·발자국이 사라졌을 수 있음. 이제는 결과 다이얼로그 종료 전까지 지도 상 마지막 위치가 유지됨. 의도된 UX 와 일치하는지 디자인 확인 권장.
- 향후 같은 계열 회귀 방지를 위해 `GameEventNotifier` 단위 테스트 스캐폴딩 추가 고려 (STOMP datasource fake + ARREST/GAME_OVER 시퀀스 재현).

### 📁 관련 커밋

- `09921d2` — fix : 게임 종료 시 참가자 목록 도둑 SVG가 ready로 바뀌는 문제 수정 #294
