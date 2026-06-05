import 'package:freezed_annotation/freezed_annotation.dart';

part 'ping_message_dto.freezed.dart';
part 'ping_message_dto.g.dart';

/// 서버 핑 수신 payload (`/subscribe/game/{gameId}/ping/{team}`)
@freezed
class PingMessageDto with _$PingMessageDto {
  const factory PingMessageDto({
    required String id, // 서버 UUID
    required int gameId,
    required String pingType, // "FOUND" | "SUSPECT" | "HELP" — String으로 받는다
    required PingLocationDto location,
    required PingSenderDto pingSender,
    required String timestamp, // KST ISO 8601
  }) = _PingMessageDto;

  factory PingMessageDto.fromJson(Map<String, dynamic> json) =>
      _$PingMessageDtoFromJson(json);
}

/// 핑 위치 정보 DTO
@freezed
class PingLocationDto with _$PingLocationDto {
  const factory PingLocationDto({
    required double latitude,
    required double longitude,
  }) = _PingLocationDto;

  factory PingLocationDto.fromJson(Map<String, dynamic> json) =>
      _$PingLocationDtoFromJson(json);
}

/// 핑 발신자 정보 DTO
@freezed
class PingSenderDto with _$PingSenderDto {
  const factory PingSenderDto({
    required int participantId,
    required String nickname,
  }) = _PingSenderDto;

  factory PingSenderDto.fromJson(Map<String, dynamic> json) =>
      _$PingSenderDtoFromJson(json);
}
