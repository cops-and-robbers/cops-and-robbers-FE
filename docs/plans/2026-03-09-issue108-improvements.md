# #108 코드 리뷰 개선사항 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** #69 코드 리뷰에서 발견된 Critical 3건, Major 7건, Minor 정리 항목을 수정하여 STOMP 안정성과 코드 품질을 개선한다.

**Architecture:** 기존 Feature-First + Clean Architecture 유지. STOMP Notifier 3곳의 에러 처리 일관성 확보, dispose 순서 통일, 레이어 위반 수정.

**Tech Stack:** Flutter 3.9.2+ / Dart 3.9.2+ / Riverpod / STOMP

---

### Task 1: [C1] `_isHandlingError` 비-401 에러 시 미리셋 — lobby_provider, chat_provider

**Files:**
- Modify: `lib/features/lobby/presentation/providers/lobby_provider.dart:330-337`
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart:491-499`

**문제:** `_handleStompError`의 비-401(else) 분기에서 `_isHandlingError = false`를 리셋하지 않음. 비-인증 STOMP 에러 후 WebSocket이 끊어지면 `_isHandlingError == true`여서 `_scheduleReconnect()`가 영원히 호출되지 않음. `GameEventNotifier`(라인 559)는 올바르게 처리됨.

**Step 1: lobby_provider.dart 수정**

`lib/features/lobby/presentation/providers/lobby_provider.dart:330-337` — else 분기 끝에 `_isHandlingError = false` 추가:

```dart
    } else {
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: errorInfo.detail.isNotEmpty
            ? errorInfo.detail
            : 'STOMP 에러가 발생했습니다.',
      );
      _isHandlingError = false; // 비-인증 에러: WebSocket 종료 후 재연결 허용
    }
```

**Step 2: chat_provider.dart 수정**

`lib/features/chat/presentation/providers/chat_provider.dart:491-499` — else 분기 끝에 `_isHandlingError = false` 추가:

```dart
    } else {
      // 비-401 STOMP 에러: 에러 메시지 표시, 자동 재연결 안 함
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: errorInfo.detail.isNotEmpty
            ? errorInfo.detail
            : 'STOMP 에러가 발생했습니다.',
      );
      _isHandlingError = false; // 비-인증 에러: WebSocket 종료 후 재연결 허용
    }
