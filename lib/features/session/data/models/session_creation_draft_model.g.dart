// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_creation_draft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionCreationDraftModelImpl _$$SessionCreationDraftModelImplFromJson(
  Map<String, dynamic> json,
) => _$SessionCreationDraftModelImpl(
  playgroundCenter: const LatLngConverter().fromJson(
    json['playgroundCenter'] as Map<String, dynamic>?,
  ),
  playgroundRadiusInMeters: (json['playgroundRadiusInMeters'] as num?)
      ?.toDouble(),
  jailCenter: const LatLngConverter().fromJson(
    json['jailCenter'] as Map<String, dynamic>?,
  ),
  jailRadiusInMeters: (json['jailRadiusInMeters'] as num?)?.toDouble(),
  roundDurationMinutes: (json['roundDurationMinutes'] as num?)?.toInt(),
  locationShareMinutes: (json['locationShareMinutes'] as num?)?.toInt(),
  policeWaitMinutes: (json['policeWaitMinutes'] as num?)?.toInt(),
  maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
);

Map<String, dynamic> _$$SessionCreationDraftModelImplToJson(
  _$SessionCreationDraftModelImpl instance,
) => <String, dynamic>{
  'playgroundCenter': const LatLngConverter().toJson(instance.playgroundCenter),
  'playgroundRadiusInMeters': instance.playgroundRadiusInMeters,
  'jailCenter': const LatLngConverter().toJson(instance.jailCenter),
  'jailRadiusInMeters': instance.jailRadiusInMeters,
  'roundDurationMinutes': instance.roundDurationMinutes,
  'locationShareMinutes': instance.locationShareMinutes,
  'policeWaitMinutes': instance.policeWaitMinutes,
  'maxParticipants': instance.maxParticipants,
};
