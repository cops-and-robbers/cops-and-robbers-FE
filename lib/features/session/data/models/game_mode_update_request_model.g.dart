// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_mode_update_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameModeUpdateRequestModelImpl _$$GameModeUpdateRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameModeUpdateRequestModelImpl(
  gameMode: GameMode.fromJson(json['gameMode'] as String?),
  area: GameAreaRequestModel.fromJson(json['area'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$GameModeUpdateRequestModelImplToJson(
  _$GameModeUpdateRequestModelImpl instance,
) => <String, dynamic>{
  'gameMode': gameModeToJson(instance.gameMode),
  'area': instance.area.toJson(),
};
