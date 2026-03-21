import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_game_status_entity.freezed.dart';

/// 참여 중인 게임 상태 엔티티
///
/// [isParticipating]이 false이면 [participationInfo]는 null.
@freezed
class UserGameStatusEntity with _$UserGameStatusEntity {
  const factory UserGameStatusEntity({
    required bool isParticipating,
    UserGameParticipationEntity? participationInfo,
  }) = _UserGameStatusEntity;
}

/// 참여 중인 게임의 상세 정보 엔티티
@freezed
class UserGameParticipationEntity with _$UserGameParticipationEntity {
  const factory UserGameParticipationEntity({
    required int gameId,
    required int participantId,

    /// 게임 상태. `WAITING` | `IN_PROGRESS`
    required String gameStatus,

    /// 팀. `POLICE` | `ROBBER`
    required String team,
  }) = _UserGameParticipationEntity;
}
