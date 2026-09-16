// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_game_record_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MyGameRecordResponseModelImpl _$$MyGameRecordResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$MyGameRecordResponseModelImpl(
  nickname: json['nickname'] as String,
  team: json['team'] as String,
  status: json['status'] as String,
  arrestCount: (json['arrestCount'] as num).toInt(),
  arrestedCount: (json['arrestedCount'] as num).toInt(),
  leftAt: json['leftAt'] as String?,
);

Map<String, dynamic> _$$MyGameRecordResponseModelImplToJson(
  _$MyGameRecordResponseModelImpl instance,
) => <String, dynamic>{
  'nickname': instance.nickname,
  'team': instance.team,
  'status': instance.status,
  'arrestCount': instance.arrestCount,
  'arrestedCount': instance.arrestedCount,
  'leftAt': instance.leftAt,
};
