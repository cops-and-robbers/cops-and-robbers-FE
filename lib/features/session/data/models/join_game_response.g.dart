// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_game_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JoinGameResponseImpl _$$JoinGameResponseImplFromJson(
  Map<String, dynamic> json,
) => _$JoinGameResponseImpl(
  gameId: (json['gameId'] as num).toInt(),
  participantId: (json['participantId'] as num).toInt(),
  isEventGame: json['isEventGame'] as bool? ?? false,
  gameMode: json['gameMode'] == null
      ? GameMode.copsAndRobbers
      : GameMode.fromJson(json['gameMode'] as String?),
);

Map<String, dynamic> _$$JoinGameResponseImplToJson(
  _$JoinGameResponseImpl instance,
) => <String, dynamic>{
  'gameId': instance.gameId,
  'participantId': instance.participantId,
  'isEventGame': instance.isEventGame,
  'gameMode': _modeToJson(instance.gameMode),
};
