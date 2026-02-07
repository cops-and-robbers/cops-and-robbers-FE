// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseModelImpl _$$LoginResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$LoginResponseModelImpl(
  userId: (json['userId'] as num).toInt(),
  nickname: json['nickname'] as String,
  tokens: TokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
  isNewUser: json['isNewUser'] as bool,
);

Map<String, dynamic> _$$LoginResponseModelImplToJson(
  _$LoginResponseModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'nickname': instance.nickname,
  'tokens': instance.tokens,
  'isNewUser': instance.isNewUser,
};

_$TokensModelImpl _$$TokensModelImplFromJson(Map<String, dynamic> json) =>
    _$TokensModelImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$$TokensModelImplToJson(_$TokensModelImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
