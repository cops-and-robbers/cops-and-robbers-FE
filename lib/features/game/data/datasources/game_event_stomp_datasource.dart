import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/websocket/base_stomp_datasource.dart';
import '../../domain/entities/ping.dart';
import '../models/game_event_model.dart';
import '../models/ping_message_dto.dart';

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
  String? _pendingTeam;

  /// 핑 수신 스트림
  final _pingController = StreamController<PingMessageDto>.broadcast();
  Stream<PingMessageDto> get onPing => _pingController.stream;

  // 중복 구독 방어용 구독 핸들 (ChatStompDatasource 패턴)
  StompUnsubscribe? _systemSub;
  StompUnsubscribe? _pingSub;

  /// 게임 이벤트 구독 예약
  ///
  /// connected 상태면 즉시, 아니면 연결 성공 시 자동 구독.
  void subscribeEvents(int gameId, {required String team}) {
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

    // 중복 구독 방어 — 기존 핸들 해제 후 재구독
    _systemSub?.call(unsubscribeHeaders: {});
    _pingSub?.call(unsubscribeHeaders: {});

    final sysDest = '/subscribe/game/$gameId/system';
    _systemSub = stompClient!.subscribe(
      destination: sysDest,
      callback: _handleFrame,
    );
    addSubscription(_systemSub);
    debugPrint('[$logTag] ✅ 게임 이벤트 구독: $sysDest');

    final pingDest = '/subscribe/game/$gameId/ping/$team';
    _pingSub = stompClient!.subscribe(
      destination: pingDest,
      callback: _handlePing,
    );
    addSubscription(_pingSub);
    debugPrint('[$logTag] ✅ 핑 구독: $pingDest');
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

  /// 핑 전송 — 연결돼 있으면 send 후 true, 끊겨 있으면 false.
  ///
  /// 호출자(PingNotifier)가 false면 rate-limit 카운트를 소모하지 않는다.
  bool publishPing(int gameId, PingType type, double lat, double lng) {
    if (stompClient == null || currentState != StompConnectionState.connected) {
      if (kDebugMode) debugPrint('[$logTag] ⚠️ publishPing 실패 - 연결되지 않음');
      return false;
    }
    stompClient!.send(
      destination: '/publish/game/$gameId/ping',
      body: jsonEncode({
        'pingType': type == PingType.found ? 'FOUND' : 'SUSPECT',
        'location': {'latitude': lat, 'longitude': lng},
      }),
    );
    if (kDebugMode) debugPrint('[$logTag] 📤 핑 전송: $type ($lat, $lng)');
    return true;
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

  void _handlePing(StompFrame frame) {
    if (isDisposed) return;
    if (frame.body == null || frame.body!.isEmpty) return;

    if (kDebugMode) {
      debugPrint('[$logTag] 📩 핑 수신 raw: ${frame.body}');
    }

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final dto = PingMessageDto.fromJson(json);
      if (kDebugMode) {
        debugPrint(
          '[$logTag] 📩 핑 파싱 완료: ${dto.pingType} '
          'from ${dto.pingSender.nickname}',
        );
      }
      _pingController.add(dto);
    } catch (e) {
      debugPrint('[$logTag] ❌ 핑 파싱 실패: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _eventController.close();
    _pingController.close();
  }
}
