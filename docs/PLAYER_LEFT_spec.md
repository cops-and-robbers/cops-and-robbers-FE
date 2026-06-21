# 인게임 퇴장 기능 구현

## 필요성

- 이벤트 관련 게임방 기능을 구현하려다 보니, 박람회 이벤트 중 사용자들이 자유롭게 입장 퇴장할 수 있는 기능이 필요한 상홤
- 굳이 이벤트 게임을 위한게 아니더라도, 게임 중 나가거나 종료가 필요한 상황임에도 게임이 시작되면 계속 실행되며 종료 될 떄 까지 기다려야 하는상황이 불편을 초래

→ 이번 구현에는 우선 박람회 이벤트와 별개로, 정상 게임 진행 상황에서 몰수 패와 몰수승 을 추가하여 게임 진행 중에도 자유롭게 퇴장 가능 하도록 기능을 설계했슴다.

이벤트 게임 관련한 구현은 해당 PR이 머지 된 후 후속 작업으로 진행 예정
(최대한 클라이언트 로직의 변경 없이 구현할 예정)

→ 하지만 게임 중간 퇴장은 어쨌든 UI 에 기능이 추가되어야 하는 사항이라 먼저 구현했음 (머진 안한 상황)

디자인 팀들은 ⭐️ 퇴장 흐름 까지만 보면 됨

---

## 인게임 중도 퇴장 스펙

## 개요

- 엔드포인트: `DELETE /api/games/{gameId}/leave`
- 게임이 진행 중(IN_PROGRESS)일 때 참가자가 퇴장하면, 퇴장자의 **팀·상태**에 따라 처리가 다르게 동작한다
- 퇴장 후 남은 참가자 수에 따라 게임이 계속되거나 강제 종료된다
- 방장이 퇴장하면 팀·상태 처리와 별개로 다음 참가자에게 방장이 위임된다

---

## ⭐️ 퇴장 흐름

```
DELETE /api/games/{gameId}/leave
  │
  ├─ 게임 상태 == WAITING (로비)
  │    │
  │    ├─ 마지막 참가자
  │    │    → 게임 방 삭제 (이벤트 없음)
  │    │
  │    ├─ 방장 퇴장
  │    │    → [lobby] EXIT
  │    │    → [lobby] HOST_CHANGED
  │    │
  │    └─ 일반 퇴장
  │         → [lobby] EXIT
  │
  └─ 게임 상태 == IN_PROGRESS (인게임)
       │
       ├─ team == POLICE (POLICE_WAITING / ALIVE)
       │    ├─ 경찰 남아있음  → [system] PLAYER_LEFT
       │    └─ 마지막 경찰   → [system] PLAYER_LEFT + GAME_OVER (POLICE_FORFEITED, winnerTeam=ROBBER)
       │
       ├─ team == ROBBER & status == ALIVE
       │    ├─ 생존 도둑 남아있음  → [system] PLAYER_LEFT
       │    └─ 마지막 생존 도둑   → [system] PLAYER_LEFT + GAME_OVER (ROBBER_FORFEITED, winnerTeam=POLICE)
       │
       └─ team == ROBBER & status == JAILED
            → [system] PLAYER_LEFT

* 방장 퇴장 시 위 케이스와 무관하게 [lobby] HOST_CHANGED 추가 발행
	- 인게임 시스템 알림에도 방장 변경 여부를 브로드캐스트 할까 생각 햇는데 인게임에서는 방장이 크게 중요한 정보가 아니니 제외 함 (방장 이라고 따료 표시 하는 것도 없지 않나..?)
```

채널 구독 경로

- `[lobby]` → `/subscribe/game/{gameId}/lobby`
- `[system]` → `/subscribe/game/{gameId}/system`

---

## 상태별 퇴장 처리

### 경찰 (POLICE_WAITING / ALIVE)

| 조건                 | 처리                                                                     |
| -------------------- | ------------------------------------------------------------------------ |
| 경찰이 아직 남아있음 | PLAYER_LEFT 이벤트 발행                                                  |
| 마지막 경찰 퇴장     | 게임 강제 종료 → GAME_OVER 이벤트 발행 (도둑팀 승리, `POLICE_FORFEITED`) |

### 도둑 — 생존 (ALIVE)

| 조건                      | 처리                                                                     |
| ------------------------- | ------------------------------------------------------------------------ |
| 생존 도둑이 아직 남아있음 | PLAYER_LEFT 이벤트 발행                                                  |
| 마지막 생존 도둑 퇴장     | 게임 강제 종료 → GAME_OVER 이벤트 발행 (경찰팀 승리, `ROBBER_FORFEITED`) |

### 도둑 — 수감 (JAILED)

| 조건 | 처리                                             |
| ---- | ------------------------------------------------ |
| 항상 | PLAYER_LEFT 이벤트 발행 (forfeit 조건 체크 없음) |

> JAILED 도둑은 생존 카운트에 포함되지 않으므로 퇴장해도 게임 종료를 유발하지 않는다.

### 방장 퇴장 (공통)

- 위 케이스 중 하나로 처리된 후, 추가로 HOST_CHANGED 이벤트 발행
- 구독 채널: `/subscribe/game/{gameId}/lobby`

---

## WebSocket 이벤트 스펙

구독 채널: `/subscribe/game/{gameId}/system`

### PLAYER_LEFT

게임이 계속될 때 퇴장자 정보를 전파한다.

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "gameId": 1,
  "type": "PLAYER_LEFT",
  "timestamp": "2026-06-15T10:00:00+09:00",
  "data": {
    "participantId": 42,
    "nickname": "닉네임",
    "team": "POLICE 또는 ROBBER"
  }
}
```

### GAME_OVER (forfeit)

강제 종료 시 발행된다. 기존 GAME_OVER 스펙과 동일하며 `reason` 값만 다르다.

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440001",
  "gameId": 1,
  "type": "GAME_OVER",
  "timestamp": "2026-06-15T10:00:05+09:00",
  "data": {
    "gameResultId": 1,
    "winnerTeam": "POLICE | ROBBER",
    "reason": "POLICE_FORFEITED | ROBBER_FORFEITED"
  }
}
```

| reason             | 발생 조건             | winnerTeam |
| ------------------ | --------------------- | ---------- |
| `POLICE_FORFEITED` | 마지막 경찰 퇴장      | `ROBBER`   |
| `ROBBER_FORFEITED` | 마지막 생존 도둑 퇴장 | `POLICE`   |

---

## FCM 푸시 알림

PLAYER_LEFT·GAME_OVER 이벤트 발행 시 게임 내 잔류 참가자 전체에게 FCM 푸시가 발송된다.

### PLAYER_LEFT

| 항목  | 값                                                 |
| ----- | -------------------------------------------------- |
| title | `{팀 한글명} 참가자 퇴장` (예: `경찰 참가자 퇴장`) |
| body  | `{닉네임}이(가) 게임에서 퇴장했습니다.`            |

### GAME_OVER

| 항목  | 값                                          |
| ----- | ------------------------------------------- |
| title | `게임 종료`                                 |
| body  | `게임이 종료되었습니다. 결과를 확인하세요!` |
