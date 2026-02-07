# API 명세서 (API Specification)

> **Base URL**: `http://43.203.59.210:8080`
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
3. [Game Participant API - 게임 참여자 관리](#3-game-participant-api---게임-참여자-관리)
   - [POST /api/games/{gameId}/participants - 게임 방 참여](#31-post-apigamesgameidparticipants---게임-방-참여)
   - [DELETE /api/games/{gameId}/participants - 게임 방 퇴장](#32-delete-apigamesgameidparticipants---게임-방-퇴장)
4. [Lobby API - 게임 로비 상태 변경](#4-lobby-api---게임-로비-상태-변경)
   - [PATCH /api/games/{gameId}/team - 로비 팀 변경](#41-patch-apigamesgameidteam---로비-팀-변경)
   - [PATCH /api/games/{gameId}/ready - 로비 준비 상태 변경](#42-patch-apigamesgameidready---로비-준비-상태-변경)
5. [User API - 사용자 정보 및 프로필 관리](#5-user-api---사용자-정보-및-프로필-관리)
   - [GET /api/user/me - 내 정보 조회](#51-get-apiuserme---내-정보-조회)
   - [PATCH /api/user/me/nickname - 닉네임 변경](#52-patch-apiusermenickname---닉네임-변경)
   - [GET /api/user/check-nickname - 닉네임 중복 확인](#53-get-apiusercheck-nickname---닉네임-중복-확인)
6. [공통 스키마](#6-공통-스키마)

---

## 1. Auth API - 소셜 로그인 및 토큰 관리

### 1.1 POST /api/auth/login - 소셜 로그인

소셜 로그인을 통해 서비스에 로그인합니다. 신규 회원인 경우 자동으로 회원가입이 진행되며, Access Token과 Refresh Token이 발급됩니다.

- **인증 필요**: No

#### Request Body (`application/json`)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `socialPlatform` | string | O | 소셜 플랫폼 (`KAKAO`, `GOOGLE`, `APPLE`) |
| `idToken` | string | O | 소셜 인증 토큰 (ID Token) |
| `fcmToken` | string | O | FCM 디바이스 토큰 |
| `deviceType` | string | O | 디바이스 타입 (`IOS`, `ANDROID`) |
| `deviceId` | string | O | 고유 디바이스 ID |

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

| 케이스 | detail |
|--------|--------|
| 필수 요청 필드 누락 | `idToken: 소셜 인증 토큰(ID Token)은 필수입니다.` |
| JSON 형식 오류 | `요청 본문의 형식이 잘못되었습니다.` |

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

#### Request Body (`application/json`) - [ReissueRequest](#reissuerequest) 재사용

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `refreshToken` | string | O | Refresh Token |

**요청 예시:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njk3MDQ2MDV9..."
}
```

#### Responses

**204 - 로그아웃 성공** (응답 본문 없음)

---

### 1.3 POST /api/auth/reissue - 토큰 재발급

만료된 Access Token을 Refresh Token을 사용하여 재발급받습니다.

- **인증 필요**: No

#### Request Body (`application/json`)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `refreshToken` | string | O | Refresh Token |

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
    "accessToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njg0OTg2MDV9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzY4NDk1MDA1LCJleHAiOjE3Njk3MDQ2MDV9..."
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

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `area` | [AreaRequest](#arearequest) | O | 영역 설정 |
| `area.playgroundCenter` | [CoordinatesRequest](#coordinatesrequest) | O | 플레이그라운드 중심 좌표 |
| `area.playgroundRadiusInMeters` | integer | O | 플레이그라운드 반경 (최소 10m) |
| `area.jailCenter` | [CoordinatesRequest](#coordinatesrequest) | O | 감옥 중심 좌표 |
| `area.jailRadiusInMeters` | integer | O | 감옥 반경 (최소 5m) |
| `settings` | [GameSettingsRequest](#gamesettingsrequest) | O | 게임 규칙 설정 |
| `settings.roundDurationMinutes` | integer | O | 라운드 시간 (10~180분) |
| `settings.locationRevealIntervalMinutes` | integer | O | 위치 공개 주기 (최소 5분) |
| `settings.policeWaitMinutes` | integer | O | 경찰 대기 시간 (최소 0분) |
| `settings.maxParticipants` | integer | O | 최대 참여 인원 (2~50명) |

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

| 케이스 | detail |
|--------|--------|
| 필수 필드 누락 | `area: 영역 설정은 필수입니다.` |
| 감옥이 플레이그라운드 밖 | `감옥 영역이 플레이그라운드 영역 내에 포함되어야 합니다.` |
| 위치 공개 주기 > 라운드 시간 | `위치 공개 주기는 라운드 시간보다 짧아야 합니다.` |
| JSON 형식 오류 | `요청 본문의 형식이 잘못되었습니다.` |

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

## 3. Game Participant API - 게임 참여자 관리

### 3.1 POST /api/games/{gameId}/participants - 게임 방 참여

초대 코드를 사용하여 게임 방에 참여합니다. 이미 다른 활성 게임에 참여 중이거나, 게임이 이미 시작되었거나, 최대 참여 인원에 도달한 경우 참여할 수 없습니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입 | 필수 | 설명 | 예시 |
|----------|------|------|------|------|
| `gameId` | integer (int64) | O | 게임 ID | `1` |

#### Request Body (`application/json`)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `inviteCode` | string | O | 초대 코드 |

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
  "participantId": 5
}
```

**400 - 잘못된 요청**

| 케이스 | detail |
|--------|--------|
| 초대 코드 누락 | `inviteCode: 초대 코드는 필수입니다.` |
| 잘못된 초대 코드 | `잘못된 초대 코드입니다.` |
| 게임이 이미 시작됨 | `이미 시작된 게임에는 참여할 수 없습니다.` |
| 최대 참여 인원 초과 | `게임 방의 최대 참여 인원에 도달했습니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "inviteCode: 초대 코드는 필수입니다.",
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

**404 - 게임을 찾을 수 없음**
```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/participants"
}
```

**409 - 이미 다른 활성 게임에 참여 중**
```json
{
  "title": "이미 참가 중인 게임",
  "status": 409,
  "detail": "이미 게임에 참가하고 있습니다.",
  "instance": "/api/games/1/participants"
}
```

---

### 3.2 DELETE /api/games/{gameId}/participants - 게임 방 퇴장

현재 참여 중인 게임 방에서 퇴장합니다. 방장이 퇴장하는 경우 가장 먼저 참여한 참여자에게 방장 권한이 이전됩니다. 마지막 참여자가 퇴장하면 게임 방이 자동으로 삭제됩니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입 | 필수 | 설명 | 예시 |
|----------|------|------|------|------|
| `gameId` | integer (int64) | O | 게임 ID | `1` |

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
  "instance": "/api/games/1/participants"
}
```

**404 - 게임 또는 참여 정보를 찾을 수 없음**

| 케이스 | detail |
|--------|--------|
| 존재하지 않는 게임 | `해당 게임을 찾을 수 없습니다.` |
| 참여하지 않은 게임 | `해당 게임에 참여하고 있지 않습니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/participants"
}
```

---

## 4. Lobby API - 게임 로비 상태 변경

### 4.1 PATCH /api/games/{gameId}/team - 로비 팀 변경

대기 상태(WAITING)에서만 팀을 변경할 수 있습니다. 팀 변경 시 해당 유저의 준비 상태는 해제됩니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입 | 필수 | 설명 | 예시 |
|----------|------|------|------|------|
| `gameId` | integer (int64) | O | 게임 ID | `1` |

#### Request Body (`application/json`)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `targetTeam` | string | O | 변경할 팀 (`POLICE`, `ROBBER`) |

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

| 케이스 | detail |
|--------|--------|
| 요청 바디 검증 실패 | `targetTeam: 팀은 필수입니다.` |
| 게임이 이미 시작됨 | `이미 시작된 게임에는 참여할 수 없습니다.` |
| 로비 조작 불가 | `게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "targetTeam: 팀은 필수입니다.",
  "instance": "/api/games/1/team"
}
```

**401 - 인증 실패**
```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/team"
}
```

**404 - 게임 또는 참여 정보 없음**

| 케이스 | detail |
|--------|--------|
| 존재하지 않는 게임 | `해당 게임을 찾을 수 없습니다.` |
| 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/team"
}
```

---

### 4.2 PATCH /api/games/{gameId}/ready - 로비 준비 상태 변경

대기 상태(WAITING)에서만 준비 상태를 변경할 수 있습니다.

- **인증 필요**: Yes (JWT)

#### Path Parameters

| 파라미터 | 타입 | 필수 | 설명 | 예시 |
|----------|------|------|------|------|
| `gameId` | integer (int64) | O | 게임 ID | `1` |

#### Request Body (`application/json`)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `isReady` | boolean | O | 준비 상태 |

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

| 케이스 | detail |
|--------|--------|
| 요청 바디 검증 실패 | `isReady: 준비 여부는 필수입니다.` |
| 게임이 이미 시작됨 | `이미 시작된 게임에는 참여할 수 없습니다.` |
| 로비 조작 불가 | `게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "isReady: 준비 여부는 필수입니다.",
  "instance": "/api/games/1/ready"
}
```

**401 - 인증 실패**
```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/games/1/ready"
}
```

**404 - 게임 또는 참여 정보 없음**

| 케이스 | detail |
|--------|--------|
| 존재하지 않는 게임 | `해당 게임을 찾을 수 없습니다.` |
| 참가자를 찾을 수 없음 | `해당 게임에 참가하지 않은 사용자입니다.` |

```json
{
  "title": "게임을 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임을 찾을 수 없습니다.",
  "instance": "/api/games/999/ready"
}
```

---

## 5. User API - 사용자 정보 및 프로필 관리

### 5.1 GET /api/user/me - 내 정보 조회

현재 로그인한 사용자의 정보를 조회합니다.

- **인증 필요**: Yes (JWT)

#### Responses

**200 - 사용자 정보 조회 성공**
```json
{
  "userId": 1,
  "nickname": "민첩한괴도5308",
  "socialPlatform": "KAKAO",
  "allowGamePush": true,
  "allowMarketingPush": false
}
```

**401 - 인증 실패**
```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/user/me"
}
```

---

### 5.2 PATCH /api/user/me/nickname - 닉네임 변경

현재 로그인한 사용자의 닉네임을 변경합니다. 본인의 현재 닉네임으로 변경 요청 시에도 204가 반환됩니다.

- **인증 필요**: Yes (JWT)

#### Request Body (`application/json`)

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `nickname` | string | O | 변경할 닉네임 (최대 10자) |

**요청 예시:**
```json
{
  "nickname": "새닉네임"
}
```

#### Responses

**204 - 닉네임 변경 성공** (응답 본문 없음)

**400 - 잘못된 요청**

| 케이스 | detail |
|--------|--------|
| 닉네임 누락/공백 | `nickname: 닉네임은 필수입니다.` |
| 길이 초과 (10자 초과) | `nickname: 닉네임은 최대 10자까지 가능합니다.` |

```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "nickname: 닉네임은 필수입니다.",
  "instance": "/api/user/me/nickname"
}
```

**401 - 인증 실패**
```json
{
  "title": "인증 필요",
  "status": 401,
  "detail": "로그인이 필요한 서비스입니다.",
  "instance": "/api/user/me/nickname"
}
```

**409 - 닉네임 중복**
```json
{
  "title": "닉네임 중복",
  "status": 409,
  "detail": "이미 사용 중인 닉네임입니다.",
  "instance": "/api/user/me/nickname"
}
```

---

### 5.3 GET /api/user/check-nickname - 닉네임 중복 확인

닉네임의 사용 가능 여부를 확인합니다.

- **인증 필요**: No

#### Query Parameters

| 파라미터 | 타입 | 필수 | 설명 | 예시 |
|----------|------|------|------|------|
| `nickname` | string | O | 확인할 닉네임 | `새닉네임` |

**요청 예시:**
```
GET /api/user/check-nickname?nickname=새닉네임
```

#### Responses

**200 - 닉네임 확인 결과**
```json
{
  "isAvailable": true,
  "message": "사용 가능한 닉네임입니다."
}
```

```json
{
  "isAvailable": false,
  "message": "이미 사용 중인 닉네임입니다."
}
```

**400 - 파라미터 누락**
```json
{
  "title": "유효하지 않은 입력값",
  "status": 400,
  "detail": "nickname: 닉네임은 필수입니다.",
  "instance": "/api/user/check-nickname"
}
```

---

## 6. 공통 스키마

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

| 필드 | 타입 | 설명 |
|------|------|------|
| `title` | string | 에러 제목 |
| `status` | integer | HTTP 상태 코드 |
| `detail` | string | 에러 상세 설명 |
| `instance` | string | 요청 경로 |

---

### LoginRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `socialPlatform` | string | O | `KAKAO` \| `GOOGLE` \| `APPLE` |
| `idToken` | string | O | 소셜 인증 토큰 |
| `fcmToken` | string | O | FCM 디바이스 토큰 |
| `deviceType` | string | O | `IOS` \| `ANDROID` |
| `deviceId` | string | O | 고유 디바이스 ID |

### LoginResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `userId` | integer (int64) | 사용자 ID |
| `nickname` | string | 닉네임 |
| `tokens` | [Tokens](#tokens) | 토큰 정보 |
| `isNewUser` | boolean | 신규 회원 여부 |

### Tokens

| 필드 | 타입 | 설명 |
|------|------|------|
| `accessToken` | string | JWT Access Token |
| `refreshToken` | string | JWT Refresh Token |

### ReissueRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `refreshToken` | string | O | Refresh Token |

### ReissueResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `tokens` | [Tokens](#tokens) | JWT 토큰 (Access + Refresh) |

### GameCreateRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `area` | [AreaRequest](#arearequest) | O | 영역 설정 |
| `settings` | [GameSettingsRequest](#gamesettingsrequest) | O | 게임 규칙 설정 |

### AreaRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `playgroundCenter` | [CoordinatesRequest](#coordinatesrequest) | O | 플레이그라운드 중심 좌표 |
| `playgroundRadiusInMeters` | integer (int32) | O | 플레이그라운드 반경 (최소 10m) |
| `jailCenter` | [CoordinatesRequest](#coordinatesrequest) | O | 감옥 중심 좌표 |
| `jailRadiusInMeters` | integer (int32) | O | 감옥 반경 (최소 5m) |

### CoordinatesRequest

| 필드 | 타입 | 필수 | 범위 | 설명 |
|------|------|------|------|------|
| `latitude` | double | O | -90 ~ 90 | 위도 |
| `longitude` | double | O | -180 ~ 180 | 경도 |

### GameSettingsRequest

| 필드 | 타입 | 필수 | 범위 | 설명 |
|------|------|------|------|------|
| `roundDurationMinutes` | integer (int32) | O | 10~180 | 라운드 시간 (분) |
| `locationRevealIntervalMinutes` | integer (int32) | O | 5~ | 위치 공개 주기 (분) |
| `policeWaitMinutes` | integer (int32) | O | 0~ | 경찰 대기 시간 (분) |
| `maxParticipants` | integer (int32) | O | 2~50 | 최대 참여 인원 |

### GameCreateResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `gameId` | integer (int64) | 게임 ID |
| `inviteCode` | string | 초대 코드 |
| `status` | string | 게임 상태 |
| `roundDurationMinutes` | integer (int32) | 라운드 시간 |
| `locationRevealIntervalMinutes` | integer (int32) | 위치 공개 주기 |
| `policeWaitMinutes` | integer (int32) | 경찰 대기 시간 |
| `maxParticipants` | integer (int32) | 최대 참여 인원 |
| `createdAt` | string (date-time) | 생성 시간 |

### GameJoinRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `inviteCode` | string | O | 초대 코드 |

### GameJoinResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `gameId` | integer (int64) | 게임 ID |
| `participantId` | integer (int64) | 참여자 ID |

### GameLeaveResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `leftUserId` | integer (int64) | 퇴장한 사용자 ID |
| `remainingCount` | integer (int32) | 남은 참여자 수 |

### TeamChangeRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `targetTeam` | string | O | `POLICE` \| `ROBBER` |

### ReadyUpdateRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `isReady` | boolean | O | 준비 상태 |

### NicknameUpdateRequest

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `nickname` | string | O | 변경할 닉네임 (최대 10자) |

### NicknameCheckResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `isAvailable` | boolean | 사용 가능 여부 |
| `message` | string | 결과 메시지 |

### MyPageResponse

| 필드 | 타입 | 설명 |
|------|------|------|
| `userId` | integer (int64) | 사용자 ID |
| `nickname` | string | 닉네임 |
| `socialPlatform` | string | `KAKAO` \| `GOOGLE` \| `APPLE` |
| `allowGamePush` | boolean | 게임 푸시 허용 여부 |
| `allowMarketingPush` | boolean | 마케팅 푸시 허용 여부 |
