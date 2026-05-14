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
///   "maxParticipants": 10,
///   "gameStartTime": "2026-03-21T15:30:00+09:00"
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

    /// 게임 시작 시각 (ISO 8601, IN_PROGRESS 상태일 때만 non-null)
    ///
    /// v2.7.0부터 `+09:00` timezone suffix 포함. 소비 시 `IsoTimestampParser`
    /// 또는 `DateTime.parse(...).toLocal()`로 단말 local 시간 정규화.
    String? gameStartTime,
  }) = _GameSettingsResponse;

  factory GameSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsResponseFromJson(json);
}
