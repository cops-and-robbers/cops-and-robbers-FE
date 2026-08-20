import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_interaction_entity.freezed.dart';

/// 모집글의 상호작용 상태 (좋아요·스크랩·참여 인원)
///
/// 게시글 본문(`CommunityPostEntity`)과 나눠 두는 이유: 이 값들만 백엔드가 아직
/// 안 주고, 앱에서 목데이터로 채우고 있다. 한 덩어리로 합쳐 두면 API가 하나씩
/// 열릴 때마다 게시글 엔티티까지 흔들린다.
///
/// [isLiked]·[isBookmarked]는 "내가 눌렀는지"다 — 비로그인이면 항상 false.
@freezed
class CommunityInteractionEntity with _$CommunityInteractionEntity {
  const factory CommunityInteractionEntity({
    required bool isLiked,
    required int likeCount,
    required bool isBookmarked,
    required int bookmarkCount,

    /// 현재 참여 인원. 모르면 null — 화면이 정원만 표시한다.
    int? currentParticipants,
  }) = _CommunityInteractionEntity;
}

/// 모집글 댓글
///
/// 답글은 [replies]에 한 겹만 중첩한다 — 답글의 답글은 UX상 열지 않는다.
/// [writerProfileIconId]는 앱 내장 아이콘 번호다(`assets/profiles/<id>.svg`).
/// 이미지 URL이 아니라 정수 하나라, 서버가 이 값을 저장해 주면 그대로 흘려보낸다.
@freezed
class CommunityCommentEntity with _$CommunityCommentEntity {
  const factory CommunityCommentEntity({
    required int id,
    required int writerId,
    required String writerNickname,
    required int writerProfileIconId,
    required String content,
    required DateTime createdAt,
    @Default([]) List<CommunityCommentEntity> replies,
  }) = _CommunityCommentEntity;
}
