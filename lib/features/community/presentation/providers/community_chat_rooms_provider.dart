import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/community_chat_repository_mock.dart';
import '../../domain/entities/community_chat_member_entity.dart';
import '../../domain/entities/community_chat_room_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/repositories/community_chat_repository.dart';
import 'community_provider.dart';

part 'community_chat_rooms_provider.g.dart';

/// 채팅 저장소 Provider — 목 교체 지점
///
/// ponytail: 1단계는 인메모리 목이다. 2단계에서 Retrofit + STOMP를 합친 impl로
/// 여기만 바꾼다. 화면·Notifier는 인터페이스만 알고 있어 손댈 곳이 없다.
/// 로그인 사용자가 바뀌면 목도 새로 만든다 — 에코의 `senderId`가 "나"여야
/// 내 말풍선으로 확정된다.
@Riverpod(keepAlive: true)
CommunityChatRepository communityChatRepository(Ref ref) {
  return CommunityChatRepositoryMock(
    myUserId: ref.watch(currentUserIdProvider) ?? 0,
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
