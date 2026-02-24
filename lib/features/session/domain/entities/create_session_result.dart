import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_session_result.freezed.dart';

/// 게임 방 생성 결과 엔티티
///
/// API 응답에서 비즈니스에 필요한 핵심 필드만 추출한 Domain 엔티티입니다.
/// 서버에서만 생성되는 값(`gameId`, `inviteCode`, `status`)을 포함합니다.
///
/// **사용 위치**:
/// - `SessionRepository` 반환 타입
/// - `SessionCreationNotifier` 상태 값
/// - `SessionCreationFlowPage`에서 대기실 이동 및 초대 코드 표시
@freezed
class CreateSessionResult with _$CreateSessionResult {
  const factory CreateSessionResult({
    /// 게임 세션 ID
    required int gameId,

    /// 초대 코드 (예: "ABC123")
    required String inviteCode,

    /// 세션 상태 (예: "WAITING")
    required String status,

    /// 최대 참가 인원
    required int maxParticipants,

    /// 위치 공개 주기 (분)
    required int locationRevealIntervalMinutes,
  }) = _CreateSessionResult;
}
