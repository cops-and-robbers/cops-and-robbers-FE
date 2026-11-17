// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_check_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NicknameCheckResponseModelImpl _$$NicknameCheckResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$NicknameCheckResponseModelImpl(
  isAvailable: json['isAvailable'] as bool,
  code: json['code'] as String?,
  message: json['message'] as String,
);

Map<String, dynamic> _$$NicknameCheckResponseModelImplToJson(
  _$NicknameCheckResponseModelImpl instance,
) => <String, dynamic>{
  'isAvailable': instance.isAvailable,
  'code': instance.code,
  'message': instance.message,
};
