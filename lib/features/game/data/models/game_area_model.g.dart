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

_$RobberLocationModelImpl _$$RobberLocationModelImplFromJson(
  Map<String, dynamic> json,
) => _$RobberLocationModelImpl(
  participantId: (json['participantId'] as num).toInt(),
  nickname: json['nickname'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$RobberLocationModelImplToJson(
  _$RobberLocationModelImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'nickname': instance.nickname,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$GameAreaModelImpl _$$GameAreaModelImplFromJson(Map<String, dynamic> json) =>
    _$GameAreaModelImpl(
      playgroundCenter: LatLngModel.fromJson(
        json['playgroundCenter'] as Map<String, dynamic>,
      ),
      playgroundRadiusInMeters: (json['playgroundRadiusInMeters'] as num)
          .toDouble(),
      jailCenter: LatLngModel.fromJson(
        json['jailCenter'] as Map<String, dynamic>,
      ),
      jailRadiusInMeters: (json['jailRadiusInMeters'] as num).toDouble(),
    );

Map<String, dynamic> _$$GameAreaModelImplToJson(_$GameAreaModelImpl instance) =>
    <String, dynamic>{
      'playgroundCenter': instance.playgroundCenter.toJson(),
      'playgroundRadiusInMeters': instance.playgroundRadiusInMeters,
      'jailCenter': instance.jailCenter.toJson(),
      'jailRadiusInMeters': instance.jailRadiusInMeters,
    };
