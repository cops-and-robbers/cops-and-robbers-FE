import 'package:freezed_annotation/freezed_annotation.dart';

part 'lobby_event_dto.freezed.dart';
part 'lobby_event_dto.g.dart';

/// 로비 이벤트 DTO
///
/// STOMP `/subscribe/game/{gameId}/lobby` 구독으로 수신되는 이벤트
///
/// ```json
/// {
///   "eventId": "uuid-random-string",
///   "gameId": 1,
///   "type": "GAME_START",
///   "timestamp": "2024-01-08T14:10:00",
///   "data": { ... }
/// }
/// ```
@freezed
class LobbyEventDto with _$LobbyEventDto {
  const factory LobbyEventDto({
    required String eventId,
    required int gameId,
    required String type,
    required String timestamp,
    @Default({}) Map<String, dynamic> data,
  }) = _LobbyEventDto;

  factory LobbyEventDto.fromJson(Map<String, dynamic> json) =>
      _$LobbyEventDtoFromJson(json);
}

/// 로비 이벤트 타입
abstract class LobbyEventType {
  /// 유저 입장
  static const String enter = 'ENTER';

  /// 유저 퇴장
  static const String exit = 'EXIT';

  /// 팀 변경
  static const String teamUpdate = 'TEAM_UPDATE';

  /// 준비 상태 변경
  static const String readyUpdate = 'READY_UPDATE';

  /// 방장 변경
  static const String hostChanged = 'HOST_CHANGED';

  /// 게임 시작
  static const String gameStart = 'GAME_START';

  /// 게임 설정 변경
  static const String settingsUpdated = 'SETTINGS_UPDATED';

  /// 게임 영역 변경
  static const String areaUpdated = 'AREA_UPDATED';
}

/// GAME_START 이벤트 data
///
/// ```json
/// {
///   "message": "시작 멘트",
///   "startTime": "2026-01-29T01:40:05"
/// }
/// ```
@freezed
class GameStartData with _$GameStartData {
  const factory GameStartData({
    required String message,
    required String startTime,
  }) = _GameStartData;

  factory GameStartData.fromJson(Map<String, dynamic> json) =>
      _$GameStartDataFromJson(json);
}

/// 로비 참가자 정보
///
/// ```json
/// {
///   "participantId": 202,
///   "nickname": "뉴비도둑",
///   "team": "ROBBER",
///   "isReady": false
/// }
/// ```
@freezed
class LobbyParticipantInfo with _$LobbyParticipantInfo {
  const factory LobbyParticipantInfo({
    required int participantId,
    required String nickname,
    required String team,
    required bool isReady,
  }) = _LobbyParticipantInfo;

  factory LobbyParticipantInfo.fromJson(Map<String, dynamic> json) =>
      _$LobbyParticipantInfoFromJson(json);
}
