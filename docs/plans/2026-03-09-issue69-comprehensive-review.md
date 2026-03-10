# 📊 Flutter 종합 코드 리뷰 결과 — #69 WebSocket STOMP 및 실시간 채팅/게임

**리뷰 대상**: `main...HEAD` 변경분 97개 dart 파일 (47 커밋)
**검사 일시**: 2026-03-09
**브랜치**: `20260205_#69_게임_채팅_WebSocket_STOMP_연결_및_실시간_채팅_기능_구현`

---

## 🚨 Critical Issues (즉시 수정 필요)

### C1. `_isHandlingError` 비-401 에러 시 미리셋 → 영구 연결 불능
- **파일**: `lobby_provider.dart:330`, `chat_provider.dart:491`
- **문제**: `_handleStompError`의 비-인증(non-401) 에러 분기에서 `_isHandlingError`를 `false`로 리셋하지 않음. 비-인증 STOMP 에러 수신 후 WebSocket이 끊어지면 `_isHandlingError == true`이므로 `_scheduleReconnect()`가 호출되지 않아 연결이 영구적으로 복구 불가.
- **참고**: `GameEventNotifier`(라인 559)는 올바르게 `_isHandlingError = false` 설정.
- **수정**: 비-401 분기 끝에 `_isHandlingError = false;` 추가.

### C2. `arrestRobber()` / `escape()` 성공 시 `isApiLoading` 미해제
- **파일**: `game_event_provider.dart:269-280`
- **문제**: API 호출 성공 경로에서 `isApiLoading: false`가 없음. STOMP ARREST/ESCAPE 이벤트의 핸들러에서 해제하지만, 이벤트 미도착 시 `isApiLoading`이 영구적으로 `true`로 남아 UI가 영구 로딩 상태에 빠짐.
- **수정**: try 블록 성공 경로에 `isApiLoading: false` 설정 추가. 또는 finally 블록에서 해제.

### C3. `GameEventStompDatasource.dispose()` StreamController close 순서 위험
- **파일**: `game_event_stomp_datasource.dart:86-89`
- **문제**: `_eventController.close()`를 `super.dispose()` 이전에 호출. `super.dispose()`의 `disconnect()` → `deactivate()` 과정에서 콜백이 이미 닫힌 controller에 접근 시 `StateError` 발생 가능.
- **수정**: `super.dispose()` 먼저 호출 후 `_eventController.close()` (ChatStompDatasource/LobbyStompDatasource와 동일 순서로 통일).

---

## ⚠️ Major Issues (배포 전 수정 권장)

### M1. ChatStompDatasource / LobbyStompDatasource dispose 순서 불일치
- **파일**: `chat_stomp_datasource.dart:92-96`, `lobby_stomp_datasource.dart:52-55`
- **문제**: `super.dispose()` 후 `_messageController.close()` / `_eventController.close()` 순서는 안전하지만, `GameEventStompDatasource`와 불일치. 3개 DataSource의 dispose 순서를 통일해야 함.
- **수정**: 모든 DataSource에서 `super.dispose()` → 자체 controller close 순서로 통일.

### M2. ChatProvider 더미 모드 fire-and-forget Future dispose 미처리
- **파일**: `chat_provider.dart:214`
- **문제**: `Future.delayed(1초)` 더미 자동응답이 fire-and-forget으로 실행. Provider dispose 후 `state =` 할당 시도 시 예외 발생 가능. `ref.onDispose`에서 타이머 취소 로직 없음.
- **수정**: Completer 또는 Timer를 사용하고, dispose 시 취소.

### M3. `ChatState.copyWith` 에러 메시지 자동 소실
- **파일**: `chat_provider.dart:52-59`
- **문제**: `copyWith(connectionState: ...)` 호출 시 `errorMessage` 파라미터가 기본 `null`이므로 기존 에러 메시지가 암묵적으로 소실됨. `GameEventState`는 `errorMessage ?? this.errorMessage` 패턴으로 올바르게 보존.
- **수정**: `GameEventState`처럼 `errorMessage ?? this.errorMessage` + `clearError` boolean 패턴 적용.

