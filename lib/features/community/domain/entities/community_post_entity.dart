import 'package:freezed_annotation/freezed_annotation.dart';

import 'community_post_status.dart';

part 'community_post_entity.freezed.dart';

/// 이 글에서 내가 받을 알림 — 댓글·답글 두 값 (BE #182)
///
/// 서버 요청이 두 값을 항상 함께 받으므로(둘 다 required) 앱도 둘을 한 덩어리로
/// 다룬다. 메뉴의 토글 하나가 둘을 같이 뒤집고, 표시 상태는 [enabled]다.
@freezed
class CommunityPostNotificationSetting with _$CommunityPostNotificationSetting {
  const CommunityPostNotificationSetting._();

  const factory CommunityPostNotificationSetting({
    required bool commentNotificationsEnabled,
    required bool replyNotificationsEnabled,
  }) = _CommunityPostNotificationSetting;

  /// 둘 중 하나라도 켜져 있으면 "알림 받는 중"으로 본다 — 내 글의 서버 기본값이
  /// (댓글 on, 답글 off)라 AND로 보면 기본 상태가 꺼짐으로 보인다.
  bool get enabled => commentNotificationsEnabled || replyNotificationsEnabled;
}

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
    /// 화면에 그리지 않고 복사에만 쓴다([locationLabel] 참고).
    /// 역지오코딩이 실패한 글은 null이다.
    String? address,

    /// 현재 참여 인원. 백엔드 추가 예정. null이면 정원만 표시한다 —
    /// "0/10명"은 아무도 안 모인 것으로 오독된다.
    int? currentParticipants,

    /// 좋아요 수와 내가 눌렀는지. 비로그인이면 [isLiked]가 항상 false다.
    required int likeCount,
    required bool isLiked,

    /// 스크랩 수와 내가 스크랩했는지.
    required int scrapCount,
    required bool isScrapped,

    /// 내가 이 글의 채팅방 멤버인가. BE 이슈로 요청한 필드 — 서버가 아직 안 주면
    /// false이고, 그때는 항상 join을 보내 409면 입장한다.
    @Default(false) bool chatJoined,

    /// 이 글에서 내가 받을 알림 설정. **단건 조회에서만** 채워진다 — 목록 경유
    /// 카드·비로그인 단건은 null이고, 그때 메뉴는 토글 항목을 그리지 않는다.
    CommunityPostNotificationSetting? notificationSetting,
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

/// 내 스크랩 목록 한 장
///
/// [CommunityPostPageEntity]와 나눠 두는 이유는 커서 타입이다 — 피드 커서는
/// 서버 내부 형식의 문자열이고 스크랩 커서는 스크랩 id 정수다. 하나로 합치면
/// 한쪽이 문자열로 변환됐다 다시 파싱되는 왕복이 생긴다.
@freezed
class CommunityScrapPageEntity with _$CommunityScrapPageEntity {
  const factory CommunityScrapPageEntity({
    required List<CommunityPostEntity> items,
    required int? nextCursor,
    required bool hasNext,
  }) = _CommunityScrapPageEntity;
}
