/// 튜토리얼 화면별 SharedPreferences 키 상수
class TutorialKeys {
  TutorialKeys._();

  static const home = 'tutorial_home';
  static const setupPlayground = 'tutorial_setup_playground';

  // 대기실 튜토리얼: 역할(경찰/도둑) 무관 사용자당 1회만 노출.
  // 모든 스텝(팀 변경·초대 코드·게임 설정·준비 버튼)이 양 팀에서 동일한
  // 안내이므로 팀별 분리가 불필요. 1번 스텝 타겟만 "현재 팀의 반대 팀 첫
  // 빈 슬롯"으로 호출 시점의 team 값으로 결정된다(키와 무관).
  static const waitingRoom = 'tutorial_waiting_room';

  // 대기방 코치마크 완료 후 인게임 튜토리얼 페이지 안내 다이얼로그를
  // 1회만 노출하기 위한 키. "튜토리얼 초기화" 시 함께 reset되어 재노출됨.
  static const inGamePrompt = 'tutorial_in_game_prompt';

  /// 전체 키 목록 (초기화 시 사용)
  static const all = [home, setupPlayground, waitingRoom, inGamePrompt];
}
