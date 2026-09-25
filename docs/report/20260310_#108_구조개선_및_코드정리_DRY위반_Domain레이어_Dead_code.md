### 📌 작업 개요

\#69 코드 리뷰에서 발견된 **구조 개선 사항 5건 + Minor 정리 항목 11건**을 해결하는 작업.
버그 수정 24건, 리팩토링 12건, 코드 정리 9건, 문서화 8건, 스타일 3건, 신규 기능 2건 — 총 **58개 커밋** (+ Merge 3건)으로 구성.

주요 성과:
- 런타임 버그 24건 수정 (STOMP, 체포/탈옥, 인증, 라우팅, 게임 설정 등)
- 아키텍처 레이어 위반 해소 (provider 위치 이동, DTO 분리)
- Dead code 정리 및 디자인 시스템 준수 강화
- API 에러 응답 활용으로 사용자 피드백 개선
- MyLocationButton 공통 컴포넌트 추출 (DRY 위반 해소)
- AuthInterceptor QueuedInterceptor 전환으로 수동 큐 제거
- CodeRabbit PR #109, #111, #113 리뷰 피드백 반영

---

### ✅ 구현 내용

---

## 1. 버그 수정 (24건)

#### STOMP 통신 안정성

| 커밋 | 내용 |
|------|------|
| `0202e22` | STOMP 비-401 에러 시 `_isHandlingError` 플래그 미리셋 → 재연결 불가 버그 수정 |
| `5ec076e` | `GameEventStompDatasource` dispose 순서 수정 — StreamController close 전 subscription 해제로 `StateError` 방지 |
| `ca87b19` | `ChatState`/`LobbyState` copyWith sentinel 패턴 미적용 → nullable 필드(`errorMessage`)가 null로 리셋 불가능한 버그 수정 |

#### 게임 시스템

| 커밋 | 내용 |
|------|------|
| `b88de75` | 체포/탈옥 API 성공 시 `isApiLoading` 미해제 → 이후 API 호출 차단되는 버그 수정 |
| `6bb6842` | `arrestRobber` STOMP/API race condition 방어 — `_pendingArrestId`로 중복 체포 요청 추적 |
| `89a6d29` | `arrestRobber` 재진입 방어 강화 — 동일 도둑에 대한 중복 체포 요청 무시 |
| `05912cf` | `_handleEscape`/`_handleLocationReveal`에서 JSON 데이터 null-safe 캐스팅 적용 |
| `b4245c5` | 경찰 시작 시간 최소값을 0분에서 1분으로 변경 (서버 유효성 검증과 일치) |
| `3fe98cc` | draft에서 로드한 `policeWaitMinutes` 슬라이더 범위 `.clamp(1, 10)` 적용 |

#### 인증 및 라우팅

| 커밋 | 내용 |
|------|------|
| `84b4b4e` | `AuthNotifier` userId null fallback 제거 — userId 없는 세션을 미인증으로 처리 |
| `1b7eaaf` | userId 없는 손상 세션 발견 시 Firebase/JWT 정리 후 미인증 상태로 전환 |
| `5ae6916` | `AuthNotifier` dispose 시 강제 로그아웃 콜백 해제 — dispose 이후 콜백 실행 방지 |
| `5c99ef7` | `build()` 중 다른 provider 수정 방지를 위해 `Future.microtask` 적용 |
| `cfaa678` | 릴리스 빌드에서 디버그 라우트(`/lifecycle-test`) 접근 차단 |
| `faa7ebd` | redirect 예외 발생 시 로그인 화면으로 안전 리다이렉트 |
| `7a3f59e` | 신규 회원 닉네임 설정 우회 방지 + 기존 회원의 닉네임 설정 페이지 직접 접근 차단 |
| `06b4cbe` | 로그인 취소 시 SnackBar 표시 및 `FirebaseAuthException` → `AuthCancelledException` 분리 처리 |
| `4ad0ff8` | 설정 페이지 닉네임 변경 시 예외 처리 타입 수정 |

