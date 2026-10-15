import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/game_result_entity.dart';

part 'game_result_response_model.freezed.dart';
part 'game_result_response_model.g.dart';

/// 게임 결과 조회 응답 DTO
///
/// `GET /api/game-results/{gameResultId}` 응답 (200)
///
/// **응답 예시**:
/// ```json
/// {
///   "winnerTeam": "POLICE",
///   "durationSeconds": 300,
///   "totalArrestCount": 5,
///   "remainingRobberCount": 1,
///   "policeMvp": { "nickname": "번개경찰" },
///   "robberMvp": { "nickname": "그림자" }
/// }
/// ```
@freezed
class GameResultResponseModel with _$GameResultResponseModel {
  const factory GameResultResponseModel({
    /// 승리 팀 ("POLICE" | "ROBBER")
    required String winnerTeam,

    /// 게임 진행 시간(초)
    required int durationSeconds,

    /// 총 체포 횟수
    required int totalArrestCount,

    /// 남은 도둑 수
    required int remainingRobberCount,

    /// 팀 MVP (BE #212). 팀당 1명이고, 후보가 없거나(전원 중도 퇴장)
    /// 필드가 없는 구버전 서버 응답이면 null이다.
    GameMvpModel? policeMvp,
    GameMvpModel? robberMvp,
  }) = _GameResultResponseModel;

  factory GameResultResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GameResultResponseModelFromJson(json);
}

/// 팀 MVP 한 명 — 화면에는 닉네임만 쓴다.
@freezed
class GameMvpModel with _$GameMvpModel {
  const factory GameMvpModel({required String nickname}) = _GameMvpModel;

  factory GameMvpModel.fromJson(Map<String, dynamic> json) =>
      _$GameMvpModelFromJson(json);
}

/// DTO → Entity. MVP는 판정을 서버가 하므로 앱은 닉네임만 그대로 옮긴다.
extension GameResultResponseModelX on GameResultResponseModel {
  GameResultEntity toEntity() => GameResultEntity(
    winnerTeam: winnerTeam,
    durationSeconds: durationSeconds,
    totalArrestCount: totalArrestCount,
    remainingRobberCount: remainingRobberCount,
    policeMvpNickname: policeMvp?.nickname,
    robberMvpNickname: robberMvp?.nickname,
  );
}
