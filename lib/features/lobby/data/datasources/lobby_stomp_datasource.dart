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
///
/// 재연결 정책은 포함하지 않으며, 상위(LobbyNotifier)에서 관리합니다.
class LobbyStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'LobbyStomp';

  final _eventController = StreamController<LobbyEventDto>.broadcast();
  Stream<LobbyEventDto> get onEvent => _eventController.stream;

  int? _pendingGameId;

  /// 로비 이벤트 구독 예약
  ///
  /// connected 상태면 즉시, 아니면 연결 성공 시 자동 구독.
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
    addSubscription(
      stompClient!.subscribe(destination: destination, callback: _handleEvent),
    );
    debugPrint('[$logTag] ✅ 로비 이벤트 구독: $destination');
  }

  @override
  void dispose() {
    // _disposed = true 및 disconnect()는 super.dispose()에서 먼저 처리
    super.dispose();
    _eventController.close();
  }

  void _handleEvent(StompFrame frame) {
    if (isDisposed) return;
    if (frame.body == null || frame.body!.isEmpty) return;

    debugPrint('[$logTag] 📩 이벤트 수신 raw: ${frame.body}');

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final dto = LobbyEventDto.fromJson(json);
      debugPrint(
        '[$logTag] 📩 이벤트 파싱 완료: type=${dto.type}, gameId=${dto.gameId}',
      );
      _eventController.add(dto);
    } catch (e) {
      debugPrint('[$logTag] ❌ 이벤트 파싱 실패: $e');
    }
  }
}
