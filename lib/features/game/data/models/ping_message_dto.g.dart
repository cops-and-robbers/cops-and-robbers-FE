// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PingMessageDtoImpl _$$PingMessageDtoImplFromJson(Map<String, dynamic> json) =>
    _$PingMessageDtoImpl(
      id: json['id'] as String,
      gameId: (json['gameId'] as num).toInt(),
      pingType: json['pingType'] as String,
      location: PingLocationDto.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      pingSender: PingSenderDto.fromJson(
        json['pingSender'] as Map<String, dynamic>,
      ),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$$PingMessageDtoImplToJson(
  _$PingMessageDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'pingType': instance.pingType,
  'location': instance.location.toJson(),
  'pingSender': instance.pingSender.toJson(),
  'timestamp': instance.timestamp,
};

_$PingLocationDtoImpl _$$PingLocationDtoImplFromJson(
  Map<String, dynamic> json,
) => _$PingLocationDtoImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$PingLocationDtoImplToJson(
  _$PingLocationDtoImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$PingSenderDtoImpl _$$PingSenderDtoImplFromJson(Map<String, dynamic> json) =>
    _$PingSenderDtoImpl(
      participantId: (json['participantId'] as num).toInt(),
      nickname: json['nickname'] as String,
    );

Map<String, dynamic> _$$PingSenderDtoImplToJson(_$PingSenderDtoImpl instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'nickname': instance.nickname,
    };
