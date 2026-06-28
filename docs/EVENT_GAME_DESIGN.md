# 이벤트 게임 모드 — 구현 설계 (프론트엔드)

> **작성일**: 2026-06-24
> **이슈**: `.issues/20260623_기능추가_이벤트_게임_모드_로직_분기.md` (#443)
> **참고 스펙**: [EVENT_GAME_spec.md](EVENT_GAME_spec.md) (프론트엔드 검토 완료본)
> **상태**: 설계 확정 (코드 검증 완료) → 구현 계획 수립 단계
>
> 본 문서는 *무엇을 / 어떻게* 바꿀지에 대한 아키텍처 설계서다. 단계별 작업 순서(plan)는 별도 구현 계획에서 다룬다.
> 모든 변경 지점은 실제 코드(`file:line`)에 대조해 검증했다.

---

## 1. 개요 & 시나리오

행사장용 **이벤트 게임 모드**. **운영진 = 도둑(고정 타겟), 사용자 = 경찰.**

- 사용자가 QR로 방 참가 → **대기실/준비 단계 없이 인게임 직행**.
- 운영진(도둑)은 잡혀도 **감옥에 가지 않고 ALIVE 유지**, 계속 도망 → 경찰이 QR로 계속 체포.
- 체포할 때마다 **증거 SVG가 1개씩 공개**(증거 수집 메커닉), 결과 화면에서 **증거 보드 + "운영진 N명 검거"** 표시.

이벤트 모드는 **코드량·체감의 ~8할이 프론트** 몫이며, 백엔드 코어(§8) 없이는 동작하지 않는다.

---

## 2. 확정 결정 요약

| # | 항목 | 결정 |
| --- | --- | --- |
| D1 | 라우팅 | `join` 응답 `isEventGame==true` → 로비/대기실 스킵 → 인게임(경찰) 직행 |
| D2 | 인게임 분기 단일 소스 | `GameParticipantInfo.isEventGame` (신규 필드). 모든 인게임 분기가 여기 하나만 읽음 |
| D3 | isEventGame 백엔드 출처 | (a) `join` 응답 = 라우팅 결정, (b) `GET /api/games/{id}` 설정 = 인게임/콜드 재진입 복원 |
| D4 | 체포 카운트/재체포 | 경찰 **로컬 집합 `myArrestedRobberIds`** 로 처리, **전역 수감 집합과 분리** |
| D5 | 영속화 | `shared_preferences` **단일 레코드** `{gameId, arrestedRobberIds:[]}`. 같은 게임 복원 / 다른 게임 자동 리셋 |
| D6 | 재진입 | 같은 게임 재진입 시 복원. 별도 "나가기 시 삭제" 로직 불필요 |
| D7 | 도둑 ALIVE UI | 이벤트 모드면 잡혀도 ALIVE — 감옥 잠금 오버레이·탈옥 버튼 비활성 |
| D8 | 체포 피드백 | 확인 모달 없음(QR=대면확인). 체포 **성공** 다이얼로그 + `evidence{N}.svg` 공개(N = 검거 집합 크기) |
| D9 | 결과 화면 | **증거 보드**(수집=선명+핀, 미수집=50% 흐림+가운데 자물쇠) + "운영진 N명 검거". **로컬 전용**(서버 통계 비의존) |
| D10 | 선개발 | **dev 플래그로 `isEventGame=true` 강제**해 백엔드 전 프론트 선개발·검증 |

---

## 3. 아키텍처 핵심

### 3.1 `isEventGame` 단일 소스 — `GameParticipantInfo`

인게임의 모든 분기(도둑 UI/체포/결과)는 **`GameParticipantInfo.isEventGame`** 하나만 읽는다.

- `game_page._initSettingsFromApiIfNeeded()`(`game_page.dart:408-456`)가 **모든 진입 경로**(딥링크 직행 / 콜드 재진입 / 활성 게임 리다이렉트)에서 `GET /api/games/{id}` 설정을 받아 `GameParticipantInfo`를 채운다.
- 따라서 **설정 응답에 `isEventGame`이 포함되면** 어느 경로로 들어와도 인게임 분기가 자연스럽게 복원된다 → **가장 견고한 단일 소스**.
- `join` 응답의 `isEventGame`은 **라우팅 스킵 결정**(로비 vs 인게임)에만 쓴다.

> 현재 `GameParticipantInfo`(`game_participant_provider.dart:11-198`)와 `GameSettingsResponse`(`game_settings_response.dart:20-43`)에 `isEventGame` **없음 → 추가**.

### 3.2 전역 수감 집합 vs 경찰 로컬 검거 집합 (분리)

| 집합 | 역할 | 이벤트 모드 동작 |
| --- | --- | --- |
| `GameEventState.arrestedParticipantIds` (`game_event_provider.dart:57-61`) | 도둑 **잠금/탈옥 UI**, 재동기화 시 서버 스냅샷(JAILED)으로 **통째 덮어쓰기**(`game_page.dart:629`) | **건드리지 않음** — 도둑 ALIVE 유지, 카운트 보존 |
| `GameEventState.myArrestedRobberIds` *(신규)* | 경찰이 **내가 잡은 도둑**(검거 카운트/재체포/증거 인덱스) | 인게임 진입 시 load, 내 체포 성공 시 add + persist |

이 분리가 핵심이다. 검증에서 `_syncGameStateOnReconnect → syncFromParticipants()`가 `arrestedParticipantIds`를 서버 상태로 **완전히 덮어쓰는 것**(`game_page.dart:569-631`)을 확인했다. 이벤트 카운트를 전역 집합에 얹으면 백그라운드 복귀/재연결 시 **소실**된다. 별도 영속 집합으로 분리해야 안전하다.

### 3.3 증거 인덱스 = 검거 집합 크기

- 운영진 participantId는 게임마다 바뀌므로 **도둑별 고정 매핑 불가** → **체포 순서 기반**.
- N번째 체포 시 `assets/events/evidence{N}.svg` 공개. N = `myArrestedRobberIds.length` (Set이라 중복 자동 제거 → 재접속 복원과도 정합).

---

## 4. 데이터 모델

### 4.1 신규: `EventArrestStorage` (shared_preferences 단일 레코드)

```
키 1개: "event_game_arrest"
값(JSON): { "gameId": 17, "arrestedRobberIds": [20, 21] }
```

- `load()`: 저장된 `gameId == 현재 gameId` → `arrestedRobberIds` 복원 / 불일치·손상 → **기존 레코드 제거** 후 빈 집합 반환(부활 방지·자동 리셋 보장). 이 제거 부수효과는 진입 시 `loadMyArrests`가 체포 가능 시점 이전에 await되어 신규 체포 저장과 경쟁하지 않는다.
- `save(gameId, ids)`: 현재 게임 기준 덮어쓰기
- 카운트 = 집합 크기. 별도 "나가기 시 삭제" 불필요(다른 게임 입장 시 자동 리셋).
- 패턴: `lib/core/i18n/locale_provider.dart:68`의 `SharedPreferences.getInstance()` 사용례 참고. Riverpod `@Riverpod(keepAlive: true)` 프로바이더로 노출.

> 위치 제안: `lib/features/game/data/services/event_arrest_storage.dart`

### 4.2 변경: 모델/상태 필드 추가

| 대상 | 변경 |
| --- | --- |
| `JoinGameResponse` (`join_game_response.dart:18-29`) | `isEventGame: bool` 추가 (기본 false) |
| `GameJoinResult` (`game_join_result.dart:10-18`) | `isEventGame: bool` 추가 |
| `GameSettingsResponse` (`game_settings_response.dart:20-43`) | `isEventGame: bool` 추가 (콜드 재진입 복원용) |
| `GameParticipantInfo` (`game_participant_provider.dart:11-198`) | `isEventGame: bool` 추가 + `copyWith`/`setGameInfo`/`initFromLobby` 반영 |
| `GameEventState` (`game_event_provider.dart`) | `myArrestedRobberIds: Set<int>` 추가 |

> freezed/riverpod 모델 변경 후 `dart run build_runner build --delete-conflicting-outputs` 필수.
> `isEventGame`은 **기본값 `false`** 로 추가하고, `GameParticipantInfo`의 모든 생성/복사 지점(const 생성자 `:44-56`, `setGameInfo`, `initFromLobby`, `copyWith`)에서 누락 없이 처리한다. `isEventGame`은 **게임 도중 불변**(SETTINGS_UPDATED로 바뀌지 않음).

---

## 5. 흐름별 설계

### 5.1 라우팅 — 로비 스킵 인게임 직행

전파 경로: `JoinGameResponse.isEventGame` → `session_repository_impl.joinGameByInvite`(`:116-124`) → `GameJoinResult.isEventGame` → `deeplink_join_notifier`의 `JoinedRoomOutcome`(`:91-95`)에 `isEventGame` 추가.

분기 지점 2곳:
- **딥링크**: `deeplink_join_page.dart:110-116` — 현재 항상 `waitingRoomWithId`. → `isEventGame==true`면 `gameWithId` 직행.
- **홈 코드/QR 입장**: `home_page`에는 네비게이션 지점이 둘 — ① 신규 join 성공 후, ② 활성 게임 리다이렉트(`_checkActiveGameAndRedirect`). **두 지점 모두** `isEventGame==true`면 게임 직행을 지키도록 점검(정확한 라인은 구현 시 grep으로 확정). 단, 콜드 재진입/활성 게임은 어차피 `game_page`가 설정 API에서 `isEventGame`을 복원하므로(§5.2), 라우팅이 게임 화면으로만 가면 인게임 분기는 보장된다.

직행 라우트 = `gameWithId(gameId) + "?team=POLICE&pid={participantId}"`.
- game 라우트는 이미 `team`(기본 police)·`pid`(기본 1) 지원(`app_router.dart:543-546`), `GamePage(sessionId, team, participantId, isDummy)` 시그니처(`game_page.dart:78-96`).
- 사용자=경찰이므로 `team=POLICE` 고정. (운영진=도둑의 앱 진입 경로는 §9 미해결.)

콜드스타트 정합: `splash_page.dart:172-179`가 `InviteJoinEvent` 감지 시 네비게이션을 `deeplink_join_page`에 양보. 이벤트 분기를 **`deeplink_join_page`의 outcome 처리 안에** 두면 기존 콜드스타트 경합([project_deeplink_coldstart_race] 이력) 회피가 유지된다.

### 5.2 인게임 부트스트랩 & isEventGame 전파

✅ 진입 순서 검증됨(`game_page.dart:204-299`): `initState → _ensureLocationAndInit → _initGameConnections`. 그 안에서 `await _initSettingsFromApiIfNeeded()`(participantInfo 충전) → `_connectGameEvents()`(STOMP 구독) → `_loadGameArea()`. **participantInfo가 STOMP 구독보다 먼저 채워짐**이 보장된다(중간 입장 포함).

- `_initSettingsFromApiIfNeeded`(`:408-456`): state가 null이면 `setGameInfo`로 기본값(`:421-429`) → `GET /{id}` 응답으로 `initFromLobby`(`:434-441`). **여기서 `isEventGame`이 `GameParticipantInfo`로 들어온다.**
- 부트스트랩 3종: `GET /{id}`(설정·`isEventGame`·gameStartTime), `GET /{id}/area`(`_loadGameArea`), 도둑 위치는 `connectAndSubscribe`의 `_fetchLastRobberLocations`로 충전.
- 중간 입장 경찰 초기 상태: `canPoliceArrest()`(`game_event_provider.dart:445-459`)가 `policeWaitMinutes==0`이면 즉시 true. 이벤트는 보통 0 → 입장 즉시 ALIVE.

콜드 재진입 복원: **GET /{id} 설정에 `isEventGame` 포함**이 1차(권장). (영속 레코드는 체포 데이터만 담고 isEventGame은 담지 않음 — 단순성 우선.)

### 5.3 체포 카운트 / 재체포 / 영속화

- 인게임 진입 시 `EventArrestStorage.load(gameId)` → `GameEventState.myArrestedRobberIds` 복원.
- 재체포 차단(`game_page.dart:2160-2174`): 이벤트 모드면 **`myArrestedRobberIds`** 기준으로 비활성(각 경찰 운영진 1회씩). 일반 모드는 기존 `arrestedParticipantIds` 유지.
- 내 체포 성공 시: `myArrestedRobberIds`에 add → `EventArrestStorage.save` → 성공 다이얼로그(§5.4).
- 전역 집합/재동기화와 격리(§3.2). `_handleArrest`(`:711-751`)는 이벤트 모드에서 전역 `arrestedParticipantIds`를 **건드리지 않는다**(도둑 ALIVE 유지) — 피드백/카운트만. 따라서 이벤트 모드에서 전역 집합은 비어 있고, **재체포 판정은 오직 `myArrestedRobberIds`** 만 읽는다(전역 집합/재연결 덮어쓰기와 무관 → 재연결 후 재체포 차단 불정합 없음).

> **동시성/정합**:
> - `arrestRobber`(`:417-470`)는 낙관적 업데이트 + `_pendingArrestId` dedup 보유. 영속화 save는 **체포 API 성공 분기에서** 수행(롤백 위험 회피). `Set`이라 STOMP echo 중복도 자동 흡수.
> - **경찰 간 race 없음**: 로컬 레코드는 **기기(=경찰)별** `shared_preferences`라 다른 경찰과 공유되지 않는다. 한 기기 내 동시 체포는 `_pendingArrestId`로 직렬화 → 증거 인덱스(N = 집합 크기) 계산이 꼬이지 않는다.
> - **탈옥 없음**: 이벤트 모드는 감옥 개념이 없어 ESCAPE가 발생하지 않는다(백엔드 엔진 룰). 따라서 한 번 add된 `myArrestedRobberIds` 원소는 제거되지 않는다.
> - **`_pendingArrestId` 소유권**: 이벤트 모드에서 pending 플래그는 `arrestRobberForEvent`가 **HTTP+영속화 완료 후** 단독 해제한다. `_handleArrest`(STOMP echo)는 이를 건드리지 않는다 — 조기 해제하면 저장 중 두 번째 체포가 시작돼 검거 집합이 유실되므로, 동일 게임 내 체포는 직렬화된다.
> - **진입 복원 선행**: `loadMyArrests`는 체포 가능 시점 이전에 await되고 union 병합이라, 복원-체포 겹침에도 신규 검거가 유실되지 않는다.

### 5.4 체포 성공 다이얼로그 (증거 공개)

- 트리거: QR 스캔 → `arrestRobber` → **API 성공 직후** 성공 다이얼로그 표시(확인 모달 없음).
- 내용: 중앙에 `assets/events/evidence{N}.svg`(N = 검거 집합 크기), 검거 문구. AppDialog 패턴 따름.
- 재사용 검토: `game_action_modal.dart:37-83`는 범용 텍스트 모달 → 증거 SVG용 **신규 위젯** 권장(예: `event_arrest_success_dialog.dart`).
- 모든 UI 텍스트는 i18n(§7).

### 5.5 도둑(운영진) ALIVE UI 분기

- `isArrestedNow`(`game_page.dart:1658-1666`)에 `&& !isEventGame` 추가 → 이벤트 모드 도둑은 잠금 오버레이 미표시.
- `arrest_lock_overlay.dart:23-126`에 `isEventGame` 파라미터 추가(또는 상위 조건부 렌더링) → 잠금/탈옥 버튼 비활성.
- 백엔드가 `status=ALIVE`를 내려도 프론트가 로컬 분기로 "갇힘 UI"를 끄는 것이므로 **순수 프론트 작업**.

### 5.6 게임 종료 & 결과 증거 보드

- `_handleGameOver`(`game_event_provider.dart:805-811`)는 기존대로 `winnerTeam/reason/gameResultId` 저장. `_showGameOverDialog`(`game_page.dart:1264-1383`)에서 **이벤트 분기**.
- 이벤트 결과 = **로컬 전용**: 증거 보드 + "운영진 N명 검거". `gameResultProvider`(서버 통계, `game_over_result_dialog.dart:207`) **비의존**.
  - 이벤트 모드는 `gameResultId`가 null일 수 있음(서버가 결과 미생성 가능) → 기존 fallback(`game_page.dart:1353-1356`)과 별개로 **로컬 데이터만으로** 보드를 그린다.
- 증거 보드 UI: 수집=선명 + 핀, 미수집=**같은 SVG 50% 흐림 + 가운데 자물쇠**. 신규 위젯(또는 `GameOverResultDialog` 이벤트 분기) — `myArrestedRobberIds.length`로 공개 수 결정.
- `GameResultReason`은 **이미 4개 전부 존재**(`game_result_reason.dart:7-10`) → 추가 작업 없음. `game_event_provider.dart:93`의 스테일 주석만 정정.

### 5.7 기타 시스템 이벤트 & 게임 나가기 / Rematch

**기타 STOMP 이벤트(이벤트 모드 동작)**:
- `LOCATION_REVEAL`(도둑 위치 공개): **기존 유지** — 경찰이 운영진 추격에 필요.
- `PLAYER_LEFT`, `*_FORFEITED`: 이탈/기권 처리는 **백엔드 종료 조건**(§8) — 프론트는 `GAME_OVER` 수신 시 결과 보드 표시.
- `ARREST` 배너/시스템 공지: 체포한 경찰 본인은 성공 다이얼로그(§5.4)를 받는다. 전역 배너/SYSTEM_CHAT의 "체포" 문구는 도둑 ALIVE 맥락이라 **문구 검토 필요**(기본: 정보성으로 유지, 어색하면 이벤트 모드 문구 분기). → §9 확인 항목.

**게임 나가기 / Rematch 시 로컬 레코드**:
- `onGoHome`(`game_page.dart:1374-1381` 인근): 게임 종료 후 홈 복귀. 로컬 레코드는 **별도 삭제하지 않아도** 다음에 *다른* 게임에 입장하는 순간 자동 리셋(§4.1)되므로 안전.
- `onRematch`(같은 `sessionId`로 이동): 이벤트 모드는 로비가 없어 **rematch 경로 자체가 모호**하다. 권장 기본값 — **이벤트 모드 결과에서는 "한 번 더" 버튼을 숨기고 "홈으로"만 노출**(행사 1회성). → §9 확인 항목. (만약 rematch를 살린다면, 같은 `gameId` 재진입 시 `load()`로 카운트가 복원됨을 인지.)

---

## 6. 파일별 변경 맵 (검증 완료)

> 라인 번호는 작성 시점 기준 **근사치**다. 구현 시 심볼/grep으로 재확인한다.

| 파일 | 변경 | 근거 |
| --- | --- | --- |
| `session/data/models/join_game_response.dart` | `isEventGame` 필드 추가 | `:18-29` |
| `session/domain/entities/game_join_result.dart` | `isEventGame` 필드 추가 | `:10-18` |
| `session/data/repositories/session_repository_impl.dart` | `joinGameByInvite`에서 `isEventGame` 매핑 | `:116-124` |
| `session/presentation/providers/deeplink_join_notifier.dart` | `JoinedRoomOutcome`에 `isEventGame` 전파 | `:91-95` |
| `session/presentation/pages/deeplink_join_page.dart` | outcome `isEventGame` 분기 → 게임 직행 | `:110-116` |
| `session/presentation/pages/home_page.dart` | join 후 `isEventGame` 분기 → 게임 직행 | join 성공 네비 |
| `session/data/models/game_settings_response.dart` | `isEventGame` 필드 추가(재진입 복원) | `:20-43` |
| `session/presentation/providers/game_participant_provider.dart` | `GameParticipantInfo.isEventGame` + copyWith/setGameInfo/initFromLobby | `:11-198` |
| `game/data/services/event_arrest_storage.dart` *(신규)* | shared_preferences 단일 레코드 저장/복원 | `pubspec:35` |
| `game/presentation/providers/game_event_provider.dart` | `myArrestedRobberIds` 추가 + load/save + 이벤트 분기(`_handleArrest`/`arrestRobber`) + 주석 정정 | `:57-61, :417-470, :711-751, :93` |
| `game/presentation/pages/game_page.dart` | 진입 시 load, 재체포 차단 분기(`:2160`), `isArrestedNow` 분기(`:1658`), 체포 성공 다이얼로그 호출, 결과 이벤트 분기(`:1264-1383`) | 다수 |
| `game/presentation/widgets/arrest_lock_overlay.dart` | `isEventGame` 파라미터 → 잠금/탈옥 비활성 | `:23-126` |
| `game/presentation/widgets/event_arrest_success_dialog.dart` *(신규)* | 증거 SVG 성공 다이얼로그 | — |
| `game/presentation/widgets/event_result_board.dart` *(신규 또는 분기)* | 증거 보드 결과 | `game_over_result_dialog.dart:98-332` |
| `pubspec.yaml` | `flutter.assets`에 `- assets/events/` 추가 | `:113-128` |
| `lib/l10n/app_{ko,en,ja}.arb` | 신규 i18n 키(§7) | — |

---

## 7. i18n 키 (신규)

UI 텍스트 하드코딩 금지 — ARB에 추가 후 `flutter gen-l10n`. 후보(최종 명명은 구현 시 확정):

- `gameEventArrestSuccessTitle` — 체포 성공 다이얼로그 제목
- `gameEventArrestSuccessMessage` — 체포 성공 메시지(`{nickname}` 플레이스홀더 가능)
- `gameEventResultTitle` — 결과 타이틀("수사 종료")
- `gameEventResultArrestCount` — "운영진 {count}명 검거"

> 메시지 끝 마침표 금지 규칙([feedback_message_no_trailing_period]) 준수. 지원 로케일 ko/en/ja 모두 추가.

---

## 8. 백엔드 종속 (블로킹) & dev 플래그 선개발

### 8.1 블로킹 — 백엔드가 반드시 해야 함

1. **`join` 응답에 `isEventGame`** (현재 `GameJoinResponse`에 없음)
2. **`GET /api/games/{id}` 설정에 `isEventGame`** (콜드 재진입/인게임 단일 소스)
3. **엔진 룰 분기**: 체포 시 `JAILED` 미전환 / `remainingThieves` 불변 / `ALL_ARRESTED`·`POLICE_FORFEITED` 미발생 / FCM 없음
4. **이벤트 방 *생성* 경로**: 운영진이 `isEventGame=true` 방을 만드는 방법 (스펙 §1-A, 현재 누락)
5. 부트스트랩 3종(`/{id}`·`/area`·`/state`)이 중간 입장(IN_PROGRESS)에도 정상 응답하는지 확인

### 8.2 프론트 독립 진행 (dev 플래그)

위 백엔드가 없어도 프론트는 **dev 전용 플래그로 `isEventGame=true` 강제**해 라우팅/부트스트랩/영속화/도둑 UI/체포 다이얼로그/결과 보드를 선개발·검증한다.

- 방식(권장): `--dart-define=EVENT_GAME_DEV=true` (디버그 빌드 한정). `bool.fromEnvironment('EVENT_GAME_DEV')` 상수.
- **주입 지점(구체)**: 인게임 분기 단일 소스가 `GameParticipantInfo.isEventGame`이므로, 이 값을 세팅하는 **`_initSettingsFromApiIfNeeded`(`game_page.dart:408-456`) 한 곳**에서 `isEventGame = (settings.isEventGame ?? false) || kEventGameDevOverride` 형태로 OR 주입한다. 라우팅 스킵까지 dev로 검증하려면 join 분기(§5.1)에도 동일 플래그를 OR. (실서비스 빌드에선 false라 영향 없음.)

---

## 9. 미해결 (기획/백엔드 확인 필요)

- **운영진(도둑) 본인 앱 진입 경로** — 어떻게 `team=ROBBER`로 들어오나(방 생성/참가). 도둑 ALIVE UI(§5.5)는 그들이 앱을 쓴다는 전제.
- **증거 SVG** — 정확히 3개 고정 세트(체포순=인덱스)인지 / 운영진 수 가변인지. 가변이면 잠금 슬롯 수 결정 로직 추가.
- **이벤트 `GAME_OVER`** — `gameResultId` null 여부, `*_FORFEITED` 발생 조건(운영진 전원 이탈 등).
- 다중 경찰이 같은 운영진을 동시 체포 시 — 재체포는 경찰 로컬 기준이라 각자 1회씩 카운트(중복 허용)인지 확정.
- **결과 "한 번 더(rematch)" 버튼** — 이벤트 모드에서 숨길지(권장: 홈으로만) / 유지할지. (§5.7)
- **ARREST 배너/SYSTEM_CHAT 문구** — 도둑 ALIVE 맥락에서 "체포됨" 공지를 그대로 둘지 / 이벤트 문구로 분기할지. (§5.7)
- **활성 게임 복귀 시 WAITING 조회 가능성** — 이벤트 참가자가 앱 재시작/409 복귀 시 서버가 WAITING으로 조회하는 시나리오가 존재하는가. (존재한다면 활성 게임 조회 응답에 `isEventGame` 필요 → 백엔드. 미존재 시 IN_PROGRESS 경로가 이미 게임 직행으로 충족.)

---

## 10. 테스트 전략

[Agents.md](../.claude/rules/Agents.md) 룰 우선. 시스템 경계만 모킹, 동작(반환값/관찰 상태) 검증.

- **단위(우선)**: `EventArrestStorage`(같은/다른 gameId 복원·리셋, Set dedup), 증거 인덱스 = 집합 크기, `canPoliceArrest`(policeWaitMinutes=0), 라우팅 분기 결정 함수(isEventGame→직행/대기실).
- **위젯**: `arrest_lock_overlay` isEventGame=true 시 잠금/탈옥 미렌더, 증거 보드(수집/미수집 상태별 렌더), 체포 성공 다이얼로그(N번째 → evidenceN).
- 모킹: `shared_preferences`는 실제 in-memory(`SharedPreferences.setMockInitialValues`) 사용. STOMP/HTTP 경계만 가짜로.
- 명명: `<subject>_<expected>_when_<condition>`.

---

## 11. 권장 구현 순서 (개략)

1. **모델/플래그 기반**: `isEventGame` 필드 4곳(join/result/settings/participantInfo) + build_runner. dev 플래그 주입 지점.
2. **라우팅**: join 분기 → 게임 직행(2 진입점).
3. **영속화**: `EventArrestStorage` + `myArrestedRobberIds` load/save + 재체포 분기.
4. **도둑 UI**: `isArrestedNow`/`arrest_lock_overlay` 분기.
5. **체포 성공 다이얼로그**: 증거 공개.
6. **결과 보드**: 이벤트 분기 + 증거 보드 + i18n + pubspec 에셋 등록.
7. **백엔드 연동**: 실제 응답 필드/엔진 룰 확정 후 dev 플래그 제거.

> 상세 단계·체크포인트는 구현 계획(writing-plans)에서 확정한다.
