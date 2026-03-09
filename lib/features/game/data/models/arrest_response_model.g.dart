// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arrest_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArrestResponseModelImpl _$$ArrestResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$ArrestResponseModelImpl(
  robberNickname: json['robberNickname'] as String? ?? '',
  remainingThieves: (json['remainingThieves'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ArrestResponseModelImplToJson(
  _$ArrestResponseModelImpl instance,
) => <String, dynamic>{
  'robberNickname': instance.robberNickname,
  'remainingThieves': instance.remainingThieves,
};
