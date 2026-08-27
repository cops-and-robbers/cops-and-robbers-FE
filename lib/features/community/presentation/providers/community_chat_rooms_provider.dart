import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/token_provider.dart';
import '../../data/datasources/community_chat_stomp_datasource.dart';
import '../../data/repositories/community_chat_repository_impl.dart';
import '../../domain/entities/community_chat_member_entity.dart';
import '../../domain/entities/community_chat_message_entity.dart';
import '../../domain/entities/community_chat_room_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/repositories/community_chat_repository.dart';
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
/// `keepAlive`: 내 모임 탭을 오갈 때마다 다시 받지 않는다. 갱신 경로는 당겨서
/// 새로고침, 방에 들어갈 때 목록에 없는 방(방금 참여), 나간 뒤 무효화 셋이다.
@Riverpod(keepAlive: true)
class CommunityChatRooms extends _$CommunityChatRooms {
  @override
  Future<List<CommunityChatRoomEntity>> build() =>
      ref.watch(communityChatRepositoryProvider).getRooms();

  /// 실패하면 예외가 그대로 올라간다 — 보던 목록은 남고 화면이 스낵바로 알린다.
  Future<void> refresh() async {
    final rooms = await ref.read(communityChatRepositoryProvider).getRooms();
    state = AsyncData(rooms);
  }

  /// 떠나 있다 돌아왔을 때(바텀 탭 복귀·앱 복귀·스코프 전환) 부른다.
  ///
  /// ponytail: 유효 시간을 두지 않는다. 모집글 목록은 3분을 쓰지만(ISS-0145)
  /// 그건 "실시간 데이터가 아니라 잠깐 낡아도 된다"는 근거 위에 선 값이고,
  /// 채팅은 정반대다. 돌아왔는데 낡은 목록을 보는 쪽이 요청 한 건보다 나쁘다.
  /// 게다가 유저당 알림 채널이 생기면(DOC-0037 §10) 이 갱신 자체가 거의
  /// 필요 없어진다 — 곧 사라질 구조에 조절 손잡이를 달지 않는다.
  /// 서버 지표에 이 호출량이 실제로 잡히면 그때 유효 시간을 넣는다.
  ///
  /// 두 가드는 남긴다: 첫 로드가 아직 안 끝났으면 그 로드가 채우고,
  /// 이미 받는 중이면 트리거가 겹쳐도 요청이 한 번 더 나가지 않는다.
  Future<void> refreshOnReturn() async {
    if (!state.hasValue || state.isLoading) return;
    await refresh();
  }

  /// 채팅방에서 메시지를 주고받는 동안 그 방의 미리보기를 같이 고친다.
  ///
  /// 채팅방은 루트 네비게이터에 push되므로 뒤로 가도 내 모임 탭 위젯이 살아
  /// 있다 — 재진입 갱신이 안 걸려 미리보기가 방에 들어가기 전 상태로 남는다.
  /// 서버 왕복 없이 이미 받은 메시지로 고치고, 최근 대화순이므로 맨 앞으로 옮긴다.
  ///
  /// 아직 목록에 없는 방(방금 참여)은 건드리지 않는다 — 없는 칸을 만들어 내면
  /// 제목·정원 같은 나머지 값을 지어내야 한다. 그건 다음 조회가 채운다.
  void applyLastMessage(int postId, CommunityChatMessageEntity message) {
    final rooms = state.valueOrNull;
    if (rooms == null) return;

    final index = rooms.indexWhere((r) => r.postId == postId);
    if (index == -1) return;

    final updated = rooms[index].copyWith(
      lastMessage: CommunityChatLastMessageEntity(
        // 아직 확정 전인 내 말풍선은 서버 id가 없다 — 그건 에코가 채운다.
        id: message.id ?? 0,
        body: message.body,
        createdAt: message.createdAt,
        senderNickname: message.senderNickname,
        senderProfileIcon: message.senderProfileIcon,
      ),
    );
    state = AsyncData([updated, ...rooms.where((r) => r.postId != postId)]);
  }
}

/// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
@riverpod
Future<List<CommunityChatMemberEntity>> communityChatMembers(
  Ref ref,
  int postId,
) => ref.watch(communityChatRepositoryProvider).getMembers(postId);

/// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
///
/// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
/// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
/// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
@riverpod
Future<CommunityPostEntity> communityChatPost(Ref ref, int postId) =>
    ref.watch(communityRepositoryProvider).getPost(postId);
