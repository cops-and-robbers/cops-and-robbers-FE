import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_settings_response.freezed.dart';
part 'game_settings_response.g.dart';

/// 게임 설정 조회 API 응답 DTO
///
/// `GET /api/games/{gameId}` 응답
///
/// ```json
/// {
///   "roundDurationMinutes": 30,
///   "locationRevealIntervalMinutes": 2,
///   "policeWaitMinutes": 3,
///   "maxParticipants": 10
/// }
/// ```
@freezed
class GameSettingsResponse with _$GameSettingsResponse {
  const factory GameSettingsResponse({
    /// 라운드 시간 (분)
    required int roundDurationMinutes,

    /// 위치 공개 주기 (분)
    required int locationRevealIntervalMinutes,

    /// 경찰 대기 시간 (분)
    required int policeWaitMinutes,

    /// 최대 참가자 수
    required int maxParticipants,
  }) = _GameSettingsResponse;

  factory GameSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsResponseFromJson(json);
}
