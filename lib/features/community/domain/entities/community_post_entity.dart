import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_post_status.dart';

part 'community_post_entity.freezed.dart';

/// 커뮤니티 모집 게시글 도메인 엔티티
///
/// UI가 직접 보는 형태. DTO의 중첩 `location`은 여기서 평평하게 편다 —
/// 카드가 좌표와 주소를 따로 쓰기 때문이다. JSON 직렬화 미지원(외부 의존성 없음).
@freezed
class CommunityPostEntity with _$CommunityPostEntity {
  const CommunityPostEntity._();

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

    /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
    ///
    /// [region]과 병기한다(DEC-0015): 좌표로는 건물명을 신뢰할 수준으로 얻을 수
    /// 없어 장소명은 작성자에게 받고, 서버 주소는 그 옆에 보조로 붙인다.
    /// 둘 다 null이면 화면이 장소 행 자체를 그리지 않는다 — 좌표는 사용자에게
    /// 무의미하다.
    String? placeName,

    /// 서버가 좌표를 역지오코딩한 동 단위 지역 — `서울특별시 광진구 군자동`.
    /// 역지오코딩이 실패하면 null이다.
    String? region,

    /// 번지까지 붙은 지번 주소 — `서울특별시 광진구 화양동 164-2`.
    ///
    /// 화면에 그리지 않고 복사에만 쓴다([locationLabel] 참고). 백엔드 추가
    /// 예정이라 아직 null이며, 그동안은 화면에 보이던 라벨이 대신 복사된다.
    String? address,

    /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
    /// "0/10명"은 아무도 안 모인 것으로 오독된다.
    int? currentParticipants,

    /// 좋아요 수. 백엔드 추가 예정. null이면 0으로 표시한다.
    int? likeCount,

    /// 스크랩 수. 백엔드 추가 예정. null이면 0으로 표시한다.
    int? bookmarkCount,
  }) = _CommunityPostEntity;

  /// 화면에 찍는 위치 한 줄 — 서버 지역과 작성자 장소명을 병기한다 (DEC-0015).
  ///
  /// 한쪽만 있으면 있는 쪽만, 둘 다 없으면 null이다. null이면 화면이 위치 행 자체를
  /// 그리지 않는다 — 좌표는 사용자에게 무의미하다.
  String? get locationLabel {
    final parts = [region, placeName].whereType<String>();
    return parts.isEmpty ? null : parts.join(' · ');
  }
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
