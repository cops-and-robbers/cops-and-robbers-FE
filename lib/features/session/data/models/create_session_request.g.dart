// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateSessionRequestImpl _$$CreateSessionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateSessionRequestImpl(
  playgroundLatitude: (json['playgroundLatitude'] as num).toDouble(),
  playgroundLongitude: (json['playgroundLongitude'] as num).toDouble(),
  playgroundRadiusInMeters: (json['playgroundRadiusInMeters'] as num)
      .toDouble(),
  jailLatitude: (json['jailLatitude'] as num).toDouble(),
  jailLongitude: (json['jailLongitude'] as num).toDouble(),
  jailRadiusInMeters: (json['jailRadiusInMeters'] as num).toDouble(),
  roundDurationMinutes: (json['roundDurationMinutes'] as num).toInt(),
  locationShareMinutes: (json['locationShareMinutes'] as num).toInt(),
  policeWaitMinutes: (json['policeWaitMinutes'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
);

Map<String, dynamic> _$$CreateSessionRequestImplToJson(
  _$CreateSessionRequestImpl instance,
) => <String, dynamic>{
  'playgroundLatitude': instance.playgroundLatitude,
  'playgroundLongitude': instance.playgroundLongitude,
  'playgroundRadiusInMeters': instance.playgroundRadiusInMeters,
  'jailLatitude': instance.jailLatitude,
  'jailLongitude': instance.jailLongitude,
  'jailRadiusInMeters': instance.jailRadiusInMeters,
  'roundDurationMinutes': instance.roundDurationMinutes,
  'locationShareMinutes': instance.locationShareMinutes,
  'policeWaitMinutes': instance.policeWaitMinutes,
  'maxParticipants': instance.maxParticipants,
};
