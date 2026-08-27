import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/websocket/base_stomp_datasource.dart';
import '../models/community_chat_model.dart';

export '../../../../core/network/websocket/base_stomp_datasource.dart'
    show StompConnectionState, StompErrorInfo;

/// 커뮤니티 채팅 STOMP DataSource
///
/// 게임과 **같은 소켓 주소**를 쓴다 — 어느 채팅인지는 주소가 아니라 구독 경로로
/// 가른다(DEC-0026). 구독은 지금 보고 있는 방 하나뿐이다: 목록 화면에서 방마다
/// 구독하면 방 100개에 구독 100개가 된다.
///
/// 재연결 정책은 여기 없다 — 게임 채팅과 같이 상위 Notifier가 관리한다.
class CommunityChatStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'CommunityChatStomp';

  final _messageController =
      StreamController<CommunityChatMessageResponseModel>.broadcast();

  /// 브로드캐스트로 도착한 메시지. 내가 보낸 것도 에코로 여기 돌아온다.
  Stream<CommunityChatMessageResponseModel> get onChatMessage =>
      _messageController.stream;

  int? _pendingPostId;
  StompUnsubscribe? _roomSub;

  /// 구독 예약. 연결돼 있으면 즉시, 아니면 연결 성공 시 자동 구독한다.
  void subscribeRoom(int postId) {
    _pendingPostId = postId;
    if (currentState == StompConnectionState.connected) _doSubscribe();
  }

  @override
  void onConnected() => _doSubscribe();

  void _doSubscribe() {
    final postId = _pendingPostId;
    if (postId == null) return;

    _roomSub?.call(unsubscribeHeaders: {});
    final destination = '/subscribe/community/$postId/chat';
    _roomSub = stompClient!.subscribe(
      destination: destination,
      callback: _handleMessage,
    );
    addSubscription(_roomSub);
    debugPrint('[$logTag] ✅ 채팅방 구독: $destination');
  }

  /// 메시지 전송.
  ///
  /// [messageKey]는 앱이 만든 UUID다 — 에코가 같은 키로 돌아와야 낙관적 말풍선이
  /// 확정된다. `messageType`을 빼면 서버가 400(`INVALID_MESSAGE_TYPE`)을 준다.
  void publishMessage(
    int postId, {
    required String messageKey,
    required String text,
  }) {
    if (stompClient == null || currentState != StompConnectionState.connected) {
      debugPrint('[$logTag] ⚠️ 전송 실패 — 연결되지 않음');
      return;
    }
    stompClient!.send(
      destination: '/publish/community/$postId/chat',
      body: jsonEncode({
        'messageKey': messageKey,
        'message': text,
        'messageType': 'TEXT',
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.close();
  }

  void _handleMessage(StompFrame frame) {
    if (isDisposed) return;
    final body = frame.body;
    if (body == null || body.isEmpty) return;

    try {
      // 소켓 payload는 REST 내역과 필드 이름이 같다 — DTO 하나로 둘 다 읽는다.
      // payload에만 있는 `communityPostId`는 모르는 키라 그냥 무시된다.
      _messageController.add(
        CommunityChatMessageResponseModel.fromJson(
          jsonDecode(body) as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      // 한 건이 깨졌다고 스트림을 닫으면 그 방의 실시간이 통째로 멈춘다.
      debugPrint('[$logTag] ❌ 메시지 파싱 실패: $e');
    }
  }
}