#### UX / UI

| 커밋 | 내용 |
|------|------|
| `f984fb8` | `MyLocationButton` 초기 로딩 시 프로그래밍적 카메라 이동으로 unfocus되는 버그 수정 (`_isProgrammaticMove` 플래그) |
| `7b487dd` | `LocationRevealCountdown` 백그라운드 복귀 시 타이머 즉시 동기화 |
| `8b545cc` | 방 참여코드 소문자 입력 시 `.toUpperCase()` 변환하여 API 호출 |
| `9024804` | 안드로이드 홈 하단 버튼 여백 추가 (플랫폼별 분기) |
| `aa180b7` | CodeRabbit 리뷰 피드백 반영 — 닉네임 설정 `canPop()` 조건부 네비게이션 복원, divisions 9로 수정 |

#### 기타

| 커밋 | 내용 |
|------|------|
| `33b5e79` | `ChatProvider` 더미 모드에서 fire-and-forget `Future` → `Timer`로 교체 (unhandled exception 방지) |
| `3d3bd55` | 홈 화면 개발자 도구 FAB에 `kDebugMode` 가드 복원 |
| `0814552` | `lifecycle_test_page`에서 `leaveGame` provider 반환 타입 변경 대응 |

---

## 2. 리팩토링 (12건)

#### 아키텍처 레이어 정리

| 커밋 | 내용 |
|------|------|
| `8929c09` | `dioProvider`, `secureTokenStorageProvider`를 feature → `core` 레이어로 이동 (크로스 피처 의존성 해소) |
| `75a7acd` | `gameSystemApiProvider`를 data → presentation 레이어로 이동 (레이어 위반 해소) |
| `524033a` | `game_system_api_datasource` 내 인라인 DTO를 별도 `data/models/` 파일로 분리 |

#### API 에러 처리 개선

| 커밋 | 내용 |
|------|------|
| `497442e` | SnackBar 하드코딩 에러 메시지 → `ApiErrorResponse.detail` 활용으로 전환 |

**변경 범위:**
- `session_provider.dart`: 4개 provider(`leaveGame`, `startGame`, `updateReady`, `changeTeam`)에서 try-catch 제거, DioException rethrow 방식으로 전환
- `home_page.dart`: 방 참여 실패 시 서버 에러 메시지 표시
- `waiting_room_page.dart`: 팀 변경/준비/시작/퇴장 실패 시 서버 에러 메시지 표시
- `settings_page.dart`: 프로필 조회 실패 시 서버 에러 메시지 표시

#### DRY 위반 해소 — MyLocationButton 공통 컴포넌트

| 커밋 | 내용 |
|------|------|
| `625dab3` | `game_page` 현재위치 버튼을 `MyLocationButton`으로 교체 |
| `f478f2f` | `zone_setting_widget` 현재위치 버튼을 `MyLocationButton`으로 교체 |

**변경 범위:**
- `game_page.dart`: `SvgIconButton` 직접 사용 → `MyLocationButton` 위젯으로 교체, `_isLocationFocused`/`_isProgrammaticMove` 상태 관리 추가
- `zone_setting_widget.dart`: 커스텀 `_buildMyLocationButton()` 메서드 → `MyLocationButton` 위젯으로 교체, 포커스 색상 동적 관리
- `google_map_view.dart`: `onCameraMoveStarted` 콜백 추가로 사용자 드래그 감지

#### 인터셉터 / 인증 리팩토링

| 커밋 | 내용 |
|------|------|
| `870c279` | `AuthInterceptor`를 `QueuedInterceptor`로 전환하여 수동 큐 로직 제거 |
| `6d3967b` | 닉네임 설정 완료 후 네비게이션 단순화 |
| `0ec623e` | 초대코드 공유 텍스트를 코드만 전달하도록 단순화 |

#### 기타 리팩토링

