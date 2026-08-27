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

/// `CommunityChatRepository` 구현체 — REST 5종 + 소켓 하나를 인터페이스 뒤로 묶는다
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

  /// 지금 소켓이 붙어 있는 방. [disconnect]가 남의 연결을 끊지 않게 하는 열쇠다.
  int? _connectedPostId;

  // ── REST ──────────────────────────────────────────────────────

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() => _guard(
    () async => (await _api.getChatRooms()).chatRooms.map(_toRoom).toList(),
    messageKey: 'errorCommunityChatRoomsLoadGeneric',
  );

  @override
  Future<List<CommunityChatMemberEntity>> getMembers(int postId) => _guard(
    () async => (await _api.getChatMembers(postId)).members
        .map(
          (m) => CommunityChatMemberEntity(
            userId: m.userId,
            nickname: m.nickname ?? '',
            profileIcon: m.profileIcon,
            isAuthor: m.isAuthor,
          ),
        )
        .toList(),
    messageKey: 'errorCommunityChatMembersLoadGeneric',
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

  // ── 소켓 ──────────────────────────────────────────────────────

  @override
  Stream<CommunityChatEvent> connect(int postId) {
    _teardown();
    _connectedPostId = postId;

    final events = StreamController<CommunityChatEvent>.broadcast();
    _events = events;

    // 셋을 한 스트림에 실어 보낸다 — Notifier가 구독 하나만 들고 있으면 된다.
    _subs
      ..add(
        _stomp.onChatMessage.listen(
          (m) => events.add(CommunityChatEvent.message(_toMessage(m))),
        ),
      )
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

    // 구독을 먼저 예약해 둔다 — 연결 성공 콜백에서 자동으로 걸린다.
    _stomp.subscribeRoom(postId);
    unawaited(_openSocket(postId, events));
    return events.stream;
  }

  Future<void> _openSocket(
    int postId,
    StreamController<CommunityChatEvent> events,
  ) async {
    final token = await _readAccessToken();
    // 토큰을 얻는 사이에 다른 방으로 옮겼으면 이 연결은 버린다.
    if (_connectedPostId != postId || events.isClosed) return;
    if (token == null) {
      events.add(const CommunityChatEvent.error('ACCESS_TOKEN_EXPIRED'));
      return;
    }
    _stomp.connect(ApiEndpoints.gameConnectionUrl, token);
  }

  @override
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  }) async => _stomp.publishMessage(postId, messageKey: messageKey, text: text);

  @override
  Future<void> disconnect(int postId) async {
    // 방 A가 B보다 늦게 정리되는 경우 — 지금 붙어 있는 방이 아니면 손대지 않는다.
    if (_connectedPostId != postId) return;
    _teardown();
    _connectedPostId = null;
    _stomp.disconnect();
  }

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
