// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportRequestModelImpl _$$ReportRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$ReportRequestModelImpl(
  gameId: (json['gameId'] as num).toInt(),
  reportedParticipantId: (json['reportedParticipantId'] as num).toInt(),
  messageContent: json['messageContent'] as String,
  reportType: json['reportType'] as String,
  etcReason: json['etcReason'] as String?,
);

Map<String, dynamic> _$$ReportRequestModelImplToJson(
  _$ReportRequestModelImpl instance,
) => <String, dynamic>{
  'gameId': instance.gameId,
  'reportedParticipantId': instance.reportedParticipantId,
  'messageContent': instance.messageContent,
  'reportType': instance.reportType,
  'etcReason': instance.etcReason,
};
