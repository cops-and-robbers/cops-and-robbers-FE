/// 튜토리얼 화면별 SharedPreferences 키 상수
class TutorialKeys {
  TutorialKeys._();

  static const home = 'tutorial_home';
  static const createStep0 = 'tutorial_create_step0';
  static const setupPlayground = 'tutorial_setup_playground';
  static const createStep2 = 'tutorial_create_step2';
  static const waitingRoom = 'tutorial_waiting_room';
  static const game = 'tutorial_game';

  /// 전체 키 목록 (초기화 시 사용)
  static const all = [
    home,
    createStep0,
    setupPlayground,
    createStep2,
    waitingRoom,
    game,
  ];
}
