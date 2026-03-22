import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_game_status_model.freezed.dart';
part 'user_game_status_model.g.dart';

/// 참여 중인 게임 정보 조회 응답 DTO
///
/// `GET /api/user/me/game` 응답 최상위 객체.
/// [isParticipating]이 false이면 [participationInfo]는 null.
@freezed
class UserGameStatusModel with _$UserGameStatusModel {
  const factory UserGameStatusModel({
    required bool isParticipating,
    UserGameParticipationModel? participationInfo,
  }) = _UserGameStatusModel;

  factory UserGameStatusModel.fromJson(Map<String, dynamic> json) =>
      _$UserGameStatusModelFromJson(json);
}

/// 참여 중인 게임의 상세 정보 DTO
@freezed
class UserGameParticipationModel with _$UserGameParticipationModel {
  const factory UserGameParticipationModel({
    required int gameId,
    required int participantId,

    /// 게임 상태. `WAITING` | `IN_PROGRESS`
    required String gameStatus,

    /// 팀. `POLICE` | `ROBBER`
    required String team,
  }) = _UserGameParticipationModel;

  factory UserGameParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$UserGameParticipationModelFromJson(json);
}
