import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/game_mode.dart';

part 'join_game_response.freezed.dart';
part 'join_game_response.g.dart';

/// 게임 참여 응답 DTO
///
/// `POST /api/games/{gameId}/participants` 응답
///
/// **응답 예시**:
/// ```json
/// {
///   "gameId": 1,
///   "participantId": 2
/// }
/// ```
@freezed
class JoinGameResponse with _$JoinGameResponse {
  const factory JoinGameResponse({
    /// 게임 ID
    required int gameId,

    /// 참여자 ID
    required int participantId,

    /// 이벤트 게임 여부 (백엔드 신규 필드, 미포함 시 false)
    @Default(false) bool isEventGame,

    /// 게임 모드 (BE #232). 키가 없으면 경찰과 도둑, 모르는 값은 unknown
    @JsonKey(fromJson: GameMode.fromJson, toJson: _modeToJson)
    @Default(GameMode.copsAndRobbers)
    GameMode gameMode,
  }) = _JoinGameResponse;

  factory JoinGameResponse.fromJson(Map<String, dynamic> json) =>
      _$JoinGameResponseFromJson(json);
}

String _modeToJson(GameMode mode) => mode.toJson();
