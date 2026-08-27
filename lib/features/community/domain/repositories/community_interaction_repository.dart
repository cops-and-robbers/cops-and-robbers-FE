import '../entities/community_interaction_entity.dart';

/// 모집글 상호작용(좋아요·스크랩) Repository 인터페이스
///
/// 이 인터페이스가 존재하는 이유는 하나다 — 토글 API는 열렸지만 목록·상세 응답에
/// 카운트(`likeCount`·`scrapCount`)와 내가 눌렀는지(`liked`·`scrapped`)가 없어
/// 버튼의 처음 상태를 그릴 수 없다. 그때까지 `CommunityInteractionRepositoryMock`이
/// 메모리로 흉내 낸다.
///
/// 서버가 그 필드를 내려주면 `communityInteractionRepositoryProvider`가 돌려주는
/// 구현체만 바꾸면 되고, 화면·상태 코드는 손대지 않는다.
///
/// 댓글은 API가 완비되어 이미 실서버로 옮겼다 — `CommunityCommentRepository`.
abstract class CommunityInteractionRepository {
  /// 게시글 한 건의 좋아요·스크랩·참여 인원 상태를 가져온다.
  Future<CommunityInteractionEntity> getInteraction(int postId);

  /// 좋아요를 토글하고 갱신된 상태를 돌려준다.
  Future<CommunityInteractionEntity> toggleLike(int postId);

  /// 스크랩을 토글하고 갱신된 상태를 돌려준다.
  Future<CommunityInteractionEntity> toggleBookmark(int postId);
}