### M4. STOMP Notifier 재연결 로직 3곳 중복 (DRY 위반)
- **파일**: `chat_provider.dart`, `lobby_provider.dart`, `game_event_provider.dart`
- **문제**: `_scheduleReconnect`, `_calculateBackoffDelay`, `_attemptReconnect`, `_handleStompError`, `_setupStreams` 패턴이 3곳에서 거의 동일하게 ~120줄씩 반복. 한 곳 수정 시 3곳 모두 반영해야 함.
- **수정**: `StompReconnectMixin` 또는 `BaseStompNotifier` 추출.

### M5. Data 레이어에서 Presentation 레이어 import (레이어 위반)
- **파일**: `game_system_api_datasource.dart:8`
- **문제**: `data/datasources/`에서 `auth/presentation/providers/auth_provider.dart`의 `dioProvider`를 import. Clean Architecture 의존성 흐름 위반.
- **수정**: `dioProvider`를 `core/network/` 레이어로 이동하거나, import 경로 수정.

### M6. Chat/Lobby/GameEvent Domain 레이어 부재
- **파일**: `features/chat/`, `features/game/`, `features/lobby/`
- **문제**: Repository 인터페이스/UseCase 없이 Presentation에서 DataSource 직접 생성. 프로젝트 Clean Architecture 원칙과 불일치.
- **수정**: 최소한 Repository 인터페이스 추가. 또는 의도적 생략이라면 CLAUDE.md에 예외 문서화.

### M7. 크로스 피처 의존 (Feature 결합도)
- **파일**: `participant_overlay.dart:6-7`, `waiting_room_participants_provider.dart:4`
- **문제**: game → lobby, session → lobby 방향으로 data 모델(`LobbyParticipantInfo`)을 직접 import. Feature 독립성 저하.
- **수정**: 공유 모델을 `core/models/` 또는 `shared/` 레이어로 이동.

### M8. `GameEventState` 수동 copyWith (17개 필드, == 연산자 미구현)
- **파일**: `game_event_provider.dart:28-150`
- **문제**: `@freezed` 대신 수동 `copyWith` 구현. `==` 연산자 미구현으로 동일 상태 재설정 시 불필요한 rebuild 발생.
- **수정**: `@freezed`로 전환 또는 `Equatable` mixin 적용.

### M9. 홈 화면 개발자 도구 FAB 프로덕션 노출
- **파일**: `home_page.dart:177-184`
- **문제**: `floatingActionButton`(bug_report 아이콘)이 빌드 모드 무관하게 항상 표시. `kDebugMode` 가드가 주석 처리됨.
- **수정**: `if (kDebugMode)` 가드 복원.

### M10. GPS 폴링 대기 busy-wait 패턴
- **파일**: `game_page.dart:180-187`
- **문제**: STOMP connected 대기를 `while + Future.delayed(300ms)` 폴링으로 최대 15초간 수행. 스트림 기반 대기로 변경 가능.
- **수정**: `onConnectionState` 스트림의 `Completer` 기반 대기로 변경.

---

## 💡 Minor Issues (개선 권장)

### m1. `ref.watch` 범위 과대 — 불필요한 리빌드
- **파일**: `game_page.dart:612-634`
- **문제**: `_buildAppBar()`에서 `gameParticipantNotifierProvider` 전체를 watch. `.select()`로 필요 필드만 선택적 구독 가능.

### m2. `waiting_room_page.dart` 중복 `ref.watch`
- **파일**: `waiting_room_page.dart:553, 707`
- **문제**: `build()` 최상단에서 watch한 `participantsState`를 `_buildBottomButton`에 파라미터로 전달하지 않고 중복 watch.

### m3. `debugPrint` in `build()` 메서드
- **파일**: `google_map_view.dart:83`, `naver_map_view.dart:98`
- **문제**: 매 빌드마다 콘솔 출력. 개발 완료 후 제거 또는 `kDebugMode` 가드 필요.

### m4. `ChatState.messages` getter 매 호출 시 새 리스트 생성
- **파일**: `chat_provider.dart:42-45`
- **문제**: `[...allScopeMessages, ...teamScopeMessages]` 매번 새 리스트 할당. build 내 호출 시 불필요한 GC 부하.

