# API_SPEC.md 업데이트 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `api-docs.json` 변경사항을 `docs/API_SPEC.md`에 반영한다.

**Architecture:** 문서 업데이트 작업. 4가지 변경사항을 API_SPEC.md에 반영: (1) Report API 신규 추가, (2) LoginRequest.fcmToken 필수→선택, (3) GameSettingsRequest 범위 변경, (4) 참여 중인 게임 조회 설명 보강.

**Tech Stack:** Markdown

---

## 변경사항 요약

| # | 구분 | 위치 | 내용 |
|---|------|------|------|
| 1 | **신규 API** | 섹션 8 (새로 생성) | `POST /api/report/chat` — 채팅 신고 |
| 2 | **신규 스키마** | 공통 스키마 | `ReportRequest` |
| 3 | **변경** | 1.1 POST /api/auth/login + LoginRequest 스키마 | `fcmToken` 필수 → 선택 (nullable) |
| 4 | **변경** | GameSettingsRequest 스키마 | `locationRevealIntervalMinutes` minimum 5 → 1 |
| 5 | **변경** | 6.5 GET /api/user/me/game | 설명에 24시간 지난 WAITING 로비 자동 삭제 추가 |

---

### Task 1: 목차에 Report API 섹션 추가 + 기존 섹션 번호 조정

**Files:**
- Modify: `docs/API_SPEC.md:10-43` (목차)

- [ ] **Step 1: 목차 업데이트**

기존 목차의 7번(System API) 뒤에 8번(Report API) 추가, 기존 8번(공통 스키마)을 9번으로 변경.

변경 전 (line 39-43):
```markdown
7. [System API - 게임 시스템 상호작용](#7-system-api---게임-시스템-상호작용)
   - [POST /api/games/{gameId}/system/arrest - 도둑 체포](#71-post-apigamesgameidsystemarrest---도둑-체포)
   - [POST /api/games/{gameId}/system/escape - 도둑 탈옥](#72-post-apigamesgameidsystemescape---도둑-탈옥)
8. [공통 스키마](#8-공통-스키마)
```

변경 후:
```markdown
7. [System API - 게임 시스템 상호작용](#7-system-api---게임-시스템-상호작용)
   - [POST /api/games/{gameId}/system/arrest - 도둑 체포](#71-post-apigamesgameidsystemarrest---도둑-체포)
   - [POST /api/games/{gameId}/system/escape - 도둑 탈옥](#72-post-apigamesgameidsystemescape---도둑-탈옥)
8. [Report API - 신고](#8-report-api---신고)
   - [POST /api/report/chat - 채팅 신고](#81-post-apireportchat---채팅-신고)
9. [공통 스키마](#9-공통-스키마)
```

---

### Task 2: LoginRequest 변경 — fcmToken 필수 → 선택

**Files:**
- Modify: `docs/API_SPEC.md:56-61` (1.1 POST /api/auth/login Request Body 테이블)
- Modify: `docs/API_SPEC.md:1692-1700` (공통 스키마 LoginRequest 테이블)

- [ ] **Step 1: 1.1 로그인 Request Body 테이블에서 fcmToken 행 수정**

변경 전 (line 60):
```markdown
| `fcmToken`       | string | O    | FCM 디바이스 토큰                        |
```

변경 후:
```markdown
| `fcmToken`       | string | -    | FCM 디바이스 토큰 (선택, nullable)       |
```

- [ ] **Step 2: 공통 스키마 LoginRequest 테이블에서 fcmToken 행 수정**

변경 전 (line 1698):
```markdown
| `fcmToken`       | string | O    | FCM 디바이스 토큰              |
```

변경 후:
```markdown
| `fcmToken`       | string | -    | FCM 디바이스 토큰 (선택, nullable) |
```

---

### Task 3: GameSettingsRequest 범위 변경

**Files:**
- Modify: `docs/API_SPEC.md:1773` (GameSettingsRequest 스키마 테이블)

- [ ] **Step 1: locationRevealIntervalMinutes 범위 수정**

변경 전 (line 1773):
```markdown
| `locationRevealIntervalMinutes` | integer (int32) | O    | 5~     | 위치 공개 주기 (분) |
```

변경 후:
```markdown
| `locationRevealIntervalMinutes` | integer (int32) | O    | 1~     | 위치 공개 주기 (분) |
```

---

### Task 4: GET /api/user/me/game 설명 업데이트

**Files:**
- Modify: `docs/API_SPEC.md:1477` (6.5 설명 텍스트)

- [ ] **Step 1: 설명에 24시간 자동 삭제 문구 추가**

변경 전 (line 1477):
```markdown
로그인한 사용자가 현재 참여 중인 게임 정보를 조회합니다. `isParticipating`으로 참여 여부를 확인할 수 있으며, 참여 중인 게임이 없으면 `participationInfo`가 null로 반환됩니다.
```

변경 후:
```markdown
로그인한 사용자가 현재 참여 중인 게임 정보를 조회합니다. `isParticipating`으로 참여 여부를 확인할 수 있으며, 참여 중인 게임이 없으면 `participationInfo`가 null로 반환됩니다. 생성 후 24시간이 지난 대기 중(WAITING) 로비는 자동으로 삭제되며 `isParticipating=false`로 응답합니다.
```

---

