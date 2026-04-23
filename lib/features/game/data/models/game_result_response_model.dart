import 'package:freezed_annotation/freezed_annotation.dart';

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
///   "remainingRobberCount": 1
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
  }) = _GameResultResponseModel;

  factory GameResultResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GameResultResponseModelFromJson(json);
}
