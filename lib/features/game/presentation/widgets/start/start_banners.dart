import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/character_assets.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/services/vibration_service.dart';
import '../../../../../l10n/app_localizations.dart';
import 'run_cycle.dart';
import 'stripe_banner.dart';

/// ① 역할 배너 — 내 팀 캐릭터, 팀 이름, 미션 한 줄. 탭하면 바로 나간다.
///
/// 들어오기 0.9초 + 머묾 2.35초 + 나가기 0.7초. 글은 0.56초부터 3.25초까지 보여
/// 8~9어절(202 WPM 기준 약 2.5초)을 읽을 수 있다. 다음 장면은
/// 첫 줄이 빠지기 시작하는 3.37초에 [onRevealNext]로 띠 자리에 비친다.
class RoleBanner extends StatelessWidget {
  const RoleBanner({
    super.key,
    required this.isPolice,
    required this.onDone,
    this.onRevealNext,
  });

  final bool isPolice;
  final VoidCallback onDone;
  final VoidCallback? onRevealNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onBand = isPolice ? AppColors.white : AppColors.black;
    return StripeBanner(
      color: isPolice ? AppColors.blue : AppColors.green,
      bandHeight: 154,
      hold: const Duration(milliseconds: 2350),
      dimBehind: true,
      tapToSkip: true,
      onDone: onDone,
      onRevealNext: onRevealNext,
      content: (context, s, _, _) => Padding(
        padding: EdgeInsets.only(left: 52 * s),
        child: Row(
          children: [
            SvgPicture.asset(
              startRoleCharacterAssetPath(team: isPolice ? 'police' : 'robber'),
              width: 88 * s,
            ),
            SizedBox(width: 10 * s),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.startRoleLabel,
                    style: AppTextStyles.tag_14.copyWith(color: onBand),
                  ),
                  SizedBox(height: 6 * s),
                  Text(
                    isPolice ? l10n.gameRoleCopLabel : l10n.gameRoleRobberLabel,
                    style: AppTextStyles.semibold_28.copyWith(color: onBand),
                  ),
                  SizedBox(height: 6 * s),
                  SizedBox(
                    width: 160 * s,
                    child: Text(
                      isPolice
                          ? l10n.startMissionPolice
                          : l10n.startMissionRobber,
                      style: AppTextStyles.paragraph_14.copyWith(color: onBand),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ④ 출동 배너 — 쥐와 고양이가 달려 들어온다. 터치를 막지 않고(지도를 바로 써야 한다)
/// 처음 뜰 때 팀별로 다르게 진동해 화면을 안 봐도 알 수 있게 한다.
class DispatchBanner extends StatefulWidget {
  const DispatchBanner({
    super.key,
    required this.isPolice,
    required this.onDone,
    this.fromFoldedScene = false,
  });

  final bool isPolice;
  final VoidCallback onDone;

  /// 대기·설명 장면이 띠 모양으로 접힌 자리에서 이어진다(줄이 빨려 들지 않는다)
  final bool fromFoldedScene;

  /// 목업 기준 띠 높이. 210은 글과 캐릭터 사이가 비어 너무 컸다 — 장면이 접히는 띠도 같은 높이.
  static const bandHeight = 168.0;

  @override
  State<DispatchBanner> createState() => _DispatchBannerState();
}

class _DispatchBannerState extends State<DispatchBanner> {
  @override
  void initState() {
    super.initState();
    VibrationService.instance().policeDispatch(isPolice: widget.isPolice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPolice = widget.isPolice;
    final onBand = isPolice ? AppColors.white : AppColors.black;
    return StripeBanner(
      color: isPolice ? AppColors.blue : AppColors.green,
      bandHeight: DispatchBanner.bandHeight,
      hold: const Duration(milliseconds: 1700),
      filledStart: widget.fromFoldedScene,
      onDone: widget.onDone,
      content: (context, s, enter, exit) => Stack(
        children: [
          Positioned(
            top: 14 * s,
            left: 45 * s,
            width: 300 * s,
            child: Column(
              children: [
                Text(
                  isPolice ? l10n.dispatchPoliceLead : l10n.dispatchRobberLead,
                  style: AppTextStyles.tag_14.copyWith(color: onBand),
                ),
                SizedBox(height: 5 * s),
                Text(
                  isPolice ? l10n.dispatchPoliceMain : l10n.dispatchRobberMain,
                  style: AppTextStyles.semibold_28.copyWith(color: onBand),
                ),
              ],
            ),
          ),
          // 그림자 뺀 그림이라 예전(그림자 포함 높이 74·88, 바닥 8)과 같은 크기·발 위치가 되게 폭과 바닥을 맞췄다
          _runner(
            team: 'robber',
            left: 205,
            width: 65,
            bottom: 18,
            start: .58,
            s: s,
            enter: enter,
            exit: exit,
          ),
          _runner(
            team: 'police',
            left: 95,
            width: 69,
            bottom: 14,
            start: .76,
            s: s,
            enter: enter,
            exit: exit,
          ),
        ],
      ),
    );
  }

  /// 왼쪽 밖에서 달려 들어온다. 고양이는 쥐보다 0.16초 늦게.
  /// 나갈 땐 0.3초에 오른쪽으로 달려 나간다(고양이 0.09초 늦게, 시안 bannerOut).
  Widget _runner({
    required String team,
    required double left,
    required double width,
    required double bottom,
    required double start,
    required double s,
    required Animation<double> enter,
    required Animation<double> exit,
  }) {
    // 나가기는 띠 전체 0.7초 기준 — 시안처럼 글보다 먼저 떠나려면 StripeBanner가
    // 내용 퇴장을 늦춰야 해서, 글이 0.2초에 사라지는 동안 함께 달려 나간다
    final outStart = team == 'police' ? 90 : 0;
    final out = Interval(
      outStart / 700,
      (outStart + 300) / 700,
      curve: const Cubic(.64, 0, .78, 0),
    );
    return Positioned(
      left: left * s,
      bottom: bottom * s,
      child: AnimatedBuilder(
        animation: Listenable.merge([enter, exit]),
        builder: (context, child) {
          final t = Interval(
            start,
            1,
            curve: const Cubic(.22, 1, .36, 1),
          ).transform(enter.value);
          final o = out.transform(exit.value);
          return Transform.translate(
            offset: Offset((-300 * (1 - t) + 340 * o) * s, 0),
            child: child,
          );
        },
        child: RunCycle(
          scale: s,
          period: Duration(milliseconds: team == 'police' ? 460 : 500),
          delay: Duration(milliseconds: team == 'police' ? 230 : 0),
          child: SvgPicture.asset(
            startChaseCharacterAssetPath(team: team),
            width: width * s,
          ),
        ),
      ),
    );
  }
}
