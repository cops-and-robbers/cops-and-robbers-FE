import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/token_provider.dart';
import '../../data/datasources/community_chat_stomp_datasource.dart';
import '../../data/repositories/community_chat_repository_impl.dart';
import '../../domain/entities/community_chat_member_entity.dart';
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
