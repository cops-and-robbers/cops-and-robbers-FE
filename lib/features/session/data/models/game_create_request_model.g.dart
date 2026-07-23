// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameCreateRequestModelImpl _$$GameCreateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameCreateRequestModelImpl(
  area: GameAreaRequestModel.fromJson(json['area'] as Map<String, dynamic>),
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

_$GameAreaRequestModelImpl _$$GameAreaRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameAreaRequestModelImpl(
  areaType: $enumDecode(_$GameAreaTypeEnumMap, json['areaType']),
  circle: json['circle'] == null
      ? null
      : CircleAreaRequestModel.fromJson(json['circle'] as Map<String, dynamic>),
  polygon: json['polygon'] == null
      ? null
      : PolygonAreaRequestModel.fromJson(
          json['polygon'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$GameAreaRequestModelImplToJson(
  _$GameAreaRequestModelImpl instance,
) => <String, dynamic>{
  'areaType': _$GameAreaTypeEnumMap[instance.areaType]!,
  if (instance.circle?.toJson() case final value?) 'circle': value,
  if (instance.polygon?.toJson() case final value?) 'polygon': value,
};

const _$GameAreaTypeEnumMap = {
  GameAreaType.circle: 'CIRCLE',
  GameAreaType.polygon: 'POLYGON',
};

_$CircleAreaRequestModelImpl _$$CircleAreaRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$CircleAreaRequestModelImpl(
  playgroundCenter: CoordinatesRequestModel.fromJson(
    json['playgroundCenter'] as Map<String, dynamic>,
  ),
  playgroundRadiusInMeters: (json['playgroundRadiusInMeters'] as num).toInt(),
  jailCenter: CoordinatesRequestModel.fromJson(
    json['jailCenter'] as Map<String, dynamic>,
  ),
  jailRadiusInMeters: (json['jailRadiusInMeters'] as num).toInt(),
);

Map<String, dynamic> _$$CircleAreaRequestModelImplToJson(
  _$CircleAreaRequestModelImpl instance,
) => <String, dynamic>{
  'playgroundCenter': instance.playgroundCenter.toJson(),
  'playgroundRadiusInMeters': instance.playgroundRadiusInMeters,
  'jailCenter': instance.jailCenter.toJson(),
  'jailRadiusInMeters': instance.jailRadiusInMeters,
};

_$PolygonAreaRequestModelImpl _$$PolygonAreaRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$PolygonAreaRequestModelImpl(
  playgroundPolygon: (json['playgroundPolygon'] as List<dynamic>)
      .map((e) => CoordinatesRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  jailPolygon: (json['jailPolygon'] as List<dynamic>)
      .map((e) => CoordinatesRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$PolygonAreaRequestModelImplToJson(
  _$PolygonAreaRequestModelImpl instance,
) => <String, dynamic>{
  'playgroundPolygon': instance.playgroundPolygon
      .map((e) => e.toJson())
      .toList(),
  'jailPolygon': instance.jailPolygon.map((e) => e.toJson()).toList(),
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
