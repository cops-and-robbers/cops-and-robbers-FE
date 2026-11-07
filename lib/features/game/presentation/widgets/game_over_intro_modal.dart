import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_result_reason.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/game_result_entity.dart';
import 'mvp_confetti.dart';
import 'mvp_reveal_order.dart';
import 'mvp_spotlight.dart';

/// 게임 종료 알림 + 팀 MVP 공개 모달 (DEC-0093 ⑤, FE #628).
///
/// 「게임 종료!」 카드를 띄우고, 결과에 팀 MVP가 있으면 카드를 흔들어 「MVP는 누굴까?!」로
/// 바꾼 뒤 진 팀 → 이긴 팀 순서로 한 명씩 보여준다. 각 화면은 연출이 끝난 뒤에만 탭으로
/// 넘어간다(캡처할 시간). MVP가 없으면(이전 서버·이벤트 게임·조회 실패·3초 안에 응답 없음)
/// 예전 「게임 종료」 팝업처럼 3초 뒤 닫힌다.
class GameOverIntroModal extends StatefulWidget {
  const GameOverIntroModal({
    super.key,
    required this.isDarkMode,
    required this.reason,
    required this.result,
  });

  final bool isDarkMode;
  final String? reason;

  /// 결과 조회. null이면 MVP를 찾지 않는다(이벤트 게임·gameResultId 없음).
  final Future<GameResultEntity>? result;

  /// 「게임 종료!」를 최소로 보여주는 시간 — 사유 문구를 읽을 시간.
  static const minIntro = Duration(milliseconds: 1400);

  /// MVP가 없을 때 닫히는 시간 — 예전 AppPopup의 autoCloseDuration과 같다.
  static const introTimeout = Duration(seconds: 3);

  /// 흔들림 시작부터 첫 MVP 화면으로 넘어가기까지.
  static const teaseHold = Duration(milliseconds: 1300);

  static const switchDuration = Duration(milliseconds: 350);

  /// MVP 화면 연출 시작부터 탭을 받기까지 — 조명이 훑고(2.05초) 캐릭터가 나온 뒤 1초.
  static const entranceDuration = Duration(
    milliseconds: _MvpStage.popAtMs + 1000,
  );

  static Future<void> show({
    required BuildContext context,
    required bool isDarkMode,
    required String? reason,
    required Future<GameResultEntity>? result,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'GameOverIntro',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      transitionBuilder: DialogAnimation.buildTransition,
      pageBuilder: (_, _, _) => GameOverIntroModal(
        isDarkMode: isDarkMode,
        reason: reason,
        result: result,
      ),
    );
  }

  @override
  State<GameOverIntroModal> createState() => _GameOverIntroModalState();
}

