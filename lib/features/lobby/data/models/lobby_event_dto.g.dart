// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lobby_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LobbyEventDtoImpl _$$LobbyEventDtoImplFromJson(Map<String, dynamic> json) =>
    _$LobbyEventDtoImpl(
      eventId: json['eventId'] as String,
      gameId: (json['gameId'] as num).toInt(),
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$LobbyEventDtoImplToJson(_$LobbyEventDtoImpl instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'gameId': instance.gameId,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'data': instance.data,
    };

_$GameStartDataImpl _$$GameStartDataImplFromJson(Map<String, dynamic> json) =>
    _$GameStartDataImpl(
      message: json['message'] as String,
      startTime: json['startTime'] as String,
    );

Map<String, dynamic> _$$GameStartDataImplToJson(_$GameStartDataImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'startTime': instance.startTime,
    };

_$LobbyParticipantInfoImpl _$$LobbyParticipantInfoImplFromJson(
  Map<String, dynamic> json,
) => _$LobbyParticipantInfoImpl(
  participantId: (json['participantId'] as num).toInt(),
  nickname: json['nickname'] as String,
  team: json['team'] as String,
  isReady: json['isReady'] as bool,
);

Map<String, dynamic> _$$LobbyParticipantInfoImplToJson(
  _$LobbyParticipantInfoImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'nickname': instance.nickname,
  'team': instance.team,
  'isReady': instance.isReady,
};
