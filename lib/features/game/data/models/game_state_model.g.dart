// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParticipantInfoModelImpl _$$ParticipantInfoModelImplFromJson(
  Map<String, dynamic> json,
) => _$ParticipantInfoModelImpl(
  participantId: (json['participantId'] as num).toInt(),
  nickname: json['nickname'] as String,
  team: json['team'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$$ParticipantInfoModelImplToJson(
  _$ParticipantInfoModelImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'nickname': instance.nickname,
  'team': instance.team,
  'status': instance.status,
};

_$RobberLocationInfoModelImpl _$$RobberLocationInfoModelImplFromJson(
  Map<String, dynamic> json,
) => _$RobberLocationInfoModelImpl(
  participantId: (json['participantId'] as num).toInt(),
  nickname: json['nickname'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$RobberLocationInfoModelImplToJson(
  _$RobberLocationInfoModelImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'nickname': instance.nickname,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$GameStateModelImpl _$$GameStateModelImplFromJson(Map<String, dynamic> json) =>
    _$GameStateModelImpl(
      robberLocations:
          (json['robberLocations'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RobberLocationInfoModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (e) => ParticipantInfoModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GameStateModelImplToJson(
  _$GameStateModelImpl instance,
) => <String, dynamic>{
  'robberLocations': instance.robberLocations.map((e) => e.toJson()).toList(),
  'participants': instance.participants.map((e) => e.toJson()).toList(),
};
