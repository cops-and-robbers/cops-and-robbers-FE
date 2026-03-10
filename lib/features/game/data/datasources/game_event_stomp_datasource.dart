import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/websocket/base_stomp_datasource.dart';
import '../models/game_event_model.dart';

export '../../../../core/network/websocket/base_stomp_datasource.dart'
    show StompConnectionState, StompErrorInfo;

/// 게임 시스템 이벤트 STOMP DataSource
///
/// `/subscribe/game/{gameId}/system` 채널을 구독하여
/// 체포·탈옥·게임종료 등의 이벤트를 수신합니다.
///
/// 재연결 정책은 [GameEventNotifier]에서 관리합니다.
class GameEventStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'GameEventStomp';

  final _eventController = StreamController<GameEventModel>.broadcast();

  /// 게임 이벤트 스트림
  Stream<GameEventModel> get onEvent => _eventController.stream;

  int? _pendingGameId;

  /// 게임 이벤트 구독 예약
  ///
  /// connected 상태면 즉시, 아니면 연결 성공 시 자동 구독.
  void subscribeEvents(int gameId) {
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
    final gameId = _pendingGameId!;

    final dest = '/subscribe/game/$gameId/system';
    addSubscription(
      stompClient!.subscribe(destination: dest, callback: _handleFrame),
    );
    debugPrint('[$logTag] ✅ 게임 이벤트 구독: $dest');
  }

  /// 도둑 위치 서버 전송 (도둑 팀만 호출)
  void publishLocation(int gameId, double lat, double lng) {
    if (stompClient == null || currentState != StompConnectionState.connected) {
      if (kDebugMode) {
        debugPrint('[$logTag] ⚠️ publishLocation 실패 - 연결되지 않음');
      }
      return;
    }
    stompClient!.send(
      destination: '/publish/game/$gameId/location',
      body: jsonEncode({'latitude': lat, 'longitude': lng}),
    );
    if (kDebugMode) {
      debugPrint('[$logTag] 📤 위치 전송: ($lat, $lng)');
    }
  }

  void _handleFrame(StompFrame frame) {
    if (isDisposed) return;
    if (frame.body == null || frame.body!.isEmpty) return;

    if (kDebugMode) {
      debugPrint('[$logTag] 📩 이벤트 수신 raw: ${frame.body}');
    }

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final event = GameEventModel.fromJson(json);
      if (kDebugMode) {
        debugPrint('[$logTag] 📩 이벤트 파싱 완료: type=${event.type}');
      }
      _eventController.add(event);
    } catch (e) {
      debugPrint('[$logTag] ❌ 이벤트 파싱 실패: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _eventController.close();
  }
}
