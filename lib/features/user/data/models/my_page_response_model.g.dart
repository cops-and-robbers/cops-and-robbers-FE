// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_page_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MyPageResponseModelImpl _$$MyPageResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$MyPageResponseModelImpl(
  userId: (json['userId'] as num).toInt(),
  nickname: json['nickname'] as String,
  socialPlatform: json['socialPlatform'] as String,
  allowGamePush: json['allowGamePush'] as bool,
  allowMarketingPush: json['allowMarketingPush'] as bool,
);

Map<String, dynamic> _$$MyPageResponseModelImplToJson(
  _$MyPageResponseModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'nickname': instance.nickname,
  'socialPlatform': instance.socialPlatform,
  'allowGamePush': instance.allowGamePush,
  'allowMarketingPush': instance.allowMarketingPush,
};
