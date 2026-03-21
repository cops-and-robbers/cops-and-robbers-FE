// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_game_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserGameStatusModelImpl _$$UserGameStatusModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserGameStatusModelImpl(
  isParticipating: json['isParticipating'] as bool,
  participationInfo: json['participationInfo'] == null
      ? null
      : UserGameParticipationModel.fromJson(
          json['participationInfo'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$UserGameStatusModelImplToJson(
  _$UserGameStatusModelImpl instance,
) => <String, dynamic>{
  'isParticipating': instance.isParticipating,
  'participationInfo': instance.participationInfo?.toJson(),
};

_$UserGameParticipationModelImpl _$$UserGameParticipationModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserGameParticipationModelImpl(
  gameId: (json['gameId'] as num).toInt(),
  participantId: (json['participantId'] as num).toInt(),
  gameStatus: json['gameStatus'] as String,
  team: json['team'] as String,
);

Map<String, dynamic> _$$UserGameParticipationModelImplToJson(
  _$UserGameParticipationModelImpl instance,
) => <String, dynamic>{
  'gameId': instance.gameId,
  'participantId': instance.participantId,
  'gameStatus': instance.gameStatus,
  'team': instance.team,
};
