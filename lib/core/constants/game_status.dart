/// 게임 진행 상태 (서버 API enum)
class GameStatus {
  GameStatus._();

  static const String waiting = 'WAITING';
  static const String inProgress = 'IN_PROGRESS';
  static const String finished = 'FINISHED';
  static const String canceled = 'CANCELED';
}
