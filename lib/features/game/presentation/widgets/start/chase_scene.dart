import 'dart:async';
import 'dart:math' as math;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/character_assets.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/services/vibration_service.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/recede.dart';
import '../../../domain/start_flow.dart';
import 'chase_scene_rules.dart';
import 'run_cycle.dart';

/// 경찰 대기(②)·도둑 설명(③)·규칙 다시 보기(⑤)가 함께 쓰는 장면.
///
/// 좌표는 300×652 목업 기준이고 화면 폭/300을 곱해 그린다(지평선 y400).
/// 남은 시간·멀어진 거리는 서버 시작 시각으로 계산해 앱을 다시 켜도 같다.
class ChaseScene extends StatefulWidget {
  const ChaseScene({
    super.key,
    required this.mode,
    required this.isPolice,
    required this.scene,
    required this.gameStartTime,
    required this.policeWaitMinutes,
    required this.revealMinutes,
    this.roundTimeMinutes,
    this.onClose,
  });

  final ChaseSceneMode mode;
  final bool isPolice;
  final StartScene scene;
  final DateTime gameStartTime;
  final int policeWaitMinutes;
  final int revealMinutes;

  /// 게임 제한 시간. 출동 뒤 다시 보기는 카운트다운 자리에 남은 게임 시간을 보여 준다.
  final int? roundTimeMinutes;

  /// 설명 화면(20초·탭)·다시 보기(탭)가 닫힐 때. 경찰 대기 화면은 탭으로 닫히지 않는다.
  final VoidCallback? onClose;

  /// 규칙 4줄을 한 번씩 다 보여 주는 시간
  static const explainerDuration = Duration(seconds: 20);

  /// 3초는 읽기도 전에 넘어가 산만했다
  static const ruleInterval = Duration(seconds: 5);

  @override
  State<ChaseScene> createState() => _ChaseSceneState();
}

class _ChaseSceneState extends State<ChaseScene> {
  late final DateTime _openedAt = clock.now();
  late DateTime _now = _openedAt;
  Timer? _ticker;
  Timer? _autoClose;
  int _lastTickSecond = -1;

  bool get _isPolice => widget.isPolice;
  Color get _team => _isPolice ? AppColors.blue : AppColors.green;

