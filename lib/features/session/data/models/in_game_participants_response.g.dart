// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_game_participants_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InGameParticipantImpl _$$InGameParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$InGameParticipantImpl(
  participantId: (json['participantId'] as num).toInt(),
  nickname: json['nickname'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$$InGameParticipantImplToJson(
  _$InGameParticipantImpl instance,
) => <String, dynamic>{
  'participantId': instance.participantId,
  'nickname': instance.nickname,
  'status': instance.status,
};

_$InGameParticipantsResponseImpl _$$InGameParticipantsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$InGameParticipantsResponseImpl(
  police: (json['police'] as List<dynamic>)
      .map((e) => InGameParticipant.fromJson(e as Map<String, dynamic>))
      .toList(),
  robbers: (json['robbers'] as List<dynamic>)
      .map((e) => InGameParticipant.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$InGameParticipantsResponseImplToJson(
  _$InGameParticipantsResponseImpl instance,
) => <String, dynamic>{
  'police': instance.police.map((e) => e.toJson()).toList(),
  'robbers': instance.robbers.map((e) => e.toJson()).toList(),
};
