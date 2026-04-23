import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement_response_model.freezed.dart';
part 'agreement_response_model.g.dart';

/// 약관 동의 상태 조회 응답 DTO
///
/// `GET /api/user/agreements` 응답
///
/// **응답 예시**:
/// ```json
/// {
///   "termsOfServiceAgreed": true,
///   "privacyPolicyAgreed": true,
///   "locationTermsAgreed": true,
///   "termsAgreedAt": "2026-04-15T10:00:00+09:00",
///   "marketingAgreed": false,
///   "marketingAgreedAt": null
/// }
/// ```
@freezed
class AgreementResponseModel with _$AgreementResponseModel {
  const factory AgreementResponseModel({
    /// 이용약관 동의 여부
    required bool termsOfServiceAgreed,

    /// 개인정보처리방침 동의 여부
    required bool privacyPolicyAgreed,

    /// 위치정보 이용약관 동의 여부
    required bool locationTermsAgreed,

    /// 마케팅 수신 동의 여부
    required bool marketingAgreed,

    /// 필수 약관 최초 동의 시각 (미동의 시 null)
    String? termsAgreedAt,

    /// 마케팅 동의 시각 (미동의 시 null)
    String? marketingAgreedAt,
  }) = _AgreementResponseModel;

  factory AgreementResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AgreementResponseModelFromJson(json);
}
