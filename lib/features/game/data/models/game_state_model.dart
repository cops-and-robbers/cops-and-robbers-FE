import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_state_model.freezed.dart';
part 'game_state_model.g.dart';

/// 게임 참여자 정보 DTO
///
/// `GET /api/games/{gameId}/state` 응답의 `participants` 항목.
/// team: "POLICE" | "ROBBER"
/// status: "WAITING" | "ALIVE" | "JAILED" | "POLICE_WAITING"
@freezed
class ParticipantInfoModel with _$ParticipantInfoModel {
  const factory ParticipantInfoModel({
    required int participantId,
    required String nickname,
    required String team,
    required String status,
  }) = _ParticipantInfoModel;

  factory ParticipantInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantInfoModelFromJson(json);
}

/// 마지막 공개된 도둑 위치 DTO
///
/// `GET /api/games/{gameId}/state` 응답의 `robberLocations` 항목.
/// 가장 최근 위치 공개 주기 기준 생존 도둑 위치 목록 (JAILED 제외).
@freezed
class RobberLocationInfoModel with _$RobberLocationInfoModel {
  const factory RobberLocationInfoModel({
    required int participantId,
    required String nickname,
    required double latitude,
    required double longitude,
  }) = _RobberLocationInfoModel;

  factory RobberLocationInfoModel.fromJson(Map<String, dynamic> json) =>
      _$RobberLocationInfoModelFromJson(json);
}

/// 게임 상태 응답 DTO
///
/// `GET /api/games/{gameId}/state` — 소켓 재연결 시 게임 화면 복원에 사용.
/// - robberLocations: 경찰 대기 중이거나 첫 공개 전이면 빈 배열
/// - participants: 전체 참여자 팀·상태 목록
@freezed
class GameStateModel with _$GameStateModel {
  const factory GameStateModel({
    @Default([]) List<RobberLocationInfoModel> robberLocations,
    @Default([]) List<ParticipantInfoModel> participants,
  }) = _GameStateModel;

  factory GameStateModel.fromJson(Map<String, dynamic> json) =>
      _$GameStateModelFromJson(json);
}
