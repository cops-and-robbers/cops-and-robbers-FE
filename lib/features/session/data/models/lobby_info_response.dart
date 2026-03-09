import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../lobby/data/models/lobby_event_dto.dart';

part 'lobby_info_response.freezed.dart';
part 'lobby_info_response.g.dart';

/// 로비 조회 API 응답 DTO
///
/// `GET /api/games/{gameId}/lobby` 응답
///
/// ```json
/// {
///   "myParticipantId": 1,
///   "hostParticipantId": 1,
///   "participants": [{ "participantId": 1, "nickname": "...", "team": "POLICE", "isReady": false }]
/// }
/// ```
///
/// 게임 기본 설정(maxParticipants, locationRevealIntervalMinutes 등)은
/// `GET /api/games/{gameId}` ([GameSettingsResponse])로 별도 조회합니다.
@freezed
class LobbyInfoResponse with _$LobbyInfoResponse {
  const factory LobbyInfoResponse({
    /// 내 participantId
    required int myParticipantId,

    /// 방장 participantId
    required int hostParticipantId,

    /// 전체 참가자 목록
    required List<LobbyParticipantInfo> participants,
  }) = _LobbyInfoResponse;

  factory LobbyInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$LobbyInfoResponseFromJson(json);
}
