import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement_request_model.freezed.dart';
part 'agreement_request_model.g.dart';

/// 약관 동의 저장 요청 DTO
///
/// `PUT /api/user/agreements` 요청 본문
///
/// **요청 예시**:
/// ```json
/// {
///   "termsOfService": true,
///   "privacyPolicy": true,
///   "locationTerms": true,
///   "marketing": false
/// }
/// ```
@freezed
class AgreementRequestModel with _$AgreementRequestModel {
  const factory AgreementRequestModel({
    /// 이용약관 동의 여부 (필수)
    required bool termsOfService,

    /// 개인정보 처리방침 동의 여부 (필수)
    required bool privacyPolicy,

    /// 위치정보 이용약관 동의 여부 (필수)
    required bool locationTerms,

    /// 마케팅 수신 동의 여부 (선택)
    required bool marketing,
  }) = _AgreementRequestModel;

  factory AgreementRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AgreementRequestModelFromJson(json);
}
