import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/token_provider.dart';
import '../../data/datasources/community_chat_stomp_datasource.dart';
import '../../data/repositories/community_chat_repository_impl.dart';
import '../../domain/entities/community_chat_event.dart';
import '../../domain/entities/community_chat_member_entity.dart';
import '../../domain/entities/community_chat_message_entity.dart';
import '../../domain/entities/community_chat_room_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/repositories/community_chat_repository.dart';
import 'community_chat_socket_provider.dart';
import 'community_provider.dart';

part 'community_chat_rooms_provider.g.dart';

/// 채팅 저장소 Provider — REST(Retrofit) + STOMP를 합친 실서버 구현
///
/// 소켓은 이 provider의 수명을 따른다. 방을 오갈 때마다 새로 만들지 않는 이유는
/// 계약 01 — 소켓은 앱당 하나다(DEC-0026).
@Riverpod(keepAlive: true)
CommunityChatRepository communityChatRepository(Ref ref) {
  final stomp = CommunityChatStompDatasource();
  ref.onDispose(stomp.dispose);
  return CommunityChatRepositoryImpl(
    ref.watch(communityRemoteDataSourceProvider),
    stomp,
    () => ref.read(tokenProviderProvider).getAccessToken(),
  );
}

/// 내가 참여 중인 채팅방 목록 (`GET /chat/rooms`)
///
/// `keepAlive`: 내 모임 탭을 오갈 때마다 다시 받지 않는다. 갱신은 소켓이 한다 —
/// 유저당 알림 채널(DEC-0045)로 모든 방의 새 메시지가 이리로 오고, 연결이 (다시)
/// 성립될 때마다 서버 기준선(`unreadCount`)을 한 번 다시 받는다. 사용자 동작은
/// 당겨서 새로고침과 에러 재시도뿐이다.
@Riverpod(keepAlive: true)
class CommunityChatRooms extends _$CommunityChatRooms {
  /// 다음 `connected`가 오면 서버 기준선을 다시 받아야 하는가.
  ///
  /// 초기값을 `state.hasValue`가 아니라 **소켓의 현재 연결 상태**에서 정한다 —
  /// 이 provider의 재빌드(에러 재시도 `ref.invalidate`, 방을 나간 뒤 무효화)는
  /// 재연결이 아니다. 소켓은 keepAlive라 재빌드돼도 그대로 살아 있으므로, 이미
  /// 붙어 있으면(흔한 경로: 로그인 후 탭 진입, invalidate 재빌드) 그 연결이
  /// 계속 유효하다 — false로 시작해 이중 조회를 막는다. 아직 안 붙었거나 끊긴
  /// 채로 빌드되면, 지금 받아 오는 기준선이 구독이 확립되기 전 스냅샷일 수 있어
  /// true로 시작해 다음 connected에서 한 번 맞춘다.
  bool _needResync = false;

  @override
  Future<List<CommunityChatRoomEntity>> build() {
    // 계정이 바뀌면 이전 유저의 방·배지가 남는다 — 소켓 Notifier가 유저 전환 시
    // 이전 구독을 먼저 끊어 disconnected 이벤트가 이 목록에 도달하지 않으므로,
    // 목록 자신이 유저를 watch해 다시 판다(최종 리뷰 C-1).
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return Future.value(const <CommunityChatRoomEntity>[]);

    final socket = ref.read(communityChatSocketProvider.notifier);
    _needResync =
        ref.read(communityChatSocketProvider).connection !=
        CommunityChatConnectionState.connected;
    final sub = socket.events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    return ref.watch(communityChatRepositoryProvider).getRooms();
  }

  /// 실패하면 예외가 그대로 올라간다 — 보던 목록은 남고 화면이 스낵바로 알린다.
  Future<void> refresh() async {
    final rooms = await ref.read(communityChatRepositoryProvider).getRooms();
    state = AsyncData(rooms);
  }

  /// 방을 열어 읽었다 — 서버 커서가 옮겨졌으니 로컬 배지도 내린다.
  void clearUnread(int postId) {
    final rooms = state.valueOrNull;
    if (rooms == null) return;
    state = AsyncData([
      for (final r in rooms)
        if (r.postId == postId) r.copyWith(unreadCount: 0) else r,
    ]);
  }

