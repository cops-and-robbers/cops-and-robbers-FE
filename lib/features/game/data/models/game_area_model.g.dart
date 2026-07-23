// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_area_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LatLngModelImpl _$$LatLngModelImplFromJson(Map<String, dynamic> json) =>
    _$LatLngModelImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$$LatLngModelImplToJson(_$LatLngModelImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$CircleAreaModelImpl _$$CircleAreaModelImplFromJson(
  Map<String, dynamic> json,
) => _$CircleAreaModelImpl(
  playgroundCenter: LatLngModel.fromJson(
    json['playgroundCenter'] as Map<String, dynamic>,
  ),
  playgroundRadiusInMeters: (json['playgroundRadiusInMeters'] as num)
      .toDouble(),
  jailCenter: LatLngModel.fromJson(json['jailCenter'] as Map<String, dynamic>),
  jailRadiusInMeters: (json['jailRadiusInMeters'] as num).toDouble(),
);

Map<String, dynamic> _$$CircleAreaModelImplToJson(
  _$CircleAreaModelImpl instance,
) => <String, dynamic>{
  'playgroundCenter': instance.playgroundCenter.toJson(),
  'playgroundRadiusInMeters': instance.playgroundRadiusInMeters,
  'jailCenter': instance.jailCenter.toJson(),
  'jailRadiusInMeters': instance.jailRadiusInMeters,
};

_$PolygonAreaModelImpl _$$PolygonAreaModelImplFromJson(
  Map<String, dynamic> json,
) => _$PolygonAreaModelImpl(
  playgroundPolygon: (json['playgroundPolygon'] as List<dynamic>)
      .map((e) => LatLngModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  jailPolygon: (json['jailPolygon'] as List<dynamic>)
      .map((e) => LatLngModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$PolygonAreaModelImplToJson(
  _$PolygonAreaModelImpl instance,
) => <String, dynamic>{
  'playgroundPolygon': instance.playgroundPolygon
      .map((e) => e.toJson())
      .toList(),
  'jailPolygon': instance.jailPolygon.map((e) => e.toJson()).toList(),
};

_$GameAreaModelImpl _$$GameAreaModelImplFromJson(Map<String, dynamic> json) =>
    _$GameAreaModelImpl(
      areaType: $enumDecode(_$GameAreaTypeEnumMap, json['areaType']),
      circle: json['circle'] == null
          ? null
          : CircleAreaModel.fromJson(json['circle'] as Map<String, dynamic>),
      polygon: json['polygon'] == null
          ? null
          : PolygonAreaModel.fromJson(json['polygon'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GameAreaModelImplToJson(_$GameAreaModelImpl instance) =>
    <String, dynamic>{
      'areaType': _$GameAreaTypeEnumMap[instance.areaType]!,
      'circle': instance.circle?.toJson(),
      'polygon': instance.polygon?.toJson(),
    };

const _$GameAreaTypeEnumMap = {
  GameAreaType.circle: 'CIRCLE',
  GameAreaType.polygon: 'POLYGON',
};
