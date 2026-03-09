# WebSocket / Chat / Game 코드 리뷰 수정 가이드

## 개요

WebSocket(STOMP), Chat, Game 영역 코드 리뷰에서 발견된 이슈를 정리한 문서입니다.
**Critical 2건은 앱 크래시를 유발하므로 우선 수정이 필요합니다.**

| 순서 | 심각도 | 요약 | 수정 대상 파일 |
|:---:|:---:|---|---|
| 1 | **Critical** | StreamController close 후 add → 크래시 | `chat_stomp_datasource.dart`, `lobby_stomp_datasource.dart` |
| 2 | **Critical** | Timer 콜백에서 dispose된 ref 접근 | `chat_provider.dart`, `lobby_provider.dart` |
| 3 | Major | DataSource 코드 90% 중복 → 공통 클래스 추출 | 신규 `base_stomp_datasource.dart` + 위 2개 |
| 4 | Major | 대기실 퇴장 시 STOMP disconnect 순서 | `waiting_room_page.dart` |
| 5 | Major | 채팅 메시지 매 build마다 O(n) 필터링 | `chat_provider.dart`, `chat_overlay.dart` |
| 6 | Minor | 채팅 자동 스크롤이 무조건 하단 이동 | `chat_message_list.dart` |

> **범위 외:** ChatNotifier / LobbyNotifier의 재연결 로직 중복(~85%)은 Task 3 이후 별도 PR로 진행합니다.

---

## Task 1: StreamController close 후 add 방지

### 왜 문제인가?

`dispose()` → `StreamController.close()` 이후에도 STOMP의 비동기 콜백(`_onWebSocketDone`, `_onDisconnect`)이
늦게 도착할 수 있습니다. 이미 닫힌 StreamController에 `.add()`를 호출하면 **`StateError: Cannot add event after closing`** 으로 앱이 크래시합니다.

**재현 시나리오:** 게임 화면에서 빠르게 뒤로가기 → `dispose()` 호출 → WebSocket 콜백이 뒤늦게 도착 → 크래시

### 수정 파일

- `lib/features/chat/data/datasources/chat_stomp_datasource.dart`
- `lib/features/lobby/data/datasources/lobby_stomp_datasource.dart`

### 수정 방법

두 파일 모두 동일한 패턴입니다. `_disposed` 플래그를 추가하고, StreamController에 값을 넣는 모든 메서드에서 체크합니다.

**chat_stomp_datasource.dart 기준:**

```dart
class ChatStompDatasource {
  StompClient? _stompClient;
  bool _disposed = false;  // ✅ 추가

  // ...

  // 이 메서드들에 가드 추가:
  void _updateState(StompConnectionState newState) {
    if (_disposed) return;  // ✅ 추가
    _currentState = newState;
    _connectionStateController.add(newState);
  }

  void _handleMessage(StompFrame frame) {
    if (_disposed) return;  // ✅ 추가
    // ... 기존 로직 동일
  }

  void _onStompError(StompFrame frame) {
    if (_disposed) return;  // ✅ 추가
    // ... 기존 로직 동일
  }

  // dispose()에서 close 전에 플래그 설정:
  void dispose() {
    _disposed = true;  // ✅ close보다 먼저!
    disconnect();
    _messageController.close();
    _connectionStateController.close();
    _errorController.close();
  }
}
```

**lobby_stomp_datasource.dart**도 동일합니다. 메서드 이름만 다릅니다:
- Chat: `_handleMessage()` → Lobby: `_handleEvent()`
- Chat: `_messageController` → Lobby: `_eventController`

### 확인

```bash
flutter analyze lib/features/chat/data/datasources/ lib/features/lobby/data/datasources/
```

---

## Task 2: Timer 콜백 내 ref 접근 안전성

### 왜 문제인가?

`ChatNotifier`와 `LobbyNotifier`의 재연결 로직에서 `Timer` 콜백이 `_attemptReconnect()`를 호출합니다.
이 메서드 안에 `await`가 있는데, **await 하는 동안 Notifier가 dispose될 수 있습니다.**
그러면 await 이후의 `ref.read()`가 이미 해제된 Provider에 접근하게 됩니다.

