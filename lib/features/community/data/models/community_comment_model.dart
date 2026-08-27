import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_comment_model.freezed.dart';
part 'community_comment_model.g.dart';

/// 모집글 댓글 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityCommentResponse (v2.24.0)
///
/// 작성자·본문이 nullable인 이유는 삭제된 댓글 때문이다 — 답글이 남은 댓글을
/// 지우면 행을 지우지 않고 자리만 남기며, 서버가 `deleted: true` + 작성자·본문·
/// 아이콘을 전부 null로 마스킹해서 내려준다 (DEC-0034).
///
/// 탈퇴한 작성자는 반대다. `writerId`가 남고 닉네임은 "알수없음", 아이콘은
/// 기본값으로 **채워서** 온다 (DEC-0041) — 비우는 삭제와 별개 규칙이다.
@freezed
class CommunityCommentResponseModel with _$CommunityCommentResponseModel {
  const factory CommunityCommentResponseModel({
    required int id,

    /// 부모 댓글 id. 1depth 댓글이면 null.
    int? parentId,
    int? writerId,
    String? writerNickname,
    int? writerProfileIcon,
    String? content,

    /// 삭제 여부. true면 답글이 남아 자리만 지킨 댓글이다.
    @Default(false) bool deleted,
    required DateTime createdAt,
    DateTime? updatedAt,

    /// 답글 목록. 댓글은 2depth 고정이라 답글의 이 값은 항상 비어 있다.
    @Default(<CommunityCommentResponseModel>[])
    List<CommunityCommentResponseModel> replies,
  }) = _CommunityCommentResponseModel;

  factory CommunityCommentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityCommentResponseModelFromJson(json);
}

/// 모집글 댓글 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityCommentListResponse (v2.24.0)
/// 커서 페이징이라 총 개수는 제공되지 않는다.
@freezed
class CommunityCommentListResponseModel
    with _$CommunityCommentListResponseModel {
  const factory CommunityCommentListResponseModel({
    /// 1depth 댓글 목록 (오래된 순). 각 댓글의 답글은 `replies`에 모두 담긴다.
    @Default(<CommunityCommentResponseModel>[])
    List<CommunityCommentResponseModel> content,

    /// 다음 페이지 커서. 마지막 페이지면 null.
    int? nextCursor,
    @Default(false) bool hasNext,
  }) = _CommunityCommentListResponseModel;

  factory CommunityCommentListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityCommentListResponseModelFromJson(json);
}

/// 댓글·답글 작성 요청 DTO
///
/// `parentId`를 보내면 답글, 생략하면 일반 댓글이다.
/// 답글에 답글을 달면 서버가 `400 INVALID_COMMENT_DEPTH`로 거절한다 (DEC-0034).
@freezed
class CommunityCommentCreateRequestModel
    with _$CommunityCommentCreateRequestModel {
  const factory CommunityCommentCreateRequestModel({
    int? parentId,
    required String content,
  }) = _CommunityCommentCreateRequestModel;

  factory CommunityCommentCreateRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityCommentCreateRequestModelFromJson(json);
}
