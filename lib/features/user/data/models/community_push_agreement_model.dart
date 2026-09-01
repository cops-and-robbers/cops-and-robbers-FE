import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_push_agreement_model.freezed.dart';
part 'community_push_agreement_model.g.dart';

/// 커뮤니티 푸시 알림 동의 조회 응답 DTO
///
/// `GET /api/user/agreements/community-push` 응답 (BE #182, v2.26.0).
/// 계약에 `required`가 없어 게임 푸시 DTO와 달리 기본값을 둔다 —
/// 가입 기본값이 동의(true)다.
@freezed
class CommunityPushAgreementResponseModel
    with _$CommunityPushAgreementResponseModel {
  const factory CommunityPushAgreementResponseModel({
    @Default(true) bool allowCommunityPush,
  }) = _CommunityPushAgreementResponseModel;

  factory CommunityPushAgreementResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityPushAgreementResponseModelFromJson(json);
}

/// 커뮤니티 푸시 알림 동의 업데이트 요청 DTO
///
/// `PUT /api/user/agreements/community-push` 요청 바디. 끄면 푸시만 오지 않고
/// 알림함에는 그대로 쌓인다 — 게시글별·댓글별 설정과 독립이다.
@freezed
class CommunityPushAgreementRequestModel
    with _$CommunityPushAgreementRequestModel {
  const factory CommunityPushAgreementRequestModel({
    required bool allowCommunityPush,
  }) = _CommunityPushAgreementRequestModel;

  factory CommunityPushAgreementRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityPushAgreementRequestModelFromJson(json);
}
