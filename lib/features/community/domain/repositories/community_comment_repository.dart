import '../entities/community_interaction_entity.dart';

/// 모집글 댓글 Repository 인터페이스
///
/// 좋아요·스크랩과 한 인터페이스에 묶여 있었으나, 댓글만 서버 API가 열려
/// 분리했다 — 반응 쪽은 응답에 카운트·내 반응 필드가 없어 아직 메모리 대역이다
/// (`CommunityInteractionRepository`).
///
/// 메서드는 엔드포인트와 1:1이다. 삭제 뒤의 목록 재조회 같은 조합은 호출자가
/// 맡는다 — Repository가 왕복을 숨기면 화면이 몇 번 도는지 알 수 없어진다.
abstract class CommunityCommentRepository {
  /// 댓글 목록을 전부 가져온다.
  ///
  /// 서버는 커서로 나눠 주지만 화면에 "더 보기"가 없고 댓글 수 라벨이 받은
  /// 만큼만 세므로, `hasNext`가 false가 될 때까지 이어 받는다.
  ///
  /// ponytail: 댓글이 수백 건인 글에서는 왕복이 그 수만큼 늘어난다. 그때는
  /// "더 보기" UI를 넣고 첫 페이지만 받도록 바꾼다.
  Future<List<CommunityCommentEntity>> getComments(int postId);

  /// 댓글 또는 답글을 단다. [parentId]가 있으면 그 댓글의 답글이 된다.
  ///
  /// 생성된 댓글 한 건을 돌려준다 — 목록에 끼워 넣는 일은 호출자가 한다.
  Future<CommunityCommentEntity> addComment({
    required int postId,
    required String content,
    int? parentId,
  });

  /// 댓글을 지운다.
  ///
  /// 서버가 답글 유무에 따라 마스킹만 하거나 부모까지 정리하므로(DEC-0034)
  /// 결과 목록을 앱이 계산할 수 없다. 호출 뒤 [getComments]로 다시 받는다.
  Future<void> deleteComment(int commentId);
}
