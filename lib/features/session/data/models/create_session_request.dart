import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_session_request.freezed.dart';
part 'create_session_request.g.dart';

/// 세션 생성 API 요청 DTO
///
/// 로컬 저장소의 SessionCreationDraftModel 데이터를
/// API 서버가 기대하는 형식으로 변환하여 전송합니다.
///
/// **사용 예시**:
/// ```dart
/// final draft = await storageService.loadDraft();
/// final request = CreateSessionRequest(
///   playgroundLatitude: draft.playgroundCenter!.latitude,
///   playgroundLongitude: draft.playgroundCenter!.longitude,
///   // ...
/// );
/// ```
@freezed
class CreateSessionRequest with _$CreateSessionRequest {
  const factory CreateSessionRequest({
    /// 플레이그라운드 중심 위도
    required double playgroundLatitude,

    /// 플레이그라운드 중심 경도
    required double playgroundLongitude,

    /// 플레이그라운드 반경 (미터)
    required double playgroundRadiusInMeters,

    /// 감옥 중심 위도
    required double jailLatitude,

    /// 감옥 중심 경도
    required double jailLongitude,

    /// 감옥 반경 (미터)
    required double jailRadiusInMeters,

    /// 라운드 시간 (분)
    required int roundDurationMinutes,

    /// 위치 공유 간격 (분)
    required int locationShareMinutes,

    /// 경찰 대기 시간 (분)
    required int policeWaitMinutes,

    /// 최대 참가자 수
    required int maxParticipants,
  }) = _CreateSessionRequest;

  factory CreateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionRequestFromJson(json);
}
