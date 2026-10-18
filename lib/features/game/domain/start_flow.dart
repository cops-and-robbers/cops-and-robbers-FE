/// 게임 시작 흐름에서 무엇을 띄울지 정하는 순수 계산.
///
/// 시각은 모두 서버 시작 시각(`gameStartTime`)과 방 설정(`policeWaitMinutes`)으로
/// 계산한다 — 앱을 다시 켜도 같은 계산으로 같은 상태가 된다.
library;

/// 대기·설명 장면 배경. 순서를 바꾸면 같은 게임인데 앱 버전마다 다른 장면이
/// 나오므로 새 장면은 뒤에만 더한다.
enum StartScene { hills, town, city }

/// 서버가 준 gameId로 고른다 — 같은 게임의 모든 기기가 같은 장면을 본다.
StartScene startWaitScene(int gameId) =>
    StartScene.values[gameId % StartScene.values.length];

enum StartIntroStep { roleBanner, policeWait, robberExplainer }

/// "막 시작했다"로 보는 한계. 시작 시스템 메시지를 건너뛰는 기준
/// (game_page `_sendGameStartSystemMessages`)과 같다.
const startIntroFreshWindow = Duration(seconds: 20);

/// 경찰 출동 시각. 대기 시간이 없으면(null 포함) 시작 시각과 같다.
DateTime? policeReleaseAt({
  required DateTime? gameStartTime,
  required int? policeWaitMinutes,
}) => gameStartTime?.add(Duration(minutes: policeWaitMinutes ?? 0));

/// 경찰 대기 진행 비율 0~1. 대기가 없으면 1.
double waitProgress({
  required DateTime gameStartTime,
  required int policeWaitMinutes,
  required DateTime now,
}) {
  if (policeWaitMinutes <= 0) return 1;
  final total = Duration(minutes: policeWaitMinutes).inMilliseconds;
  final elapsed = now.difference(gameStartTime).inMilliseconds;
  return (elapsed / total).clamp(0.0, 1.0);
}

/// 지금 게임 화면에 들어온 사람이 차례로 볼 단계.
///
/// - 역할 배너는 시작 직후(20초 안)에만 — 다시 켠 앱에서 또 보이지 않게
/// - 경찰 대기 화면은 출동 전이면 언제든(상태라서 다시 켜도 보여야 한다)
/// - 도둑 설명 화면은 시작 직후 + 출동 전에만
List<StartIntroStep> startIntroSteps({
  required bool isPolice,
  required bool isEventGame,
  required DateTime? gameStartTime,
  required int? policeWaitMinutes,
  required DateTime now,
}) {
  if (isEventGame || gameStartTime == null) return const [];
  final fresh = now.difference(gameStartTime) <= startIntroFreshWindow;
  final release = policeReleaseAt(
    gameStartTime: gameStartTime,
    policeWaitMinutes: policeWaitMinutes,
  )!;
  final waiting = now.isBefore(release);
  return [
    if (fresh) StartIntroStep.roleBanner,
    if (isPolice && waiting) StartIntroStep.policeWait,
    if (!isPolice && fresh && waiting) StartIntroStep.robberExplainer,
  ];
}
