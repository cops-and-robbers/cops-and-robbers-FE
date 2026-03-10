import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_game_response.freezed.dart';
part 'leave_game_response.g.dart';

/// 게임 퇴장 API 응답 DTO
///
/// `DELETE /api/games/{gameId}/participants` 응답
///
/// **API 응답 예시**:
/// ```json
/// {
///   "leftUserId": 2,
///   "remainingCount": 5
/// }
/// ```
@freezed
class LeaveGameResponse with _$LeaveGameResponse {
  const factory LeaveGameResponse({
    /// 퇴장한 사용자 ID
    required int leftUserId,

    /// 남은 참여자 수
    required int remainingCount,
  }) = _LeaveGameResponse;

  factory LeaveGameResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaveGameResponseFromJson(json);
}
