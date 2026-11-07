/// 게임 시작 흐름에서 무엇을 띄울지 정하는 순수 계산.
///
/// 시각은 모두 서버 시작 시각(`gameStartTime`)과 방 설정(`policeWaitMinutes`)으로
/// 계산한다 — 앱을 다시 켜도 같은 계산으로 같은 상태가 된다.
library;

import 'dart:math' as math;

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

/// 숫자를 세기 시작하는 시점 — 출동 5초 전부터 5, 4, 3, 2, 1을 센다.
const dispatchCountdownLead = Duration(seconds: 5);

/// 숫자 전에 화면을 덮는 시간. 나갈 때 원형으로 열리는 것을 거꾸로 돌려,
/// 장면·지도가 보이는 구멍이 가장자리에서 사이렌 쪽으로 닫힌다.
const dispatchCoverDuration = Duration(seconds: 1);

/// 카운팅 화면이 뜨는 시점(출동 6초 전) — 덮기 1초 + 숫자 5초.
const dispatchOverlayLead = Duration(seconds: 6);

/// 1 다음 "출동!"을 보여 주는 시간. 이 뒤에 원형으로 열리며 지도가 드러난다.
const dispatchGoHold = Duration(milliseconds: 1200);

/// 사이렌 자리에서 원형으로 열리는 시간.
const dispatchIrisDuration = Duration(milliseconds: 1000);

/// 효과가 켜지는 시점(출동 4초 전). 5초는 시안 그대로 둔다.
const _dispatchEffectFrom = Duration(seconds: 4);

/// 카운팅 화면의 한 순간.
/// [seconds] 출동 전이면 남은 초 올림(덮는 동안은 6), 출동부터는 null("출동!").
/// [cover] 들어올 때 덮기 진행 0~1(선형, 1이면 다 덮임). [intensity] 효과 세기 0~1.
/// [iris] 나갈 때 원형 열기 진행 0~1(선형). [done] 다 끝났는지.
typedef DispatchCountdownFrame = ({
  int? seconds,
  double cover,
  double intensity,
  double iris,
  bool done,
});

/// 출동 시각과 지금 시각만으로 정한다 — 여러 폰이 같은 순간에 같은 숫자를 보이게.
DispatchCountdownFrame dispatchCountdownFrame({
  required DateTime releaseAt,
  required DateTime now,
}) {
  final remainingMs = releaseAt.difference(now).inMilliseconds;
  final afterMs = -remainingMs;
  final irisStartMs = dispatchGoHold.inMilliseconds;
  final doneMs = irisStartMs + dispatchIrisDuration.inMilliseconds;
  if (remainingMs > 0) {
    final fromMs = _dispatchEffectFrom.inMilliseconds;
    // 4초 시점부터 1초 끝까지 0→1, 뒤로 갈수록 가파르게(앞은 조용하고 끝에 몰아친다)
    final e = ((fromMs - remainingMs) / fromMs).clamp(0.0, 1.0);
    final coverMs = dispatchCoverDuration.inMilliseconds;
    final countMs = dispatchCountdownLead.inMilliseconds;
    return (
      seconds: (remainingMs / 1000).ceil(),
      cover: ((countMs + coverMs - remainingMs) / coverMs).clamp(0.0, 1.0),
      intensity: math.pow(e, 1.6).toDouble(),
      iris: 0,
      done: false,
    );
  }
  return (
    seconds: null,
    cover: 1,
    intensity: 1,
    iris: ((afterMs - irisStartMs) / dispatchIrisDuration.inMilliseconds).clamp(
      0.0,
      1.0,
    ),
    done: afterMs >= doneMs,
  );
}
