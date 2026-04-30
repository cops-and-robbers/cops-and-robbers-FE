/// 튜토리얼 화면별 SharedPreferences 키 상수
class TutorialKeys {
  TutorialKeys._();

  static const home = 'tutorial_home';
  static const createStep0 = 'tutorial_create_step0';
  static const setupPlayground = 'tutorial_setup_playground';
  static const createStep2 = 'tutorial_create_step2';

  // 대기실 튜토리얼: 팀별로 1회씩 노출되도록 키를 분리.
  // 경찰 시점과 도둑 시점은 타겟 위젯(반대 팀 첫 슬롯)이 물리적으로 달라서
  // 같은 키 하나로 묶으면 한쪽을 본 사용자에게 반대편 안내가 사라진다.
  static const waitingRoomPolice = 'tutorial_waiting_room_police';
  static const waitingRoomRobber = 'tutorial_waiting_room_robber';

  static const game = 'tutorial_game';
  static const gameParticipants = 'tutorial_game_participants';

  // 게임 진입 시 1회성 배터리 안내 다이얼로그 — 튜토리얼은 아니지만
  // "1회만 표시 + 초기화로 재노출" 정책이 동일하므로 같이 관리.
  static const batteryOptNotice = 'tutorial_battery_opt_notice';
  static const batteryImpactNotice = 'tutorial_battery_impact_notice';

  /// 팀 문자열('POLICE' | 'ROBBER')에 대응하는 대기실 튜토리얼 키.
  /// 알 수 없는 값/`null`은 `null`을 반환하므로 호출부에서 가드해야 한다.
  static String? waitingRoomByTeam(String? team) {
    if (team == 'POLICE') return waitingRoomPolice;
    if (team == 'ROBBER') return waitingRoomRobber;
    return null;
  }

  /// 전체 키 목록 (초기화 시 사용)
  static const all = [
    home,
    createStep0,
    setupPlayground,
    createStep2,
    waitingRoomPolice,
    waitingRoomRobber,
    game,
    gameParticipants,
    batteryOptNotice,
    batteryImpactNotice,
  ];
}
