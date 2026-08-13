import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/models/page_info_model.dart';

part 'community_post_model.freezed.dart';
part 'community_post_model.g.dart';

/// 모임 장소 DTO
///
/// 백엔드 스키마: api-docs.json#LocationResponse
@freezed
class CommunityLocationModel with _$CommunityLocationModel {
  const factory CommunityLocationModel({
    required double latitude,
    required double longitude,

    /// 사람이 읽는 주소. 백엔드 추가 예정이라 지금은 항상 null이다.
    /// 클라이언트 역지오코딩을 하지 않는 이유는 설계 문서 1절 참고.
    String? address,
  }) = _CommunityLocationModel;

  factory CommunityLocationModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityLocationModelFromJson(json);
}

/// 모집 게시글 단건 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostResponse (v2.15.0)
///
/// nullable 필드 4개는 백엔드가 아직 안 보내는 값이다. 미리 선언해 두면
/// 백엔드가 필드를 추가하는 순간 코드 변경 없이 값이 흘러들어온다.
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
/// 백엔드 스키마: api-docs.json#CommunityPostListResponse
@freezed
class CommunityPostListResponseModel with _$CommunityPostListResponseModel {
  const factory CommunityPostListResponseModel({
    required List<CommunityPostResponseModel> content,
    required PageInfoModel page,
  }) = _CommunityPostListResponseModel;

  factory CommunityPostListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostListResponseModelFromJson(json);
}