### m5. `scope` 필드 String 타입 사용
- **파일**: `chat_send_request.dart:22`, `chat_message_dto.dart:28`
- **문제**: "TEAM"/"ALL" 문자열 대신 enum + `@JsonEnum` 사용하면 타입 안전성 향상.

### m6. `game_page.dart` 과도한 위젯 책임 (~730줄)
- **파일**: `game_page.dart`
- **문제**: STOMP 연결, GPS 전송, 타이머, 오버레이, 다이얼로그 등 모두 한 파일에 집중.
- **제안**: GPS 전송 로직을 별도 Provider/Controller로 분리.

### m7. Dead code — `TokenProvider.getRefreshToken()` 미사용
- **파일**: `token_provider.dart:23`
- **문제**: 인터페이스의 `getRefreshToken()` 메서드를 호출하는 곳이 프로젝트 전체에 없음.

### m8. Dead code — `ChatState.messages` getter 미참조
- **파일**: `chat_provider.dart:42-45`
- **문제**: 주석에 "더미 모드 등 호환용"이지만 프로젝트 내 참조 0건.

### m9. 더미 모드 전용 메서드 (`changeDummyTeam`, `toggleDummyReady`)
- **파일**: `waiting_room_participants_provider.dart:223, 240`
- **문제**: 프로덕션 코드에서 참조 없음. 더미 모드 제거 시 함께 정리.

### m10. `game_system_api_datasource.dart` 파일 역할 혼재
- **파일**: `game_system_api_datasource.dart`
- **문제**: DTO 2개 + Retrofit API + Provider가 하나의 파일에. 모델은 `data/models/`로 분리 필요.

### m11. `game_page.dart:419` fire-and-forget `leaveGame` 호출
- **파일**: `game_page.dart:419`
- **문제**: 게임 종료 다이얼로그의 "홈으로" 버튼에서 `leaveGame` 실패 시 사용자 피드백 없음. 서버에서 여전히 참가 중으로 인식 → 다음 게임 참여 시 409 가능.

---

## ✅ Positive Feedback (잘한 점)

1. **BaseStompDatasource 추상화 우수**: 연결 생명주기, 상태 관리, 에러 핸들링을 잘 캡슐화. `@protected`, `@mustCallSuper`, `isDisposed` 가드 패턴 적절.
2. **견고한 재연결 정책**: 지수 백오프 + 최대 재시도 제한 + 의도적 disconnect 가드 + 인증 에러 분리 처리.
3. **낙관적 업데이트 + 롤백**: `arrestRobber`/`escape`에서 낙관적 UI 업데이트 후 API 실패 시 롤백. 실시간 인터랙션 UX 우수.
4. **GamePage dispose 처리**: `Future.microtask`로 provider cleanup을 지연하여 Riverpod dispose 제한 우회. 올바른 패턴.
5. **Stack 자식 인덱스 안정성**: `if/else`와 `SizedBox.shrink()`로 Stack children 수를 일정하게 유지. ChatOverlay State 재생성 방지. 주석으로 이유 설명.
6. **DartDoc 문서화 충실**: Public API에 `///` 주석 일관 적용. DTO에 JSON 예시 포함.
7. **네이밍 컨벤션 준수**: `snake_case` 파일명, `PascalCase` 클래스명, suffix 규칙 잘 지킴.

---

## 📈 리뷰별 상세 요약

### Review-Safety: Dead Code & Runtime Safety
| 유형 | 건수 |
|------|------|
| Dead Code | 4건 |
| Runtime Safety | 7건 |
| 불필요한 리빌드 | 3건 |

### Review-Design-System: Constants & Design System
| 유형 | 건수 |
|------|------|
| 하드코딩 색상 | 7건 |
| 하드코딩 간격/패딩/라운드 | 7건 |
| 하드코딩 텍스트 스타일 | 2건 |
| 미사용 앱 상수 | 6건 |

### Review-Architecture: Architecture & Structure
| 유형 | 건수 |
|------|------|
| 아키텍처 위반 | 5건 |
| DRY 위반 | 3건 |
| 불필요한 구조 | 2건 |
| Riverpod 구조 | 4건 |
| 네이밍 위반 | 2건 |