| 커밋 | 내용 |
|------|------|
| `556598b` | `ChatState`/`LobbyState` copyWith에 sentinel 패턴 적용 — nullable 필드 null 리셋 가능 |
| `a859809` | GoRouter redirect 안정성 개선 — 예외 처리 및 안전 리다이렉트 |
| `f768e12` | 지도 에러 fallback UI를 공통 위젯으로 추출 + 디자인 시스템 상수 적용 |

---

## 3. 신규 기능 (2건)

| 커밋 | 내용 |
|------|------|
| `9003984` | `MyLocationButton` 공통 컴포넌트 생성 — SVG 아이콘 기반, `isFocused` 상태에 따라 색상 전환 |
| `75b37d1` | `GoogleMapView`에 `onCameraMoveStarted` 콜백 추가 — 사용자 드래그 감지 지원 |

---

## 4. 타이머 백그라운드 동기화 (2건)

| 커밋 | 내용 |
|------|------|
| `2231416` | `app_popup`, `countdown_timer_content`, `game_timer_text` — 백그라운드 전환 후 복귀 시 잔여 시간 보정 로직 추가 |
| `502afb5` | 타이머 아키텍처 설계 문서 및 WebSocket 이벤트 정리 문서 추가 |

---

## 5. 디자인 시스템 상수 교체 (1건)

| 커밋 | 내용 |
|------|------|
| `6118023` | `game_page.dart`, `chat_overlay.dart`, `chat_input_bar.dart`, `waiting_room_page.dart` 등에서 하드코딩된 간격/패딩/라운드를 `AppSpacing`/`AppPadding`/`AppRadius` 상수로 일괄 교체 |

---

## 6. 코드 정리 (9건)

| 커밋 | 내용 |
|------|------|
| `babf9e0` | `build()` 메서드 내 불필요한 `debugPrint` 제거 (매 빌드마다 콘솔 출력 방지) |
| `2688afa` | Dead code 정리 — `TokenProvider.getRefreshToken()`, `ChatState.messages` getter 제거 |
| `117ccf1` | hot-path `debugPrint`에 `kDebugMode` 가드 추가 (릴리스 성능 보호) |
| `d5bc305` | `ArrestResponseModel` required 전환 + `SecureTokenStorage` dead code 제거 |
| `76a4f58` | 의존성 lock 파일 업데이트 |
| `1011ef4` | `build_runner` 재생성 파일 업데이트 |
| `282f506` | chat/lobby provider 코드 생성 해시 갱신 |
| `1e5be69` | `game_event_provider` 코드 생성 해시 갱신 |
| `d425e2e` | `auth_provider` 코드 생성 해시 갱신 |

---

## 7. 스타일 (3건)

| 커밋 | 내용 |
|------|------|
| `80f14ba` | 포맷팅 수정 |
| `f6941e3` | `zone_setting_widget` `MyLocationButton` 들여쓰기 정리 |
| `6118023` | 하드코딩된 간격/패딩/라운드를 디자인 시스템 상수로 교체 |

---

## 8. 문서화 (8건)

| 커밋 | 내용 |
|------|------|
| `26c7c5d` | `api-docs.json` 변경사항 반영 및 `API_SPEC.md` 업데이트 |
| `fe87682` | #69 종합 코드 리뷰 결과 및 개선 계획 작성 |
| `de159c5` | issue108 개선 작업 실행 계획 추가 |
| `2941f73` | issue108 2차 리뷰 계획 문서 추가 |
| `7e01004` | CodeRabbit PR #109 리뷰 반영 구현 계획 추가 |
| `502afb5` | 타이머 아키텍처 및 WebSocket 이벤트 문서 추가 |
| `85d6e3d` | MyLocationButton 공통 컴포넌트 설계 문서 추가 |
| `dcfe18e` | MyLocationButton 구현 계획 문서 추가 |

---

### 📊 작업 통계