특히 `_handleStompError()`는 **현재 코드에서 datasource를 await 후에 `ref.read()`하고 있어** 더 위험합니다.

### 수정 파일

- `lib/features/chat/presentation/providers/chat_provider.dart`
- `lib/features/lobby/presentation/providers/lobby_provider.dart`

### 수정 원칙

> **`ref.read()`는 반드시 `await` 전에 호출하여 로컬 변수에 캡처한다.**
> `await` 후에는 캡처한 변수만 사용하고, `_intentionalDisconnect`를 재확인한다.

### Before → After

**`_attemptReconnect()` — 현재 코드 (거의 OK, 미세 보강):**

```dart
// 현재 코드 — datasource는 await 전에 캡처하고 있어서 OK
final datasource = ref.read(chatStompDatasourceProvider);  // ← await 전 ✅
final tokenProvider = ref.read(tokenProviderProvider);      // ← await 전 ✅
final accessToken = await tokenProvider.getAccessToken();

if (_intentionalDisconnect) return;  // ← await 후 체크 ✅

datasource.connect(wsUrl, accessToken);  // ← 캡처된 변수 사용 ✅
```

이 부분은 현재 코드가 이미 올바른 구조입니다. `_gameId` null 체크만 추가하면 됩니다:
```dart
if (_intentionalDisconnect || _gameId == null) return;  // ← _gameId도 체크
```

**`_handleStompError()` — 현재 코드 (위험!):**

```dart
// ❌ 현재 코드 — datasource를 await 후에 ref.read()
final tokenProvider = ref.read(tokenProviderProvider);
final newToken = await tokenProvider.refreshAccessTokenIfNeeded();

if (_intentionalDisconnect || _gameId == null) return;

final datasource = ref.read(chatStompDatasourceProvider);  // ❌ await 후에 ref.read!
datasource.connect(wsUrl, newToken);
```

```dart
// ✅ 수정 후 — 모두 await 전에 캡처
final tokenProvider = ref.read(tokenProviderProvider);
final datasource = ref.read(chatStompDatasourceProvider);  // ✅ await 전으로 이동
final newToken = await tokenProvider.refreshAccessTokenIfNeeded();

if (_intentionalDisconnect || _gameId == null) return;

datasource.connect(wsUrl, newToken);  // ✅ 캡처된 변수 사용
```

**lobby_provider.dart**도 동일 패턴으로 수정합니다.

### 확인

```bash
flutter analyze lib/features/chat/presentation/providers/ lib/features/lobby/presentation/providers/
```

---

## Task 3: BaseStompDatasource 공통 클래스 추출

### 왜 필요한가?

`ChatStompDatasource`(261줄)와 `LobbyStompDatasource`(209줄)의 코드가 **90% 동일**합니다.
`connect()`, `disconnect()`, `dispose()`, STOMP 콜백 5개, `_unsubscribeAll()`, `_updateState()` 등이
복붙 수준으로 같습니다. Task 1의 `_disposed` 버그도 양쪽에 동시에 존재했던 이유입니다.

### 작업 내용

1. **신규 생성**: `lib/core/network/websocket/base_stomp_datasource.dart`
2. **수정**: `chat_stomp_datasource.dart` → `BaseStompDatasource` 상속
3. **수정**: `lobby_stomp_datasource.dart` → `BaseStompDatasource` 상속
4. **삭제**: `lib/core/network/websocket/_placeholder.dart` (더 이상 불필요)
5. **수정**: `chat_provider.dart` — `subscribeAll()` + `subscribeTeam()` → `subscribeChat()` 통합
6. **수정**: `lobby_provider.dart` — `_setupStreams()` connected 블록에서 구독 호출 제거

### 구조 설계