  int get _remainingSeconds {
    final release = policeReleaseAt(
      gameStartTime: widget.gameStartTime,
      policeWaitMinutes: widget.policeWaitMinutes,
    )!;
    final ms = release.difference(_now).inMilliseconds;
    // 올림 — 00:00이 되는 순간이 출동 시각과 맞는다
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    // 규칙 회전·멀어지기가 부드럽게 보이도록 1초보다 잘게 갱신한다
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
    if (widget.mode == ChaseSceneMode.robberExplainer) {
      _autoClose = Timer(
        ChaseScene.explainerDuration,
        () => widget.onClose?.call(),
      );
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _now = clock.now());
    final sec = _remainingSeconds;
    // 화면을 끈 채면 울리지 않는다 — Android는 멈춘 앱의 타이머도 돌아 주머니 속에서 진동한다
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final visible = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    if (visible &&
        widget.mode == ChaseSceneMode.policeWait &&
        sec > 0 &&
        sec <= 10 &&
        sec != _lastTickSecond) {
      _lastTickSecond = sec;
      VibrationService.instance().countdownTick();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _autoClose?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rules = chaseSceneRules(
      l10n,
      mode: widget.mode,
      isPolice: _isPolice,
      revealMinutes: widget.revealMinutes,
    );
    final ruleIndex =
        (_now.difference(_openedAt).inMilliseconds ~/
            ChaseScene.ruleInterval.inMilliseconds) %
        rules.length;
    final p = waitProgress(
      gameStartTime: widget.gameStartTime,
      policeWaitMinutes: widget.policeWaitMinutes,
      now: _now,
    );
    final sec = _remainingSeconds;
    // 다시 보기도 시작 화면과 똑같이 보여 주되, 출동 뒤엔 셀 대기 시간이 없어 남은 게임 시간을 센다
    final showsGameTime = widget.mode == ChaseSceneMode.rulesReplay && sec == 0;
    final finalCount = !showsGameTime && sec <= 10;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / 300;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.mode == ChaseSceneMode.policeWait
              ? null
              : widget.onClose,
          // ColoredBox가 아니라 Material — ⓘ는 Scaffold 없는 다이얼로그 라우트라
          // Material 바탕이 없으면 글자에 노란 밑줄(디버그 경고 스타일)이 그어진다
          child: Material(
            // 그림보다 긴 화면은 아래를 땅 색으로 채운다(지평선 위치는 폭 기준으로 고정)
            color: _isPolice ? AppColors.black100 : AppColors.black900,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    startWaitBackgroundAssetPath(
                      scene: widget.scene.name,
                      isNight: !_isPolice,
                    ),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    // 원본(1179×2562)을 그대로 풀면 장마다 12MB — 화면 폭만큼만 디코딩한다
                    cacheWidth:
                        (constraints.maxWidth *
                                MediaQuery.devicePixelRatioOf(context))
                            .round(),
                  ),
                ),
                ..._characters(s, p, showsGameTime, finalCount),
                Positioned(
                  top: 116 * s,
                  left: 0,
                  right: 0,
                  child: _headline(
                    l10n,
                    s,
                    sec,
                    showsGameTime,
                    finalCount,
                    reduceMotion,
                  ),
                ),
                Positioned(
                  top: 212 * s,
                  left: 0,
                  right: 0,
                  child: Center(child: _title(l10n)),
                ),
                Positioned(
                  top: 244 * s,
                  left: 0,
                  right: 0,
                  child: _mission(l10n),
                ),
                Positioned.fill(
                  child: CustomSingleChildLayout(
                    delegate: _RuleSlot(
                      scale: s,
                      nearBottom: _nearBottom * s,
                      tallestRule: _tallestRule(
                        context,
                        l10n,
                        rules,
                        205 * s,
                        s,
                      ),
                      tallestSkyRule: _tallestRule(
                        context,
                        l10n,
                        rules,
                        260 * s,
                        s,
                      ),
                      bottomClearance: widget.mode == ChaseSceneMode.policeWait
                          ? 8
                          : 40,
                    ),
                    child: _rule(l10n, rules, ruleIndex, s, reduceMotion),
                  ),
                ),
                if (widget.mode != ChaseSceneMode.policeWait)
                  Positioned(
                    left: 20 * s,
                    bottom: 24 * s,
                    child: Text(
                      l10n.startTapToMap,
                      style: AppTextStyles.tag_12.copyWith(
                        color: AppColors.black400,
                      ),
                    ),
                  ),
                // 다시 보기는 저절로 닫히지 않아 남은 시간 막대가 없다
                if (widget.mode == ChaseSceneMode.robberExplainer)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor:
                            (1 -
                                    _now.difference(_openedAt).inMilliseconds /
                                        ChaseScene
                                            .explainerDuration
                                            .inMilliseconds)
                                .clamp(0.0, 1.0),
                        child: ColoredBox(color: _team),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headline(
    AppLocalizations l10n,
    double s,
    int sec,
    bool showsGameTime,
    bool finalCount,
    bool reduceMotion,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 18 * s,
          child: Center(
            child: Text(
              showsGameTime
                  ? l10n.startGameTimeLeftLabel
                  : l10n.startWaitCountdownLabel,
              style: AppTextStyles.tag_12.copyWith(
                color: _isPolice ? AppColors.black600 : AppColors.black400,
              ),
            ),
          ),
        ),
        // 숫자 칸 높이를 고정해 마지막 10초에 커져도 아래 글을 밀지 않는다. 커진 채 가만히 있는다.
        SizedBox(
          height: 72 * s,
          child: Center(
            child: AnimatedScale(
              scale: finalCount ? 72 / 56 : 1,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: Text(
                showsGameTime ? _gameTimeLeft() : _mmss(sec),
                style: AppTextStyles.semibold_56.copyWith(
                  color: _team,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _mmss(int sec) =>
      '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';

  /// 앱바 GameTimerText와 같은 계산(경과 초 버림)이라 두 숫자가 어긋나지 않는다
  String _gameTimeLeft() {
    final minutes = widget.roundTimeMinutes;
    if (minutes == null) return '--:--';
    final left =
        Duration(minutes: minutes) - _now.difference(widget.gameStartTime);
    return _mmss(left.isNegative ? 0 : left.inSeconds);
  }

  Widget _title(AppLocalizations l10n) {
    return Text(
      _isPolice ? l10n.startWaitPoliceTitle : l10n.startWaitRobberTitle,
      style: AppTextStyles.subHeading_18.copyWith(
        color: _isPolice ? AppColors.black : AppColors.white,
      ),
    );
  }

  Widget _mission(AppLocalizations l10n) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: l10n.startMissionLabel,
            style: AppTextStyles.paragraph14Semibold.copyWith(color: _team),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: _isPolice ? l10n.startMissionPolice : l10n.startMissionRobber,
            style: AppTextStyles.paragraph_14.copyWith(
              color: _isPolice ? AppColors.black800 : AppColors.black100,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 앞 캐릭터의 아래 끝(목업 y). 폭 96에 SVG 비율(고양이 272×323, 쥐 248×243)을 곱한 높이.
  double get _nearBottom =>
      _isPolice ? 400 + 96 * 323 / 272 : 392 + 96 * 243 / 248;

  /// 경찰 시점: 앞에 기다리는 고양이, 멀어지는 쥐 / 도둑 시점: 앞에 달리는 쥐, 멀어지는 고양이
  List<Widget> _characters(
    double s,
    double p,
    bool showsGameTime,
    bool finalCount,
  ) {
    final nearTeam = _isPolice ? 'police' : 'robber';
    final farTeam = _isPolice ? 'robber' : 'police';
    final far = recede(p, _isPolice ? policeWaitRecede : robberWaitRecede);
    // 경찰 고양이는 출동 전까지 기다리고(다시 보기도 같다), 출동 뒤엔 달린다
    final nearMotion = !_isPolice || showsGameTime
        ? RunMotion.run
        : (finalCount ? RunMotion.ready : RunMotion.breathe);
    return [
      Positioned(
        left: far.left * s,
        top: far.top * s,
        width: far.width * s,
        child: RunCycle(
          scale: s,
          period: _runPeriod(farTeam),
          delay: _runDelay(farTeam),
          child: SvgPicture.asset(
            startChaseCharacterAssetPath(team: farTeam),
            width: far.width * s,
          ),
        ),
      ),
      Positioned(
        left: (_isPolice ? 20 : 134) * s,
        top: (_isPolice ? 400 : 392) * s,
        width: 96 * s,
        child: RunCycle(
          scale: s,
          motion: nearMotion,
          period: _runPeriod(nearTeam),
          delay: _runDelay(nearTeam),
          child: SvgPicture.asset(
            startChaseCharacterAssetPath(team: nearTeam),
            width: 96 * s,
          ),
        ),
      ),
    ];
  }

  // 고양이는 0.46초 주기로 반 박자 늦게 — 둘이 함께 있을 때 발이 엇갈린다
  Duration _runPeriod(String team) =>
      Duration(milliseconds: team == 'police' ? 460 : 500);
  Duration _runDelay(String team) =>
      Duration(milliseconds: team == 'police' ? 230 : 0);

  String _counter(AppLocalizations l10n, int index, int total) =>
      l10n.startRulesCounter(index + 1, total);

  /// 돌아가는 규칙 중 가장 긴 블록의 높이 — 자리를 이걸로 한 번 골라야 규칙이 바뀔 때
  /// 블록이 아래위로 튀지 않는다(영어 규칙은 4줄까지 길어진다).
  double _tallestRule(
    BuildContext context,
    AppLocalizations l10n,
    List<String> rules,
    double width,
    double s,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double height(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout(maxWidth: width);
      final h = painter.height;
      painter.dispose();
      return h;
    }

    var tallest = 0.0;
    for (var i = 0; i < rules.length; i++) {
      tallest = math.max(
        tallest,
        height(_counter(l10n, i, rules.length), AppTextStyles.tag12Semibold) +
            4 * s +
            height(rules[i], AppTextStyles.paragraph_16),
      );
    }
    return tallest;
  }

  Widget _rule(
    AppLocalizations l10n,
    List<String> rules,
    int index,
    double s,
    bool reduceMotion,
  ) {
    final counter = _counter(l10n, index, rules.length);
    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 600),
      // 줄 수가 달라도 "게임 규칙 n/m" 라벨이 한자리에 있게 왼쪽 위를 기준으로 바뀐다
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: Column(
        key: ValueKey(index),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            counter,
            style: AppTextStyles.tag12Semibold.copyWith(color: _team),
          ),
          SizedBox(height: 4 * s),
          Text(
            rules[index],
            style: AppTextStyles.paragraph_16.copyWith(
              color: _isPolice ? AppColors.black800 : AppColors.black100,
            ),
          ),
        ],
      ),
    );
  }
}

/// 규칙 블록 자리(왼쪽 20·폭 205). 목업대로 아래(bottom 56)에 두되 앞 캐릭터와 겹치면
/// 발 아래로 내린다. 가장 긴 규칙이 발 아래에 안 들어가는 화면(16:9 375×667·360×640,
/// 영어 4줄 규칙의 360×740 등)은 하늘 쪽, 멀어지는 캐릭터가 가장 클 때의 머리(y 370)
/// 위로 올리고 폭을 260으로 넓혀 미션 줄에 닿지 않게 줄 수를 줄인다.
class _RuleSlot extends SingleChildLayoutDelegate {
  const _RuleSlot({
    required this.scale,
    required this.nearBottom,
    required this.tallestRule,
    required this.tallestSkyRule,
    required this.bottomClearance,
  });

  final double scale;
  final double nearBottom;

  /// 폭 205에서 가장 긴 규칙 블록의 높이
  final double tallestRule;

  /// 하늘 쪽 폭 260에서 가장 긴 규칙 블록의 높이
  final double tallestSkyRule;

  /// 화면 아래에서 비워 둘 목업 높이 — 설명 화면은 "탭하면 지도로 돌아가요"(bottom 24) 줄 자리
  final double bottomClearance;

  bool _inSky(double height) =>
      height - bottomClearance * scale - (nearBottom + 8 * scale) < tallestRule;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      // 높이를 가장 긴 규칙으로 고정해야 규칙이 바뀌어도 자리가 그대로다
      _inSky(constraints.maxHeight)
      ? BoxConstraints.tightFor(width: 260 * scale, height: tallestSkyRule)
      : BoxConstraints.tightFor(width: 205 * scale, height: tallestRule);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final s = scale;
    final belowFeet = nearBottom + 8 * s;
    final floor = size.height - bottomClearance * s;
    final lowest = floor - childSize.height;
    final double top;
    if (_inSky(size.height)) {
      top = 364 * s - childSize.height;
    } else {
      final mockupTop = size.height - 56 * s - childSize.height;
      top = math.min(math.max(mockupTop, belowFeet), lowest);
    }
    return Offset(20 * s, top);
  }

  @override
  bool shouldRelayout(_RuleSlot old) =>
      old.scale != scale ||
      old.nearBottom != nearBottom ||
      old.tallestRule != tallestRule ||
      old.tallestSkyRule != tallestSkyRule ||
      old.bottomClearance != bottomClearance;
}
