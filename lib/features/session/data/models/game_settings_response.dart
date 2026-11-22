import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/game_mode.dart';

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

    /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false) — 콜드 재진입 복원용
    @Default(false) bool isEventGame,

    /// 구역 축소 최종 반경(m). null이면 꺼짐 (#668, BE v3.1.0)
    int? shrinkFinalRadiusInMeters,

    /// 방장이 무전을 켰는지. 키가 없는 응답(구버전 서버·예전 방)은 꺼짐 (#723)
    @Default(false) bool radioEnabled,

    /// 게임 모드. 키가 없는 구버전 응답은 경찰과 도둑, 모르는 값은 unknown
    @JsonKey(fromJson: GameMode.fromJson, toJson: _modeToJson)
    @Default(GameMode.copsAndRobbers)
    GameMode gameMode,
  }) = _GameSettingsResponse;

  factory GameSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsResponseFromJson(json);
}

String _modeToJson(GameMode mode) => mode.toJson();
