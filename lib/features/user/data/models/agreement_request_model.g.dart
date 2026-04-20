// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agreement_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgreementRequestModelImpl _$$AgreementRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$AgreementRequestModelImpl(
  termsOfService: json['termsOfService'] as bool,
  privacyPolicy: json['privacyPolicy'] as bool,
  locationTerms: json['locationTerms'] as bool,
  marketing: json['marketing'] as bool,
);

Map<String, dynamic> _$$AgreementRequestModelImplToJson(
  _$AgreementRequestModelImpl instance,
) => <String, dynamic>{
  'termsOfService': instance.termsOfService,
  'privacyPolicy': instance.privacyPolicy,
  'locationTerms': instance.locationTerms,
  'marketing': instance.marketing,
};
