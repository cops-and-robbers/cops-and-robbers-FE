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
/// 가른다(DEC-0026). 구독은 둘이다: 로그인한 유저의 **알림 채널** 하나(모든 방의
/// 메시지가 이리로 온다 — DEC-0045)와, 지금 보고 있는 **방** 하나. 목록 화면에서
/// 방마다 구독하면 방 100개에 구독 100개가 되므로 그러지 않는다.
///
/// 재연결 정책은 여기 없다 — 상위 Notifier(`CommunityChatSocketNotifier`)가 관리한다.
class CommunityChatStompDatasource extends BaseStompDatasource {
  @override
  String get logTag => 'CommunityChatStomp';

  static String userChannel(int userId) =>
      '/subscribe/user/$userId/community/chat';
  static String roomChannel(int postId) => '/subscribe/community/$postId/chat';

  final _messageController =
      StreamController<CommunityChatMessageResponseModel>.broadcast();

  /// 브로드캐스트로 도착한 메시지. 방 채널·개인 채널 어느 쪽에서 왔든 같은
  /// 스트림이다 — 방 화면에 있는 동안 같은 메시지가 두 번 온다. 중복 제거는
  /// 소비자가 `id`로 한다(DEC-0045). 내가 보낸 것도 에코로 여기 돌아온다.
  Stream<CommunityChatMessageResponseModel> get onChatMessage =>
      _messageController.stream;

  int? _userId;
  int? _pendingPostId;
  StompUnsubscribe? _roomSub;

  /// [userId]의 알림 채널을 연결될 때마다 다시 구독하도록 기억하고 연결한다.
  void connectAs(String wsUrl, String accessToken, {required int userId}) {
    _userId = userId;
    connect(wsUrl, accessToken);
  }

  /// 방 구독 예약. 연결돼 있으면 즉시, 아니면 연결 성공 시 자동 구독한다.
  /// 재연결에도 살아남는다 — `onConnected`가 다시 건다.
  void subscribeRoom(int postId) {
    _pendingPostId = postId;
    if (currentState == StompConnectionState.connected) _subscribeRoom();
  }

  /// 방 구독만 해제. 소켓·개인 채널은 그대로다.
  ///
  /// 다른 방 번호면 아무것도 안 한다 — 방 A→B로 옮길 때 A의 정리가 B보다 늦게
  /// 와서 B의 구독을 풀어 버리는 것을 막는다.
  void unsubscribeRoom(int postId) {
    if (_pendingPostId != postId) return;
    _pendingPostId = null;
    _roomSub?.call(unsubscribeHeaders: {});
    _roomSub = null;
    debugPrint('[$logTag] 채팅방 구독 해제: ${roomChannel(postId)}');
  }

  @override
  void onConnected() {
    _subscribeUser();
    _subscribeRoom();
  }

  void _subscribeUser() {
    final userId = _userId;
    if (userId == null) return;
    // UNSUBSCRIBE는 보내지 않는다 — 소켓이 닫히면 서버가 세션과 함께 정리한다.
    // 구독 거부는 무음이다(DEC-0046): 실패해도 ERROR 프레임이 오지 않는다.
    addSubscription(
      stompClient!.subscribe(
        destination: userChannel(userId),
        callback: _handleMessage,
      ),
    );
    debugPrint('[$logTag] ✅ 알림 채널 구독: ${userChannel(userId)}');
  }

  void _subscribeRoom() {
    final postId = _pendingPostId;
    if (postId == null) return;

    _roomSub?.call(unsubscribeHeaders: {});
    _roomSub = stompClient!.subscribe(
      destination: roomChannel(postId),
      callback: _handleMessage,
    );
    debugPrint('[$logTag] ✅ 채팅방 구독: ${roomChannel(postId)}');
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

  /// 게임 초대 전송(#516). TEXT와 달리 낙관적 말풍선이 없어 호출부가 실패를
  /// 알 길이 반환값뿐이다 — 연결이 없으면 보내지 않고 false.
  bool publishGameInvite(
    int postId, {
    required String messageKey,
    required String inviteCode,
  }) {
    if (stompClient == null || currentState != StompConnectionState.connected) {
      debugPrint('[$logTag] ⚠️ 초대 전송 실패 — 연결되지 않음');
      return false;
    }
    stompClient!.send(
      destination: '/publish/community/$postId/chat',
      body: jsonEncode({
        'messageKey': messageKey,
        'gameInvite': {'inviteCode': inviteCode},
        'messageType': 'GAME_INVITE',
      }),
    );
    return true;
  }

  @override
  void disconnect() {
    // 클라이언트가 내려가면 구독 핸들도 같이 죽는다 — 다음 연결에서 다시 건다.
    _roomSub = null;
    super.disconnect();
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
      _messageController.add(
        CommunityChatMessageResponseModel.fromJson(
          jsonDecode(body) as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      // 한 건이 깨졌다고 스트림을 닫으면 실시간이 통째로 멈춘다.
      debugPrint('[$logTag] ❌ 메시지 파싱 실패: $e');
    }
  }
}
