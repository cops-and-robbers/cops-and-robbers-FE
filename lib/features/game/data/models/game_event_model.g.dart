// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameEventModelImpl _$$GameEventModelImplFromJson(Map<String, dynamic> json) =>
    _$GameEventModelImpl(
      eventId: json['eventId'] as String? ?? '',
      type: $enumDecode(
        _$GameEventTypeEnumMap,
        json['type'],
        unknownValue: GameEventType.unknown,
      ),
      timestamp: json['timestamp'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$GameEventModelImplToJson(
  _$GameEventModelImpl instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'type': _$GameEventTypeEnumMap[instance.type]!,
  'timestamp': instance.timestamp,
  'data': instance.data,
};

const _$GameEventTypeEnumMap = {
  GameEventType.arrest: 'ARREST',
  GameEventType.escape: 'ESCAPE',
  GameEventType.gameOver: 'GAME_OVER',
  GameEventType.start: 'START',
  GameEventType.policeMoveStart: 'POLICE_MOVE_START',
  GameEventType.locationReveal: 'LOCATION_REVEAL',
  GameEventType.robberLocationReveal: 'ROBBER_LOCATION_REVEAL',
  GameEventType.playerLeft: 'PLAYER_LEFT',
  GameEventType.unknown: 'UNKNOWN',
};
