import 'package:flutter/foundation.dart';

import '../../domain/start_flow.dart';

/// 게임 시작 흐름의 단계 진행(① 역할 배너 → ② 경찰 대기·③ 도둑 설명 → ④ 출동 카운팅).
///
/// 위젯·시계에 기대지 않는다. 시간은 화면이 재서 [policeReleased] 등을 부른다.
class StartIntroController extends ChangeNotifier {
  StartIntroController({
    required List<StartIntroStep> steps,
    required this.hasPoliceWait,
  }) : _steps = steps,
       _showRoleBanner = steps.contains(StartIntroStep.roleBanner) {
    if (!_showRoleBanner) _enterWaitPhase();
  }

  final List<StartIntroStep> _steps;

  /// 대기가 없는 방은 출동 순간이 없어 ④를 띄우지 않는다.
  final bool hasPoliceWait;

  bool _showRoleBanner;
  bool _showPoliceWait = false;
  bool _showRobberExplainer = false;
  bool _showDispatchCountdown = false;
  bool _countdownStarted = false;
  bool _released = false;
  bool _waitEntered = false;
  bool _hintDue = false;

  bool get showRoleBanner => _showRoleBanner;
  bool get showPoliceWait => _showPoliceWait;
  bool get showRobberExplainer => _showRobberExplainer;

  /// 출동 5초 전부터 "출동!"·원형 열기가 끝날 때까지. 장면·지도 위를 덮는다.
  bool get showDispatchCountdown => _showDispatchCountdown;

  /// ⓘ 위치 안내를 띄울 때가 됐는지. 한 번 켜지면 그대로 — 띄웠는지는 화면이 기록한다.
  bool get hintDue => _hintDue;

  void _enterWaitPhase() {
    if (_waitEntered) return; // 한 번만 — 닫은 설명 화면을 다시 열지 않는다
    _waitEntered = true;
    _showPoliceWait = _steps.contains(StartIntroStep.policeWait);
    _showRobberExplainer = _steps.contains(StartIntroStep.robberExplainer);
  }

  /// 역할 배너가 빠지는 도중(3.7초) — 띠 아래에서 다음 장면을 먼저 띄운다.
  void roleBannerLeaving() {
    if (!_showRoleBanner || _released) return;
    _enterWaitPhase();
    notifyListeners();
  }

  void roleBannerDone() {
    if (!_showRoleBanner) return;
    _showRoleBanner = false;
    if (!_released) _enterWaitPhase();
    if (!hasPoliceWait) _hintDue = true;
    notifyListeners();
  }

  void robberExplainerClosed() {
    if (!_showRobberExplainer) return;
    _showRobberExplainer = false;
    _hintDue = true;
    notifyListeners();
  }

  /// 출동 5초 전 — 화면이 보일 때 한 번만 카운팅을 띄운다.
  void dispatchCountdownStarted() {
    if (!hasPoliceWait || _released || _countdownStarted) return;
    _countdownStarted = true;
    _showDispatchCountdown = true;
    notifyListeners();
  }

  /// 기기 시계의 출동 시각 또는 서버 POLICE_MOVE_START — 먼저 온 한 번만 처리한다.
  /// 카운팅 아래의 장면만 닫는다. 카운팅은 자기 시계대로 "출동!"까지 간다.
  /// [inForeground]가 false면(백그라운드에서 지나 늦게 처리) 카운팅도 닫는다.
  void policeReleased({required bool inForeground}) {
    if (_released) return;
    _released = true;
    _showPoliceWait = false;
    _showRobberExplainer = false;
    if (!inForeground) _showDispatchCountdown = false;
    notifyListeners();
  }

  void dispatchCountdownDone() {
    if (!_showDispatchCountdown) return;
    _showDispatchCountdown = false;
    _hintDue = true;
    notifyListeners();
  }

  void gameOver() {
    _released = true;
    _showRoleBanner = false;
    _showPoliceWait = false;
    _showRobberExplainer = false;
    _showDispatchCountdown = false;
    notifyListeners();
  }
}
