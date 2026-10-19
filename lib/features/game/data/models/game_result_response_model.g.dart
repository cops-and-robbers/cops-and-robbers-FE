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
  policeMvp: json['policeMvp'] == null
      ? null
      : GameMvpModel.fromJson(json['policeMvp'] as Map<String, dynamic>),
  robberMvp: json['robberMvp'] == null
      ? null
      : GameMvpModel.fromJson(json['robberMvp'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$GameResultResponseModelImplToJson(
  _$GameResultResponseModelImpl instance,
) => <String, dynamic>{
  'winnerTeam': instance.winnerTeam,
  'durationSeconds': instance.durationSeconds,
  'totalArrestCount': instance.totalArrestCount,
  'remainingRobberCount': instance.remainingRobberCount,
  'policeMvp': instance.policeMvp?.toJson(),
  'robberMvp': instance.robberMvp?.toJson(),
};

_$GameMvpModelImpl _$$GameMvpModelImplFromJson(Map<String, dynamic> json) =>
    _$GameMvpModelImpl(nickname: json['nickname'] as String);

Map<String, dynamic> _$$GameMvpModelImplToJson(_$GameMvpModelImpl instance) =>
    <String, dynamic>{'nickname': instance.nickname};
