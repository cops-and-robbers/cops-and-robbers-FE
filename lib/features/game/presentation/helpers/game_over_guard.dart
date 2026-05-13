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
}
