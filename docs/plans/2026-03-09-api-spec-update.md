# API_SPEC.md 업데이트 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** api-docs.json 변경사항을 반영하여 API_SPEC.md를 최신 상태로 업데이트

**Architecture:** api-docs.json (OpenAPI 3.0.1)을 single source of truth로 삼아 API_SPEC.md를 재생성. 스키마 정의가 스웨거 예시와 불일치하는 경우 스키마가 우선.

**Tech Stack:** Markdown 문서

---

### Task 1: API_SPEC.md 전체 재작성

**Files:**
- Modify: `docs/API_SPEC.md`
- Reference: `docs/api-docs.json`

**변경 사항 요약:**

#### 신규 엔드포인트 7개 추가
1. `PUT /api/games/{gameId}/settings` — Game API 섹션 (2.2)
2. `GET /api/games/{gameId}` — Game API 섹션 (2.3)
3. `GET /api/games/{gameId}/area` — Game Area API 섹션 (신규 섹션 3)
4. `PUT /api/games/{gameId}/area` — Game Area API 섹션 (3.2)
5. `GET /api/games/{gameId}/lobby` — Lobby API 섹션 (5.1)
6. `GET /api/games/{gameId}/participants` — Game Participant API 섹션 (4.3)
7. `DELETE /api/user/me` — User API 섹션 (6.4)

#### 섹션 재구성 (api-docs.json 태그 순서 반영)
1. Auth API (변경 없음)
2. Game API (POST 생성 + PUT 설정 수정 + GET 기본 설정 조회)
3. Game Area API (신규 — GET 조회 + PUT 수정)
4. Game Participant API (기존 join/leave + 신규 participants 조회)
5. Lobby API (기존 team/ready/start + 신규 lobby 조회)
6. User API (기존 + 신규 회원탈퇴)
7. System API (변경 없음)
8. 공통 스키마 (신규 스키마 10개 추가)

#### 신규 스키마 10개 추가
- GameSettingsUpdateResponse
- GameAreaRequest / GameAreaResponse / GameAreaUpdateResponse
- Coordinates (응답용, CoordinatesRequest와 별도)
- GameInfoResponse
- GameParticipantListResponse / ParticipantResponse
- LobbyInfoResponse
- DeleteAccountResponse

#### 기존 엔드포인트 — 변경 없음
- POST /api/auth/login, logout, reissue
- POST /api/games (create)
- POST /api/games/join, DELETE leave
- PATCH team, ready, POST start
- GET /api/user/me, PATCH nickname, GET check-nickname
- POST arrest, escape

**Step 1: API_SPEC.md 전체 재작성**

기존 API_SPEC.md의 형식과 스타일을 유지하면서, api-docs.json의 모든 엔드포인트와 스키마를 반영하여 전체 문서를 재작성.

**Step 2: 커밋**

```bash
git add docs/API_SPEC.md
git commit -m "docs: api-docs.json 변경사항 반영하여 API_SPEC.md 업데이트"
```
