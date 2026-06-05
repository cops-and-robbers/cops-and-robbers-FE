# 핑

생성일: June 1, 2026 10:41 PM

# 핑 기능 명세

팀원에게 지도 위 특정 좌표를 실시간으로 공유하는 기능 → 웹 소켓으로 데이터 송수신이 이루어 진다

- 핑 전송: 단일 엔드포인트 → but, 같은 팀 참여자에게만 전달됨 (서버 주도 라우팅)
- 핑 수신: 경찰/도둑 구독 채널이 분리되어 있어 자신의 팀에 맞는 채널을 구독 하면 됨

핑은 팀 별 핑만 존재하며, 게임 참여자가 모두 볼 수 있는 핑은 존재 X

---

## 웹 소켓 연결

- `ws://host/game-connection`
- 헤더
  ```json
  {
    "Authorization": "Bearer {Access_Token}"
  }
  ```

→ 웹 소켓은 원래 하던대로 연결 해 주면 됨 최초 1회

---

## 핑 전송

**Client → Server**

- `SEND /publish/game/{gameId}/ping`

```json
{
  "pingType": "FOUND",
  "location": {
    "latitude": 37.5665,
    "longitude": 126.978
  }
}
```

| 필드                 | 타입     | 설명      |
| -------------------- | -------- | --------- | ------ | ------- |
| `pingType`           | `FOUND`  | `SUSPECT` | `HELP` | 핑 종류 |
| `location.latitude`  | `double` | 위도      |
| `location.longitude` | `double` | 경도      |

- ping type은 일단 디스코드 스레드에 핑 초안 으로 생각하고 있는 종류 두 가지
  (발견 `FOUND` / 의심 `SUSPECT`)
- 도움 요청 `HELP` 는 그냥 혹시 몰라서 만들어 둠 (안 써도 됨)

---

## 핑 수신

**Server → Client**

| 팀   | 구독 채널                              |
| ---- | -------------------------------------- |
| 경찰 | `/subscribe/game/{gameId}/ping/police` |
| 도둑 | `/subscribe/game/{gameId}/ping/robber` |

- 구독 채널은 자신의 팀에 맞는 채널 하나만 구독
- 다른 팀 채널 구독 시도는 서버에서 거부됩니다.

[응답 예시]

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "gameId": 1,
  "pingType": "FOUND",
  "location": {
    "latitude": 37.5665,
    "longitude": 126.978
  },
  "pingSender": {
    "participantId": 42,
    "nickname": "경찰관1"
  },
  "timestamp": "2026-06-01T14:32:10.123+09:00"
}
```

| 필드                       | 타입     | 설명                     |
| -------------------------- | -------- | ------------------------ |
| `id`                       | `string` | 핑 고유 ID (UUID)        |
| `gameId`                   | `number` | 게임 ID                  |
| `pingType`                 | `string` | 핑 종류                  |
| `location`                 | `object` | 핑 좌표                  |
| `pingSender.participantId` | `number` | 전송자 참여자 ID         |
| `pingSender.nickname`      | `string` | 전송자 닉네임            |
| `timestamp`                | `string` | 전송 시각 (KST ISO 8601) |

## PingType

| 값        | 설명      |
| --------- | --------- |
| `FOUND`   | 발견      |
| `SUSPECT` | 의심      |
| `HELP`    | 지원 요청 |

---

## 무시되는 경우 (Drop)

아래 상황에서 핑 전송 시 서버가 핑을 조용히 무시합니다. 별도 에러 응답 없음.

| 상황               | 설명                                      |
| ------------------ | ----------------------------------------- |
| 게임 미진행        | 게임이 시작되지 않았거나 이미 종료된 경우 |
| 구역 이탈          | 전송 좌표가 플레이그라운드 반경 밖인 경우 |
| 참여자가 아닌 경우 | 해당 게임의 참여자가 아닌 사용자가 핑을 전송한 경우 |