```
BaseStompDatasource (abstract)
├── connect(), disconnect(), dispose()     ← 공통
├── _onConnect(), _onStompError() 등       ← 공통
├── _updateState(), _unsubscribeAll()      ← 공통
├── _disposed 플래그                        ← Task 1 통합
├── stompClient getter (protected)         ← 서브클래스용
├── addSubscription() (protected)          ← 서브클래스용
└── onConnected() (abstract)               ← 서브클래스에서 구현
    │
    ├── ChatStompDatasource
    │   ├── subscribeChat(gameId, team)    ← 전체+팀 채팅 구독
    │   ├── publishChat(gameId, msg, scope)
    │   └── _handleMessage(StompFrame)     ← 메시지 파싱
    │
    └── LobbyStompDatasource
        ├── subscribeLobby(gameId)         ← 로비 이벤트 구독
        └── _handleEvent(StompFrame)       ← 이벤트 파싱
```

### 핵심 변경: 구독 타이밍 개선

현재는 Notifier의 `_setupStreams()`에서 connected 상태일 때 수동으로 구독 메서드를 호출합니다.
리팩토링 후에는 DataSource 자체가 pending 패턴을 사용합니다:

```dart
// DataSource에서 pending 패턴
void subscribeChat(int gameId, String team) {
  _pendingGameId = gameId;
  _pendingTeam = team;
  if (currentState == StompConnectionState.connected) {
    _doSubscribe();  // 이미 연결됨 → 즉시 구독
  }
  // 아직 연결 안 됨 → onConnected()에서 자동 구독
}

@override
void onConnected() {
  _doSubscribe();  // 연결 성공 콜백 → pending 구독 실행
}
```

이로 인해 **Notifier의 `_setupStreams()` connected 블록에서 구독 호출을 제거**해야 합니다.
대신 `connectAndSubscribe()` 초기에 `datasource.subscribeChat(gameId, team)`을 호출하여 pending을 설정합니다.

### 전체 코드

아래에 3개 파일의 전체 코드를 첨부합니다. 그대로 사용해도 되고, 기존 코드를 참고하여 작성해도 됩니다.

<details>
<summary><b>base_stomp_datasource.dart (신규 생성)</b></summary>

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'stomp_connection.dart';

export 'stomp_connection.dart' show StompConnectionState, StompErrorInfo;

/// STOMP DataSource 공통 베이스 클래스
///
/// Chat, Lobby 등 STOMP 기반 DataSource의 공통 로직을 제공합니다:
/// - STOMP 연결/해제/dispose
/// - 연결 상태 스트림
/// - STOMP ERROR 파싱 (RFC 7807)
/// - 구독 관리
///
/// 서브클래스는 [onConnected]를 override하여 연결 후 구독을 설정합니다.
abstract class BaseStompDatasource {
  StompClient? _stompClient;
  bool _disposed = false;

  /// 로그 태그 (서브클래스에서 지정, 예: 'ChatStomp')
  String get logTag;

  /// 연결 상태 스트림
  final _connectionStateController =
      StreamController<StompConnectionState>.broadcast();
  Stream<StompConnectionState> get onConnectionState =>
      _connectionStateController.stream;

  /// STOMP ERROR 스트림
  final _errorController = StreamController<StompErrorInfo>.broadcast();
  Stream<StompErrorInfo> get onError => _errorController.stream;

  /// 현재 연결 상태
  StompConnectionState _currentState = StompConnectionState.disconnected;
  StompConnectionState get currentState => _currentState;

  /// 구독 해제 함수 보관
  final List<StompUnsubscribe?> _subscriptions = [];

  /// STOMP 클라이언트 (서브클래스에서 구독 시 사용)
  @protected
  StompClient? get stompClient => _stompClient;

  /// 구독 등록 (서브클래스에서 호출)
  @protected
  void addSubscription(StompUnsubscribe? sub) {
    _subscriptions.add(sub);
  }

