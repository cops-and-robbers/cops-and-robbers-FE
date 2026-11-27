## 🔥 구현 기능

서버가 경찰(`POLICE`)·도둑(`ROBBER`)을 `CHASER`·`RUNNER`로 바꾸고 있다(BE #254, PR #255, Swagger v4.5.0). 앱이 **옛 이름과 새 이름을 모두 읽게** 하고, 그다음 **새 이름으로 보내게** 한다.

| 순서 | 무엇 | 언제 해도 되나 |
|---|---|---|
| 1 | 받는 값: 옛 값과 새 값을 둘 다 처리 | 지금. 어느 서버에서도 안전하다 |
| 2 | 받는 필드: 새 키를 먼저 읽고 없으면 옛 키 | 지금. 어느 서버에서도 안전하다 |
| 3 | 보내는 필드와 구독 경로: 새 이름으로 | **운영 서버에 BE PR #255가 나간 뒤에 출시** |

화면 문구(경찰/술래)는 지금처럼 앱이 `gameMode`를 보고 정한다. 바뀌는 화면은 없다.

<br>

## 📝 현재 문제점

- 앱 `main`에는 `CHASER`·`RUNNER`를 다루는 코드가 없다. 서버 값을 문자열 그대로 비교한다(`game_team.dart:8`, `participant_status.dart:7`, `game_result_reason.dart:11`, `chat_constants.dart:17`).
- 서버는 지금(1단계) 옛 값과 옛 키를 그대로 내려주므로 당장 깨지는 것은 없다. 그러나 강제 업데이트 뒤 서버가 옛 이름을 지우면(BE 4단계) 이 앱은 팀 판별, 출동·위치 공개 이벤트, 체포·탈옥 알림, 에러 문구가 모두 깨진다.
- 좀비 모드(BE PR #258)는 새 이름 위에 올라온다.

> [!WARNING]
> 운영 서버(v3.13.0, 2026-11-24)에는 아직 PR #255가 없다. 옛 서버는 새 키(`chaserWaitMinutes`)를 모르고 새 경로(`/chat/chaser`)에 발행하지 않는다. 순서 3을 먼저 출시하면 운영에서 방 생성 값이 빠지고 팀 채팅·핑이 오지 않는다.

<br>

## 🛠️ 해결 방안 / 제안 기능

**서버에서 받는 즉시 한 이름으로 맞춘다.** 화면·프로바이더는 지금 쓰는 값만 계속 보면 된다. 지금 팀 값을 소문자로 바꿔 구독 경로와 캐릭터 에셋 경로를 만들고 있어서(`chat_stomp_datasource.dart:64`, `game_event_stomp_datasource.dart:74`), 받는 곳에서 맞추지 않으면 서버 값이 바뀌는 날 경로와 에셋이 함께 어긋난다.

### 1. 받는 값 (옛 값, 새 값 둘 다)

| 값 | 옛 이름 | 새 이름 | 앱 위치 |
|---|---|---|---|
| 팀 | `POLICE` / `ROBBER` | `CHASER` / `RUNNER` | `game_team.dart:8`, `chat_constants.dart:17` |
| 참가자 상태 | `POLICE_WAITING` | `CHASER_WAITING` | `participant_status.dart:7` |
| 종료 사유 | `POLICE_FORFEITED` / `ROBBER_FORFEITED` | `CHASER_FORFEITED` / `RUNNER_FORFEITED` | `game_result_reason.dart:11` |
| 시스템 이벤트 `type` | `POLICE_MOVE_START` / `ROBBER_LOCATION_REVEAL` | `CHASER_MOVE_START` / `RUNNER_LOCATION_REVEAL` | `game_event_model.dart:17,21` |
| FCM `data.type` | 위와 같음 | 위와 같음 | `firebase_messaging_service.dart:71` |

에러 코드 8개도 둘 다 받는다(`error_message_mapper.dart:172~283`, `game_event_provider.dart:670`, `radio_session_provider.dart:109,325`).

| 옛 코드 | 새 코드 |
|---|---|
| `INVALID_POLICE_WAIT_TIME` | `INVALID_CHASER_WAIT_TIME` |
| `NOT_ROBBER_TEAM` | `NOT_RUNNER_TEAM` |
| `ONLY_POLICE_CAN_ARREST` | `ONLY_CHASER_CAN_ARREST` |
| `ONLY_ROBBER_CAN_BE_ARRESTED` | `ONLY_RUNNER_CAN_BE_ARRESTED` |
| `ONLY_ROBBER_CAN_ESCAPE` | `ONLY_RUNNER_CAN_ESCAPE` |
| `POLICE_WAITING_TIME` | `CHASER_WAITING_TIME` |
| `ONLY_POLICE_CAN_USE_RADIO` | `ONLY_CHASER_CAN_USE_RADIO` |
| `RADIO_POLICE_WAITING_TIME` | `RADIO_CHASER_WAITING_TIME` |

### 2. 받는 필드 (새 키 먼저, 없으면 옛 키)

| 응답 | 옛 키 | 새 키 | 앱 위치 |
|---|---|---|---|
| 방 생성, 방 정보, 설정 변경, 로비 `SETTINGS_UPDATED` | `policeWaitMinutes` | `chaserWaitMinutes` | `create_session_response.dart`, `game_settings_response.dart` |
| 게임 결과 | `policeMvp`, `robberMvp`, `remainingRobberCount` | `chaserMvp`, `runnerMvp`, `remainingRunnerCount` | `game_result_response_model.dart` |
| 참가자 목록 | `police`, `robbers` | `chasers`, `runners` | `in_game_participants_response.dart` |
| 게임 상태 | `robberLocations` | `runnerLocations` | `game_state_model.dart` |
| 체포 응답 | `robberNickname`, `remainingThieves` | `runnerNickname`, `remainingRunners` | `arrest_response_model.dart` |
| 시스템 `ARREST` | `police`, `robber`, `remainingThieves` | `chaser`, `runner`, `remainingRunners` | `game_event_provider.dart:914~921` |
| 시스템 `ESCAPE` | `escapedThief`, `remainingThieves` | `escapedRunner`, `remainingRunners` | `game_event_provider.dart:1016` |

### 3. 보내는 필드와 구독 경로 (새 이름으로)

| 대상 | 옛 이름 | 새 이름 | 앱 위치 |
|---|---|---|---|
| 방 생성·설정 변경 요청 | `policeWaitMinutes` | `chaserWaitMinutes` | `game_create_request_model.dart` |
| 체포 요청 | `robberParticipantId` | `runnerParticipantId` | `arrest_request_model.dart` |
| 팀 변경 `targetTeam` | `POLICE` / `ROBBER` | `CHASER` / `RUNNER` | `team_change_request.dart` |
| 팀 채팅 구독 | `/chat/police`, `/chat/robber` | `/chat/chaser`, `/chat/runner` | `chat_stomp_datasource.dart:64` |
| 팀 핑 구독 | `/ping/police`, `/ping/robber` | `/ping/chaser`, `/ping/runner` | `game_event_stomp_datasource.dart:74` |

> [!IMPORTANT]
> 순서 3이 들어간 버전은 **운영 서버에 BE PR #255가 배포된 뒤에** 심사에 올린다. 그리고 BE 4단계(옛 이름 제거) 전의 **강제 업데이트 최소 버전은 순서 3까지 들어간 버전**이어야 한다.

<br>

## ⚙️ 작업 내용

- 순서 1 → 2 → 3으로 진행한다. 1·2는 서버 상태와 무관하게 머지할 수 있다.
- 테스트는 서버 조합 셋으로 본다: 옛 서버(옛 값·옛 키만), 지금 dev(옛 값 + 옛 키·새 키), 4단계 뒤 서버(새 값·새 키만).
- 테섭에서 경찰과 도둑 한 판, 술래잡기 한 판을 끝까지 돌린다(팀 채팅·핑, 체포·탈옥 알림, 결과 MVP, 무전).
- `docs/api-docs.json`을 v4.5.0으로 갱신한다.

<br>

## 📌 참고

- BE 이슈 #254, PR #255 (dev 머지 2026-11-26, Swagger v4.5.0)
- 이번 범위가 아닌 것
  - 체포·감옥·탈옥 용어(`JAILED`, `ARREST`, `ESCAPE`): 서버도 바꾸지 않았다.
  - 로비 `TEAM_UPDATE`의 `chaserCount`·`runnerCount`: 앱이 읽지 않는다(대기방이 참가자 목록에서 직접 센다).
  - 앱 안의 변수·에셋 이름(`isPolice`, `icon_police_*` 등): 받는 곳에서 한 이름으로 맞추므로 그대로 둔다.
  - 옛 이름 지원 코드 지우기: BE 4단계가 나간 뒤 따로 한다.
  - 좀비 모드: BE PR #258이 머지되면 따로 한다.

<br>

## 🚧 작업목록

- [ ] 받는 값 둘 다 처리: 팀, 참가자 상태, 종료 사유, 시스템 이벤트 `type`, FCM `type`
- [ ] 에러 코드 8개 둘 다 처리
- [ ] 받는 필드 새 키 먼저, 없으면 옛 키 (응답 5종, 시스템 `ARREST`·`ESCAPE`)
- [ ] 서버 조합 셋에 대한 파싱 테스트
- [ ] 보내는 필드 3종을 새 이름으로
- [ ] 팀 채팅·핑 구독 경로를 새 이름으로
- [ ] 테섭에서 경찰과 도둑, 술래잡기 한 판씩
- [ ] `docs/api-docs.json` v4.5.0 갱신
- [ ] 출시 전 운영 서버에 BE PR #255 배포 확인

<br>

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
