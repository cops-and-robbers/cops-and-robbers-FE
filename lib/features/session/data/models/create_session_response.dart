import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_session_response.freezed.dart';
part 'create_session_response.g.dart';

/// 세션 생성 API 응답 DTO
///
/// API 서버로부터 받은 세션 생성 결과를 파싱합니다.
/// 초대 코드와 세션 ID를 포함하여 InviteCodePage로 전달됩니다.
///
/// **API 응답 예시**:
/// ```json
/// {
///   "gameId": 1,
///   "inviteCode": "ABC123",
///   "status": "WAITING",
///   "roundDurationMinutes": 30,
///   "locationRevealIntervalMinutes": 5,
///   "policeWaitMinutes": 3,
///   "maxParticipants": 10,
///   "createdAt": "2026-01-16T01:25:37.543066"
/// }
/// ```
@freezed
class CreateSessionResponse with _$CreateSessionResponse {
  const factory CreateSessionResponse({
    /// 게임 세션 ID
    required int gameId,

    /// 초대 코드 (예: "ABC123")
    required String inviteCode,

    /// 세션 상태 (예: "WAITING")
    required String status,

    /// 라운드 시간 (분)
    required int roundDurationMinutes,

    /// 위치 공개 주기 (분)
    required int locationRevealIntervalMinutes,

    /// 경찰 대기 시간 (분)
    required int policeWaitMinutes,

    /// 최대 참가자 수
    required int maxParticipants,

    /// 생성 시각 (ISO 8601 형식)
    required String createdAt,
  }) = _CreateSessionResponse;

  factory CreateSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionResponseFromJson(json);
}
