/// 진동 피드백 패턴 상수
///
/// 이벤트별 고유 진동 패턴(duration, amplitude, pattern, intensities)을 정의한다.
/// 피드백 후 수정이 용이하도록 중앙 관리.
abstract final class VibrationPatterns {
  // ═══════════════════════════════════════════════════════════════════════
  // 채팅 — 메시지 수신
  // ═══════════════════════════════════════════════════════════════════════

  static const int messageReceivedDuration = 100;
  static const int messageReceivedAmplitude = 80;

  // ═══════════════════════════════════════════════════════════════════════
  // 대기방 — 플레이어 입장/퇴장
  // ═══════════════════════════════════════════════════════════════════════

  static const int playerJoinLeaveDuration = 80;
  static const int playerJoinLeaveAmplitude = 60;

  // ═══════════════════════════════════════════════════════════════════════
  // 대기방 — 게임 시작 (리듬 패턴)
  // ═══════════════════════════════════════════════════════════════════════

  static const List<int> gameStartPattern = [0, 200, 100, 200, 100, 500];
  static const List<int> gameStartIntensities = [0, 200, 0, 200, 0, 255];

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임 — 체포
  // ═══════════════════════════════════════════════════════════════════════

  static const int arrestedDuration = 500;
  static const int arrestedAmplitude = 255;

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임 — 탈옥 (연속 2회)
  // ═══════════════════════════════════════════════════════════════════════

  static const List<int> escapedPattern = [0, 200, 100, 200];
  static const List<int> escapedIntensities = [0, 200, 0, 200];

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임 — 위치 공개
  // ═══════════════════════════════════════════════════════════════════════

  static const int locationRevealedDuration = 250;
  static const int locationRevealedAmplitude = 150;

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임 — 영역 이탈 경고 (반복 패턴)
  // ═══════════════════════════════════════════════════════════════════════

  static const List<int> zoneExitPattern = [0, 300, 100, 300, 100, 300];
  static const List<int> zoneExitIntensities = [0, 255, 0, 255, 0, 255];

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임 — 구역 축소 (#668). 1~3차는 짧게 두 번, 최종은 길게
  // ═══════════════════════════════════════════════════════════════════════

  static const List<int> zoneShrinkPattern = [0, 120, 80, 120];
  static const List<int> zoneShrinkIntensities = [0, 200, 0, 255];
  static const List<int> zoneShrinkFinalPattern = [0, 500];
  static const List<int> zoneShrinkFinalIntensities = [0, 255];

  // ═══════════════════════════════════════════════════════════════════════
  // 인게임 — 게임 종료 (리듬 패턴)
  // ═══════════════════════════════════════════════════════════════════════

  static const List<int> gameEndPattern = [0, 200, 100, 200, 100, 500];
  static const List<int> gameEndIntensities = [0, 200, 0, 200, 0, 255];

  // 경찰 대기 마지막 10초 — 초마다 아주 짧게 (화면을 안 봐도 출동이 임박했음을 안다)
  static const int countdownTickDuration = 40;
  static const int countdownTickAmplitude = 120;

  // 출동 카운팅 5~1초 — 빛줄기가 세지듯 초마다 점점 세진다. 경찰·도둑 같다.
  // 5·4·3은 한 번씩 세게, 2는 두 번, 1은 세 번 빠르게 (사이렌 소리와 박자를 맞추기 쉽게 초마다 한 묶음)
  static ({List<int> pattern, List<int> intensities}) dispatchCountdownBeat(
    int secondsLeft,
  ) => switch (secondsLeft) {
    >= 5 => (pattern: const [0, 40], intensities: const [0, 90]),
    4 => (pattern: const [0, 50], intensities: const [0, 130]),
    3 => (pattern: const [0, 70], intensities: const [0, 170]),
    2 => (pattern: const [0, 70, 70, 70], intensities: const [0, 210, 0, 210]),
    _ => (
      pattern: const [0, 90, 60, 90, 60, 90],
      intensities: const [0, 255, 0, 255, 0, 255],
    ),
  };

  // 출동! — 길게 "부웅" 뒤 "탁탁". 카운팅과 확실히 다른, 가장 센 진동. 경찰·도둑 같다.
  static const List<int> dispatchGoPattern = [0, 500, 120, 120, 80, 120];
  static const List<int> dispatchGoIntensities = [0, 255, 0, 255, 0, 255];
}
