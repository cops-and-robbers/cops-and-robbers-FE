import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment_entity.freezed.dart';

/// 모집글 댓글
///
/// 답글은 [replies]에 한 겹만 중첩한다 — 서버가 2depth로 고정하므로(DEC-0034)
/// 답글의 [replies]는 항상 비어 있다.
///
/// 작성자·본문이 nullable인 이유는 삭제된 댓글이다. 답글이 남은 댓글을 지우면
/// 서버가 행을 지우지 않고 [deleted]만 세워 자리를 남기며, 작성자·본문·아이콘을
/// 전부 비워서 내려준다 — 화면은 그 자리를 "삭제된 댓글입니다"로 그린다.
///
/// 탈퇴한 작성자는 반대다. [writerId]가 남고 닉네임·아이콘이 채워져서 온다
/// (DEC-0041) — 비우는 삭제와 별개 규칙이라 [deleted]로만 갈라야 한다.
///
/// [writerProfileIconId]는 앱 내장 아이콘 번호다(`assets/profiles/<id>.svg`).
@freezed
class CommunityCommentEntity with _$CommunityCommentEntity {
  const factory CommunityCommentEntity({
    required int id,

    /// 부모 댓글 id. 1depth 댓글이면 null.
    int? parentId,
    int? writerId,
    String? writerNickname,
    int? writerProfileIconId,
    String? content,

    /// 삭제되어 자리만 남은 댓글인지.
    @Default(false) bool deleted,
    required DateTime createdAt,
    @Default([]) List<CommunityCommentEntity> replies,
  }) = _CommunityCommentEntity;
}
