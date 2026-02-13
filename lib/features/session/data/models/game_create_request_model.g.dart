// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameCreateRequestModelImpl _$$GameCreateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameCreateRequestModelImpl(
  area: AreaRequestModel.fromJson(json['area'] as Map<String, dynamic>),
  settings: GameSettingsRequestModel.fromJson(
    json['settings'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$GameCreateRequestModelImplToJson(
  _$GameCreateRequestModelImpl instance,
) => <String, dynamic>{
  'area': instance.area.toJson(),
  'settings': instance.settings.toJson(),
};

_$AreaRequestModelImpl _$$AreaRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$AreaRequestModelImpl(
  playgroundCenter: CoordinatesRequestModel.fromJson(
    json['playgroundCenter'] as Map<String, dynamic>,
  ),
  playgroundRadiusInMeters: (json['playgroundRadiusInMeters'] as num).toInt(),
  jailCenter: CoordinatesRequestModel.fromJson(
    json['jailCenter'] as Map<String, dynamic>,
  ),
  jailRadiusInMeters: (json['jailRadiusInMeters'] as num).toInt(),
);

Map<String, dynamic> _$$AreaRequestModelImplToJson(
  _$AreaRequestModelImpl instance,
) => <String, dynamic>{
  'playgroundCenter': instance.playgroundCenter.toJson(),
  'playgroundRadiusInMeters': instance.playgroundRadiusInMeters,
  'jailCenter': instance.jailCenter.toJson(),
  'jailRadiusInMeters': instance.jailRadiusInMeters,
};

_$CoordinatesRequestModelImpl _$$CoordinatesRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$CoordinatesRequestModelImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$CoordinatesRequestModelImplToJson(
  _$CoordinatesRequestModelImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$GameSettingsRequestModelImpl _$$GameSettingsRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameSettingsRequestModelImpl(
  roundDurationMinutes: (json['roundDurationMinutes'] as num).toInt(),
  locationRevealIntervalMinutes: (json['locationRevealIntervalMinutes'] as num)
      .toInt(),
  policeWaitMinutes: (json['policeWaitMinutes'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
);

Map<String, dynamic> _$$GameSettingsRequestModelImplToJson(
  _$GameSettingsRequestModelImpl instance,
) => <String, dynamic>{
  'roundDurationMinutes': instance.roundDurationMinutes,
  'locationRevealIntervalMinutes': instance.locationRevealIntervalMinutes,
  'policeWaitMinutes': instance.policeWaitMinutes,
  'maxParticipants': instance.maxParticipants,
};
