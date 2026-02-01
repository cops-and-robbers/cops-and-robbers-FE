// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateSessionResponseImpl _$$CreateSessionResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreateSessionResponseImpl(
  gameId: (json['gameId'] as num).toInt(),
  inviteCode: json['inviteCode'] as String,
  status: json['status'] as String,
  roundDurationMinutes: (json['roundDurationMinutes'] as num).toInt(),
  locationShareMinutes: (json['locationShareMinutes'] as num).toInt(),
  policeWaitMinutes: (json['policeWaitMinutes'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$CreateSessionResponseImplToJson(
  _$CreateSessionResponseImpl instance,
) => <String, dynamic>{
  'gameId': instance.gameId,
  'inviteCode': instance.inviteCode,
  'status': instance.status,
  'roundDurationMinutes': instance.roundDurationMinutes,
  'locationShareMinutes': instance.locationShareMinutes,
  'policeWaitMinutes': instance.policeWaitMinutes,
  'maxParticipants': instance.maxParticipants,
  'createdAt': instance.createdAt,
};
