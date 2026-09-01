import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/community_chat_event.dart';
import '../../domain/entities/community_chat_member_entity.dart';
import '../../domain/entities/community_chat_message_entity.dart';
import '../../domain/entities/community_chat_page_entity.dart';
import '../../domain/entities/community_chat_room_entity.dart';
import '../../domain/repositories/community_chat_repository.dart';
import '../datasources/community_chat_stomp_datasource.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/community_chat_model.dart';
import '../models/community_wire.dart';

/// 토큰을 얻는 함수. 소켓은 연결할 때마다 최신 토큰이 필요하다.
typedef AccessTokenReader = Future<String?> Function();

/// `CommunityChatRepository` 구현체 — REST 7종 + 소켓 하나를 인터페이스 뒤로 묶는다
///
/// 화면과 Notifier는 이 인터페이스만 알기 때문에, 서버가 REST로 주는지 소켓으로
/// 주는지가 위로 새지 않는다.
class CommunityChatRepositoryImpl implements CommunityChatRepository {
  CommunityChatRepositoryImpl(this._api, this._stomp, this._readAccessToken);

  final CommunityRemoteDataSource _api;
  final CommunityChatStompDatasource _stomp;
  final AccessTokenReader _readAccessToken;

  StreamController<CommunityChatEvent>? _events;
  final _subs = <StreamSubscription<Object?>>[];

  // ── REST ──────────────────────────────────────────────────────

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() => _guard(
    () async => (await _api.getChatRooms()).chatRooms.map(_toRoom).toList(),
    messageKey: 'errorCommunityChatRoomsLoadGeneric',
  );

  @override
  Future<CommunityChatMembersEntity> getMembers(int postId) => _guard(() async {
    final res = await _api.getChatMembers(postId);
    return CommunityChatMembersEntity(
      notificationEnabled: res.notificationEnabled,
      members: res.members
          .map(
            (m) => CommunityChatMemberEntity(
              userId: m.userId,
              nickname: m.nickname ?? '',
              profileIcon: m.profileIcon,
              isAuthor: m.isAuthor,
            ),
          )
          .toList(),
    );
  }, messageKey: 'errorCommunityChatMembersLoadGeneric');

  @override
  Future<void> kickMember(int postId, int userId) => _guard(
    () => _api.kickChatMember(postId, userId),
    messageKey: 'errorCommunityChatKickGeneric',
  );

  /// 이미 멤버(409)면 성공으로 삼킨다 — 서버가 `chatJoined`를 주지 않아 앱은
  /// 참여 여부를 미리 알 수 없다. 무조건 보내고 409면 이미 들어가 있다는 뜻이다.
  @override
  Future<void> join(int postId) => _guard(() async {
    try {
      await _api.joinChat(postId);
    } on DioException catch (e) {
      if (_errorCodeOf(e) != 'ALREADY_JOINED') rethrow;
      debugPrint('[CommunityChat] 이미 참여한 방 — 입장으로 이어간다');
    }
  }, messageKey: 'errorCommunityChatJoinGeneric');

  @override
  Future<void> leave(int postId) => _guard(
    () => _api.leaveChat(postId),
    messageKey: 'errorCommunityChatLeaveGeneric',
  );

