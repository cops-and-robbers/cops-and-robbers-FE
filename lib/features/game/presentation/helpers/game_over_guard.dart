import 'package:cops_and_robbers/core/constants/game_status.dart';

/// 게임 종료(GameOver 결과 모달 표시) 상태에서 발생할 수 있는
/// 잘못된 자동 동작을 막기 위한 pure 가드 함수 모음.
///
/// - resume lifecycle 자동 라우팅
/// - STOMP 재연결 후 서버 상태 sync API 호출
/// - 결과 모달 콜백에서 ref/context 사용
///
/// GamePage 내부에서 `if (조건) return;` 분기 결정을 단일 책임 함수로
/// 위임해 단위 테스트로 행동을 명세화한다.
class GameOverGuard {
  GameOverGuard._();

  /// 결과 모달이 표시 중이면 lifecycle resume 트리거의 자동 라우팅을 스킵한다.
  /// 사용자 명시 선택(모달 콜백)으로만 다음 화면으로 이동하도록 한다.
  static bool shouldSkipResume({required bool gameOverDialogShown}) =>
      gameOverDialogShown;

  /// 결과 모달 표시 중에는 STOMP 재연결 후 서버 sync API를 호출하지 않는다.
  /// 게임 종료 후엔 서버가 400을 응답하므로 호출 자체를 막아 노이즈를 제거한다.
  static bool shouldSkipSync({required bool gameOverDialogShown}) =>
      gameOverDialogShown;

  /// 결과 모달 콜백 실행 시 caller(GamePage)가 dispose됐다면 ref/context 사용 금지.
  /// FCM 강퇴, 네트워크 강제 종료 등 외부 사유로 dispose된 경우의 안전망.
  static bool shouldSkipDialogCallback({required bool isMounted}) => !isMounted;

  /// GAME_OVER 이벤트를 놓친 상태에서 REST 상태만으로 게임 종료 fallback을 띄울지 판단한다.
  ///
  /// 백엔드가 결과 ID를 재조회할 수 있는 API를 제공하지 않으므로, 이 경우 승패/통계
  /// 결과 모달 대신 중립 종료 다이얼로그를 보여준다.
  static bool shouldShowMissedGameOverFallback({
    required bool isParticipating,
    required String? gameStatus,
  }) {
    return !isParticipating ||
        gameStatus == GameStatus.finished ||
        gameStatus == GameStatus.canceled;
  }

  /// 게임 상태 동기화 API가 게임 종료 후 반환하는 400인지 판단한다.
  static bool isGameNotInProgressError({
    required int? statusCode,
    required String? errorCode,
  }) {
    return statusCode == 400 && errorCode == 'GAME_NOT_IN_PROGRESS';
  }

  /// GAME_OVER 이후 "홈으로" 선택 시 서버 퇴장 API를 호출한다.
  ///
  /// 서버는 게임 종료 후 세션을 재대결용 WAITING 대기방으로 되돌리고 참가자를
  /// 유지한다. 퇴장하지 않으면 활성 게임 복귀 안전망(스플래시 복구·홈 안전망·
  /// resume 체크)이 사용자를 대기방으로 되돌리는 버그가 발생한다(실기기 재현).
  /// "한 번 더"는 대기방 잔류가 의도이므로 호출하지 않는다.
  static bool shouldRequestLeaveGameAfterGameOver() => true;
}
