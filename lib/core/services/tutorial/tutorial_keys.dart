/// 튜토리얼 화면별 SharedPreferences 키 상수
class TutorialKeys {
  TutorialKeys._();

  static const home = 'tutorial_home';
  static const createStep0 = 'tutorial_create_step0';
  static const setupPlayground = 'tutorial_setup_playground';
  static const createStep2 = 'tutorial_create_step2';

  // 대기실 튜토리얼: 역할(경찰/도둑) 무관 사용자당 1회만 노출.
  // 모든 스텝(팀 변경·초대 코드·게임 설정·준비 버튼)이 양 팀에서 동일한
  // 안내이므로 팀별 분리가 불필요. 1번 스텝 타겟만 "현재 팀의 반대 팀 첫
  // 빈 슬롯"으로 호출 시점의 team 값으로 결정된다(키와 무관).
  static const waitingRoom = 'tutorial_waiting_room';

  /// 전체 키 목록 (초기화 시 사용)
  static const all = [
    home,
    createStep0,
    setupPlayground,
    createStep2,
    waitingRoom,
  ];
}
