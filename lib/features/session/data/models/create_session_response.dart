import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_session_response.freezed.dart';
part 'create_session_response.g.dart';

/// 세션 생성 API 응답 DTO
///
/// API 서버로부터 받은 세션 생성 결과를 파싱합니다.
/// 초대 코드와 세션 ID를 포함하여 InviteCodePage로 전달됩니다.
///
/// **API 응답 예시** (v2.7.0+ — timezone suffix 포함):
/// ```json
/// {
///   "gameId": 1,
///   "inviteCode": "ABC123",
///   "status": "WAITING",
///   "roundDurationMinutes": 30,
///   "locationRevealIntervalMinutes": 5,
///   "policeWaitMinutes": 3,
///   "maxParticipants": 10,
///   "createdAt": "2026-01-16T01:25:37+09:00"
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

    /// 생성 시각 (v2.7.0부터 `+09:00` timezone suffix 포함 ISO 8601)
    ///
    /// `fromJson`은 json_serializable 기본 동작으로 String → DateTime 파싱.
    /// `toJson`은 UTC로 강제 변환하여 ISO 8601 + `Z` suffix를 보장
    /// (로컬 DateTime 직렬화 시 timezone 정보가 누락되는 문제 방지).
    @JsonKey(toJson: _dateTimeToIso) required DateTime createdAt,
  }) = _CreateSessionResponse;

  factory CreateSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionResponseFromJson(json);
}

/// DateTime → ISO 8601 (UTC `Z` suffix 포함) 직렬화 헬퍼
///
/// Why: 기본 `DateTime.toIso8601String()`은 로컬 DateTime일 때 timezone suffix를
/// 생략한다 (예: `2020-09-10T09:03:00.000`). UTC로 정규화하여 항상 timezone
/// 정보가 포함된 ISO 8601 출력을 보장한다.
String _dateTimeToIso(DateTime dt) => dt.toUtc().toIso8601String();
