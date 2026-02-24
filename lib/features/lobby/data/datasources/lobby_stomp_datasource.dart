import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/websocket/stomp_connection.dart';
import '../models/lobby_event_dto.dart';

export '../../../../core/network/websocket/stomp_connection.dart'
    show StompConnectionState, StompErrorInfo;

/// 로비 STOMP DataSource
///
/// STOMP 프로토콜을 통한 대기실 실시간 통신을 담당합니다.
/// - 연결/해제
/// - 로비 이벤트 구독 (`/subscribe/game/{gameId}/lobby`)
/// - STOMP ERROR 처리 (401 인증 만료 등)
class LobbyStompDatasource {
  StompClient? _stompClient;

  /// 수신 이벤트 스트림
  final _eventController = StreamController<LobbyEventDto>.broadcast();
  Stream<LobbyEventDto> get onEvent => _eventController.stream;

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
  void connect(String wsUrl, String accessToken) {
    debugPrint('[LobbyStomp] 🔄 connect() 호출 → $wsUrl');
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
        // 자동 재연결 비활성화 - LobbyNotifier가 재연결 정책을 관리
        reconnectDelay: Duration.zero,
      ),
    );

    _stompClient!.activate();
  }

  /// 로비 이벤트 구독
  ///
  /// destination: /subscribe/game/{gameId}/lobby
  void subscribeLobby(int gameId) {
    if (_stompClient == null ||
        _currentState != StompConnectionState.connected) {
      debugPrint('[LobbyStomp] ⚠️ subscribeLobby 실패 - 연결되지 않음');
      return;
    }

    final destination = '/subscribe/game/$gameId/lobby';
    final sub = _stompClient!.subscribe(
      destination: destination,
      callback: _handleEvent,
    );
    _subscriptions.add(sub);
    debugPrint('[LobbyStomp] ✅ 로비 이벤트 구독 완료: $destination');
  }

  /// 연결 해제
  void disconnect() {
    _unsubscribeAll();
    _stompClient?.deactivate();
    _stompClient = null;
    _updateState(StompConnectionState.disconnected);
    debugPrint('[LobbyStomp] 연결 해제');
  }

  /// 리소스 정리
  void dispose() {
    debugPrint('[LobbyStomp] ⚠️ dispose() 호출됨');
    disconnect();
    _eventController.close();
    _connectionStateController.close();
    _errorController.close();
  }

  // ============================================
  // STOMP 콜백
  // ============================================

  void _onConnect(StompFrame frame) {
    _updateState(StompConnectionState.connected);
    debugPrint('[LobbyStomp] ✅ STOMP 연결 성공');
  }

  void _onStompError(StompFrame frame) {
    debugPrint('[LobbyStomp] ❌ STOMP ERROR body: ${frame.body}');

    StompErrorInfo? errorInfo;
    if (frame.body != null && frame.body!.isNotEmpty) {
      try {
        final json = jsonDecode(frame.body!) as Map<String, dynamic>;
        errorInfo = StompErrorInfo.fromJson(json);
      } catch (e) {
        debugPrint('[LobbyStomp] ⚠️ STOMP ERROR body 파싱 실패: $e');
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

    // 401 인증 만료 시 클라이언트 비활성화
    if (errorInfo.isAuthExpired) {
      debugPrint('[LobbyStomp] 인증 만료 - 클라이언트 비활성화');
      _unsubscribeAll();
      _stompClient?.deactivate();
      _stompClient = null;
    }
  }

  void _onWebSocketError(dynamic error) {
    debugPrint('[LobbyStomp] ❌ WebSocket Error: $error');
    _updateState(StompConnectionState.error);
  }

  void _onWebSocketDone() {
    debugPrint('[LobbyStomp] WebSocket 연결 종료');
    _updateState(StompConnectionState.disconnected);
  }

  void _onDisconnect(StompFrame frame) {
    debugPrint('[LobbyStomp] STOMP Disconnect');
    _updateState(StompConnectionState.disconnected);
  }

  // ============================================
  // 내부 메서드
  // ============================================

  void _handleEvent(StompFrame frame) {
    if (frame.body == null || frame.body!.isEmpty) return;

    debugPrint('[LobbyStomp] 📩 이벤트 수신 raw: ${frame.body}');

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final dto = LobbyEventDto.fromJson(json);
      debugPrint(
        '[LobbyStomp] 📩 이벤트 파싱 완료: type=${dto.type}, gameId=${dto.gameId}',
      );
      _eventController.add(dto);
    } catch (e) {
      debugPrint('[LobbyStomp] ❌ 이벤트 파싱 실패: $e');
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