  /// STOMP 서버에 연결
  void connect(String wsUrl, String accessToken) {
    debugPrint('[$logTag] 🔄 connect() 호출 → $wsUrl');
    _unsubscribeAll();
    _stompClient?.deactivate();
    _stompClient = null;

    _updateState(StompConnectionState.connecting);

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        onConnect: _onConnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        onWebSocketDone: _onWebSocketDone,
        onDisconnect: _onDisconnect,
        reconnectDelay: Duration.zero,
      ),
    );

    _stompClient!.activate();
  }

  /// 연결 해제
  void disconnect() {
    _unsubscribeAll();
    _stompClient?.deactivate();
    _stompClient = null;
    _updateState(StompConnectionState.disconnected);
    debugPrint('[$logTag] 연결 해제');
  }

  /// 리소스 정리 (Provider onDispose에서 호출)
  @mustCallSuper
  void dispose() {
    debugPrint('[$logTag] ⚠️ dispose() 호출됨');
    _disposed = true;
    disconnect();
    _connectionStateController.close();
    _errorController.close();
  }

  /// 연결 성공 시 호출 — 서브클래스에서 구독 설정
  @protected
  void onConnected();

  // ============================================
  // STOMP 콜백
  // ============================================

  void _onConnect(StompFrame frame) {
    _updateState(StompConnectionState.connected);
    debugPrint('[$logTag] ✅ STOMP 연결 성공');
    onConnected();
  }

  void _onStompError(StompFrame frame) {
    if (_disposed) return;
    debugPrint('[$logTag] ❌ STOMP ERROR body: ${frame.body}');

    StompErrorInfo errorInfo;
    if (frame.body != null && frame.body!.isNotEmpty) {
      try {
        final json = jsonDecode(frame.body!) as Map<String, dynamic>;
        errorInfo = StompErrorInfo.fromJson(json);
      } catch (e) {
        debugPrint('[$logTag] ⚠️ STOMP ERROR body 파싱 실패: $e');
        errorInfo = StompErrorInfo(
          title: 'STOMP Error',
          status: 0,
          detail: frame.body ?? 'Unknown error',
          instance: 'STOMP',
        );
      }
    } else {
      errorInfo = const StompErrorInfo(
        title: 'STOMP Error',
        status: 0,
        detail: 'Unknown STOMP error',
        instance: 'STOMP',
      );
    }

    _updateState(StompConnectionState.error);
    _errorController.add(errorInfo);

    if (errorInfo.isAuthExpired) {
      debugPrint('[$logTag] 인증 만료 - 클라이언트 비활성화');
      _unsubscribeAll();
      _stompClient?.deactivate();
      _stompClient = null;
    }
  }

  void _onWebSocketError(dynamic error) {
    if (_disposed) return;
    debugPrint('[$logTag] ❌ WebSocket Error: $error');
    _updateState(StompConnectionState.error);
  }

  void _onWebSocketDone() {
    if (_disposed) return;
    debugPrint('[$logTag] WebSocket 연결 종료');
    _updateState(StompConnectionState.disconnected);
  }

  void _onDisconnect(StompFrame frame) {
    if (_disposed) return;
    debugPrint('[$logTag] STOMP Disconnect');
    _updateState(StompConnectionState.disconnected);
  }

  // ============================================
  // 내부 메서드
  // ============================================

  void _unsubscribeAll() {
    for (final unsubscribe in _subscriptions) {
      if (unsubscribe != null) {
        try {
          unsubscribe(unsubscribeHeaders: {});
        } catch (_) {}
      }
    }
    _subscriptions.clear();
  }

  void _updateState(StompConnectionState newState) {
    if (_disposed) return;
    _currentState = newState;
    _connectionStateController.add(newState);
  }
}
```

</details>

<details>
<summary><b>chat_stomp_datasource.dart (리팩토링 후)</b></summary>

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/websocket/base_stomp_datasource.dart';
import '../models/chat_message_dto.dart';
import '../models/chat_send_request.dart';

export '../../../../core/network/websocket/base_stomp_datasource.dart'
    show StompConnectionState, StompErrorInfo;

/// 채팅 STOMP DataSource
///
/// [BaseStompDatasource]를 상속하여 채팅 전용 구독/발행을 구현합니다.
class ChatStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'ChatStomp';

  final _messageController = StreamController<ChatMessageDto>.broadcast();
  Stream<ChatMessageDto> get onMessage => _messageController.stream;

  int? _pendingGameId;
  String? _pendingTeam;

  /// 전체 + 팀 채팅 구독 예약
  ///
  /// connected 상태면 즉시, 아니면 연결 성공 시 자동 구독.
  void subscribeChat(int gameId, String team) {
    _pendingGameId = gameId;
    _pendingTeam = team;
    if (currentState == StompConnectionState.connected) {
      _doSubscribe();
    }
  }

  @override
  void onConnected() {
    _doSubscribe();
  }

  void _doSubscribe() {
    if (_pendingGameId == null || _pendingTeam == null) return;
    final gameId = _pendingGameId!;
    final team = _pendingTeam!;

    final allDest = '/subscribe/game/$gameId/chat/all';
    addSubscription(stompClient!.subscribe(
      destination: allDest,
      callback: _handleMessage,
    ));
    debugPrint('[$logTag] ✅ 전체 채팅 구독: $allDest');

    final teamDest = '/subscribe/game/$gameId/chat/$team';
    addSubscription(stompClient!.subscribe(
      destination: teamDest,
      callback: _handleMessage,
    ));
    debugPrint('[$logTag] ✅ 팀 채팅 구독: $teamDest');
  }

  /// 채팅 메시지 발행
  void publishChat(int gameId, String message, String scope) {
    if (stompClient == null ||
        currentState != StompConnectionState.connected) {
      debugPrint('[$logTag] ⚠️ publishChat 실패 - 연결되지 않음');
      return;
    }

    final request = ChatSendRequest(message: message, scope: scope);
    final destination = '/publish/game/$gameId/chat';
    stompClient!.send(
      destination: destination,
      body: jsonEncode(request.toJson()),
    );
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }

  void _handleMessage(StompFrame frame) {
    if (frame.body == null || frame.body!.isEmpty) return;
    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      _messageController.add(ChatMessageDto.fromJson(json));
    } catch (e) {
      debugPrint('[$logTag] ❌ 메시지 파싱 실패: $e');
    }
  }
}
```

