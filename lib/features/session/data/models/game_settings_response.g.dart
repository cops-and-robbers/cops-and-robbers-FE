// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSettingsResponseImpl _$$GameSettingsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$GameSettingsResponseImpl(
  roundDurationMinutes: (json['roundDurationMinutes'] as num).toInt(),
  locationRevealIntervalMinutes: (json['locationRevealIntervalMinutes'] as num)
      .toInt(),
  policeWaitMinutes: (json['policeWaitMinutes'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  gameStartTime: json['gameStartTime'] as String?,
  isEventGame: json['isEventGame'] as bool? ?? false,
  shrinkFinalRadiusInMeters: (json['shrinkFinalRadiusInMeters'] as num?)
      ?.toInt(),
  radioEnabled: json['radioEnabled'] as bool? ?? false,
  gameMode: json['gameMode'] == null
      ? GameMode.copsAndRobbers
      : GameMode.fromJson(json['gameMode'] as String?),
);

Map<String, dynamic> _$$GameSettingsResponseImplToJson(
  _$GameSettingsResponseImpl instance,
) => <String, dynamic>{
  'roundDurationMinutes': instance.roundDurationMinutes,
  'locationRevealIntervalMinutes': instance.locationRevealIntervalMinutes,
  'policeWaitMinutes': instance.policeWaitMinutes,
  'maxParticipants': instance.maxParticipants,
  'gameStartTime': instance.gameStartTime,
  'isEventGame': instance.isEventGame,
  'shrinkFinalRadiusInMeters': instance.shrinkFinalRadiusInMeters,
  'radioEnabled': instance.radioEnabled,
  'gameMode': _modeToJson(instance.gameMode),
};
