import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_change_request.freezed.dart';
part 'team_change_request.g.dart';

/// 팀 변경 요청 DTO
///
/// `PATCH /api/games/{gameId}/lobby/team` 요청 바디
///
/// **요청 예시**:
/// ```json
/// {
///   "targetTeam": "POLICE"
/// }
/// ```
@freezed
class TeamChangeRequest with _$TeamChangeRequest {
  const factory TeamChangeRequest({
    /// 변경할 팀 ("POLICE" 또는 "ROBBER")
    required String targetTeam,
  }) = _TeamChangeRequest;

  factory TeamChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$TeamChangeRequestFromJson(json);
}