### Review-General: Security / Performance / Bugs
| 유형 | 건수 |
|------|------|
| Security | 1건 |
| Performance | 3건 |
| Bugs | 4건 |
| Code Quality | 6건 |

---

## 📊 통계

| 리뷰 | Critical | Major | Minor | 합계 |
|------|----------|-------|-------|------|
| Review-Safety | 2 | 2 | 3 | 7 |
| Review-Design-System | 0 | 0 | 6 | 6 |
| Review-Architecture | 2 | 6 | 4 | 12 |
| Review-General | 1 | 5 | 5 | 11 |
| **합계 (중복 제거)** | **3** | **10** | **11** | **24** |

---

## 🎯 핵심 개선 사항 (Top 5)

1. **[C1] `_isHandlingError` 비-401 에러 시 미리셋** → Lobby/Chat STOMP 연결이 비-인증 에러 후 영구 복구 불능
2. **[C2] `arrestRobber()`/`escape()` `isApiLoading` 미해제** → 체포/탈옥 UI가 영구 로딩 상태에 빠짐
3. **[C3] `GameEventStompDatasource.dispose()` 순서** → `StateError` 크래시 가능
4. **[M3] `ChatState.copyWith` 에러 메시지 자동 소실** → 에러 상태가 다른 필드 업데이트 시 사라짐
5. **[M4] STOMP 재연결 로직 3곳 중복** → 유지보수 부담, C1 같은 불일치 버그 원인

## 전체 평가: **Request Changes**

Critical 3건은 런타임 크래시 또는 기능 장애를 유발할 수 있으므로 즉시 수정 필요.

---

## 📋 개선 계획

### Phase 1: Critical 수정 (즉시)
| # | 작업 | 파일 | 예상 범위 |
|---|------|------|----------|
| 1 | `_isHandlingError = false` 추가 (비-401 분기) | `lobby_provider.dart`, `chat_provider.dart` | 각 1줄 추가 |
| 2 | `arrestRobber()`/`escape()` 성공 경로 `isApiLoading: false` | `game_event_provider.dart` | 각 1줄 추가 |
| 3 | `GameEventStompDatasource.dispose()` 순서 수정 | `game_event_stomp_datasource.dart` | 2줄 순서 변경 |

### Phase 2: Major 수정 (배포 전)
| # | 작업 | 파일 | 예상 범위 |
|---|------|------|----------|
| 4 | `ChatState.copyWith` 에러 보존 패턴 수정 | `chat_provider.dart` | ~10줄 |
| 5 | 더미 모드 fire-and-forget Future dispose 처리 | `chat_provider.dart` | ~10줄 |
| 6 | 홈 화면 FAB `kDebugMode` 가드 복원 | `home_page.dart` | 1줄 |
| 7 | `dioProvider` import 경로 수정 (레이어 위반) | `game_system_api_datasource.dart` | 1줄 |

### Phase 3: 구조 개선 (다음 스프린트)
| # | 작업 | 범위 |
|---|------|------|
| 8 | STOMP Notifier 재연결 로직 공통 mixin 추출 | `chat_provider`, `lobby_provider`, `game_event_provider` |
| 9 | 크로스 피처 공유 모델(`LobbyParticipantInfo`) `core/` 이동 | lobby, session, game |
| 10 | 디자인 시스템 상수 하드코딩 13건 일괄 교체 | 6개 파일 |
| 11 | `GameEventState`/`ChatState` → `@freezed` 전환 | 2개 파일 |
| 12 | Chat/Lobby/GameEvent Domain 레이어 결정 및 문서화 | 3개 feature |

### Phase 4: Minor 정리 (여유 시)
| # | 작업 |
|---|------|
| 13 | `debugPrint` in `build()` 제거 |
| 14 | Dead code 정리 (`getRefreshToken`, `messages` getter, 더미 메서드) |
| 15 | `scope` String → enum 전환 |
| 16 | `GamePage` 책임 분리 (GPS 로직 Provider 추출) |
| 17 | 미사용 `AppColors`/`AppPadding` 상수 정리 |
