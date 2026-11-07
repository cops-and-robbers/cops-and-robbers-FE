import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/constants/app_shadows.dart';
import '../../../../../core/constants/character_assets.dart';
import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/services/vibration_service.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/start_flow.dart';
import 'chase_scene_rules.dart';
import 'police_car_drive.dart';

/// 경찰 대기(②)·도둑 설명(③)·규칙 다시 보기(⑤)가 함께 쓰는 장면.
///
/// 배경 그림 위에 팀 이름·남은 시간·공지·미션·규칙 카드를 얹고 바닥에 경찰차가 지나간다.
/// 좌표는 393×852 시안 기준이고 화면 폭/393을 곱해 그린다.
/// 남은 시간은 서버 시작 시각으로 계산해 앱을 다시 켜도 같다.
class ChaseScene extends StatefulWidget {
  const ChaseScene({
    super.key,
    required this.mode,
    required this.isPolice,
    required this.gameStartTime,
    required this.policeWaitMinutes,
    required this.revealMinutes,
    this.roundTimeMinutes,
    this.onClose,
    this.notice,
  });

  final ChaseSceneMode mode;
  final bool isPolice;
  final DateTime gameStartTime;
  final int policeWaitMinutes;
  final int revealMinutes;

  /// 게임 제한 시간. 출동 뒤 다시 보기는 카운트다운 자리에 남은 게임 시간을 보여 준다.
  final int? roundTimeMinutes;

  /// 설명 화면(20초·탭)·다시 보기(탭)가 닫힐 때. 경찰 대기 화면은 탭으로 닫히지 않는다.
  final VoidCallback? onClose;

  /// 지금 살아 있는 인게임 공지 문구. 지도에서 위에 뜨는 것과 같은 공지를
  /// 장면에서는 "게임 안내"의 한 장으로 규칙 앞에 넣어 함께 돌린다.
  final String? notice;

  /// 규칙 4줄을 한 번씩 다 보여 주는 시간
  static const explainerDuration = Duration(seconds: 20);

  /// 3초는 읽기도 전에 넘어가 산만했다
  static const ruleInterval = Duration(seconds: 5);

  /// 카드를 눌러 긴 문구를 펼치고 접는 시간
  static const expandDuration = Duration(milliseconds: 200);

  /// 시안 폭
  static const designWidth = 393.0;

  @override
  State<ChaseScene> createState() => _ChaseSceneState();
}

class _ChaseSceneState extends State<ChaseScene> {
  late final DateTime _openedAt = clock.now();
  late DateTime _now = _openedAt;
  Timer? _ticker;
  bool _autoClosed = false;
  int _lastTickSecond = -1;

  /// 펼친 규칙을 읽는 동안 멈춘 시간. 규칙 회전 시계에서 뺀다.
  Duration _rulePaused = Duration.zero;
  DateTime? _ruleExpandedAt;
  bool _missionExpanded = false;

  bool get _ruleExpanded => _ruleExpandedAt != null;

  /// 게임 안내에 넣은 공지(온 순서). 규칙보다 앞에 두고 함께 돌린다.
  final List<String> _notices = [];

  /// 회전의 기준 — [_guideAnchor](읽기 시계)에 [_guideStart]번째 장을 보여 주기 시작했다
  int _guideStart = 0;
  Duration _guideAnchor = Duration.zero;

  /// 새 공지는 안내에 더하고 바로 그 장으로 넘어간다
  void _addNotice(String text) {
    if (_notices.contains(text)) return;
    _notices.add(text);
    _guideStart = _notices.length - 1;
    _guideAnchor = _readClock;
  }

  void _toggleRule() => setState(() {
    final expandedAt = _ruleExpandedAt;
    if (expandedAt == null) {
      // 화면에 보이는 규칙은 마지막 틱(_now) 기준이다 — 지금 시각으로 멈추면 그 사이 넘어간 다음 규칙이 펼쳐진다
      _ruleExpandedAt = _now;
    } else {
      // 화면 시각도 지금으로 당긴다 — 마지막 틱 시각으로 두면 접는 순간 시계가 뒤로 가
      // 바뀐 직후의 규칙이 이전 규칙으로 잠깐 돌아가고 진행 막대도 뒤로 튄다
      _now = clock.now();
      _rulePaused += _now.difference(expandedAt);
      _ruleExpandedAt = null;
    }
  });

