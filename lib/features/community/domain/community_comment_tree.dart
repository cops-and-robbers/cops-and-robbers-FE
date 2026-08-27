import 'entities/community_interaction_entity.dart';

/// 새로 만들어진 댓글을 목록의 제자리에 끼워 넣은 새 목록을 돌려준다.
///
/// 작성 API는 만들어진 댓글 한 건만 주므로(201), 목록을 다시 받지 않고 여기서
/// 합친다 — 재조회하면 커서가 처음으로 되감긴다.
///
/// 1depth 댓글은 맨 뒤에, 답글은 부모의 `replies` 맨 뒤에 붙는다 (둘 다 오래된 순).
/// 부모를 찾지 못하면 최상위로 붙인다 — 서버가 받아준 댓글이라 부모는 서버에
/// 있고, 목록이 낡아 못 찾았을 뿐이다. 조용히 버리면 사용자가 방금 쓴 글이
/// 사라진 것처럼 보인다.
List<CommunityCommentEntity> withNewComment(
  List<CommunityCommentEntity> comments,
  CommunityCommentEntity created,
) {
  final parentId = created.parentId;
  if (parentId == null) return [...comments, created];

  var attached = false;
  final next = [
    for (final comment in comments)
      if (comment.id == parentId)
        () {
          attached = true;
          return comment.copyWith(replies: [...comment.replies, created]);
        }()
      else
        comment,
  ];

  return attached ? next : [...comments, created];
}