</details>

<details>
<summary><b>lobby_stomp_datasource.dart (리팩토링 후)</b></summary>

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/websocket/base_stomp_datasource.dart';
import '../models/lobby_event_dto.dart';

export '../../../../core/network/websocket/base_stomp_datasource.dart'
    show StompConnectionState, StompErrorInfo;

/// 로비 STOMP DataSource
///
/// [BaseStompDatasource]를 상속하여 로비 이벤트 구독을 구현합니다.
class LobbyStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'LobbyStomp';

  final _eventController = StreamController<LobbyEventDto>.broadcast();
  Stream<LobbyEventDto> get onEvent => _eventController.stream;

  int? _pendingGameId;

  /// 로비 이벤트 구독 예약
  void subscribeLobby(int gameId) {
    _pendingGameId = gameId;
    if (currentState == StompConnectionState.connected) {
      _doSubscribe();
    }
  }

  @override
  void onConnected() {
    _doSubscribe();
  }

  void _doSubscribe() {
    if (_pendingGameId == null) return;
    final destination = '/subscribe/game/$_pendingGameId/lobby';
    addSubscription(stompClient!.subscribe(
      destination: destination,
      callback: _handleEvent,
    ));
    debugPrint('[$logTag] ✅ 로비 이벤트 구독: $destination');
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }

  void _handleEvent(StompFrame frame) {
    if (frame.body == null || frame.body!.isEmpty) return;
    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final dto = LobbyEventDto.fromJson(json);
      debugPrint('[$logTag] 📩 이벤트: type=${dto.type}, gameId=${dto.gameId}');
      _eventController.add(dto);
    } catch (e) {
      debugPrint('[$logTag] ❌ 이벤트 파싱 실패: $e');
    }
  }
}
```

</details>

### Notifier 쪽 수정 사항

Task 3으로 DataSource API가 변경되므로 Notifier에서 호출부를 맞춰야 합니다.

**chat_provider.dart:**

```dart
// connectAndSubscribe() 마지막 부분
// 변경 전:
datasource.connect(wsUrl, accessToken);
// → connected 후 _setupStreams()에서 subscribeAll() + subscribeTeam() 호출