| 구분 | 건수 |
|------|------|
| 총 커밋 | 58개 (+ Merge 3건) |
| 버그 수정 (`fix`) | 24건 |
| 리팩토링 (`refactor`) | 12건 |
| 신규 기능 (`feat`) | 2건 |
| 코드 정리 (`chore`) | 9건 |
| 문서화 (`docs`) | 8건 |
| 스타일 (`style`) | 3건 |
| PR 머지 | #109, #111, #113 |

---

### 📌 이슈 대비 진행 현황

#### 구조 개선 (Phase 3) — 5건 중 4건 완료

| 항목 | 상태 | 비고 |
|------|------|------|
| STOMP 재연결 로직 공통 mixin 추출 | ⏳ 미착수 | DRY 위반 해소 필요 |
| 크로스 피처 공유 모델 `core/` 이동 | ✅ 부분 완료 | `dioProvider`, `secureTokenStorageProvider` core 이동 완료 |
| 디자인 시스템 상수 하드코딩 교체 | ✅ 완료 | `6118023` — game_page, chat_overlay, chat_input_bar, waiting_room 등 일괄 교체 |
| GameEventState/ChatState → @freezed 전환 | ⏳ 미착수 | sentinel copyWith 패턴으로 임시 해결 |
| Chat/Lobby/GameEvent Domain 레이어 결정 | ⏳ 미착수 | Repository 인터페이스 추가 또는 예외 문서화 필요 |

#### 코드 정리 (Phase 4) — 11건 중 7건 완료

| 항목 | 상태 | 비고 |
|------|------|------|
| build() 내 debugPrint 제거 | ✅ 완료 | `babf9e0` |
| Dead code 정리 | ✅ 완료 | `2688afa`, `d5bc305` |
| scope 필드 String → enum 전환 | ⏳ 미착수 | |
| GamePage 책임 분리 | ⏳ 미착수 | ~730줄 → GPS 로직 Provider 추출 필요 |
| 미사용 상수 정리 | ⏳ 미착수 | |
| ref.watch 범위 최적화 | ⏳ 미착수 | .select() 적용 필요 |
| game_system_api_datasource DTO 분리 | ✅ 완료 | `524033a` |
| leaveGame 사용자 피드백 추가 | ✅ 완료 | `497442e` (API 에러 응답 활용) |
| hot-path debugPrint kDebugMode 가드 | ✅ 완료 | `117ccf1` |
| 릴리스 빌드 디버그 라우트 차단 | ✅ 완료 | `cfaa678` |
| 인증 안정성 강화 | ✅ 완료 | `84b4b4e`, `1b7eaaf`, `5ae6916` 등 |

#### 추가 개선 (이슈 외 작업)

| 항목 | 상태 | 비고 |
|------|------|------|
| MyLocationButton DRY 위반 해소 | ✅ 완료 | `9003984` — 공통 컴포넌트 추출, game_page + zone_setting_widget 교체 |
| AuthInterceptor QueuedInterceptor 전환 | ✅ 완료 | `870c279` — 수동 큐 로직 제거 |
| 로그인 취소 예외 분리 | ✅ 완료 | `06b4cbe` — `AuthCancelledException` 도입 |
| 타이머 백그라운드 동기화 | ✅ 완료 | `2231416`, `7b487dd` |
| 방 참여코드 대문자 변환 | ✅ 완료 | `8b545cc` |
| 안드로이드 하단 여백 추가 | ✅ 완료 | `9024804` |

---

### 📌 참고사항

- CodeRabbit PR #109, #111, #113 리뷰에서 추가 발견된 버그들(인증 손상 세션, 라우팅 보안, 슬라이더 범위)도 함께 수정
- `sentinel 패턴`은 @freezed 전환 전 임시 해결책으로 적용. 향후 @freezed 전환 시 제거 예정
- STOMP 공통 mixin 추출, GamePage 책임 분리 등 대규모 리팩토링은 별도 작업으로 진행 필요
- `MyLocationButton` 공통 컴포넌트에 `_isProgrammaticMove` 플래그 패턴 적용 — 초기 카메라 이동, 반경 변경 등 프로그래밍적 이동 시 포커스 해제 방지
