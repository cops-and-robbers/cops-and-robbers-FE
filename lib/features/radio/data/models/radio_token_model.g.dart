// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RadioTokenModelImpl _$$RadioTokenModelImplFromJson(
  Map<String, dynamic> json,
) => _$RadioTokenModelImpl(
  url: json['url'] as String,
  room: json['room'] as String,
  identity: json['identity'] as String,
  token: json['token'] as String,
  expiresAt: json['expiresAt'] as String,
);

Map<String, dynamic> _$$RadioTokenModelImplToJson(
  _$RadioTokenModelImpl instance,
) => <String, dynamic>{
  'url': instance.url,
  'room': instance.room,
  'identity': instance.identity,
  'token': instance.token,
  'expiresAt': instance.expiresAt,
};