// 변경 후:
datasource.subscribeChat(gameId, team);  // pending 설정
datasource.connect(wsUrl, accessToken);  // connected 시 자동 구독
```

```dart
// _setupStreams() connected 블록
// 변경 전:
if (_gameId != null && _team != null) {
  datasource.subscribeAll(_gameId!);
  datasource.subscribeTeam(_gameId!, _team!);
}

// 변경 후: (구독은 onConnected()에서 자동 실행되므로 제거)
// 구독 호출 삭제 — BaseStompDatasource.onConnected()에서 자동 처리
```

**lobby_provider.dart:**

```dart
// connectAndSubscribe() 마지막 부분
datasource.subscribeLobby(gameId);  // pending 설정
datasource.connect(wsUrl, accessToken);

// _setupStreams() connected 블록의 subscribeLobby() 호출도 제거
```

### 삭제

```bash
rm lib/core/network/websocket/_placeholder.dart
```

### 확인

```bash
flutter analyze
```

---

## Task 4: 대기실 퇴장 시 STOMP disconnect 순서

### 왜 문제인가?

현재 `_leaveRoom()`의 흐름:
1. REST API 퇴장 호출 (`leaveGameProvider`) ← 서버에서 EXIT 이벤트 브로드캐스트
2. 홈으로 이동
3. `dispose()`에서 STOMP disconnect

**문제:** 1번과 3번 사이에 서버가 보낸 EXIT 이벤트를 본인이 수신합니다.
이미 나가는 중인데 참가자 목록이 업데이트되는 불필요한 상태 변경이 발생합니다.

### 수정 파일

- `lib/features/session/presentation/pages/waiting_room_page.dart`

### Before → After

```dart
// ❌ 현재 코드 (waiting_room_page.dart:349-358)
Future<void> _leaveRoom() async {
  final gameId = int.tryParse(widget.sessionId);
  if (gameId != null) {
    await ref.read(leaveGameProvider(gameId).future);  // REST 먼저
  }
  ref.read(gameParticipantNotifierProvider.notifier).clear();
  if (mounted) {
    context.go(RoutePaths.home);
  }
  // → dispose()에서 STOMP disconnect (늦음)
}
```

```dart
// ✅ 수정 후
Future<void> _leaveRoom() async {
  // ① STOMP 먼저 끊기 (EXIT 이벤트 자기 수신 방지)
  _lobbyEventSub?.close();
  _lobbyEventSub = null;
  ref.read(lobbyNotifierProvider.notifier).disconnectLobby();

  // ② 그 다음 REST API 퇴장
  final gameId = int.tryParse(widget.sessionId);
  if (gameId != null) {
    await ref.read(leaveGameProvider(gameId).future);
  }

  // ③ 상태 초기화
  ref.read(gameParticipantNotifierProvider.notifier).clear();
  ref.read(waitingRoomParticipantsProvider.notifier).clear();

  if (mounted) {
    context.go(RoutePaths.home);
  }
}
```

`dispose()`는 `_leaveRoom()`에서 이미 null로 설정된 `_lobbyEventSub`를 다시 close하므로 안전합니다.
`disconnectLobby()`도 이미 disconnected 상태면 내부적으로 무시합니다.

### 확인

```bash
flutter analyze lib/features/session/presentation/pages/waiting_room_page.dart
```

---

## Task 5: 채팅 메시지 필터링 성능 개선

### 왜 문제인가?

`ChatOverlay.build()`에서 매번 이렇게 호출합니다:

```dart
// chat_overlay.dart:158-173 — 매 build마다 O(n) × 2회
ChatMessageList(messages: _filterMessages(chatState.messages, 'ALL'), ...)
ChatMessageList(messages: _filterMessages(chatState.messages, 'TEAM'), ...)
```

`_filterMessages()`는 `.where().toList()`로 전체 리스트를 순회합니다.
메시지가 200개(max)면 매 build마다 400회 비교 + 2개의 새 리스트 생성.

### 수정 파일

- `lib/features/chat/presentation/providers/chat_provider.dart`
- `lib/features/chat/presentation/widgets/chat_overlay.dart`

### 수정 방법

`ChatState`에서 메시지를 scope별로 분리 저장하여, build 시 필터링 없이 바로 사용합니다.

**ChatState 변경:**

```dart
// 변경 전
class ChatState {
  final List<ChatMessageDto> messages;           // 전부 한 리스트
  // ...
}

