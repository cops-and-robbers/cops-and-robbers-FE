// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agreement_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgreementResponseModelImpl _$$AgreementResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$AgreementResponseModelImpl(
  termsOfServiceAgreed: json['termsOfServiceAgreed'] as bool,
  privacyPolicyAgreed: json['privacyPolicyAgreed'] as bool,
  locationTermsAgreed: json['locationTermsAgreed'] as bool,
  marketingAgreed: json['marketingAgreed'] as bool,
  termsAgreedAt: json['termsAgreedAt'] as String?,
  marketingAgreedAt: json['marketingAgreedAt'] as String?,
);

Map<String, dynamic> _$$AgreementResponseModelImplToJson(
  _$AgreementResponseModelImpl instance,
) => <String, dynamic>{
  'termsOfServiceAgreed': instance.termsOfServiceAgreed,
  'privacyPolicyAgreed': instance.privacyPolicyAgreed,
  'locationTermsAgreed': instance.locationTermsAgreed,
  'marketingAgreed': instance.marketingAgreed,
  'termsAgreedAt': instance.termsAgreedAt,
  'marketingAgreedAt': instance.marketingAgreedAt,
};
