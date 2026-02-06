import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/chat_message_dto.dart';
import '../models/chat_send_request.dart';

/// STOMP 연결 상태
enum StompConnectionState { disconnected, connecting, connected, error }

/// STOMP ERROR 프레임에서 파싱된 에러 정보
class StompErrorInfo {
  final String title;
  final int status;
  final String detail;
  final String instance;

  const StompErrorInfo({
    required this.title,
    required this.status,
    required this.detail,
    required this.instance,
  });

  factory StompErrorInfo.fromJson(Map<String, dynamic> json) {
    return StompErrorInfo(
      title: json['title'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      detail: json['detail'] as String? ?? '',
      instance: json['instance'] as String? ?? '',
    );
  }

  bool get isAuthExpired => status == 401 && instance == 'STOMP';
}

/// 채팅 STOMP DataSource
///
/// STOMP 프로토콜을 통한 실시간 채팅 통신을 담당합니다.
/// - 연결/해제
/// - 전체 채팅 + 팀 채팅 구독
/// - 메시지 발행
/// - STOMP ERROR 처리 (401 인증 만료 등)
///
/// 재연결 정책은 포함하지 않으며, 상위(ChatNotifier)에서 관리합니다.
/// (B안: 자동 재연결 OFF, Notifier 단일 컨트롤)
class ChatStompDatasource {
  StompClient? _stompClient;

  /// 수신 메시지 스트림
  final _messageController = StreamController<ChatMessageDto>.broadcast();
  Stream<ChatMessageDto> get onMessage => _messageController.stream;

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

  /// STOMP 서버에 연결
  ///
  /// [wsUrl] WebSocket URL (예: ws://{domain}/game-connection)
  /// [accessToken] JWT Access Token (Bearer 인증)
  ///
  /// 현재는 Firebase ID Token을 사용하며,
  /// 서버 JWT 도입 후에는 서버 발급 accessToken을 사용합니다.
  void connect(String wsUrl, String accessToken) {
    debugPrint('[ChatStomp] 🔄 connect() 호출 → $wsUrl');
    // 기존 연결 정리
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
        // 자동 재연결 비활성화 - ChatNotifier가 재연결 정책을 관리
        reconnectDelay: Duration.zero,
      ),
    );

    _stompClient!.activate();
  }

  /// 전체 채팅 구독
  ///
  /// destination: /sub/game/{gameId}/chat/all
  void subscribeAll(int gameId) {
    if (_stompClient == null ||
        _currentState != StompConnectionState.connected) {
      debugPrint('[ChatStomp] ⚠️ subscribeAll 실패 - 연결되지 않음');
      return;
    }

    final sub = _stompClient!.subscribe(
      destination: '/sub/game/$gameId/chat/all',
      callback: _handleMessage,
    );
    _subscriptions.add(sub);
    debugPrint('[ChatStomp] ✅ 전체 채팅 구독 완료: /sub/game/$gameId/chat/all');
  }

  /// 팀 채팅 구독
  ///
  /// destination: /sub/game/{gameId}/chat/{team}
  /// [team] "police" 또는 "robber" (소문자)
  void subscribeTeam(int gameId, String team) {
    if (_stompClient == null ||
        _currentState != StompConnectionState.connected) {
      debugPrint('[ChatStomp] ⚠️ subscribeTeam 실패 - 연결되지 않음');
      return;
    }

    final sub = _stompClient!.subscribe(
      destination: '/sub/game/$gameId/chat/$team',
      callback: _handleMessage,
    );
    _subscriptions.add(sub);
    debugPrint('[ChatStomp] ✅ 팀 채팅 구독 완료: /sub/game/$gameId/chat/$team');
  }

  /// 채팅 메시지 발행
  ///
  /// destination: /pub/game/{gameId}/chat
  void publishChat(int gameId, String message, String scope) {
    if (_stompClient == null ||
        _currentState != StompConnectionState.connected) {
      debugPrint('[ChatStomp] ⚠️ publishChat 실패 - 연결되지 않음');
      return;
    }

    final request = ChatSendRequest(message: message, scope: scope);

    _stompClient!.send(
      destination: '/pub/game/$gameId/chat',
      body: jsonEncode(request.toJson()),
    );
    debugPrint('[ChatStomp] 메시지 전송: $message (scope: $scope)');
  }

  /// 연결 해제
  void disconnect() {
    _unsubscribeAll();
    _stompClient?.deactivate();
    _stompClient = null;
    _updateState(StompConnectionState.disconnected);
    debugPrint('[ChatStomp] 연결 해제');
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('[ChatStomp] ⚠️ dispose() 호출됨 - Provider가 해제되고 있음');
    disconnect();
    _messageController.close();
    _connectionStateController.close();
    _errorController.close();
  }

  // ============================================
  // STOMP 콜백
  // ============================================

  void _onConnect(StompFrame frame) {
    _updateState(StompConnectionState.connected);
    debugPrint('[ChatStomp] ✅ STOMP 연결 성공');
  }

  void _onStompError(StompFrame frame) {
    debugPrint('[ChatStomp] ❌ STOMP ERROR body: ${frame.body}');
    debugPrint('[ChatStomp] STOMP ERROR headers: ${frame.headers}');
    debugPrint('[ChatStomp] STOMP ERROR command: ${frame.command}');

    StompErrorInfo? errorInfo;
    if (frame.body != null && frame.body!.isNotEmpty) {
      try {
        final json = jsonDecode(frame.body!) as Map<String, dynamic>;
        errorInfo = StompErrorInfo.fromJson(json);
      } catch (e) {
        debugPrint('[ChatStomp] ⚠️ STOMP ERROR body 파싱 실패: $e');
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

    // 401 인증 만료 시 클라이언트 비활성화 (자동 재연결 방지)
    if (errorInfo.isAuthExpired) {
      debugPrint('[ChatStomp] 인증 만료 - 클라이언트 비활성화');
      _unsubscribeAll();
      _stompClient?.deactivate();
      _stompClient = null;
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint(
      '[ChatStomp] ❌ WebSocket Error: $error (type: ${error.runtimeType})',
    );
    _updateState(StompConnectionState.error);
  }

  void _onWebSocketDone() {
    debugPrint('[ChatStomp] WebSocket 연결 종료');
    _updateState(StompConnectionState.disconnected);
  }

  void _onDisconnect(StompFrame frame) {
    debugPrint('[ChatStomp] STOMP Disconnect');
    _updateState(StompConnectionState.disconnected);
  }

  // ============================================
  // 내부 메서드
  // ============================================

  void _handleMessage(StompFrame frame) {
    if (frame.body == null || frame.body!.isEmpty) return;

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final dto = ChatMessageDto.fromJson(json);
      _messageController.add(dto);
    } catch (e) {
      debugPrint('[ChatStomp] ❌ 메시지 파싱 실패: $e');
    }
  }

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
    _currentState = newState;
    _connectionStateController.add(newState);
  }
}
