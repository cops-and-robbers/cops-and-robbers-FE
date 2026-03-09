# API 명세서 (API Specification)

> **Base URL**: `백엔드주소`
> **OpenAPI Version**: 3.0.1
> **API Version**: 1.0.0
> **인증 방식**: JWT Bearer Token (`Authorization: Bearer {accessToken}`)

---

## 목차

1. [Auth API - 소셜 로그인 및 토큰 관리](#1-auth-api---소셜-로그인-및-토큰-관리)
   - [POST /api/auth/login - 소셜 로그인](#11-post-apiauthlogin---소셜-로그인)
   - [POST /api/auth/logout - 로그아웃](#12-post-apiauthlogout---로그아웃)
   - [POST /api/auth/reissue - 토큰 재발급](#13-post-apiauthreissue---토큰-재발급)
2. [Game API - 게임 방 생성 및 관리](#2-game-api---게임-방-생성-및-관리)
   - [POST /api/games - 게임 방 생성](#21-post-apigames---게임-방-생성)
   - [PUT /api/games/{gameId}/settings - 게임 설정 수정](#22-put-apigamesgameidsettings---게임-설정-수정)
   - [GET /api/games/{gameId} - 게임 기본 설정 조회](#23-get-apigamesgameid---게임-기본-설정-조회)
3. [Game Area API - 게임 맵 정보 조회](#3-game-area-api---게임-맵-정보-조회)
   - [GET /api/games/{gameId}/area - 게임 맵 정보 조회](#31-get-apigamesgameidarea---게임-맵-정보-조회)
   - [PUT /api/games/{gameId}/area - 게임 영역 수정](#32-put-apigamesgameidarea---게임-영역-수정)
4. [Game Participant API - 게임 참여자 관리](#4-game-participant-api---게임-참여자-관리)
   - [POST /api/games/join - 게임 방 참여](#41-post-apigamesjoin---게임-방-참여)
   - [DELETE /api/games/{gameId}/leave - 게임 방 퇴장](#42-delete-apigamesgameidleave---게임-방-퇴장)
   - [GET /api/games/{gameId}/participants - 게임 참가자 인게임 상태 목록 조회](#43-get-apigamesgameidparticipants---게임-참가자-인게임-상태-목록-조회)
5. [Lobby API - 게임 로비 상태 변경](#5-lobby-api---게임-로비-상태-변경)
   - [GET /api/games/{gameId}/lobby - 로비 조회](#51-get-apigamesgameidlobby---로비-조회)
   - [PATCH /api/games/{gameId}/lobby/team - 로비 팀 변경](#52-patch-apigamesgameidlobbyteam---로비-팀-변경)
   - [PATCH /api/games/{gameId}/lobby/ready - 로비 준비 상태 변경](#53-patch-apigamesgameidlobbyready---로비-준비-상태-변경)
   - [POST /api/games/{gameId}/lobby/start - 게임 시작](#54-post-apigamesgameidlobbystart---게임-시작)
6. [User API - 사용자 정보 및 프로필 관리](#6-user-api---사용자-정보-및-프로필-관리)
   - [GET /api/user/me - 내 정보 조회](#61-get-apiuserme---내-정보-조회)
   - [PATCH /api/user/me/nickname - 닉네임 변경](#62-patch-apiusermenickname---닉네임-변경)
   - [GET /api/user/check-nickname - 닉네임 중복 확인](#63-get-apiusercheck-nickname---닉네임-중복-확인)
   - [DELETE /api/user/me - 회원탈퇴](#64-delete-apiuserme---회원탈퇴)
7. [System API - 게임 시스템 상호작용](#7-system-api---게임-시스템-상호작용)
   - [POST /api/games/{gameId}/system/arrest - 도둑 체포](#71-post-apigamesgameidsystemarrest---도둑-체포)
   - [POST /api/games/{gameId}/system/escape - 도둑 탈옥](#72-post-apigamesgameidsystemescape---도둑-탈옥)
8. [공통 스키마](#8-공통-스키마)

---

## 1. Auth API - 소셜 로그인 및 토큰 관리

### 1.1 POST /api/auth/login - 소셜 로그인

소셜 로그인을 통해 서비스에 로그인합니다. 신규 회원인 경우 자동으로 회원가입이 진행되며, Access Token과 Refresh Token이 발급됩니다.

- **인증 필요**: No

#### Request Body (`application/json`)

| 필드             | 타입   | 필수 | 설명                                     |
| ---------------- | ------ | ---- | ---------------------------------------- |
| `socialPlatform` | string | O    | 소셜 플랫폼 (`KAKAO`, `GOOGLE`, `APPLE`) |
| `idToken`        | string | O    | 소셜 인증 토큰 (ID Token)                |
| `fcmToken`       | string | O    | FCM 디바이스 토큰                        |
| `deviceType`     | string | O    | 디바이스 타입 (`IOS`, `ANDROID`)         |
| `deviceId`       | string | O    | 고유 디바이스 ID                         |

**요청 예시:**

```json
{
  "socialPlatform": "KAKAO",
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "fcmToken": "fcm-device-token-here",
  "deviceType": "IOS",
  "deviceId": "unique-device-id-123"
}
```

#### Responses

**200 - 기존 회원 로그인 성공**

```json
{
  "userId": 1,
  "nickname": "민첩한괴도5308",
  "tokens": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njg0OTg2MDV9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njk3MDQ2MDV9..."
  },
  "isNewUser": false
}
```

**201 - 신규 회원 가입 및 로그인 성공**

```json
{
  "userId": 2,
  "nickname": "집요한괴도4053",
  "tokens": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyIiwiaWF0IjoxNzY4NDk1MDEwLCJleHAiOjE3Njg0OTg2MTB9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIyIiwiaWF0IjoxNzY4NDk1MDEwLCJleHAiOjE3Njk3MDQ2MTB9..."
  },
  "isNewUser": true
}
```

**400 - 잘못된 요청**

| 케이스              | title                | detail                                            |
| ------------------- | -------------------- | ------------------------------------------------- |
| 필수 요청 필드 누락 | 유효하지 않은 입력값 | `idToken: 소셜 인증 토큰(ID Token)은 필수입니다.` |
| JSON 형식 오류      | 잘못된 요청 본문     | `요청 본문의 형식이 잘못되었습니다.`              |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "idToken: 소셜 인증 토큰(ID Token)은 필수입니다.",
  "instance": "/api/auth/login"
}
```

**401 - 소셜 ID Token 검증 실패**

```json
{
  "title": "소셜 로그인 실패",
  "status": 401,
  "detail": "유효하지 않은 소셜 인증 토큰입니다.",
  "instance": "/api/auth/login"
}
```

---

### 1.2 POST /api/auth/logout - 로그아웃

로그아웃합니다. (리프레시 토큰 삭제 + 유저 디바이스 정보 삭제)

- **인증 필요**: No

#### Request Body (`application/json`)

| 필드           | 타입   | 필수 | 설명          |
| -------------- | ------ | ---- | ------------- |
| `refreshToken` | string | O    | Refresh Token |

**요청 예시:**

```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njk3MDQ2MDV9..."
}
```

#### Responses

**204 - 로그아웃 성공** (항상 204 응답, 응답 본문 없음)

---

### 1.3 POST /api/auth/reissue - 토큰 재발급

만료된 Access Token을 Refresh Token을 사용하여 재발급받습니다.

- **인증 필요**: No

#### Request Body (`application/json`)

| 필드           | 타입   | 필수 | 설명          |
| -------------- | ------ | ---- | ------------- |
| `refreshToken` | string | O    | Refresh Token |

**요청 예시:**

```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njk3MDQ2MDV9..."
}
```

#### Responses

**200 - 토큰 재발급 성공**

```json
{
  "tokens": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIx.....",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIx....."
  }
}
```

**400 - 잘못된 요청**

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "refreshToken: Refresh Token은 필수입니다.",
  "instance": "/api/auth/reissue"
}
```

**401 - Refresh Token 검증 실패**

```json
{
  "title": "토큰 재발급 실패",
  "status": 401,
  "detail": "유효하지 않거나 만료된 Refresh Token입니다.",
  "instance": "/api/auth/reissue"
}
```

---

## 2. Game API - 게임 방 생성 및 관리

### 2.1 POST /api/games - 게임 방 생성

새로운 게임 방을 생성하고 초대 코드를 발급받습니다. 게임 영역(플레이그라운드, 감옥)과 게임 규칙을 설정할 수 있습니다. 방을 생성한 사용자는 자동으로 방장이 됩니다.

- **인증 필요**: Yes (JWT)

#### Request Body (`application/json`)

| 필드                                     | 타입                                        | 필수 | 설명                           |
| ---------------------------------------- | ------------------------------------------- | ---- | ------------------------------ |
| `area`                                   | [GameAreaRequest](#gamearearequest)         | O    | 영역 설정                      |
| `area.playgroundCenter`                  | [CoordinatesRequest](#coordinatesrequest)   | O    | 플레이그라운드 중심 좌표       |
| `area.playgroundRadiusInMeters`          | integer (int32)                             | O    | 플레이그라운드 반경 (최소 10m) |
| `area.jailCenter`                        | [CoordinatesRequest](#coordinatesrequest)   | O    | 감옥 중심 좌표                 |
| `area.jailRadiusInMeters`                | integer (int32)                             | O    | 감옥 반경 (최소 5m)            |
| `settings`                               | [GameSettingsRequest](#gamesettingsrequest) | O    | 게임 규칙 설정                 |
| `settings.roundDurationMinutes`          | integer (int32)                             | O    | 라운드 시간 (10~180분)         |
| `settings.locationRevealIntervalMinutes` | integer (int32)                             | O    | 위치 공개 주기 (최소 5분)      |
| `settings.policeWaitMinutes`             | integer (int32)                             | O    | 경찰 대기 시간 (최소 0분)      |
| `settings.maxParticipants`               | integer (int32)                             | O    | 최대 참여 인원 (2~50명)        |

**요청 예시:**

```json
{
  "area": {
    "playgroundCenter": {
      "latitude": 37.5665,
      "longitude": 126.978
    },
    "playgroundRadiusInMeters": 1000,
    "jailCenter": {
      "latitude": 37.5665,
      "longitude": 126.978
    },
    "jailRadiusInMeters": 100
  },
  "settings": {
    "roundDurationMinutes": 30,
    "locationRevealIntervalMinutes": 5,
    "policeWaitMinutes": 3,
    "maxParticipants": 10
  }
}
```

#### Responses

**201 - 게임 방 생성 성공**

```json
{
  "gameId": 1,
  "inviteCode": "ABC123",
  "status": "WAITING",
  "roundDurationMinutes": 30,
  "locationRevealIntervalMinutes": 5,
  "policeWaitMinutes": 3,
  "maxParticipants": 10,
  "createdAt": "2026-01-16T01:25:37.543066"
}
```

**400 - 잘못된 요청**

| 케이스                       | title                | detail                                                    |
| ---------------------------- | -------------------- | --------------------------------------------------------- |
| 필수 필드 누락               | 유효하지 않은 입력값 | `area: 영역 설정은 필수입니다.`                           |
| 감옥이 플레이그라운드 밖     | 영역 설정 오류       | `감옥 영역이 플레이그라운드 영역 내에 포함되어야 합니다.` |
| 위치 공개 주기 > 라운드 시간 | 게임 설정 오류       | `위치 공개 주기는 라운드 시간보다 짧아야 합니다.`         |
| JSON 형식 오류               | 잘못된 요청 본문     | `요청 본문의 형식이 잘못되었습니다.`                      |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "area: 영역 설정은 필수입니다.",
  "instance": "/api/games"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games"
}
```

**409 - 이미 다른 활성 게임에 참여 중**

```json
{
  "title": "이미 참가 중인 게임",
  "status": 409,
  "detail": "이미 게임에 참가하고 있습니다.",
  "instance": "/api/games"
}
```

---

### 2.2 PUT /api/games/{gameId}/settings - 게임 설정 수정

대기실에서 게임 규칙을 수정합니다.

- **인증 필요**: Yes (JWT)
- 방장만 호출 가능
- 게임이 WAITING 상태일 때만 가능
- 모든 설정 필드를 세트로 전송 (부분 수정 불가)
- 위치 공개 주기 < 라운드 시간
- 경찰 대기 시간 < 라운드 시간
- **WebSocket**: 성공 시 대기실 구독자 전체에게 `SETTINGS_UPDATED` 이벤트가 브로드캐스트됩니다.

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Request Body (`application/json`)

| 필드                            | 타입            | 필수 | 범위   | 설명                |
| ------------------------------- | --------------- | ---- | ------ | ------------------- |
| `roundDurationMinutes`          | integer (int32) | O    | 10~180 | 라운드 시간 (분)    |
| `locationRevealIntervalMinutes` | integer (int32) | O    | 5~     | 위치 공개 주기 (분) |
| `policeWaitMinutes`             | integer (int32) | O    | 0~     | 경찰 대기 시간 (분) |
| `maxParticipants`               | integer (int32) | O    | 2~50   | 최대 참여 인원      |

**요청 예시:**

```json
{
  "roundDurationMinutes": 60,
  "locationRevealIntervalMinutes": 10,
  "policeWaitMinutes": 5,
  "maxParticipants": 20
}
```

#### Responses

**200 - 설정 수정 성공**

```json
{
  "roundDurationMinutes": 60,
  "locationRevealIntervalMinutes": 10,
  "policeWaitMinutes": 5,
  "maxParticipants": 20
}
```

**400 - 잘못된 요청**

| 케이스                                  | title                      | detail                                              |
| --------------------------------------- | -------------------------- | --------------------------------------------------- |
| 위치 공개 주기가 라운드 시간 이상인 경우 | 유효하지 않은 위치 공개 주기 | `위치 공개 주기는 라운드 시간보다 짧아야 합니다.`   |
| 게임이 대기 중이 아닌 경우              | 대기 중인 게임이 아님       | `대기 중인 게임에서만 설정을 변경할 수 있습니다.`   |

```json
{
  "title": "유효하지 않은 위치 공개 주기",
  "status": 400,
  "detail": "위치 공개 주기는 라운드 시간보다 짧아야 합니다.",
  "instance": "/api/games/1/settings"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/settings"
}
```

**403 - 방장 권한 없음**

```json
{
  "title": "호스트 권한 필요",
  "status": 403,
  "detail": "방장만 게임을 시작할 수 있습니다.",
  "instance": "/api/games/1/settings"
}
```

---

### 2.3 GET /api/games/{gameId} - 게임 기본 설정 조회

게임의 기본 설정 정보를 조회합니다.

- **인증 필요**: Yes (JWT)
- 대기 중(WAITING) 또는 진행 중(IN_PROGRESS) 상태에서만 조회 가능
- 해당 게임의 참가자만 조회 가능

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Responses

**200 - 게임 설정 조회 성공**

```json
{
  "roundDurationMinutes": 30,
  "locationRevealIntervalMinutes": 5,
  "policeWaitMinutes": 3,
  "maxParticipants": 10
}
```

**400 - 비활성 게임**

```json
{
  "title": "비활성 게임",
  "status": 400,
  "detail": "대기 중이거나 진행 중인 게임에서만 조회할 수 있습니다.",
  "instance": "/api/games/1"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1"
}
```

**404 - 게임 또는 참가자 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 게임을 찾을 수 없음   | 게임을 찾을 수 없음   | `요청하신 게임 정보가 존재하지 않습니다.` |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "요청하신 게임 정보가 존재하지 않습니다.",
  "instance": "/api/games/999"
}
```

---

## 3. Game Area API - 게임 맵 정보 조회

### 3.1 GET /api/games/{gameId}/area - 게임 맵 정보 조회

플레이그라운드 및 감옥 영역 정보를 조회합니다.

- **인증 필요**: Yes (JWT)
- 게임이 대기 중(WAITING) 또는 진행 중(IN_PROGRESS) 상태에서만 조회 가능
- 해당 게임의 참가자만 조회 가능

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Responses

**200 - 맵 정보 조회 성공**

```json
{
  "playgroundCenter": {
    "latitude": 37.5665,
    "longitude": 126.978
  },
  "playgroundRadiusInMeters": 1000,
  "jailCenter": {
    "latitude": 37.566,
    "longitude": 126.977
  },
  "jailRadiusInMeters": 100
}
```

**400 - 비활성 게임**

```json
{
  "title": "비활성 게임",
  "status": 400,
  "detail": "대기 중이거나 진행 중인 게임에서만 조회할 수 있습니다.",
  "instance": "/api/games/1/area"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/area"
}
```

**404 - 게임 또는 참가자 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 게임을 찾을 수 없음   | 게임을 찾을 수 없음   | `요청하신 게임 정보가 존재하지 않습니다.` |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "요청하신 게임 정보가 존재하지 않습니다.",
  "instance": "/api/games/999/area"
}
```

---

### 3.2 PUT /api/games/{gameId}/area - 게임 영역 수정

대기실에서 플레이그라운드 및 감옥 영역을 수정합니다.

- **인증 필요**: Yes (JWT)
- 방장만 호출 가능
- 게임이 WAITING 상태일 때만 가능
- 플레이그라운드와 감옥을 반드시 세트로 전송 (부분 수정 불가)
- 감옥은 플레이그라운드 내부에 완전히 포함되어야 함
- 감옥 반경 < 플레이그라운드 반경
- **WebSocket**: 성공 시 대기실 구독자 전체에게 `AREA_UPDATED` 이벤트가 브로드캐스트됩니다.

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Request Body (`application/json`)

| 필드                       | 타입                                      | 필수 | 설명                           |
| -------------------------- | ----------------------------------------- | ---- | ------------------------------ |
| `playgroundCenter`         | [CoordinatesRequest](#coordinatesrequest) | O    | 플레이그라운드 중심 좌표       |
| `playgroundRadiusInMeters` | integer (int32)                           | O    | 플레이그라운드 반경 (최소 10m) |
| `jailCenter`               | [CoordinatesRequest](#coordinatesrequest) | O    | 감옥 중심 좌표                 |
| `jailRadiusInMeters`       | integer (int32)                           | O    | 감옥 반경 (최소 5m)            |

**요청 예시:**

```json
{
  "playgroundCenter": {
    "latitude": 37.5665,
    "longitude": 126.978
  },
  "playgroundRadiusInMeters": 1000,
  "jailCenter": {
    "latitude": 37.567,
    "longitude": 126.9785
  },
  "jailRadiusInMeters": 100
}
```

#### Responses

**200 - 영역 수정 성공**

```json
{
  "playgroundCenter": {
    "latitude": 37.5665,
    "longitude": 126.978
  },
  "playgroundRadiusInMeters": 1000,
  "jailCenter": {
    "latitude": 37.567,
    "longitude": 126.9785
  },
  "jailRadiusInMeters": 100
}
```

**400 - 잘못된 요청**

| 케이스                          | title                 | detail                                              |
| ------------------------------- | --------------------- | --------------------------------------------------- |
| 감옥이 플레이그라운드 밖에 위치 | 감옥 영역 벗어남       | `감옥은 운동장 내부에 완전히 포함되어야 합니다.`    |
| 게임이 대기 중이 아닌 경우      | 대기 중인 게임이 아님  | `대기 중인 게임에서만 설정을 변경할 수 있습니다.`   |

```json
{
  "title": "감옥 영역 벗어남",
  "status": 400,
  "detail": "감옥은 운동장 내부에 완전히 포함되어야 합니다.",
  "instance": "/api/games/1/area"
}
```

**403 - 방장 권한 없음**

```json
{
  "title": "호스트 권한 필요",
  "status": 403,
  "detail": "방장만 게임을 시작할 수 있습니다.",
  "instance": "/api/games/1/area"
}
```

---

## 4. Game Participant API - 게임 참여자 관리

### 4.1 POST /api/games/join - 게임 방 참여

초대 코드를 사용하여 게임 방에 참여합니다. 이미 다른 활성 게임에 참여 중이거나, 게임이 이미 시작되었거나, 최대 참여 인원에 도달한 경우 참여할 수 없습니다.

- **인증 필요**: Yes (JWT)

#### Request Body (`application/json`)

| 필드         | 타입   | 필수 | 설명      |
| ------------ | ------ | ---- | --------- |
| `inviteCode` | string | O    | 초대 코드 |

**요청 예시:**

```json
{
  "inviteCode": "ABC123"
}
```

#### Responses

**200 - 게임 참여 성공**

```json
{
  "gameId": 1,
  "participantId": 2
}
```

**400 - 잘못된 요청**

| 케이스              | title                | detail                                     |
| ------------------- | -------------------- | ------------------------------------------ |
| 초대 코드 누락      | 유효하지 않은 입력값 | `inviteCode: 초대 코드는 필수입니다.`      |
| 잘못된 초대 코드    | 초대 코드 오류       | `입력하신 초대 코드가 유효하지 않습니다.`  |
| 게임이 이미 시작됨  | 게임 참여 불가       | `이미 시작된 게임에는 참여할 수 없습니다.` |
| 최대 참여 인원 초과 | 게임 참여 불가       | `게임 방의 최대 참여 인원에 도달했습니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "inviteCode: 초대 코드는 필수입니다.",
  "instance": "/api/games/join"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/join"
}
```

**409 - 이미 다른 활성 게임에 참여 중**

```json
{
  "title": "이미 참가 중인 게임",
  "status": 409,
  "detail": "이미 게임에 참가하고 있습니다.",
  "instance": "/api/games/join"
}
```

---

### 4.2 DELETE /api/games/{gameId}/leave - 게임 방 퇴장

현재 참여 중인 게임 방에서 퇴장합니다. 방장이 퇴장하는 경우 가장 먼저 참여한 참여자에게 방장 권한이 이전됩니다. 마지막 참여자가 퇴장하면 게임 방이 자동으로 삭제됩니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Responses

**200 - 게임 퇴장 성공**

일반 참여자 퇴장:

```json
{
  "leftUserId": 2,
  "remainingCount": 5
}
```

마지막 참여자 퇴장 (방 삭제):

```json
{
  "leftUserId": 1,
  "remainingCount": 0
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/leave"
}
```

**404 - 게임 또는 참여 정보를 찾을 수 없음**

| 케이스             | title                    | detail                                |
| ------------------ | ------------------------ | ------------------------------------- |
| 존재하지 않는 게임 | 게임을 찾을 수 없음      | `해당 게임을 찾을 수 없습니다.`       |
| 참여하지 않은 게임 | 참여 정보를 찾을 수 없음 | `해당 게임에 참여하고 있지 않습니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/leave"
}
```

---

### 4.3 GET /api/games/{gameId}/participants - 게임 참가자 인게임 상태 목록 조회

경찰/도둑 팀별 참가자 목록과 상태를 조회합니다.

- **인증 필요**: Yes (JWT)
- 게임이 진행 중(IN_PROGRESS) 상태에서만 조회 가능
- 해당 게임의 참가자만 조회 가능
- 경찰 상태: `POLICE_WAITING`(대기 중), `ALIVE`(활성)
- 도둑 상태: `ALIVE`(생존), `JAILED`(잡힘)

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Responses

**200 - 참가자 목록 조회 성공**

```json
{
  "police": [
    {
      "participantId": 1,
      "nickname": "경찰1",
      "status": "POLICE_WAITING"
    },
    {
      "participantId": 2,
      "nickname": "경찰2",
      "status": "ALIVE"
    }
  ],
  "robbers": [
    {
      "participantId": 3,
      "nickname": "도둑1",
      "status": "ALIVE"
    },
    {
      "participantId": 4,
      "nickname": "도둑2",
      "status": "JAILED"
    }
  ]
}
```

**400 - 게임 미진행**

```json
{
  "title": "게임 진행 중 아님",
  "status": 400,
  "detail": "게임이 진행 중인 상태가 아닙니다.",
  "instance": "/api/games/1/participants"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/participants"
}
```

**404 - 게임 또는 참가자 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 게임을 찾을 수 없음   | 게임을 찾을 수 없음   | `요청하신 게임 정보가 존재하지 않습니다.` |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "요청하신 게임 정보가 존재하지 않습니다.",
  "instance": "/api/games/999/participants"
}
```

---

## 5. Lobby API - 게임 로비 상태 변경

### 5.1 GET /api/games/{gameId}/lobby - 로비 조회

대기 상태(WAITING)인 게임의 로비 정보를 조회합니다. 요청자의 참가자 ID, 방장 ID, 전체 참가자 목록을 반환합니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Responses

**200 - 로비 조회 성공**

```json
{
  "myParticipantId": 2,
  "hostParticipantId": 1,
  "participants": [
    {
      "participantId": 1,
      "nickname": "방장닉네임",
      "team": "POLICE",
      "isReady": true
    },
    {
      "participantId": 2,
      "nickname": "내닉네임",
      "team": "ROBBER",
      "isReady": false
    }
  ]
}
```

**400 - 게임이 대기 상태가 아님**

```json
{
  "title": "이미 시작된 게임",
  "status": 400,
  "detail": "이미 시작된 게임에는 참여할 수 없습니다.",
  "instance": "/api/games/1/lobby"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/lobby"
}
```

**404 - 게임 또는 참여 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 존재하지 않는 게임    | 게임을 찾을 수 없음   | `요청하신 게임 정보가 존재하지 않습니다.` |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "요청하신 게임 정보가 존재하지 않습니다.",
  "instance": "/api/games/999/lobby"
}
```

---

### 5.2 PATCH /api/games/{gameId}/lobby/team - 로비 팀 변경

대기 상태(WAITING)에서만 팀을 변경할 수 있습니다. 팀 변경 시 해당 유저의 준비 상태는 해제됩니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Request Body (`application/json`)

| 필드         | 타입   | 필수 | 설명                           |
| ------------ | ------ | ---- | ------------------------------ |
| `targetTeam` | string | O    | 변경할 팀 (`POLICE`, `ROBBER`) |

**요청 예시 (경찰로 변경):**

```json
{
  "targetTeam": "POLICE"
}
```

**요청 예시 (도둑으로 변경):**

```json
{
  "targetTeam": "ROBBER"
}
```

#### Responses

**204 - 팀 변경 성공** (응답 본문 없음)

**400 - 잘못된 요청**

| 케이스              | title                | detail                                                   |
| ------------------- | -------------------- | -------------------------------------------------------- |
| 요청 바디 검증 실패 | 유효하지 않은 입력값 | `targetTeam: 팀은 필수입니다.`                           |
| 게임이 이미 시작됨  | 이미 시작된 게임     | `이미 시작된 게임에는 참여할 수 없습니다.`               |
| 로비 조작 불가      | 로비 조작 불가       | `게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "targetTeam: 팀은 필수입니다.",
  "instance": "/api/games/1/lobby/team"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/lobby/team"
}
```

**404 - 게임 또는 참여 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 존재하지 않는 게임    | 게임을 찾을 수 없음   | `해당 게임을 찾을 수 없습니다.`           |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/lobby/team"
}
```

---

### 5.3 PATCH /api/games/{gameId}/lobby/ready - 로비 준비 상태 변경

대기 상태(WAITING)에서만 준비 상태를 변경할 수 있습니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Request Body (`application/json`)

| 필드      | 타입    | 필수 | 설명      |
| --------- | ------- | ---- | --------- |
| `isReady` | boolean | O    | 준비 상태 |

**요청 예시 (준비 ON):**

```json
{
  "isReady": true
}
```

**요청 예시 (준비 OFF):**

```json
{
  "isReady": false
}
```

#### Responses

**204 - 준비 상태 변경 성공** (응답 본문 없음)

**400 - 잘못된 요청**

| 케이스              | title                | detail                                                   |
| ------------------- | -------------------- | -------------------------------------------------------- |
| 요청 바디 검증 실패 | 유효하지 않은 입력값 | `isReady: 준비 여부는 필수입니다.`                       |
| 방장 레디 해제 불가 | 방장 레디 해제 불가  | `방장은 항상 준비 상태여야 합니다.`                      |
| 게임이 이미 시작됨  | 이미 시작된 게임     | `이미 시작된 게임에는 참여할 수 없습니다.`               |
| 로비 조작 불가      | 로비 조작 불가       | `게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "isReady: 준비 여부는 필수입니다.",
  "instance": "/api/games/1/lobby/ready"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/lobby/ready"
}
```

**404 - 게임 또는 참여 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 존재하지 않는 게임    | 게임을 찾을 수 없음   | `해당 게임을 찾을 수 없습니다.`           |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/lobby/ready"
}
```

---

### 5.4 POST /api/games/{gameId}/lobby/start - 게임 시작

대기 중인 게임을 시작합니다.

- **인증 필요**: Yes (JWT)
- 방장(Host)만 시작 가능
- 경찰/도둑 팀 각각 1명 이상 필요
- 모든 참가자가 준비(Ready) 상태여야 함

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Responses

**204 - 게임 시작 성공** (응답 본문 없음)

**400 - 잘못된 요청**

| 케이스                      | title                     | detail                                                       |
| --------------------------- | ------------------------- | ------------------------------------------------------------ |
| 방장이 아님                 | 권한 없음                 | `게임을 시작할 수 있는 권한이 없습니다. (방장만 가능)`       |
| 팀 구성 오류                | 팀 구성 오류              | `경찰과 도둑 팀에 각각 최소 1명 이상의 참가자가 필요합니다.` |
| 모든 참가자가 준비하지 않음 | 준비되지 않은 참가자 존재 | `모든 참가자가 준비 상태여야 게임을 시작할 수 있습니다.`     |
| 게임이 이미 시작됨          | 이미 시작된 게임          | `이미 시작된 게임에는 참여할 수 없습니다.`                   |
| 로비 조작 불가              | 로비 조작 불가            | `게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다.`     |

```json
{
  "title": "권한 없음",
  "status": 400,
  "detail": "게임을 시작할 수 있는 권한이 없습니다. (방장만 가능)",
  "instance": "/api/games/1/lobby/start"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/lobby/start"
}
```

**404 - 게임 또는 참여 정보 없음**

| 케이스                | title                 | detail                                    |
| --------------------- | --------------------- | ----------------------------------------- |
| 존재하지 않는 게임    | 게임을 찾을 수 없음   | `해당 게임을 찾을 수 없습니다.`           |
| 참가자를 찾을 수 없음 | 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/lobby/start"
}
```

---

## 6. User API - 사용자 정보 및 프로필 관리

### 6.1 GET /api/user/me - 내 정보 조회

로그인한 사용자의 상세 정보를 조회합니다. (일단은 테스트용)

- **인증 필요**: Yes (JWT)

#### Responses

**200 - 조회 성공**

```json
{
  "userId": 7,
  "nickname": "민첩한괴도5308",
  "socialPlatform": "KAKAO",
  "allowGamePush": true,
  "allowMarketingPush": false
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 실패",
  "status": 401,
  "detail": "유효하지 않은 토큰입니다.",
  "instance": "/api/user/me"
}
```

---

### 6.2 PATCH /api/user/me/nickname - 닉네임 변경

로그인한 사용자의 닉네임을 변경합니다. (최대 10자, 중복 불가)

- **인증 필요**: Yes (JWT)
- 현재 유저 본인의 닉네임으로 변경 요청 시에도 204 응답

#### Request Body (`application/json`)

| 필드       | 타입   | 필수 | 설명                      |
| ---------- | ------ | ---- | ------------------------- |
| `nickname` | string | O    | 변경할 닉네임 (최대 10자) |

**요청 예시:**

```json
{
  "nickname": "날렵한경찰123"
}
```

#### Responses

**204 - 변경 성공** (응답 본문 없음)

**400 - 유효성 검사 실패**

| 케이스                | title                | detail                                         |
| --------------------- | -------------------- | ---------------------------------------------- |
| 공백 입력             | 유효하지 않은 입력값 | `nickname: 닉네임은 필수 입력 항목입니다.`     |
| 길이 초과 (10자 초과) | 유효하지 않은 입력값 | `nickname: 닉네임은 최대 10자까지 가능합니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "nickname: 닉네임은 필수 입력 항목입니다.",
  "instance": "/api/user/me/nickname"
}
```

**409 - 닉네임 중복**

```json
{
  "title": "닉네임 중복",
  "status": 409,
  "detail": "이미 사용 중인 닉네임입니다. 다른 닉네임을 선택해주세요.",
  "instance": "/api/user/me/nickname"
}
```

---

### 6.3 GET /api/user/check-nickname - 닉네임 중복 확인

닉네임 변경 전, 해당 닉네임이 이미 사용 중인지 확인합니다. (쿼리 파라미터로 요청)

- **인증 필요**: No

#### Query Parameters

| 파라미터   | 타입   | 필수 | 설명          | 예시             |
| ---------- | ------ | ---- | ------------- | ---------------- |
| `nickname` | string | O    | 확인할 닉네임 | `민첩한괴도5308` |

**요청 예시:**

```http
GET /api/user/check-nickname?nickname=민첩한괴도5308
```

#### Responses

**200 - 확인 완료**

사용 가능한 닉네임:

```json
{
  "isAvailable": true,
  "message": "사용 가능한 닉네임 입니다!"
}
```

사용 중인 닉네임 (중복):

```json
{
  "isAvailable": false,
  "message": "이미 사용 중인 닉네임입니다."
}
```

**400 - 파라미터 누락**

```json
{
  "title": "잘못된 요청",
  "status": 400,
  "detail": "Required request parameter 'nickname' for method parameter type String is not present",
  "instance": "/api/user/check-nickname"
}
```

---

### 6.4 DELETE /api/user/me - 회원탈퇴

로그인한 사용자의 사용자 정보를 삭제합니다.

- **인증 필요**: Yes (JWT)

#### Responses

**200 - 탈퇴 성공**

```json
{
  "message": "회원탈퇴가 완료되었습니다."
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 실패",
  "status": 401,
  "detail": "유효하지 않은 토큰입니다.",
  "instance": "/api/user/me"
}
```

**409 - 진행 중인 게임이 있는 경우**

```json
{
  "title": "회원탈퇴 불가",
  "status": 409,
  "detail": "진행 중인 게임 세션이 있어 탈퇴할 수 없습니다.",
  "instance": "/api/user/me"
}
```

---

## 7. System API - 게임 시스템 상호작용

### 7.1 POST /api/games/{gameId}/system/arrest - 도둑 체포

경찰이 도둑을 체포합니다.

- **인증 필요**: Yes (JWT)
- 경찰만 요청 가능
- 도둑만 체포 대상이 될 수 있음
- 이미 체포된 도둑은 체포 불가
- 같은 게임 내 참가자끼리만 상호작용 가능

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Request Body (`application/json`)

| 필드                  | 타입            | 필수 | 설명                   |
| --------------------- | --------------- | ---- | ---------------------- |
| `robberParticipantId` | integer (int64) | O    | 체포 대상 도둑 참가 ID |

**요청 예시:**

```json
{
  "robberParticipantId": 102
}
```

#### Responses

**200 - 체포 성공**

```json
{
  "robberNickname": "잡힌도둑",
  "remainingThieves": 2
}
```

**400 - 잘못된 요청**

| 케이스             | title              | detail                                              |
| ------------------ | ------------------ | --------------------------------------------------- |
| 게임 진행 중 아님  | 게임 진행 중 아님  | `게임이 진행 중인 상태가 아닙니다.`                 |
| 경찰이 아님        | 경찰만 체포 가능   | `경찰 팀만 도둑을 체포할 수 있습니다.`              |
| 경찰 대기 시간     | 경찰 대기 시간     | `경찰은 대기 시간 동안 도둑을 체포할 수 없습니다.`  |
| 대상이 도둑이 아님 | 도둑만 체포 가능   | `도둑 팀만 체포될 수 있습니다.`                     |
| 참가자 게임 불일치 | 참가자 게임 불일치 | `경찰과 도둑이 서로 다른 게임에 참여하고 있습니다.` |
| 이미 체포된 도둑   | 이미 체포됨        | `이미 수감된 도둑입니다.`                           |

```json
{
  "title": "경찰만 체포 가능",
  "status": 400,
  "detail": "경찰 팀만 도둑을 체포할 수 있습니다.",
  "instance": "/api/games/1/system/arrest"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/system/arrest"
}
```

**404 - 참가자 정보 없음**

```json
{
  "title": "참가자를 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임에 참가하지 않은 사용자입니다.",
  "instance": "/api/games/1/system/arrest"
}
```

---

### 7.2 POST /api/games/{gameId}/system/escape - 도둑 탈옥

수감된 도둑이 탈옥합니다.

- **인증 필요**: Yes (JWT)
- 도둑만 요청 가능
- 수감된 상태(JAILED)에서만 탈옥 가능

#### Path Parameters

| 파라미터 | 타입            | 필수 | 설명    | 예시 |
| -------- | --------------- | ---- | ------- | ---- |
| `gameId` | integer (int64) | O    | 게임 ID | `1`  |

#### Request Body

없음

#### Responses

**204 - 탈옥 성공** (응답 본문 없음)

**400 - 잘못된 요청**

| 케이스            | title             | detail                                  |
| ----------------- | ----------------- | --------------------------------------- |
| 게임 진행 중 아님 | 게임 진행 중 아님 | `게임이 진행 중인 상태가 아닙니다.`     |
| 수감되지 않음     | 수감되지 않음     | `수감된 상태에서만 탈옥할 수 있습니다.` |

```json
{
  "title": "수감되지 않음",
  "status": 400,
  "detail": "수감된 상태에서만 탈옥할 수 있습니다.",
  "instance": "/api/games/1/system/escape"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/system/escape"
}
```

**404 - 참가자 정보 없음**

```json
{
  "title": "참가자를 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임에 참가하지 않은 사용자입니다.",
  "instance": "/api/games/1/system/escape"
}
```

---

## 8. 공통 스키마

### ErrorResponse

모든 에러 응답의 공통 형식입니다.

```json
{
  "title": "에러 제목",
  "status": 400,
  "detail": "에러 상세 설명",
  "instance": "/api/요청경로"
}
```

| 필드       | 타입            | 설명           |
| ---------- | --------------- | -------------- |
| `title`    | string          | 에러 제목      |
| `status`   | integer (int32) | HTTP 상태 코드 |
| `detail`   | string          | 에러 상세 설명 |
| `instance` | string          | 요청 경로      |

---

### LoginRequest

| 필드             | 타입   | 필수 | 설명                           |
| ---------------- | ------ | ---- | ------------------------------ |
| `socialPlatform` | string | O    | `KAKAO` \| `GOOGLE` \| `APPLE` |
| `idToken`        | string | O    | 소셜 인증 토큰                 |
| `fcmToken`       | string | O    | FCM 디바이스 토큰              |
| `deviceType`     | string | O    | `IOS` \| `ANDROID`             |
| `deviceId`       | string | O    | 고유 디바이스 ID               |

### LoginResponse

| 필드        | 타입              | 설명           |
| ----------- | ----------------- | -------------- |
| `userId`    | integer (int64)   | 사용자 ID      |
| `nickname`  | string            | 닉네임         |
| `tokens`    | [Tokens](#tokens) | 토큰 정보      |
| `isNewUser` | boolean           | 신규 회원 여부 |

### Tokens

| 필드           | 타입   | 설명              |
| -------------- | ------ | ----------------- |
| `accessToken`  | string | JWT Access Token  |
| `refreshToken` | string | JWT Refresh Token |

### LogoutRequest

| 필드           | 타입   | 필수 | 설명          |
| -------------- | ------ | ---- | ------------- |
| `refreshToken` | string | O    | Refresh Token |

### ReissueRequest

| 필드           | 타입   | 필수 | 설명          |
| -------------- | ------ | ---- | ------------- |
| `refreshToken` | string | O    | Refresh Token |

### ReissueResponse

| 필드     | 타입              | 설명                        |
| -------- | ----------------- | --------------------------- |
| `tokens` | [Tokens](#tokens) | JWT 토큰 (Access + Refresh) |

### GameCreateRequest

| 필드       | 타입                                        | 필수 | 설명           |
| ---------- | ------------------------------------------- | ---- | -------------- |
| `area`     | [GameAreaRequest](#gamearearequest)         | O    | 영역 설정      |
| `settings` | [GameSettingsRequest](#gamesettingsrequest) | O    | 게임 규칙 설정 |

### GameAreaRequest

| 필드                       | 타입                                      | 필수 | 설명                           |
| -------------------------- | ----------------------------------------- | ---- | ------------------------------ |
| `playgroundCenter`         | [CoordinatesRequest](#coordinatesrequest) | O    | 플레이그라운드 중심 좌표       |
| `playgroundRadiusInMeters` | integer (int32)                           | O    | 플레이그라운드 반경 (최소 10m) |
| `jailCenter`               | [CoordinatesRequest](#coordinatesrequest) | O    | 감옥 중심 좌표                 |
| `jailRadiusInMeters`       | integer (int32)                           | O    | 감옥 반경 (최소 5m)            |

### CoordinatesRequest

| 필드        | 타입   | 필수 | 범위       | 설명 |
| ----------- | ------ | ---- | ---------- | ---- |
| `latitude`  | double | O    | -90 ~ 90   | 위도 |
| `longitude` | double | O    | -180 ~ 180 | 경도 |

### Coordinates

응답에서 사용되는 좌표 객체입니다.

| 필드        | 타입   | 설명 |
| ----------- | ------ | ---- |
| `latitude`  | double | 위도 |
| `longitude` | double | 경도 |

### GameSettingsRequest

| 필드                            | 타입            | 필수 | 범위   | 설명                |
| ------------------------------- | --------------- | ---- | ------ | ------------------- |
| `roundDurationMinutes`          | integer (int32) | O    | 10~180 | 라운드 시간 (분)    |
| `locationRevealIntervalMinutes` | integer (int32) | O    | 5~     | 위치 공개 주기 (분) |
| `policeWaitMinutes`             | integer (int32) | O    | 0~     | 경찰 대기 시간 (분) |
| `maxParticipants`               | integer (int32) | O    | 2~50   | 최대 참여 인원      |

### GameSettingsUpdateResponse

| 필드                            | 타입            | 설명           |
| ------------------------------- | --------------- | -------------- |
| `roundDurationMinutes`          | integer (int32) | 라운드 시간    |
| `locationRevealIntervalMinutes` | integer (int32) | 위치 공개 주기 |
| `policeWaitMinutes`             | integer (int32) | 경찰 대기 시간 |
| `maxParticipants`               | integer (int32) | 최대 참여 인원 |

### GameInfoResponse

| 필드                            | 타입            | 설명           |
| ------------------------------- | --------------- | -------------- |
| `roundDurationMinutes`          | integer (int32) | 라운드 시간    |
| `locationRevealIntervalMinutes` | integer (int32) | 위치 공개 주기 |
| `policeWaitMinutes`             | integer (int32) | 경찰 대기 시간 |
| `maxParticipants`               | integer (int32) | 최대 참여 인원 |

### GameAreaResponse

| 필드                       | 타입                          | 설명                 |
| -------------------------- | ----------------------------- | -------------------- |
| `playgroundCenter`         | [Coordinates](#coordinates)   | 플레이그라운드 중심  |
| `playgroundRadiusInMeters` | integer (int32)               | 플레이그라운드 반경  |
| `jailCenter`               | [Coordinates](#coordinates)   | 감옥 중심            |
| `jailRadiusInMeters`       | integer (int32)               | 감옥 반경            |

### GameAreaUpdateResponse

| 필드                       | 타입                          | 설명                 |
| -------------------------- | ----------------------------- | -------------------- |
| `playgroundCenter`         | [Coordinates](#coordinates)   | 플레이그라운드 중심  |
| `playgroundRadiusInMeters` | integer (int32)               | 플레이그라운드 반경  |
| `jailCenter`               | [Coordinates](#coordinates)   | 감옥 중심            |
| `jailRadiusInMeters`       | integer (int32)               | 감옥 반경            |

### GameCreateResponse

| 필드                            | 타입               | 설명           |
| ------------------------------- | ------------------ | -------------- |
| `gameId`                        | integer (int64)    | 게임 ID        |
| `inviteCode`                    | string             | 초대 코드      |
| `status`                        | string             | 게임 상태      |
| `roundDurationMinutes`          | integer (int32)    | 라운드 시간    |
| `locationRevealIntervalMinutes` | integer (int32)    | 위치 공개 주기 |
| `policeWaitMinutes`             | integer (int32)    | 경찰 대기 시간 |
| `maxParticipants`               | integer (int32)    | 최대 참여 인원 |
| `createdAt`                     | string (date-time) | 생성 시간      |

### GameJoinRequest

| 필드         | 타입   | 필수 | 설명      |
| ------------ | ------ | ---- | --------- |
| `inviteCode` | string | O    | 초대 코드 |

### GameJoinResponse

| 필드            | 타입            | 설명      |
| --------------- | --------------- | --------- |
| `gameId`        | integer (int64) | 게임 ID   |
| `participantId` | integer (int64) | 참여자 ID |

### GameLeaveResponse

| 필드             | 타입            | 설명             |
| ---------------- | --------------- | ---------------- |
| `leftUserId`     | integer (int64) | 퇴장한 사용자 ID |
| `remainingCount` | integer (int32) | 남은 참여자 수   |

### GameParticipantListResponse

| 필드      | 타입                                          | 설명          |
| --------- | --------------------------------------------- | ------------- |
| `police`  | [ParticipantResponse](#participantresponse)[] | 경찰 팀 목록  |
| `robbers` | [ParticipantResponse](#participantresponse)[] | 도둑 팀 목록  |

### ParticipantResponse

로비 및 인게임 참가자 정보에 공통으로 사용됩니다.

| 필드            | 타입            | 설명                             |
| --------------- | --------------- | -------------------------------- |
| `participantId` | integer (int64) | 참가자 ID                        |
| `nickname`      | string          | 닉네임                           |
| `team`          | string          | 팀 (`POLICE` \| `ROBBER`)        |
| `isReady`       | boolean         | 준비 상태 (로비에서 사용)        |

> **참고**: 인게임 참가자 목록 조회 시 응답 예시에서는 `status` 필드(`POLICE_WAITING`, `ALIVE`, `JAILED`)가 사용됩니다. 스키마 정의와 Swagger 예시가 불일치하는 경우, 실제 서버 응답은 스키마 업데이트를 기다려야 합니다.

### LobbyInfoResponse

| 필드                | 타입                                          | 설명          |
| ------------------- | --------------------------------------------- | ------------- |
| `myParticipantId`   | integer (int64)                               | 나의 참가자 ID |
| `hostParticipantId` | integer (int64)                               | 방장 참가자 ID |
| `participants`      | [ParticipantResponse](#participantresponse)[] | 참가자 목록    |

### TeamChangeRequest

| 필드         | 타입   | 필수 | 설명                 |
| ------------ | ------ | ---- | -------------------- |
| `targetTeam` | string | O    | `POLICE` \| `ROBBER` |

### ReadyUpdateRequest

| 필드      | 타입    | 필수 | 설명      |
| --------- | ------- | ---- | --------- |
| `isReady` | boolean | O    | 준비 상태 |

### ArrestRequest

| 필드                  | 타입            | 필수 | 설명                   |
| --------------------- | --------------- | ---- | ---------------------- |
| `robberParticipantId` | integer (int64) | O    | 체포 대상 도둑 참가 ID |

### ArrestResponse

| 필드               | 타입            | 설명               |
| ------------------ | --------------- | ------------------ |
| `robberNickname`   | string          | 체포된 도둑 닉네임 |
| `remainingThieves` | integer (int32) | 남은 도둑 수       |

### NicknameUpdateRequest

| 필드       | 타입   | 필수 | 설명                      |
| ---------- | ------ | ---- | ------------------------- |
| `nickname` | string | O    | 변경할 닉네임 (최대 10자) |

### NicknameCheckResponse

| 필드          | 타입    | 설명           |
| ------------- | ------- | -------------- |
| `isAvailable` | boolean | 사용 가능 여부 |
| `message`     | string  | 결과 메시지    |

### MyPageResponse

| 필드                 | 타입            | 설명                           |
| -------------------- | --------------- | ------------------------------ |
| `userId`             | integer (int64) | 사용자 ID                      |
| `nickname`           | string          | 닉네임                         |
| `socialPlatform`     | string          | `KAKAO` \| `GOOGLE` \| `APPLE` |
| `allowGamePush`      | boolean         | 게임 푸시 허용 여부            |
| `allowMarketingPush` | boolean         | 마케팅 푸시 허용 여부          |

### DeleteAccountResponse

| 필드      | 타입   | 설명      |
| --------- | ------ | --------- |
| `message` | string | 결과 메시지 |