class _GameOverIntroModalState extends State<GameOverIntroModal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  // late가 아니다 — 처음 읽는 시점(복귀 시)이 아니라 모달이 뜬 시점 기준이어야 한다.
  final DateTime _introDeadline = DateTime.now().add(
    GameOverIntroModal.introTimeout,
  );

  List<MvpReveal> _reveals = const [];
  bool _minShown = false;
  bool _resultSettled = false;

  /// 흔들림이 시작됐으면 3초 타임아웃으로 닫지 않는다.
  bool _teased = false;
  bool _showTeaseText = false;

  /// 0 = 「게임 종료!」 카드, 1.. = _reveals[_step - 1]
  int _step = 0;

  /// 지금 화면의 연출이 끝나야 탭·뒤로가기를 받는다.
  bool _tapReady = false;
  bool _closed = false;

  /// 단계가 바뀌면 이전 단계의 예약 콜백을 무효화한다.
  int _gen = 0;

  /// 예약한 타이머 — 모달이 닫히면 모두 취소한다.
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final result = widget.result;
    if (result == null) {
      _resultSettled = true;
    } else {
      result.then(
        (entity) {
          _reveals = mvpRevealOrder(
            winnerTeam: entity.winnerTeam,
            policeMvpNickname: entity.policeMvpNickname,
            robberMvpNickname: entity.robberMvpNickname,
          );
          _settle();
        },
        // 실패는 MVP 없음과 같다 — 에러 표시는 결과 다이얼로그가 맡는다.
        onError: (Object _) => _settle(),
      );
    }
    _after(GameOverIntroModal.minIntro, () {
      _minShown = true;
      _maybeTease();
    });
    _after(GameOverIntroModal.introTimeout, () {
      if (!_teased) _close();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final timer in _timers) {
      timer.cancel();
    }
    _shake.dispose();
    super.dispose();
  }

  // 백그라운드에서 3초가 지난 채 돌아오면 카드 단계는 바로 닫는다 (AppPopup과 같은 처리).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_teased &&
        DateTime.now().isAfter(_introDeadline)) {
      _close();
    }
  }

  void _after(Duration delay, VoidCallback action) {
    final gen = _gen;
    _timers.add(
      Timer(delay, () {
        if (mounted && !_closed && gen == _gen) action();
      }),
    );
  }

  void _settle() {
    if (!mounted || _closed) return;
    _resultSettled = true;
    _maybeTease();
  }

  void _maybeTease() {
    if (!_minShown || !_resultSettled || _teased || _reveals.isEmpty) return;
    _teased = true;
    _shake.forward(from: 0);
    _after(
      const Duration(milliseconds: 250),
      () => setState(() => _showTeaseText = true),
    );
    _after(GameOverIntroModal.teaseHold, _next);
  }

  void _next() {
    _gen++;
    if (_step >= _reveals.length) return _close();
    setState(() {
      _step++;
      _tapReady = false;
    });
    _after(
      GameOverIntroModal.switchDuration + GameOverIntroModal.entranceDuration,
      () => setState(() => _tapReady = true),
    );
  }

  void _close() {
    if (_closed || !mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    _closed = true;
    _gen++;
    // 위에 다른 다이얼로그(예: 복귀 시 위치 권한 안내)가 떠 있으면 pop()은 그걸 닫는다.
    // 자기 라우트만 걷어낸다 — AppPopup._closePopup과 같은 처리.
    final navigator = Navigator.of(context);
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  void _onTap() {
    if (_tapReady) _next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reveal = _step == 0 ? null : _reveals[_step - 1];
    final onLightStage = reveal != null && GameTeam.isPolice(reveal.team);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onTap();
      },
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: GameOverIntroModal.switchDuration,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.92, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: reveal == null
                        ? _buildCard(l10n)
                        : _MvpStage(reveal: reveal),
                  ),
                ),
              ),
              // 하단 안내 바 (시안 9085:21588 · 9085:21641, 화면 아래에서 37).
              // 시안의 shadow_vague는 바 전체 불투명도 15%에 묻혀(실효 1.5%) 생략한다.
              Positioned(
                left: AppSpacing.horizontal16,
                right: AppSpacing.horizontal16,
                bottom: 37.h,
                child: AnimatedOpacity(
                  opacity: _tapReady ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: 47.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: onLightStage
                          ? AppColors.black300Alpha15
                          : AppColors.whiteAlpha15,
                      borderRadius: AppRadius.large,
                    ),
                    child: Text(
                      l10n.mvpRevealTapToContinue,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: onLightStage
                            ? AppColors.black400
                            : AppColors.black300,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 예전 「게임 종료」 AppPopup과 같은 카드. 흔들리다 「MVP는 누굴까?!」로 바뀐다.
  Widget _buildCard(AppLocalizations l10n) {
    final dark = widget.isDarkMode;
    return Center(
      child: AnimatedBuilder(
        animation: _shake,
        builder: (_, child) {
          final t = _shake.value;
          final dx = math.sin(t * math.pi * 6) * 14 * (1 - t);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: Container(
          width: double.infinity,
          margin: AppPadding.horizontal36,
          // AppPopup 카드와 같은 안쪽 여백 — 팝업에서 넘어온 티가 나지 않게.
          padding: EdgeInsets.symmetric(vertical: 42.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: dark ? AppColors.black : AppColors.white,
            borderRadius: AppRadius.xxlarge,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showTeaseText
                ? Text(
                    l10n.mvpRevealTease,
                    key: const ValueKey('tease'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.semibold_28.copyWith(
                      color: dark ? AppColors.green : AppColors.blue,
                    ),
                  )
                : Column(
                    key: const ValueKey('over'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.gameOverBannerTitle,
                        textAlign: TextAlign.center,
                        style: dark
                            ? AppTextStyles.robberHeading.copyWith(
                                color: AppColors.green,
                              )
                            : AppTextStyles.heading_20.copyWith(
                                color: AppColors.black,
                              ),
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                      Text(
                        gameOverReasonMessage(l10n, widget.reason),
                        textAlign: TextAlign.center,
                        style: dark
                            ? AppTextStyles.paragraph_14_100.copyWith(
                                color: AppColors.black400,
                              )
                            : AppTextStyles.paragraph_14.copyWith(
                                color: AppColors.black600,
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// 무대형 MVP 화면 (시안 도둑 9085:21586 · 경찰 9085:21639, 연출 FE #679).
///
/// 배경은 보는 사람이 아니라 MVP의 팀을 따른다. 어두운 빈 무대를 천장 조명이 훑다가
/// 가운데에 멈추면, 조명이 꺼지며 캐릭터가 납작하게 눌렸다 쭉 늘어나며 튀어나오고
/// 무대(빛 원·글자)가 켜지며 양옆에서 색종이가 터진다.
class _MvpStage extends StatefulWidget {
  const _MvpStage({required this.reveal});

  final MvpReveal reveal;

  // 연출 시간표(ms) — 앞 화면이 걷히는 동안 이미 어둡다.
  static const sweepStartMs = 300;
  static const sweepEndMs = 2000;
  static const popAtMs = 2050;
  static const popMs = 750;
  static const litMs = 250;
  static const totalMs = popAtMs + popMs;

  @override
  State<_MvpStage> createState() => _MvpStageState();
}

class _MvpStageState extends State<_MvpStage>
    with SingleTickerProviderStateMixin {
  // 시안 393x852 기준 세로 위치. 두 팀 시안이 몇 px씩 달라(무대 247/253) 가운데 값을 쓴다.
  static const _titleTop = 118.0;
  static const _labelTop = 213.0;
  static const _glowTop = 250.0;
  static const _glowSize = 330.0;
  static const _characterTop = 315.0;
  static const _nicknameTop = 572.0;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _MvpStage.totalMs),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// 발끝 기준 쫀득한 등장 — 납작하게 눌렸다(넓고 낮게) 쭉 늘어나고 출렁이며 자리 잡는다.
  static ({double sx, double sy, double dy}) _squash(double p) {
    if (p <= 0) return (sx: 0, sy: 0, dy: 0);
    final grow = 1 - math.pow(1 - (p / 0.22).clamp(0.0, 1.0), 3).toDouble();
    final wobble = -0.38 * math.exp(-4.2 * p) * math.cos(15 * p);
    final hopT = (p / 0.45).clamp(0.0, 1.0);
    final hop = -38 * math.sin(math.pi * hopT) * (1 - hopT);
    return (sx: grow * (1 - wobble * 0.75), sy: grow * (1 + wobble), dy: hop);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final police = GameTeam.isPolice(widget.reveal.team);
    final team = GameTeam.toLowerKey(widget.reveal.team);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ms = _c.value * _MvpStage.totalMs;
        final sinceLit = ms - _MvpStage.popAtMs;
        final lit = (sinceLit / _MvpStage.litMs).clamp(0.0, 1.0);
        final squash = _squash(sinceLit / _MvpStage.popMs);

        Widget at(double top, Widget child) => Positioned(
          left: 0,
          right: 0,
          top: top.h,
          child: Center(child: child),
        );

        return ColoredBox(
          color: police ? AppColors.white : AppColors.black,
          child: Stack(
            children: [
              // 무대(빛 원 → 색종이 → 글자 순) — 조명이 꺼지는 순간 켜진다.
              at(
                _glowTop,
                Opacity(
                  opacity: lit,
                  child: SvgPicture.asset(
                    mvpGlowAssetPath(team: team),
                    width: _glowSize.w,
                    height: _glowSize.w,
                  ),
                ),
              ),
              // 색종이는 빛 원 위, 글자·캐릭터 뒤 — 캐릭터가 나오는 순간 터진다.
              if (sinceLit >= 0) const Positioned.fill(child: MvpConfetti()),
              Opacity(
                opacity: lit,
                child: Stack(
                  children: [
                    at(
                      _titleTop,
                      Text(
                        l10n.mvpRevealTitle,
                        style: AppTextStyles.subHeading_18.copyWith(
                          color: AppColors.black400,
                        ),
                      ),
                    ),
                    at(
                      _labelTop,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontal18,
                          vertical: AppSpacing.vertical6,
                        ),
                        decoration: BoxDecoration(
                          color: police ? AppColors.blue : AppColors.green,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          police
                              ? l10n.labelPoliceTeamMvp
                              : l10n.labelRobberTeamMvp,
                          style: AppTextStyles.subHeading_18.copyWith(
                            color: police ? AppColors.white : AppColors.black,
                          ),
                        ),
                      ),
                    ),
                    // 닉네임과 부제는 한 묶음 — 글자 크기를 키워도 겹치지 않는다(시안 간격 12).
                    at(
                      _nicknameTop,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.role(
                                  isPolice: police,
                                  isDark: !police,
                                ),
                                width: 24.w,
                                height: 24.w,
                              ),
                              SizedBox(width: AppSpacing.horizontal6),
                              Flexible(
                                child: Text(
                                  widget.reveal.nickname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading_24.copyWith(
                                    color: police
                                        ? AppColors.black
                                        : AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.vertical12),
                          Text(
                            police
                                ? l10n.mvpRevealPoliceSubtitle
                                : l10n.mvpRevealRobberSubtitle,
                            style: AppTextStyles.label16Medium.copyWith(
                              color: police
                                  ? AppColors.black600
                                  : AppColors.black300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              at(
                _characterTop,
                Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.translationValues(
                    0,
                    squash.dy.h,
                    0,
                  )..multiply(Matrix4.diagonal3Values(squash.sx, squash.sy, 1)),
                  // 폭은 에셋 원래 크기(도둑 239 · 경찰 217)를 화면 비율로만 늘린다.
                  child: SvgPicture.asset(
                    mvpCharacterAssetPath(team: team),
                    width: (police ? 217 : 239).w,
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: MvpSpotlightPainter(
                      darkness: 1 - lit,
                      sweep:
                          ((ms - _MvpStage.sweepStartMs) /
                                  (_MvpStage.sweepEndMs -
                                      _MvpStage.sweepStartMs))
                              .clamp(0.0, 1.0),
                      beamOn: ((ms - _MvpStage.sweepStartMs) / 150).clamp(
                        0.0,
                        1.0,
                      ),
                      beamStrength: police ? 0.45 : 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
