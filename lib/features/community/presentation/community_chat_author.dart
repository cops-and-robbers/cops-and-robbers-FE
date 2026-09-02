import '../domain/entities/community_chat_member_entity.dart';
import '../domain/entities/community_post_entity.dart';

/// 내가 이 채팅방의 방장인가.
///
/// 모집글 작성자([post.writerId])로 우선 판정하고, 상세를 못 불러왔으면 멤버
/// 목록의 방장 표시로 물러선다 — 둘 중 하나만 있어도 나가기·공지 버튼을 숨길지
/// 정할 수 있어야 한다(서버가 거절하기 전에 앱이 먼저 막는다).
bool isChatRoomAuthor({
  required CommunityPostEntity? post,
  required List<CommunityChatMemberEntity>? members,
  required int? myId,
}) {
  if (post != null && post.writerId == myId) return true;
  return members?.any((m) => m.userId == myId && m.isAuthor) ?? false;
}
