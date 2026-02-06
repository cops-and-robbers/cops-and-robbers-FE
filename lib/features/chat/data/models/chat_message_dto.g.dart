// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageDtoImpl _$$ChatMessageDtoImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageDtoImpl(
      id: json['id'] as String,
      gameId: (json['gameId'] as num).toInt(),
      sender: ChatSenderDto.fromJson(json['sender'] as Map<String, dynamic>),
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      scope: json['scope'] as String,
    );

Map<String, dynamic> _$$ChatMessageDtoImplToJson(
  _$ChatMessageDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'sender': instance.sender,
  'message': instance.message,
  'timestamp': instance.timestamp,
  'scope': instance.scope,
};

_$ChatSenderDtoImpl _$$ChatSenderDtoImplFromJson(Map<String, dynamic> json) =>
    _$ChatSenderDtoImpl(
      participantId: (json['participantId'] as num).toInt(),
      nickname: json['nickname'] as String,
      team: json['team'] as String,
    );

Map<String, dynamic> _$$ChatSenderDtoImplToJson(_$ChatSenderDtoImpl instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'nickname': instance.nickname,
      'team': instance.team,
    };
