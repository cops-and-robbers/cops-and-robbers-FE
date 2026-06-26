import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _JoinGameResponse;

  factory JoinGameResponse.fromJson(Map<String, dynamic> json) =>
      _$JoinGameResponseFromJson(json);
}
