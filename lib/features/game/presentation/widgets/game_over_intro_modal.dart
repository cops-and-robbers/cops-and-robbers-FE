import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/game_result_reason.dart';
import '../../../../core/constants/game_team.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/game_result_entity.dart';
import 'mvp_reveal_order.dart';

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
  static const entranceDuration = Duration(milliseconds: 1000);

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
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.vertical48,
                child: AnimatedOpacity(
                  opacity: _tapReady ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    l10n.mvpRevealTapToContinue,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.tag_12.copyWith(
                      color: onLightStage
                          ? AppColors.black500
                          : AppColors.black300,
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

/// 무대형 MVP 화면 — 배경은 보는 사람이 아니라 MVP의 팀을 따른다.
/// 캐릭터가 탄성 확대로 먼저 나오고, 라벨·닉네임이 뒤따라 떠오른다.
class _MvpStage extends StatelessWidget {
  const _MvpStage({required this.reveal});

  final MvpReveal reveal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final police = GameTeam.isPolice(reveal.team);
    final teamColor = police ? AppColors.blue : AppColors.green;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: GameOverIntroModal.entranceDuration,
      builder: (_, v, _) {
        final charT = Curves.elasticOut.transform((v / 0.7).clamp(0.0, 1.0));
        final textT = Curves.easeOut.transform(
          ((v - 0.4) / 0.6).clamp(0.0, 1.0),
        );
        return Container(
          color: police ? AppColors.blueVer2_50 : AppColors.black,
          padding: AppPadding.horizontal20,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: textT,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal14,
                      vertical: AppSpacing.vertical6,
                    ),
                    decoration: BoxDecoration(
                      color: teamColor,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      police
                          ? l10n.labelPoliceTeamMvp
                          : l10n.labelRobberTeamMvp,
                      style: AppTextStyles.label_16.copyWith(
                        color: police ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.vertical24),
                Transform.scale(
                  scale: charT,
                  child: SvgPicture.asset(
                    mvpCharacterAssetPath(
                      team: GameTeam.toLowerKey(reveal.team),
                    ),
                    width: 220.w,
                  ),
                ),
                SizedBox(height: AppSpacing.vertical24),
                Opacity(
                  opacity: textT,
                  child: Transform.translate(
                    offset: Offset(0, (1 - textT) * 16),
                    child: Text(
                      reveal.nickname,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.semibold_28.copyWith(
                        color: police ? AppColors.black : AppColors.white,
                      ),
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
}
