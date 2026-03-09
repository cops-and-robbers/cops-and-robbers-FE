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
///
/// 재연결 정책은 포함하지 않으며, 상위(ChatNotifier)에서 관리합니다.
class ChatStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'ChatStomp';

  final _messageController = StreamController<ChatMessageDto>.broadcast();
  Stream<ChatMessageDto> get onMessage => _messageController.stream;

  int? _pendingGameId;
  String? _pendingTeam;

  StompUnsubscribe? _allSub;
  StompUnsubscribe? _teamSub;

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

    _allSub?.call(unsubscribeHeaders: {});
    _teamSub?.call(unsubscribeHeaders: {});

    final allDest = '/subscribe/game/$gameId/chat/all';
    _allSub = stompClient!.subscribe(
      destination: allDest,
      callback: _handleMessage,
    );
    addSubscription(_allSub);
    debugPrint('[$logTag] ✅ 전체 채팅 구독: $allDest');

    final teamDest = '/subscribe/game/$gameId/chat/$team';
    _teamSub = stompClient!.subscribe(
      destination: teamDest,
      callback: _handleMessage,
    );
    addSubscription(_teamSub);
    debugPrint('[$logTag] ✅ 팀 채팅 구독: $teamDest');
  }

  /// 채팅 메시지 발행
  ///
  /// destination: /publish/game/{gameId}/chat
  void publishChat(int gameId, String message, String scope) {
    if (stompClient == null || currentState != StompConnectionState.connected) {
      debugPrint('[$logTag] ⚠️ publishChat 실패 - 연결되지 않음');
      return;
    }

    final request = ChatSendRequest(message: message, scope: scope);
    final destination = '/publish/game/$gameId/chat';
    stompClient!.send(
      destination: destination,
      body: jsonEncode(request.toJson()),
    );
    debugPrint('[$logTag] 메시지 전송: $message (scope: $scope) → $destination');
  }

  @override
  void dispose() {
    // _disposed = true 및 disconnect()는 super.dispose()에서 먼저 처리
    super.dispose();
    _messageController.close();
  }

  void _handleMessage(StompFrame frame) {
    if (isDisposed) return;
    if (frame.body == null || frame.body!.isEmpty) return;

    debugPrint('[$logTag] 📩 메시지 수신 raw: ${frame.body}');

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final dto = ChatMessageDto.fromJson(json);
      debugPrint(
        '[$logTag] 📩 메시지 파싱 완료: sender=${dto.sender.nickname}, '
        'message=${dto.message}, scope=${dto.scope}',
      );
      _messageController.add(dto);
    } catch (e) {
      debugPrint('[$logTag] ❌ 메시지 파싱 실패: $e');
    }
  }
}
