import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_game_request.freezed.dart';
part 'join_game_request.g.dart';

/// 게임 참여 요청 DTO
///
/// `POST /api/games/{gameId}/participants` 요청 바디
///
/// **요청 예시**:
/// ```json
/// {
///   "inviteCode": "ABC123"
/// }
/// ```
@freezed
class JoinGameRequest with _$JoinGameRequest {
  const factory JoinGameRequest({
    /// 초대 코드
    required String inviteCode,
  }) = _JoinGameRequest;

  factory JoinGameRequest.fromJson(Map<String, dynamic> json) =>
      _$JoinGameRequestFromJson(json);
}