```

**Step 3: 빌드 확인**

```bash
flutter analyze
```

Expected: 에러 없음

**Step 4: 커밋**

```bash
git add lib/features/lobby/presentation/providers/lobby_provider.dart lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "fix : STOMP 비-401 에러 시 _isHandlingError 미리셋 버그 수정 #108"
```

---

### Task 2: [C2] `arrestRobber()`/`escape()` 성공 시 `isApiLoading` 미해제

**Files:**
- Modify: `lib/features/game/presentation/providers/game_event_provider.dart:262-280`

**문제:** API 호출 성공 경로에서 `isApiLoading: false` 미설정. STOMP 이벤트 핸들러가 해제하지만, 이벤트 미도착 시 영구 로딩.

**Step 1: arrestRobber 성공 경로에 isApiLoading 해제 추가**

`game_event_provider.dart:262-269` — try 블록 성공 경로에 추가:

```dart
    try {
      await ref
          .read(gameSystemApiProvider)
          .arrest(
            gameId,
            ArrestRequestModel(robberParticipantId: robberParticipantId),
          );
      // API 성공 → 로딩 해제 (STOMP 이벤트에서 최종 상태 확정)
      state = state.copyWith(isApiLoading: false);
    } catch (e) {
```

**Step 2: escape 성공 경로에 isApiLoading 해제 추가**

`game_event_provider.dart:293-296` — try 블록 성공 경로에 추가:

```dart
    try {
      await ref.read(gameSystemApiProvider).escape(gameId);
      // API 성공 → 로딩 해제 (STOMP 이벤트에서 최종 상태 확정)
      state = state.copyWith(isApiLoading: false);
    } catch (e) {
```

**Step 3: 빌드 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/game/presentation/providers/game_event_provider.dart
git commit -m "fix : 체포/탈옥 API 성공 시 isApiLoading 미해제 버그 수정 #108"
```

---

### Task 3: [C3] `GameEventStompDatasource.dispose()` StreamController close 순서 수정

**Files:**
- Modify: `lib/features/game/data/datasources/game_event_stomp_datasource.dart:85-89`

**문제:** `_eventController.close()`를 `super.dispose()` 이전에 호출. `super.dispose()` 내부에서 콜백이 이미 닫힌 controller에 접근 시 `StateError`. ChatStompDatasource/LobbyStompDatasource는 `super.dispose()` → controller close 순서로 올바름.

**Step 1: dispose 순서 변경**

`game_event_stomp_datasource.dart:85-89`:

```dart
  @override
  void dispose() {
    super.dispose();
    _eventController.close();
  }
```

**Step 2: 빌드 확인**

```bash
flutter analyze
```

**Step 3: 커밋**

```bash
git add lib/features/game/data/datasources/game_event_stomp_datasource.dart
git commit -m "fix : GameEventStompDatasource dispose 순서 수정 — StateError 방지 #108"
```

---

### Task 4: [M3] `ChatState.copyWith` 에러 메시지 자동 소실 수정

**Files:**
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart:47-59`

**문제:** `copyWith(connectionState: ...)` 호출 시 `errorMessage` 파라미터 기본값이 `null`이므로 기존 에러 메시지가 암묵적으로 소실됨. `GameEventState`는 `clearError` boolean 패턴으로 올바르게 보존.

**Step 1: ChatState.copyWith에 clearError 패턴 적용**

`chat_provider.dart:47-59`를 다음으로 교체:

```dart
  ChatState copyWith({
    List<ChatMessageDto>? allScopeMessages,
    List<ChatMessageDto>? teamScopeMessages,
    StompConnectionState? connectionState,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      allScopeMessages: allScopeMessages ?? this.allScopeMessages,
      teamScopeMessages: teamScopeMessages ?? this.teamScopeMessages,
      connectionState: connectionState ?? this.connectionState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
```

**Step 2: 연결 성공 시 에러 메시지 클리어 패턴 수정**

`chat_provider.dart:338` — `state = state.copyWith(errorMessage: null);`를 다음으로 교체:

```dart
        state = state.copyWith(clearError: true);
```

**Step 3: LobbyState.copyWith에도 동일 패턴 적용**

`lobby_provider.dart:36-46`를 다음으로 교체:

```dart
  LobbyState copyWith({
    StompConnectionState? connectionState,
    String? errorMessage,
    LobbyEventDto? lastEvent,
    bool clearError = false,
  }) {
    return LobbyState(
      connectionState: connectionState ?? this.connectionState,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }
```

**Step 4: lobby_provider.dart 연결 성공 시 클리어 패턴 수정**

`lobby_provider.dart:194` — `state = state.copyWith(errorMessage: null);`를 다음으로 교체:

```dart
        state = state.copyWith(clearError: true);
```

**Step 5: 빌드 확인**

```bash
flutter analyze
```

**Step 6: 커밋**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart lib/features/lobby/presentation/providers/lobby_provider.dart
git commit -m "fix : ChatState/LobbyState copyWith 에러 메시지 자동 소실 수정 #108"
```

---

### Task 5: [M2] ChatProvider 더미 모드 fire-and-forget Future dispose 미처리

**Files:**
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart:95-110, 213-227`

**문제:** `Future.delayed(1초)` 더미 자동응답이 fire-and-forget. Provider dispose 후 `state =` 할당 시 예외 발생 가능.

**Step 1: Timer 필드 추가 및 dispose 시 취소**

`chat_provider.dart` ChatNotifier 클래스에 필드 추가 (line ~95 부근):

```dart
  /// 더미 모드 자동응답 타이머
  Timer? _dummyReplyTimer;
```

`build()` 메서드의 `ref.onDispose` 블록(line 105-110)에 추가:

```dart
    ref.onDispose(() {
      _messageSub?.cancel();
      _connectionSub?.cancel();
      _errorSub?.cancel();
      _reconnectTimer?.cancel();
      _dummyReplyTimer?.cancel();
    });
```

**Step 2: Future.delayed를 Timer로 교체**

`chat_provider.dart:214-227`의 `Future.delayed` 블록을 교체:

```dart
      // 상대방 자동 응답 (1초 후)
      _dummyReplyTimer?.cancel();
      _dummyReplyTimer = Timer(const Duration(seconds: 1), () {
        if (_isDummyMode) {
          _addDummyMessage(
            message: '${scope == 'TEAM' ? '[팀] ' : ''}응답 테스트 메시지!',
            scope: scope,
            participantId: 999,
            nickname: scope == 'TEAM' ? '팀원닉네임' : '상대닉네임',
            team: scope == 'TEAM'
                ? (_team?.toUpperCase() ?? 'POLICE')
                : 'ROBBER',
          );
        }
      });
```

**Step 3: 빌드 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart
git commit -m "fix : ChatProvider 더미 모드 fire-and-forget Future → Timer 교체 #108"
```

---

### Task 6: [M5] Data 레이어에서 Presentation 레이어 import 수정 (레이어 위반)

**Files:**
- Modify: `lib/features/game/data/datasources/game_system_api_datasource.dart:8`

**문제:** `data/datasources/`에서 `auth/presentation/providers/auth_provider.dart`의 `dioProvider`를 import. Clean Architecture 의존성 흐름 위반. `dioProvider`는 `lib/core/network/dio_client.dart`에도 정의되어 있을 수 있으므로 확인 필요.

**Step 1: dioProvider 위치 확인**

```bash
grep -rn "dioProvider" lib/core/ --include="*.dart"
```

`dioProvider`가 `core/network/` 또는 `core/` 어딘가에 이미 있으면 그 경로로 import 변경.
없으면 `auth_provider.dart`에서 `dioProvider` 정의를 `core/network/dio_client.dart`로 이동.

**Step 2: import 경로 수정**

`game_system_api_datasource.dart`의 import를 올바른 core 경로로 변경:

```dart
// Before:
import '../../../auth/presentation/providers/auth_provider.dart';

// After: (정확한 경로는 Step 1 결과에 따라 결정)
import '../../../../core/network/dio_client.dart';
```

**Step 3: 빌드 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/game/data/datasources/game_system_api_datasource.dart
git commit -m "fix : game_system_api_datasource 레이어 위반 import 수정 #108"
```

---

### Task 7: [M9] 홈 화면 개발자 도구 FAB `kDebugMode` 가드 복원

**Files:**
- Modify: `lib/features/session/presentation/pages/home_page.dart:177-184`

**문제:** `floatingActionButton`이 빌드 모드 무관하게 항상 표시. 주석 처리된 `kDebugMode` 가드 복원 필요.

**Step 1: kDebugMode 가드 적용**

`home_page.dart:177-184`를 다음으로 교체:

```dart
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.black.withValues(alpha: 0.7),
              foregroundColor: AppColors.white,
              onPressed: () => _showDevMenu(context),
              child: const Icon(Icons.bug_report),
            )
          : null,
```

**Step 2: `kDebugMode` import 확인**

`import 'package:flutter/foundation.dart';`가 파일 상단에 있는지 확인. 없으면 추가.

**Step 3: 빌드 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/session/presentation/pages/home_page.dart
git commit -m "fix : 홈 화면 개발자 도구 FAB kDebugMode 가드 복원 #108"
```

---

### Task 8: [m3] `debugPrint` in `build()` 제거

**Files:**
- Modify: `lib/features/game/presentation/widgets/google_map_view.dart:83`
- Modify: `lib/features/game/presentation/widgets/naver_map_view.dart:98`

**문제:** 매 빌드마다 콘솔 출력. 성능 영향 미미하지만 로그 노이즈.

**Step 1: google_map_view.dart build() 내 debugPrint 제거**

`google_map_view.dart:83` — `debugPrint('🗺️ GoogleMapView build 호출');` 라인 삭제.

**Step 2: naver_map_view.dart build() 내 debugPrint 제거**

`naver_map_view.dart:98` — `debugPrint('🗺️ NaverMapView build 호출');` 라인 삭제.

**Step 3: 빌드 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/game/presentation/widgets/google_map_view.dart lib/features/game/presentation/widgets/naver_map_view.dart
git commit -m "chore : build() 내 불필요한 debugPrint 제거 #108"
```

---

### Task 9: [m7, m8] Dead code 정리

**Files:**
- Modify: `lib/features/auth/presentation/providers/token_provider.dart:20-23`
- Modify: `lib/features/chat/presentation/providers/chat_provider.dart:41-45`

**문제:**
- `TokenProvider.getRefreshToken()`: 프로젝트 전체에서 호출하는 곳 없음
- `ChatState.messages` getter: 프로젝트 내 참조 0건

**Step 1: ChatState.messages getter 제거**

`chat_provider.dart:41-45` — 아래 코드 삭제:

```dart
  /// 전체 메시지 (더미 모드 등 호환용)
  List<ChatMessageDto> get messages => [
    ...allScopeMessages,
    ...teamScopeMessages,
  ];
```

**Step 2: TokenProvider.getRefreshToken() 제거 가능 여부 확인**

```bash
grep -rn "getRefreshToken" lib/ --include="*.dart"
```

인터페이스와 구현체 모두에서 참조가 없으면 제거. 인터페이스를 구현하는 다른 클래스가 있을 수 있으므로 확인 후 결정.

만약 `ServerTokenProvider`만 구현하고 있고 외부 호출이 없으면:
- `TokenProvider` 인터페이스에서 `getRefreshToken()` 제거
- `ServerTokenProvider`에서 `getRefreshToken()` 구현 제거

**Step 3: 빌드 확인**

```bash
flutter analyze
```

**Step 4: 커밋**

```bash
git add lib/features/chat/presentation/providers/chat_provider.dart lib/features/auth/presentation/providers/token_provider.dart
git commit -m "chore : dead code 정리 — 미사용 getRefreshToken, messages getter 제거 #108"
```

---

### Task 10: [m10] `game_system_api_datasource.dart` 파일 역할 분리

**Files:**
- Modify: `lib/features/game/data/datasources/game_system_api_datasource.dart`
- Create: `lib/features/game/data/models/arrest_request_model.dart`
- Create: `lib/features/game/data/models/arrest_response_model.dart`

**문제:** DTO 2개 + Retrofit API + Provider가 하나의 파일에 혼재. 모델은 `data/models/`로 분리 필요.

**Step 1: ArrestRequestModel을 별도 파일로 분리**

`lib/features/game/data/models/arrest_request_model.dart` 생성:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrest_request_model.freezed.dart';
part 'arrest_request_model.g.dart';

/// 체포 요청 모델
@freezed
class ArrestRequestModel with _$ArrestRequestModel {
  const factory ArrestRequestModel({
    required int robberParticipantId,
  }) = _ArrestRequestModel;

  factory ArrestRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestRequestModelFromJson(json);
}
```

**Step 2: ArrestResponseModel을 별도 파일로 분리**

`lib/features/game/data/models/arrest_response_model.dart` 생성:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrest_response_model.freezed.dart';
part 'arrest_response_model.g.dart';

/// 체포 응답 모델
@freezed
class ArrestResponseModel with _$ArrestResponseModel {
  const factory ArrestResponseModel({
    required String message,
  }) = _ArrestResponseModel;

  factory ArrestResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ArrestResponseModelFromJson(json);
}
```

**Step 3: game_system_api_datasource.dart에서 DTO 제거, import로 교체**

DTO 정의를 제거하고 새 파일 import:

```dart
import '../models/arrest_request_model.dart';
import '../models/arrest_response_model.dart';
```

`part` 지시문도 `arrest_request_model`, `arrest_response_model` 관련 freezed/g.dart 제거.

**Step 4: 코드 생성 실행**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 5: 빌드 확인**

```bash
flutter analyze
```

**Step 6: 커밋**

```bash
git add lib/features/game/data/
git commit -m "refactor : game_system_api_datasource DTO를 별도 모델 파일로 분리 #108"
```

---

### Task 11: 포맷팅 및 최종 확인

**Step 1: 전체 포맷팅**

```bash
dart format lib/
```

**Step 2: 최종 분석**

```bash
flutter analyze
```

**Step 3: 포맷팅 변경사항 있으면 커밋**

```bash
git add -u
git commit -m "style : 포맷팅 수정 #108"
```
