import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_post_status.dart';

part 'community_post_entity.freezed.dart';

/// 커뮤니티 모집 게시글 도메인 엔티티
///
/// UI가 직접 보는 형태. DTO의 중첩 `location`은 여기서 평평하게 편다 —
/// 카드가 좌표와 주소를 따로 쓰기 때문이다. JSON 직렬화 미지원(외부 의존성 없음).
@freezed
class CommunityPostEntity with _$CommunityPostEntity {
  const factory CommunityPostEntity({
    required int id,
    required int writerId,
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required int maxParticipants,
    required CommunityPostStatus status,
    required DateTime createdAt,

    /// 모임 장소 주소. 백엔드 추가 예정이라 지금은 항상 null이며,
    /// null이면 카드에서 위치 행 자체를 그리지 않는다 (좌표는 사용자에게 무의미).
    String? address,

    /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
    /// "0/10명"은 아무도 안 모인 것으로 오독된다.
    int? currentParticipants,

    /// 좋아요 수. 백엔드 추가 예정. null이면 0으로 표시한다.
    int? likeCount,

    /// 스크랩 수. 백엔드 추가 예정. null이면 0으로 표시한다.
    int? bookmarkCount,
  }) = _CommunityPostEntity;
}

/// 페이지네이션이 적용된 게시글 페이지 엔티티
///
/// [currentPage]는 0-based. 무한 스크롤 누적은 presentation의
/// `CommunityFeedState`가 담당하고, 여기는 서버 응답 한 장을 그대로 표현한다.
@freezed
class CommunityPostPageEntity with _$CommunityPostPageEntity {
  const factory CommunityPostPageEntity({
    required List<CommunityPostEntity> items,
    required int currentPage,
    required int totalPages,
  }) = _CommunityPostPageEntity;
}