### Task 5: Report API 섹션 신규 작성

**Files:**
- Modify: `docs/API_SPEC.md` (7번 System API 섹션 끝, `## 8. 공통 스키마` 바로 위에 삽입)

- [ ] **Step 1: 기존 "## 8. 공통 스키마"를 "## 9. 공통 스키마"로 변경**

- [ ] **Step 2: "## 8. Report API - 신고" 섹션 삽입**

`## 7. System API` 섹션 끝 (`---` 구분선 뒤)과 `## 9. 공통 스키마` 사이에 아래 내용을 삽입:

```markdown
## 8. Report API - 신고

### 8.1 POST /api/report/chat - 채팅 신고

채팅 메시지를 신고합니다.

- **인증 필요**: Yes (JWT)

#### Request Body (`application/json`)

| 필드                    | 타입            | 필수 | 설명                                                                                                  |
| ----------------------- | --------------- | ---- | ----------------------------------------------------------------------------------------------------- |
| `gameId`                | integer (int64) | O    | 게임 ID                                                                                               |
| `reportedParticipantId` | integer (int64) | O    | 신고 대상 참가자 ID                                                                                   |
| `messageContent`        | string          | O    | 신고된 메시지 내용                                                                                    |
| `reportType`            | string          | O    | 신고 유형 (`FISHING` \| `VERBAL_ABUSE` \| `IMPERSONATION` \| `SPAM` \| `CHEATING` \| `DEMORALIZATION` \| `ETC`) |
| `etcReason`             | string          | -    | 기타 사유 (신고 유형이 `ETC`일 때 필수, 최대 300자)                                                   |

**요청 예시:**

```json
{
  "gameId": 3,
  "reportedParticipantId": 12,
  "messageContent": "나쁜 말",
  "reportType": "VERBAL_ABUSE"
}
```

#### Responses

**201 - 신고 성공** (응답 본문 없음)

**400 - 잘못된 요청**

| 케이스              | title                      | detail                              |
| ------------------- | -------------------------- | ----------------------------------- |
| 게임 진행 중 아님   | 게임 진행 중 아님          | 게임이 진행 중인 상태가 아닙니다.   |
| 본인 신고 불가      | 본인을 신고할 수 없습니다. | 본인을 신고할 수 없습니다.          |

```json
{
  "title": "게임 진행 중 아님",
  "status": 400,
  "detail": "게임이 진행 중인 상태가 아닙니다.",
  "instance": "/api/report/chat"
}
```

**401 - 인증 실패**

```json
{
  "title": "인증되지 않은 요청",
  "status": 401,
  "detail": "로그인이 필요합니다.",
  "instance": "/api/report/chat"
}
```

**404 - 리소스 없음**

| 케이스             | title                        | detail                                   |
| ------------------ | ---------------------------- | ---------------------------------------- |
| 참가자 미존재      | 참가자를 찾을 수 없음        | 해당 게임에 참가하지 않은 사용자입니다.   |
| 신고 대상 미존재   | 신고 대상을 찾을 수 없습니다. | 해당 게임에 존재하지 않는 참가자입니다.  |

```json
{
  "title": "참가자를 찾을 수 없음",
  "status": 404,
  "detail": "해당 게임에 참가하지 않은 사용자입니다.",
  "instance": "/api/report/chat"
}
```

**409 - 중복 신고**

```json
{
  "title": "이미 신고한 사용자입니다.",
  "status": 409,
  "detail": "해당 게임에서 이미 신고한 사용자입니다.",
  "instance": "/api/report/chat"
}
```

**500 - 서버 오류**

```json
{
  "title": "알 수 없는 오류",
  "status": 500,
  "detail": "서버 내부에 알 수 없는 오류가 발생했습니다. 관리자에게 문의 하세요.",
  "instance": "/api/report/chat"
}
```

---
```

---

### Task 6: 공통 스키마에 ReportRequest 추가

**Files:**
- Modify: `docs/API_SPEC.md` (공통 스키마 섹션 내, 적절한 위치에 삽입)

- [ ] **Step 1: ReportRequest 스키마 추가**

`### DeleteAccountResponse` 뒤(파일 끝)에 아래 내용 추가:

```markdown

### ReportRequest

| 필드                    | 타입            | 필수 | 설명                                                                                                  |
| ----------------------- | --------------- | ---- | ----------------------------------------------------------------------------------------------------- |
| `gameId`                | integer (int64) | O    | 게임 ID                                                                                               |
| `reportedParticipantId` | integer (int64) | O    | 신고 대상 참가자 ID                                                                                   |
| `messageContent`        | string          | O    | 신고된 메시지 내용                                                                                    |
| `reportType`            | string          | O    | 신고 유형 (`FISHING` \| `VERBAL_ABUSE` \| `IMPERSONATION` \| `SPAM` \| `CHEATING` \| `DEMORALIZATION` \| `ETC`) |
| `etcReason`             | string          | -    | 기타 사유 (신고 유형이 `ETC`일 때 필수, 최대 300자)                                                   |
```

---

### Task 7: 커밋

- [ ] **Step 1: 커밋**

```bash
git add docs/API_SPEC.md
git commit -m "docs: API_SPEC.md 업데이트 — Report API 추가, fcmToken 선택 변경, 위치공개주기 최솟값 변경"
```
