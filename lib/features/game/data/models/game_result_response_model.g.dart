// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameResultResponseModelImpl _$$GameResultResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameResultResponseModelImpl(
  winnerTeam: json['winnerTeam'] as String,
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  totalArrestCount: (json['totalArrestCount'] as num).toInt(),
  remainingRobberCount: (json['remainingRobberCount'] as num).toInt(),
);

Map<String, dynamic> _$$GameResultResponseModelImplToJson(
  _$GameResultResponseModelImpl instance,
) => <String, dynamic>{
  'winnerTeam': instance.winnerTeam,
  'durationSeconds': instance.durationSeconds,
  'totalArrestCount': instance.totalArrestCount,
  'remainingRobberCount': instance.remainingRobberCount,
};
