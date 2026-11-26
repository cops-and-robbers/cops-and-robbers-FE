import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/server_term_compat.dart';

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
    /// 앱 값(POLICE/ROBBER)을 서버 새 값(CHASER/RUNNER)으로 보낸다 (BE #254)
    @JsonKey(toJson: toServerTeam) required String targetTeam,
  }) = _TeamChangeRequest;

  factory TeamChangeRequest.fromJson(Map<String, dynamic> json) =>
      _$TeamChangeRequestFromJson(json);
}
