import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_model.freezed.dart';
part 'community_post_model.g.dart';

/// 모임 장소 DTO
///
/// 백엔드 스키마: api-docs.json#LocationResponse (v2.17.0)
///
/// 주소 3종은 서버가 좌표를 한 번 역지오코딩해 저장해 둔 값이다. 셋 다 null일 수
/// 있다 — 역지오코딩이 실패해도 글 작성 자체는 성공시키기 때문이다.
/// 어느 표기를 쓸지는 화면이 정한다 (Repository에서 `locationLabel`로 접는다).
@freezed
class CommunityLocationModel with _$CommunityLocationModel {
  const factory CommunityLocationModel({
    required double latitude,
    required double longitude,

    /// 지번 주소 — `서울 광진구 군자동 98`
    String? address,

    /// 도로명 주소 — `서울특별시 광진구 능동로 209`. 도로명이 없는 지역이면 null.
    String? roadAddress,

    /// 건물명 — `세종대학교`. 공터·공원·길 위 좌표면 null.
    String? buildingName,
  }) = _CommunityLocationModel;

  factory CommunityLocationModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityLocationModelFromJson(json);
}

/// 커서 페이지네이션 응답 봉투의 커서 정보 DTO
///
/// 백엔드 스키마: api-docs.json#CursorInfo (v2.17.0)
///
/// 목록 API 중 커서를 쓰는 건 아직 커뮤니티뿐이라 여기 둔다. 두 번째 API가
/// 커서로 바뀌면 `PageInfoModel`처럼 core로 옮긴다.
/// [nextCursor]는 서버 내부 형식이다 — 파싱하지 말고 다음 요청에 그대로 싣는다.
/// [hasNext]가 false면 [nextCursor]는 항상 null이다.
@freezed
class CursorInfoModel with _$CursorInfoModel {
  const factory CursorInfoModel({
    required String? nextCursor,
    required bool hasNext,
  }) = _CursorInfoModel;

  factory CursorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CursorInfoModelFromJson(json);
}

/// 모집 게시글 단건 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostResponse (v2.17.0)
///
/// [writerNickname]은 탈퇴한 작성자면 null이다.
/// 나머지 nullable 3개는 백엔드가 아직 안 보내는 값이다(2·3단계 예정). 미리
/// 선언해 두면 백엔드가 필드를 추가하는 순간 코드 변경 없이 값이 흘러들어온다.
/// `status`를 enum이 아니라 `String`으로 받는 이유: 도메인 변환을 Repository
/// 경계에서 하고, 알 수 없는 값이면 거기서 예외를 던지기 위함이다.
@freezed
class CommunityPostResponseModel with _$CommunityPostResponseModel {
  const factory CommunityPostResponseModel({
    required int id,
    required int writerId,
    required String title,
    required String content,
    required DateTime meetingAt,
    required CommunityLocationModel location,
    required int maxParticipants,
    required String status,
    required DateTime createdAt,

    /// 작성자 닉네임. 탈퇴한 작성자면 null.
    String? writerNickname,

    // ── 백엔드 추가 예정 ──
    int? currentParticipants,
    int? likeCount,
    int? bookmarkCount,
  }) = _CommunityPostResponseModel;

  factory CommunityPostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostResponseModelFromJson(json);
}

/// 모집 게시글 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostListResponse (v2.17.0)
/// 총 개수(`totalElements`)는 커서 방식이라 제공되지 않는다.
@freezed
class CommunityPostListResponseModel with _$CommunityPostListResponseModel {
  const factory CommunityPostListResponseModel({
    required List<CommunityPostResponseModel> content,
    required CursorInfoModel cursor,
  }) = _CommunityPostListResponseModel;

  factory CommunityPostListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostListResponseModelFromJson(json);
}
