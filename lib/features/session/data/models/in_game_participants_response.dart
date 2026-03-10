import 'package:freezed_annotation/freezed_annotation.dart';

part 'in_game_participants_response.freezed.dart';
part 'in_game_participants_response.g.dart';

/// 인게임 참가자 정보
///
/// ```json
/// { "participantId": 1, "nickname": "경찰1", "status": "POLICE_WAITING" }
/// ```
///
/// **status 값**:
/// - `POLICE_WAITING`: 경찰 대기
/// - `ALIVE`: 도둑 도주 중
/// - `JAILED`: 도둑 수감됨
@freezed
class InGameParticipant with _$InGameParticipant {
  const factory InGameParticipant({
    /// 참가자 ID
    required int participantId,

    /// 닉네임
    required String nickname,

    /// 상태 ("POLICE_WAITING" / "ALIVE" / "JAILED")
    required String status,
  }) = _InGameParticipant;

  factory InGameParticipant.fromJson(Map<String, dynamic> json) =>
      _$InGameParticipantFromJson(json);
}

/// 인게임 참가자 목록 조회 API 응답 DTO
///
/// `GET /api/games/{gameId}/participants` 응답
///
/// ```json
/// {
///   "police": [{ "participantId": 1, "nickname": "경찰1", "status": "POLICE_WAITING" }],
///   "robbers": [{ "participantId": 2, "nickname": "도둑1", "status": "ALIVE" }]
/// }
/// ```
@freezed
class InGameParticipantsResponse with _$InGameParticipantsResponse {
  const factory InGameParticipantsResponse({
    /// 경찰 목록
    required List<InGameParticipant> police,

    /// 도둑 목록
    required List<InGameParticipant> robbers,
  }) = _InGameParticipantsResponse;

  factory InGameParticipantsResponse.fromJson(Map<String, dynamic> json) =>
      _$InGameParticipantsResponseFromJson(json);
}
