import '../entities/community_interaction_entity.dart';

/// 모집글 상호작용(좋아요·스크랩·댓글) Repository 인터페이스
///
/// 이 인터페이스가 존재하는 이유는 하나다 — 백엔드가 아직 이 API들을 안 열었고,
/// 지금은 `CommunityInteractionRepositoryMock`이 메모리로 흉내 내고 있다.
/// API가 열리면 `communityInteractionRepositoryProvider`가 돌려주는 구현체만
/// 바꾸면 되고, 화면·상태 코드는 손대지 않는다.
///
/// 항목별로 API가 따로 열릴 수 있으므로 구현체를 통째로 바꾸는 대신
/// 메서드 단위로 실제 호출을 섞어도 된다 (예: 좋아요만 실서버, 댓글은 목).
abstract class CommunityInteractionRepository {
  /// 게시글 한 건의 좋아요·스크랩·참여 인원 상태를 가져온다.
  Future<CommunityInteractionEntity> getInteraction(int postId);

  /// 좋아요를 토글하고 갱신된 상태를 돌려준다.
  Future<CommunityInteractionEntity> toggleLike(int postId);

  /// 스크랩을 토글하고 갱신된 상태를 돌려준다.
  Future<CommunityInteractionEntity> toggleBookmark(int postId);

  /// 댓글 목록을 가져온다 (답글은 각 댓글의 `replies`에 중첩).
  Future<List<CommunityCommentEntity>> getComments(int postId);

  /// 댓글 또는 답글을 단다. [parentId]가 있으면 그 댓글의 답글이 된다.
  ///
  /// 갱신된 전체 목록을 돌려준다 — 새 댓글 한 건만 받아 화면에서 끼워 넣으면
  /// 답글 위치 계산을 화면이 떠안는다.
  Future<List<CommunityCommentEntity>> addComment({
    required int postId,
    required String content,
    int? parentId,
  });

  /// 댓글을 지운다. 갱신된 전체 목록을 돌려준다.
  Future<List<CommunityCommentEntity>> deleteComment({
    required int postId,
    required int commentId,
  });
}