  bool get _isPolice => widget.isPolice;
  Color get _team => _isPolice ? AppColors.blue : AppColors.green;

  /// 팀 이름 줄은 숫자보다 옅은 팀 색
  Color get _teamName =>
      _isPolice ? AppColors.blueVer2Rich : AppColors.green800;

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
    // 장면이 열릴 때 살아 있는 공지가 있으면 그것부터 보여 준다
    if (widget.notice case final notice?) _addNotice(notice);
    // 규칙 회전·막대가 부드럽게 보이도록 1초보다 잘게 갱신한다
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  @override
  void didUpdateWidget(ChaseScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 보는 중에 새 공지가 오면 안내에 더하고 바로 보여 준다
    final notice = widget.notice;
    if (notice != null && notice != oldWidget.notice) _addNotice(notice);
  }

  /// 규칙 회전과 도둑 설명 자동 닫힘이 함께 쓰는 시계. 규칙을 펼쳐 읽는 동안은 멈춘다.
  Duration get _readClock =>
      (_ruleExpandedAt ?? _now).difference(_openedAt) - _rulePaused;

  void _tick() {
    if (!mounted) return;
    setState(() => _now = clock.now());
    if (widget.mode == ChaseSceneMode.robberExplainer &&
        !_autoClosed &&
        _readClock >= ChaseScene.explainerDuration) {
      _autoClosed = true;
      widget.onClose?.call();
    }
    final sec = _remainingSeconds;
    // 화면을 끈 채면 울리지 않는다 — Android는 멈춘 앱의 타이머도 돌아 주머니 속에서 진동한다
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    final visible = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    // 마지막 5초는 위에 뜨는 출동 카운팅이 울린다 — 같은 초에 두 번 울리지 않게
    if (visible &&
        widget.mode == ChaseSceneMode.policeWait &&
        sec > dispatchCountdownLead.inSeconds &&
        sec <= 10 &&
        sec != _lastTickSecond) {
      _lastTickSecond = sec;
      VibrationService.instance().countdownTick();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
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
    // 게임 안내 = 공지(먼저) + 규칙. 펼친 동안은 그 장에 머문다 — 읽던 문구가 넘어가 버리지 않게
    final guide = [..._notices, ...rules];
    final ruleIndex =
        (_guideStart +
            (_readClock - _guideAnchor).inMilliseconds ~/
                ChaseScene.ruleInterval.inMilliseconds) %
        guide.length;
    final sec = _remainingSeconds;
    // 다시 보기도 시작 화면과 똑같이 보여 주되, 출동 뒤엔 셀 대기 시간이 없어 남은 게임 시간을 센다
    final showsGameTime = widget.mode == ChaseSceneMode.rulesReplay && sec == 0;
    final finalCount = !showsGameTime && sec <= 10;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = constraints.maxWidth / ChaseScene.designWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.mode == ChaseSceneMode.policeWait
              ? null
              : widget.onClose,
          // ColoredBox가 아니라 Material — ⓘ는 Scaffold 없는 다이얼로그 라우트라
          // Material 바탕이 없으면 글자에 노란 밑줄(디버그 경고 스타일)이 그어진다
          child: Material(
            color: _isPolice ? AppColors.blueVer2_50 : AppColors.black900,
            child: Stack(
              children: [
                // 땅이 아래에 붙도록 아래 기준으로 채운다. 긴 화면은 하늘 위쪽이 잘린다.
                Positioned.fill(
                  child: Image.asset(
                    startWaitBackgroundAssetPath(isNight: !_isPolice),
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 42 * s,
                  child: PoliceCarDrive(scale: s),
                ),
                Positioned(
                  top: 118 * s,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // 큰 글씨·짧은 화면에서 펼친 카드가 아래로 넘치면 스크롤로 읽게 한다.
                  // 넘치지 않으면 끌어도 움직이지 않는다(Clamping).
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    // 시안: 안내 문구 아래 44에서 카드가 시작한다
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(
                          l10n,
                          s,
                          sec,
                          showsGameTime,
                          finalCount,
                          reduceMotion,
                        ),
                        // 피그마 9164:20378: 안내 → 첫 카드 50(위쪽 공지 줄 없음)
                        SizedBox(height: AppSpacing.vertical50),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16 * s),
                          child: _cards(
                            context,
                            l10n,
                            guide,
                            ruleIndex,
                            s,
                            reduceMotion,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 도둑 설명·ⓘ 다시 보기는 화면을 누르면 닫히고 지도로 간다 — 맨 아래에 알려 준다.
                // 경찰 대기는 출동 전까지 닫을 수 없어 안내가 없다
                if (widget.mode != ChaseSceneMode.policeWait)
                  Positioned(
                    left: AppSpacing.horizontal16,
                    right: AppSpacing.horizontal16,
                    bottom: 14 * s,
                    child: Text(
                      l10n.startExplainerTapHint,
                      textAlign: TextAlign.center,
                      // 위 "경찰 출동까지" 라벨과 같은 색 — 경찰은 밝은 바탕이다
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: _isPolice
                            ? AppColors.black500
                            : AppColors.black200,
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
                                    _readClock.inMilliseconds /
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

  /// 팀 이름 → 라벨 → 큰 숫자 → 한 줄 안내. 칸 높이를 고정해 숫자가 커져도 아래를 밀지 않는다.
  Widget _header(
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
          height: 24 * s,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 시안은 아이콘도 팀 이름과 같은 색이다
              SvgPicture.asset(
                AppIcons.role(isPolice: _isPolice, isDark: !_isPolice),
                width: 24 * s,
                height: 24 * s,
                colorFilter: ColorFilter.mode(_teamName, BlendMode.srcIn),
              ),
              SizedBox(width: AppSpacing.horizontal6),
              Text(
                _isPolice ? l10n.gameTeamCop : l10n.gameTeamRobber,
                style: AppTextStyles.heading_20.copyWith(color: _teamName),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.vertical48),
        SizedBox(
          height: 16 * s,
          child: Center(
            child: Text(
              showsGameTime
                  ? l10n.startGameTimeLeftLabel
                  : l10n.startWaitCountdownLabel,
              style: AppTextStyles.label_16.copyWith(
                color: _isPolice ? AppColors.black500 : AppColors.black200,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.vertical14),
        SizedBox(
          height: 80 * s,
          child: Center(
            child: AnimatedScale(
              scale: finalCount ? 1.2 : 1,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: Text(
                showsGameTime ? _gameTimeLeft() : _mmss(sec),
                style: AppTextStyles.scoreDreamExtrabold_80.copyWith(
                  color: _team,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.vertical14),
        Text(
          _isPolice ? l10n.startWaitPoliceTitle : l10n.startWaitRobberTitle,
          style: AppTextStyles.subHeading_18.copyWith(
            color: _isPolice ? AppColors.black700 : AppColors.white,
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

  Widget _cards(
    BuildContext context,
    AppLocalizations l10n,
    List<String> guide,
    int ruleIndex,
    double s,
    bool reduceMotion,
  ) {
    final gap = SizedBox(height: AppSpacing.vertical18);
    final textWidth =
        ChaseScene.designWidth * s -
        AppSpacing.horizontal16 * 2 -
        AppSpacing.horizontal16 * 2 -
        20 * s -
        AppSpacing.horizontal6;
    final mission = _isPolice
        ? l10n.startMissionPolice
        : l10n.startMissionRobber;
    final rule = guide[ruleIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _card(
          s,
          icon: _missionFlag(s),
          onTap: _missionExpanded || _overflows(context, mission, textWidth)
              ? () => setState(() => _missionExpanded = !_missionExpanded)
              : null,
          child: _labeled(
            s,
            _isPolice
                ? l10n.startMissionPoliceLabel
                : l10n.startMissionRobberLabel,
            mission,
            expanded: _missionExpanded,
            reduceMotion: reduceMotion,
          ),
        ),
        gap,
        _card(
          s,
          icon: SvgPicture.asset(AppIcons.bulb, width: 20 * s, height: 20 * s),
          onTap: _ruleExpanded || _overflows(context, rule, textWidth)
              ? _toggleRule
              : null,
          child: AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 600),
            // 줄 수가 달라도 "게임 안내 n/m" 라벨이 한자리에 있게 왼쪽 위를 기준으로 바뀐다
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(
              key: ValueKey('$ruleIndex:$rule'),
              child: _labeled(
                s,
                // 공지는 서버 이벤트라 몇 개 올지 몰라 번호 없이, 규칙만 n/규칙 수로 센다
                ruleIndex < _notices.length
                    ? l10n.startGuideLabel
                    : _counter(
                        l10n,
                        ruleIndex - _notices.length,
                        guide.length - _notices.length,
                      ),
                rule,
                expanded: _ruleExpanded,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 긴 문구는 한 줄(…)로 두고 카드를 누르면 펼친다. 넘치지 않는 카드는 누를 게 없다.
  Widget _card(
    double s, {
    required Widget icon,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: AppSpacing.vertical18,
      ),
      decoration: BoxDecoration(
        // 피그마 9164:20378: 도둑 카드는 black900
        color: _isPolice ? AppColors.blueVer2_50 : AppColors.black900,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.vague,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘(20)은 라벨 줄(14 × 1.4 = 20)과 같은 높이라 위를 맞추면 가운데가 맞는다
          icon,
          SizedBox(width: AppSpacing.horizontal6),
          Expanded(child: child),
        ],
      ),
    );
    if (onTap == null) return card;
    // 장면 전체 탭(지도로 돌아가기)보다 먼저 받아 카드만 펼친다
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }

  Widget _labeled(
    double s,
    String label,
    String body, {
    required bool expanded,
    required bool reduceMotion,
  }) {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        SizedBox(height: AppSpacing.vertical4),
        Text(
          body,
          style: _bodyStyle,
          maxLines: expanded ? null : 1,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );
    // 동작 줄이기면 바로 바꾼다 — AnimatedSize는 시간이 0이면 레이아웃 도중 자신을 다시
    // 더럽혀 오류를 낸다(A RenderAnimatedSize was mutated in its own performLayout)
    if (reduceMotion) return column;
    return AnimatedSize(
      duration: ChaseScene.expandDuration,
      alignment: Alignment.topLeft,
      child: column,
    );
  }

  bool _overflows(BuildContext context, String text, double width) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _bodyStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout(maxWidth: width);
    final overflows = painter.didExceedMaxLines;
    painter.dispose();
    return overflows;
  }

  TextStyle get _labelStyle => AppTextStyles.paragraph_14.copyWith(
    color: _isPolice ? AppColors.black600 : AppColors.black200,
  );

  TextStyle get _bodyStyle => AppTextStyles.paragraph14Semibold116.copyWith(
    color: _isPolice ? AppColors.black : AppColors.white,
  );

  /// 미션 깃발은 경찰 파랑 그림 하나라 도둑은 같은 그림의 색만 초록으로 바꾼다
  Widget _missionFlag(double s) => _isPolice
      ? SvgPicture.asset(AppIcons.flag, width: 20 * s, height: 20 * s)
      : SvgPicture(
          SvgAssetLoader(AppIcons.flag, colorMapper: const _RobberFlagColors()),
          width: 20 * s,
          height: 20 * s,
        );

  String _counter(AppLocalizations l10n, int index, int total) =>
      l10n.startRulesCounter(index + 1, total);
}

/// 경찰 깃발(파랑) → 도둑 깃발(초록). 깃대는 옅은 색, 깃발은 진한 색을 유지한다.
class _RobberFlagColors extends ColorMapper {
  const _RobberFlagColors();

  static const _policeFlag = Color(0xFF0088FF);
  static const _policePole = Color(0xFFB6DDFF);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => switch (color) {
    _policeFlag => AppColors.green,
    _policePole => AppColors.green500,
    _ => color,
  };
}