  /// 소켓으로 온 메시지를 목록에 반영한다 — 미리보기 교체, 맨 앞으로, 그리고 +1.
  ///
  /// +1 규칙은 서버 집계(DEC-0044)와 같아야 숫자가 튀지 않는다: 내가 보낸 것과
  /// SYSTEM은 세지 않는다. 개인 채널은 발신자 본인에게도 오므로 `senderId` 판정은
  /// 필수다. `id > lastMessage.id` 조건 하나가 두 가지를 같이 막는다 — 방 화면에
  /// 있는 동안 두 채널이 같은 메시지를 두 번 보내는 것, 그리고 기준선을 막 받았는데
  /// 거기 이미 반영된 메시지가 소켓으로 뒤늦게 오는 것.
  ///
  /// 아직 목록에 없는 방(방금 참여)은 건드리지 않는다 — 없는 칸을 만들어 내면
  /// 제목·정원 같은 나머지 값을 지어내야 한다. 그건 다음 조회가 채운다.
  void applyIncoming(int postId, CommunityChatMessageEntity message) {
    final rooms = state.valueOrNull;
    if (rooms == null) return;
    final index = rooms.indexWhere((r) => r.postId == postId);
    if (index == -1) return;

    final room = rooms[index];
    final id = message.id;
    final lastId = room.lastMessage?.id;
    if (id == null || (lastId != null && id <= lastId)) return;

    final counts =
        message.senderId != ref.read(currentUserIdProvider) &&
        message.countsAsUnread;
    final updated = room.copyWith(
      lastMessage: CommunityChatLastMessageEntity(
        id: id,
        body: message.body,
        createdAt: message.createdAt,
        senderNickname: message.senderNickname,
        senderProfileIcon: message.senderProfileIcon,
      ),
      unreadCount: counts ? room.unreadCount + 1 : room.unreadCount,
    );
    state = AsyncData([updated, ...rooms.where((r) => r.postId != postId)]);
  }

  void _onEvent(CommunityChatEvent e) {
    switch (e) {
      case CommunityChatMessageEvent(:final postId, :final message):
        applyIncoming(postId, message);
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.disconnected,
      ):
        // 끊겼다 — 다음에 다시 붙으면 그동안 못 받은 +1을 서버 집계로 메운다.
        _needResync = true;
      case CommunityChatConnectionEvent(
        state: CommunityChatConnectionState.connected,
      ):
        if (!_needResync) return;
        _needResync = false;
        unawaited(_resyncWhenLoaded());
      default:
        break;
    }
  }

  /// 첫 로드가 비행 중이면 그 응답을 기다렸다가 기준선을 다시 받는다 — 그 GET은
  /// 구독 확립 이전 스냅샷일 수 있다(스펙 §3-5 ③). 이미 로드돼 있으면 즉시 —
  /// `await future`를 무조건 거치면 이미 끝난 future라도 한 틱 늦어져, 방을
  /// 막 연 화면의 로컬 배지 삭제(clearUnread)를 재동기화가 되돌릴 수 있다.
  Future<void> _resyncWhenLoaded() async {
    if (!state.hasValue || state.isLoading) {
      try {
        await future;
      } on Object {
        return; // 첫 로드 실패는 화면 에러 경로가 처리한다
      }
    }
    await _resync();
  }

  Future<void> _resync() async {
    try {
      await refresh();
    } on AppException catch (e) {
      // 사용자가 시킨 갱신이 아니다 — 보던 목록을 그대로 둔다.
      debugPrint('[내 모임] ⚠️ 재연결 기준선 갱신 실패 — 보던 목록 유지: ${e.message}');
    }
  }
}

/// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
/// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
@riverpod
class CommunityChatMembersNotifier extends _$CommunityChatMembersNotifier {
  bool _disposed = false;

  @override
  Future<CommunityChatMembersEntity> build(int postId) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return ref.watch(communityChatRepositoryProvider).getMembers(postId);
  }

  /// 실패는 되돌린 뒤 호출자에게 던진다(스낵바). 사이드바가 닫혀 dispose됐으면
  /// 상태를 건드리지 않는다.
  Future<void> toggleNotification() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = !current.notificationEnabled;
    final repo = ref.read(communityChatRepositoryProvider);
    state = AsyncData(current.copyWith(notificationEnabled: next));
    try {
      await repo.setNotification(postId, enabled: next);
    } on AppException {
      if (!_disposed) state = AsyncData(current);
      rethrow;
    }
  }

  /// 멤버를 강퇴하고 목록을 **서버에서 다시 받는다**.
  ///
  /// 성공 응답만 믿고 로컬에서 지우지 않는 이유: 서버가 정본이고, 강퇴와 동시에
  /// 다른 사람이 들어오거나 나갔을 수 있다(게임 로비 강퇴 ISS-0061의 판단과 같다).
  Future<void> kick(int userId) async {
    final repo = ref.read(communityChatRepositoryProvider);
    await repo.kickMember(postId, userId);
    final fresh = await repo.getMembers(postId);
    if (_disposed) return;
    state = AsyncData(fresh);
  }
}

/// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
///
/// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
/// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
/// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
@riverpod
Future<CommunityPostEntity> communityChatPost(Ref ref, int postId) =>
    ref.watch(communityRepositoryProvider).getPost(postId);
