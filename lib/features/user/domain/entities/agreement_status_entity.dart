import 'package:freezed_annotation/freezed_annotation.dart';

part 'agreement_status_entity.freezed.dart';

/// 약관 동의 상태 엔티티
///
/// 4종 약관(이용약관·개인정보처리방침·위치정보 이용약관·마케팅)의 동의 여부를 담는
/// 불변 엔티티입니다. Presentation Layer는 이 엔티티만 참조합니다.
@freezed
class AgreementStatusEntity with _$AgreementStatusEntity {
  const factory AgreementStatusEntity({
    /// 이용약관 동의 여부 (필수)
    required bool termsOfService,

    /// 개인정보 처리방침 동의 여부 (필수)
    required bool privacyPolicy,

    /// 위치정보 이용약관 동의 여부 (필수)
    required bool locationTerms,

    /// 마케팅 수신 동의 여부 (선택)
    required bool marketing,
  }) = _AgreementStatusEntity;

  const AgreementStatusEntity._();

  /// 필수 약관 3종이 모두 동의 완료되었는지 여부
  bool get hasAllRequired => termsOfService && privacyPolicy && locationTerms;
}
