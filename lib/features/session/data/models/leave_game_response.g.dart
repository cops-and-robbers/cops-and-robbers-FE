// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_game_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveGameResponseImpl _$$LeaveGameResponseImplFromJson(
  Map<String, dynamic> json,
) => _$LeaveGameResponseImpl(
  leftUserId: (json['leftUserId'] as num).toInt(),
  remainingCount: (json['remainingCount'] as num).toInt(),
);

Map<String, dynamic> _$$LeaveGameResponseImplToJson(
  _$LeaveGameResponseImpl instance,
) => <String, dynamic>{
  'leftUserId': instance.leftUserId,
  'remainingCount': instance.remainingCount,
};
