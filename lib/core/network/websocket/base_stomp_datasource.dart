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

  /// dispose 여부 (서브클래스에서 가드로 사용)
  @protected
  bool get isDisposed => _disposed;

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
        // 자동 재연결 비활성화 - Notifier가 재연결 정책을 관리
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
    if (_disposed) return;
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
