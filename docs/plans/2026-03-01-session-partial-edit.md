# 게임 세션 부분 수정 기능 설계

> **상태**: 대기 (백엔드 수정 API 완성 후 진행)
> **작성일**: 2026-03-01
> **배경**: 백엔드 요청 — 생성은 순차 플로우, 수정은 "구역"과 "설정"을 독립적으로 변경 가능해야 함

---

## 요구사항

### 생성 (현행 유지)
구역 설정 → 게임 설정 → 방 생성 (순차 플로우, 변경 없음)

### 수정 (신규)
- **구역 수정**: 플레이그라운드 → 감옥 **세트로** 변경 (개별 불가)
- **설정 수정**: 참여인원 / 라운드 시간 / 위치공유 주기 / 경찰 대기시간 **각각** 독립 변경 가능

---

## 현재 구조 분석

### 그대로 사용 가능
| 항목 | 파일 | 이유 |
|------|------|------|
| API 요청 모델 | `game_create_request_model.dart` | `AreaRequestModel`과 `GameSettingsRequestModel`이 이미 분리됨 |
| Draft 모델 | `session_creation_draft_model.dart` | nullable 필드로 부분 상태 저장 가능 |
| Step 위젯 | `step_0_select_area_content.dart` 등 | 독립적 위젯이라 수정 페이지에서 재사용 가능 |

### 추가 필요
| 항목 | 현재 | 필요 |
|------|------|------|
| Repository | `createGame()`만 존재 | `updateGameArea()`, `updateGameSettings()` 추가 |
| Provider | 생성 전용 | update 메서드 추가 |
| DataSource | `POST /api/games`만 존재 | `PATCH` 엔드포인트 2개 추가 |
| 페이지 | 순차 플로우만 존재 | 수정 전용 페이지 2개 추가 |

---

## 구현 계획

### 1. Data 레이어

#### 1-1. 요청 모델 (신규 또는 기존 재사용)
- `AreaRequestModel` — 기존 모델 그대로 사용
- `GameSettingsRequestModel` — 기존 모델 그대로 사용
- 별도 update 모델이 필요하면 그때 추가

#### 1-2. DataSource
```dart
// session_remote_datasource.dart에 추가
@PATCH('/api/games/{id}/area')
Future<GameDetailModel> updateGameArea(
  @Path('id') int gameId,
  @Body() AreaRequestModel area,
);

@PATCH('/api/games/{id}/settings')
Future<GameDetailModel> updateGameSettings(
  @Path('id') int gameId,
  @Body() GameSettingsRequestModel settings,
);
```

> **참고**: 엔드포인트 경로는 백엔드 API 확정 후 조정

#### 1-3. Repository 구현체
```dart
// session_repository_impl.dart에 추가
Future<GameDetailEntity> updateGameArea(int gameId, AreaRequestModel area);
Future<GameDetailEntity> updateGameSettings(int gameId, GameSettingsRequestModel settings);
```

### 2. Domain 레이어

#### 2-1. Repository 인터페이스
```dart
// session_repository.dart에 추가
Future<GameDetailEntity> updateGameArea(int gameId, AreaRequestModel area);
Future<GameDetailEntity> updateGameSettings(int gameId, GameSettingsRequestModel settings);
```

### 3. Presentation 레이어

#### 3-1. Provider
```dart
// session_provider.dart에 추가하거나 별도 파일 생성
Future<void> updateGameArea(int gameId, AreaRequestModel area);
Future<void> updateGameSettings(int gameId, GameSettingsRequestModel settings);
```

#### 3-2. 수정 전용 페이지 (신규)

**`EditGameZonePage`**
- 기존 `Step0SelectAreaContent` 재사용
- 플레이그라운드 → 감옥 순서 강제 (세트 수정)
- 완료 시 `updateGameArea()` 호출

**`EditGameSettingsPage`**
- 기존 `Step1ParticipantSettingsContent` + `Step2GameSettingsContent` 재사용
- 각 설정 값 독립 변경 가능 (한 화면에 모두 표시)
- 완료 시 `updateGameSettings()` 호출

#### 3-3. 라우팅
```
/games/:id/edit/zone      → EditGameZonePage
/games/:id/edit/settings  → EditGameSettingsPage
```

---

## 진입점 (UI)

대기실 또는 게임 상세 화면에서:
- **[구역 수정]** 버튼 → `EditGameZonePage`
- **[설정 수정]** 버튼 → `EditGameSettingsPage`

> 호스트만 수정 가능하도록 권한 체크 필요

---

## 파일 변경 요약

| 작업 | 파일 | 변경 |
|------|------|------|
| 유지 | `session_creation_flow_page.dart` | 변경 없음 |
| 유지 | `step_0~3 위젯` | 변경 없음 (재사용) |
| 수정 | `session_remote_datasource.dart` | PATCH 메서드 2개 추가 |
| 수정 | `session_repository.dart` (인터페이스) | update 메서드 2개 추가 |
| 수정 | `session_repository_impl.dart` | update 구현 2개 추가 |
| 수정 | `session_provider.dart` | update 메서드 2개 추가 |
| 수정 | `app_router.dart` | 수정 페이지 라우트 추가 |
| 신규 | `edit_game_zone_page.dart` | 구역 수정 페이지 |
| 신규 | `edit_game_settings_page.dart` | 설정 수정 페이지 |

---

## 미확정 사항

- [ ] 백엔드 수정 API 엔드포인트 경로 확정
- [ ] 응답 모델 확인 (수정 후 전체 게임 정보 반환? 또는 변경분만?)
- [ ] 게임 진행 중 수정 가능 여부 (대기실에서만? 게임 중에도?)
- [ ] 수정 권한 범위 (호스트만? 참가자도?)
