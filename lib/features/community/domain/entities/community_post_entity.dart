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

    /// 화면에 그대로 찍는 위치 한 줄. 서버가 주는 주소 3종(건물명·도로명·지번)
    /// 중 가장 구체적인 것을 Repository가 골라 넣는다.
    /// 역지오코딩이 실패하면 null이며, 그때는 카드가 위치 행 자체를 그리지 않는다
    /// (좌표는 사용자에게 무의미). 지번/도로명을 따로 써야 하는 화면이 생기면
    /// 그때 필드를 나눈다.
    String? locationLabel,

    /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
    /// "0/10명"은 아무도 안 모인 것으로 오독된다.
    int? currentParticipants,

    /// 좋아요 수. 백엔드 추가 예정. null이면 0으로 표시한다.
    int? likeCount,

    /// 스크랩 수. 백엔드 추가 예정. null이면 0으로 표시한다.
    int? bookmarkCount,
  }) = _CommunityPostEntity;
}

/// 커서 페이지네이션이 적용된 게시글 페이지 엔티티
///
/// 무한 스크롤 누적은 presentation의 `CommunityFeedState`가 담당하고,
/// 여기는 서버 응답 한 장을 그대로 표현한다.
/// [nextCursor]는 서버 내부 형식이라 해석하지 않고 다음 요청에 그대로 싣는다.
/// [hasNext]가 false면 [nextCursor]는 null이다.
@freezed
class CommunityPostPageEntity with _$CommunityPostPageEntity {
  const factory CommunityPostPageEntity({
    required List<CommunityPostEntity> items,
    required String? nextCursor,
    required bool hasNext,
  }) = _CommunityPostPageEntity;
}
