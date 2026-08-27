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

/// 지운 댓글 하나를 걷어낸 새 목록을 돌려준다.
///
/// 서버 재조회가 실패했을 때만 쓰는 최소 반영이다. 서버는 답글이 남았으면 자리를
/// 남기고 마스킹하며 마지막 답글이 지워지면 부모까지 정리하는데(DEC-0034), 그
/// 연쇄를 앱이 흉내 내면 서버가 규칙을 바꿀 때 조용히 어긋난다. 그래서 여기서는
/// 그 한 건만 빼고, 정확한 모양은 다음 조회에 맡긴다.
List<CommunityCommentEntity> withoutComment(
  List<CommunityCommentEntity> comments,
  int commentId,
) => [
  for (final comment in comments)
    if (comment.id != commentId)
      comment.copyWith(
        replies: comment.replies.where((r) => r.id != commentId).toList(),
      ),
];
