import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_notification_model.freezed.dart';
part 'community_notification_model.g.dart';

/// 알림 한 건 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityNotificationResponse (v2.27.0)
///
/// [type]을 enum이 아니라 `String`으로 받는 이유는 `CommunityPostStatus`와 같다
/// — 도메인 변환은 Repository 경계(`community_wire.dart`)에서 한다.
@freezed
class CommunityNotificationResponseModel
    with _$CommunityNotificationResponseModel {
  const factory CommunityNotificationResponseModel({
    required int id,
    required String type,
    required int communityPostId,
    required String postTitle,
    required String content,
    required bool read,
    required DateTime createdAt,
  }) = _CommunityNotificationResponseModel;

  factory CommunityNotificationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityNotificationResponseModelFromJson(json);
}

/// 알림함 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityNotificationListResponse (v2.27.0)
///
/// 커서가 평평한 정수라 [CommunityScrapListResponseModel]과 같은 봉투 모양이다.
@freezed
class CommunityNotificationListResponseModel
    with _$CommunityNotificationListResponseModel {
  const factory CommunityNotificationListResponseModel({
    required List<CommunityNotificationResponseModel> content,
    required bool hasNext,
    int? nextCursor,
  }) = _CommunityNotificationListResponseModel;

  factory CommunityNotificationListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityNotificationListResponseModelFromJson(json);
}

/// 안 읽은 알림 개수 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityNotificationUnreadCountResponse (v2.27.0)
@freezed
class CommunityNotificationUnreadCountResponseModel
    with _$CommunityNotificationUnreadCountResponseModel {
  const factory CommunityNotificationUnreadCountResponseModel({
    required int unreadCount,
  }) = _CommunityNotificationUnreadCountResponseModel;

  factory CommunityNotificationUnreadCountResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityNotificationUnreadCountResponseModelFromJson(json);
}
