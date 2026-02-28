// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lobby_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LobbyInfoResponseImpl _$$LobbyInfoResponseImplFromJson(
  Map<String, dynamic> json,
) => _$LobbyInfoResponseImpl(
  myParticipantId: (json['myParticipantId'] as num).toInt(),
  hostParticipantId: (json['hostParticipantId'] as num).toInt(),
  participants: (json['participants'] as List<dynamic>)
      .map((e) => LobbyParticipantInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$LobbyInfoResponseImplToJson(
  _$LobbyInfoResponseImpl instance,
) => <String, dynamic>{
  'myParticipantId': instance.myParticipantId,
  'hostParticipantId': instance.hostParticipantId,
  'participants': instance.participants.map((e) => e.toJson()).toList(),
};