  @override
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  }) => _guard(() async {
    final page = await _api.getChatMessages(postId, cursor: cursor, size: size);
    return CommunityChatPageEntity(
      messages: page.messages.map(_toMessage).toList(),
      nextCursor: page.nextCursor,
      hasNext: page.hasNext,
    );
  }, messageKey: 'errorCommunityChatMessagesLoadGeneric');

  @override
  Future<void> markRead(int postId, int lastReadMessageId) => _guard(
    () => _api.readChat(
      postId,
      CommunityChatReadRequestModel(lastReadMessageId: lastReadMessageId),
    ),
    messageKey: 'errorCommunityChatReadGeneric',
  );

  @override
  Future<void> setNotification(int postId, {required bool enabled}) => _guard(
    () => _api.updateChatNotification(
      postId,
      CommunityChatNotificationRequestModel(allowNotification: enabled),
    ),
    messageKey: 'errorCommunityChatNotificationGeneric',
  );

  // ── 소켓 ──────────────────────────────────────────────────────

  @override
  Stream<CommunityChatEvent> connect(int userId) {
    _teardown();

    final events = StreamController<CommunityChatEvent>.broadcast();
    _events = events;

    // 셋을 한 스트림에 실어 보낸다 — Notifier가 구독 하나만 들고 있으면 된다.
    _subs
      ..add(_stomp.onChatMessage.listen((m) => _forwardMessage(m, events)))
      ..add(
        _stomp.onConnectionState.listen(
          (s) => events.add(CommunityChatEvent.connection(_toConnection(s))),
        ),
      )
      ..add(
        _stomp.onError.listen(
          (e) => events.add(
            CommunityChatEvent.error(e.errorCode ?? 'INTERNAL_SERVER_ERROR'),
          ),
        ),
      );

    unawaited(_openSocket(userId, events));
    return events.stream;
  }

  void _forwardMessage(
    CommunityChatMessageResponseModel m,
    StreamController<CommunityChatEvent> events,
  ) {
    final postId = m.communityPostId;
    if (postId == null) {
      // 개인 채널 메시지는 방 번호가 payload에만 있다 — 없으면 어느 방인지 몰라
      // 목록도 방도 반영할 수 없다. 버리고 로그만 남긴다.
      debugPrint('[CommunityChat] ⚠️ communityPostId 없는 메시지 무시: id=${m.id}');
      return;
    }
    events.add(CommunityChatEvent.message(postId, _toMessage(m)));
  }

  Future<void> _openSocket(
    int userId,
    StreamController<CommunityChatEvent> events,
  ) async {
    final token = await _readAccessToken();
    // 토큰을 얻는 사이에 로그아웃했으면 이 연결은 버린다.
    if (events.isClosed) return;
    if (token == null) {
      events.add(const CommunityChatEvent.error('ACCESS_TOKEN_EXPIRED'));
      // connect()의 모든 종료 경로는 연결 이벤트를 낸다 — 안 내면 소켓 Notifier가
      // connecting에 갇혀 재연결 가드가 영원히 막는다(최종 리뷰 I-1).
      events.add(
        const CommunityChatEvent.connection(
          CommunityChatConnectionState.disconnected,
        ),
      );
      return;
    }
    _stomp.connectAs(ApiEndpoints.gameConnectionUrl, token, userId: userId);
  }

  @override
  Future<void> disconnect() async {
    _teardown();
    _stomp.disconnect();
  }

  @override
  void subscribeRoom(int postId) => _stomp.subscribeRoom(postId);

  @override
  void unsubscribeRoom(int postId) => _stomp.unsubscribeRoom(postId);

  @override
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  }) async => _stomp.publishMessage(postId, messageKey: messageKey, text: text);

  @override
  bool sendGameInvite(
    int postId, {
    required String messageKey,
    required String inviteCode,
  }) => _stomp.publishGameInvite(
    postId,
    messageKey: messageKey,
    inviteCode: inviteCode,
  );

  void _teardown() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
    unawaited(_events?.close());
    _events = null;
  }

  // ── 매핑 ──────────────────────────────────────────────────────

  CommunityChatRoomEntity _toRoom(CommunityChatRoomResponseModel m) =>
      CommunityChatRoomEntity(
        postId: m.postId,
        title: m.title ?? '',
        status: communityPostStatusFromWire(m.status ?? ''),
        meetingAt: (m.meetingAt ?? DateTime.now()).toLocal(),
        memberCount: m.memberCount ?? 0,
        lastMessage: _toLastMessage(m.lastMessage),
        unreadCount: m.unreadCount,
      );

  CommunityChatLastMessageEntity? _toLastMessage(
    CommunityChatLastMessageResponseModel? m,
  ) {
    if (m == null) return null;
    return CommunityChatLastMessageEntity(
      id: m.id,
      body: communityChatMessageBodyFromWire(
        m.messageType ?? '',
        m.message ?? '',
      ),
      // 서버가 UTC로 주므로 기기 시간대로 맞춘다 — 안 하면 9시간 이르게 보인다.
      createdAt: (m.createdAt ?? DateTime.now()).toLocal(),
      senderNickname: m.senderNickname,
      senderProfileIcon: m.senderProfileIcon,
    );
  }

  CommunityChatMessageEntity _toMessage(CommunityChatMessageResponseModel m) =>
      CommunityChatMessageEntity(
        id: m.id,
        // 서버가 채워 보내는 경우가 있어(앱이 안 보내면 UUID 생성) 비어 있지 않다.
        messageKey: m.messageKey ?? '',
        senderId: m.senderId ?? 0,
        senderNickname: m.senderNickname ?? '',
        senderProfileIcon: m.senderProfileIcon,
        body: communityChatMessageBodyFromWire(
          m.messageType ?? '',
          m.message ?? '',
        ),
        createdAt: (m.createdAt ?? DateTime.now()).toLocal(),
        // 안 읽은 개수 규칙은 와이어 타입 기준이다 — 본문이 unknown으로 접혀도 센다/안 센다가 서버와 같아야 한다.
        isSystem: m.messageType == 'SYSTEM',
      );

  CommunityChatConnectionState _toConnection(
    StompConnectionState s,
  ) => switch (s) {
    StompConnectionState.connected => CommunityChatConnectionState.connected,
    StompConnectionState.connecting => CommunityChatConnectionState.connecting,
    // error도 끊김으로 본다 — Notifier의 재연결 정책이 하나로 받는다.
    StompConnectionState.disconnected ||
    StompConnectionState.error => CommunityChatConnectionState.disconnected,
  };

  String? _errorCodeOf(DioException e) {
    final data = e.response?.data;
    return data is Map ? data['errorCode'] as String? : null;
  }

  Future<T> _guard<T>(
    Future<T> Function() run, {
    required String messageKey,
  }) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: '채팅 처리 중 오류가 발생했습니다',
        messageKey: messageKey,
        originalException: e,
      );
    }
  }
}