// 변경 후
class ChatState {
  final List<ChatMessageDto> allScopeMessages;   // scope == 'ALL' 만
  final List<ChatMessageDto> teamScopeMessages;  // scope == 'TEAM' 만
  // ...

  // 기존 호환용 (더미 모드 등)
  List<ChatMessageDto> get messages => [...allScopeMessages, ...teamScopeMessages];
}
```

**메시지 수신 시 분류:**

```dart
// _setupStreams() 메시지 구독
_messageSub = datasource.onMessage.listen((message) {
  if (message.scope == 'TEAM') {
    final updated = [...state.teamScopeMessages, message];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages) : updated;
    state = state.copyWith(teamScopeMessages: trimmed);
  } else {
    final updated = [...state.allScopeMessages, message];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages) : updated;
    state = state.copyWith(allScopeMessages: trimmed);
  }
});
```

**ChatOverlay에서 직접 사용:**

```dart
// 변경 전
ChatMessageList(messages: _filterMessages(chatState.messages, 'ALL'), ...)
ChatMessageList(messages: _filterMessages(chatState.messages, 'TEAM'), ...)

// 변경 후
ChatMessageList(messages: chatState.allScopeMessages, ...)
ChatMessageList(messages: chatState.teamScopeMessages, ...)
```

`_filterMessages()` 메서드는 삭제합니다.

> **참고:** `_addDummyMessage()`도 동일하게 scope별 분류하도록 수정 필요합니다.

### 확인

```bash
flutter analyze lib/features/chat/
```

---

## Task 6: 채팅 자동 스크롤 개선

### 왜 문제인가?

현재 `ChatMessageList`는 새 메시지가 올 때마다 **무조건** 맨 아래로 스크롤합니다.
사용자가 위로 스크롤하여 이전 메시지를 읽고 있어도 강제로 끌려 내려갑니다.

### 수정 파일

- `lib/features/chat/presentation/widgets/chat_message_list.dart`

### Before → After

```dart
// ❌ 현재 코드 (chat_message_list.dart:42-50) — 무조건 스크롤
void _scrollToBottom() {
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
```

```dart
// ✅ 수정 후 — 하단 근처(100px 이내)일 때만
void _scrollToBottom() {
  if (!_scrollController.hasClients) return;
  final position = _scrollController.position;
  final isNearBottom = position.maxScrollExtent - position.pixels < 100;
  if (isNearBottom) {
    _scrollController.animateTo(
      position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
```

### 확인

```bash
flutter analyze lib/features/chat/presentation/widgets/chat_message_list.dart
```

---

## 실행 순서

| 순서 | Task | 심각도 | 비고 |
|:---:|---|:---:|---|
| 1 | StreamController crash 방지 | Critical | 먼저 적용하여 즉시 크래시 방지 |
| 2 | Timer 콜백 ref 안전성 | Critical | |
| 3 | BaseStompDatasource 추출 | Major | Task 1의 `_disposed`가 베이스 클래스에 통합됨 |
| 4 | 대기실 퇴장 STOMP 타이밍 | Major | |
| 5 | 채팅 메시지 필터링 성능 | Major | |
| 6 | 자동 스크롤 UX 개선 | Minor | |

**Task 1 → Task 3 관계:**
Task 1에서 양쪽 파일에 `_disposed`를 추가한 뒤, Task 3에서 베이스 클래스로 통합합니다.
Task 3을 완료하면 Task 1의 개별 패치는 자연스럽게 정리됩니다.
커밋은 Task별로 나눠서 해주세요.
