import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/app_shadows.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../dialogs/dialog_animation.dart';
import 'tutorial_stage.dart';

const _copChase = 'assets/characters/police/start/default/chase.svg';
const _robChase = 'assets/characters/robber/start/default/chase.svg';
const _jailed = 'assets/characters/robber/default/jailed.svg';
const _caught = 'assets/characters/robber/result/default/lose_body.svg';
const _outed = 'assets/characters/robber/default/not_ready.svg';
const _homepageQr = 'assets/onboarding/homepage_qr.png';

/// 처음 뜰 때 그림이 한 박자 늦게 나오지 않도록 미리 읽어 둘 목록.
const tutorialSvgAssets = [
  _copChase,
  _robChase,
  _jailed,
  _caught,
  _outed,
  AppIcons.shoeprint,
  AppIcons.qrCode,
  AppIcons.qrScan,
  AppIcons.copy,
  AppIcons.zoneExit,
  'assets/profiles/1.svg',
  'assets/profiles/2.svg',
  'assets/onboarding/onboarding4.svg',
];

/// 지도 위 인물과 앱 화면 표시. 라이트·다크 전환과 상관없이 맨 위에 그린다.
///
/// 좌표는 무대 기준 크기(393×486)다.
class TutorialOverlays extends StatelessWidget {
  const TutorialOverlays({required this.stage, super.key});

  final TutorialStage stage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = stage.q;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _actor(stage.cop, SvgPicture.asset(_copChase, width: 92)),
        _actor(
          stage.rob,
          SvgPicture.asset(_robChase, width: 92),
          isRobber: true,
        ),
        _actor(stage.jailed, SvgPicture.asset(_jailed, width: 130)),
        _actor(stage.ally, SvgPicture.asset(_robChase, width: 92)),
        _actor(stage.caught, SvgPicture.asset(_caught, width: 104)),
        _actor(stage.outed, SvgPicture.asset(_outed, width: 110)),
        _actor(stage.dot, const _LocationDot()),
        _actor(
          stage.paw,
          // 도둑 시점 지도에서는 발자국도 도둑 강조색으로 그린다
          SvgPicture.asset(
            AppIcons.shoeprint,
            width: 54,
            height: 38,
            colorFilter: stage.dark
                ? const ColorFilter.mode(AppColors.green, BlendMode.srcIn)
                : null,
          ),
        ),
        // OpenStreetMap 데이터 사용 조건(ODbL)상 지도가 보이는 동안 표기한다
        if (stage.art['op'] <= 0)
          Positioned(
            right: 8,
            bottom: 4,
            child: Text(
              '© OpenStreetMap contributors',
              style: AppTextStyles.tag_10.copyWith(
                color: stage.dark ? AppColors.black400 : AppColors.black600,
              ),
            ),
          ),
        _fade(q['fab'], _fab()),
        _fade(
          q['bar'],
          Positioned(
            left: -800,
            top: -800,
            right: -800,
            bottom: -800,
            child: ColoredBox(color: DialogAnimation.barrierColor),
          ),
        ),
        _fade(q['item'], _myQrItem(l10n)),
        _fade(q['hand'], _heldPhone()),
        _fade(q['tg'], _qrTarget()),
        _fade(q['fr'], _scanFrame()),
        _fade(q['tilt'], _tiltHint()),
        _fade(
          q['flash'],
          Positioned(
            left: 126,
            top: 173,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.xlarge,
              ),
            ),
          ),
        ),
        _fade(
          q['rip'],
          Positioned(
            left: q['rx'],
            top: q['ry'],
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
        ),
        _fade(q['fb'], _callout(l10n)),
        _fade(q['inv'], _inviteCard(l10n)),
        for (final (key, left, asset) in const [
          ('a1', 104.5, 'assets/profiles/1.svg'),
          ('a2', 168.5, 'assets/profiles/2.svg'),
          ('a3', 232.5, 'assets/profiles/1.svg'),
        ])
          _fade(q[key], _avatar(q[key], left, asset)),
        _fade(q['tm'], _timer()),
        _fade(q['zb'], _zoneExitBanner(l10n)),
      ],
    );
  }

  /// 투명할 때는 그리지 않는다. 표시가 많아 매 프레임 비용이 쌓인다.
  Widget _fade(double opacity, Positioned positioned) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned(
      left: positioned.left,
      top: positioned.top,
      right: positioned.right,
      bottom: positioned.bottom,
      width: positioned.width,
      height: positioned.height,
      child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: positioned.child),
    );
  }

  Widget _actor(TutorialActor a, Widget child, {bool isRobber = false}) {
    if (a['op'] <= 0) return const SizedBox.shrink();
    final run = stage.run;
    final p = stage.cameraFrame().project(a['x'], a['y']);
    final fleeing = isRobber && run['v'] > .02;
    final runT = run['t'];
    final speed = run['v'];
    final progress = stage.escape['p'];
    final hurry = isRobber && stage.escaping && progress > 0 && progress < 1
        ? math.min(1.0, (1 - progress) * 5)
        : 0.0;
    final now = stage.clockMs * .015;
    final zigzag = fleeing ? math.sin(runT * 5) * 26 * speed : 0.0;
    final hop = fleeing
        ? math.sin(runT * 13).abs() * 16 * speed
        : math.sin(now).abs() * 13 * hurry;
    final tiltDeg = fleeing
        ? math.sin(runT * 13) * 8 * speed
        : math.sin(now) * 7 * hurry;
    final mirror = fleeing && math.cos(runT * 5) < 0 ? -1.0 : 1.0;
    final scale = a['sc'] * math.min(1.9, p.k);

    return Positioned(
      left: p.x - a.width / 2 + zigzag,
      top: p.y - (a.centered ? a.height / 2 : a.height) - hop,
      width: a.width,
      height: a.height,
      child: Opacity(
        opacity: a['op'].clamp(0.0, 1.0),
        child: Transform(
          alignment: a.centered ? Alignment.center : Alignment.bottomCenter,
          transform: Matrix4.identity()
            ..rotateZ(tiltDeg * math.pi / 180)
            ..scaleByDouble(mirror * scale, scale, 1, 1),
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            alignment: a.centered ? Alignment.center : Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
    );
  }

  Positioned _fab() => Positioned(
    left: 168.5,
    top: 410,
    child: Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.green,
        shape: BoxShape.circle,
      ),
      child: Transform.rotate(
        angle: math.pi / 4,
        child: const Icon(Icons.add, color: AppColors.black, size: 40),
      ),
    ),
  );

  // 실제 플로팅 메뉴처럼 내 QR은 오른쪽에 있다
  Positioned _myQrItem(AppLocalizations l10n) => Positioned(
    left: 276,
    top: 326,
    width: 88,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
            boxShadow: AppShadows.softThemed(true),
          ),
          child: SvgPicture.asset(AppIcons.qrCode, width: 32, height: 32),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.gameMenuMyQr,
          style: AppTextStyles.robberParagraph.copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Positioned _heldPhone() {
    final q = stage.q;
    final run = stage.run;
    return Positioned(
      right: 4,
      bottom: -96,
      width: 132,
      height: 250,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..translateByDouble(
            0,
            q['hy'] + math.sin(run['t'] * 18) * 10 * run['v'],
            0,
            1,
          )
          ..rotateZ(
            (-6 + math.sin(run['t'] * 9) * 2.5 * run['v']) * math.pi / 180,
          )
          ..scaleByDouble(q['hs'], q['hs'], 1, 1),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: AppRadius.xxlarge,
            border: Border.all(color: AppColors.black800, width: 2),
          ),
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              color: AppColors.black900,
              borderRadius: AppRadius.xlarge,
            ),
            child: Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blue, width: 2),
                borderRadius: AppRadius.large,
              ),
              child: SvgPicture.asset(AppIcons.qrScan, width: 40, height: 40),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _qrTarget() => Positioned(
    left: stage.qrX - 152,
    top: stage.qrY - 80,
    width: 232,
    height: 180,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 72,
          top: 0,
          child: Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: AppRadius.xlarge,
              border: Border.all(color: AppColors.black800, width: 2),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.medium,
              ),
              child: Image.asset(_homepageQr, fit: BoxFit.contain),
            ),
          ),
        ),
        Positioned(
          left: -14,
          top: 92,
          child: SvgPicture.asset(
            stage.targetCaught ? _caught : _robChase,
            width: 92,
          ),
        ),
      ],
    ),
  );

  Positioned _scanFrame() => Positioned(
    left: 71.5,
    top: 118,
    width: 250,
    height: 250,
    child: CustomPaint(painter: _ScanFramePainter(stage.holdProgress)),
  );

  // 폰을 움직이라는 힌트. QR을 찍을 때까지 계속 떠 있는다.
  Positioned _tiltHint() {
    final phase = (stage.clockMs / 1400 * 2 * math.pi);
    return Positioned(
      left: 176,
      top: 40,
      child: Transform.rotate(
        angle: math.sin(phase) * 16 * math.pi / 180,
        child: Container(
          width: 40,
          height: 64,
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.blue, width: 3),
            borderRadius: AppRadius.medium,
          ),
          child: Container(width: 10, height: 3, color: AppColors.blue),
        ),
      ),
    );
  }

  Positioned _callout(AppLocalizations l10n) => Positioned(
    left: 0,
    right: 0,
    top: 64,
    child: Transform.scale(
      scale: .8 + .2 * stage.q['fb'],
      child: Text(
        stage.callout == TutorialCallout.arrest
            ? l10n.tutorialCalloutArrest
            : l10n.tutorialCalloutTouch,
        textAlign: TextAlign.center,
        style: AppTextStyles.semibold_28.copyWith(
          color: AppColors.blue,
          shadows: const [Shadow(color: AppColors.white, blurRadius: 8)],
        ),
      ),
    ),
  );

  // 실제 초대코드 창과 같은 문구·구성이다. 코드와 QR은 예시 값이다.
  Positioned _inviteCard(AppLocalizations l10n) => Positioned(
    left: 44.5,
    top: 20,
    width: 304,
    child: Transform.scale(
      scale: .9 + .1 * stage.q['inv'],
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dialogInviteCodeCreatedTitle,
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.dialogInviteCodeShareMessage,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Image.asset(_homepageQr, width: 150, height: 150),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A3F9K2',
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  AppIcons.copy,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black300,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Positioned _avatar(double value, double left, String asset) => Positioned(
    left: left,
    top: 414,
    child: Transform.scale(
      scale: .6 + .4 * value,
      child: Container(
        width: 56,
        height: 56,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.ver2,
        ),
        child: SvgPicture.asset(asset, fit: BoxFit.cover),
      ),
    ),
  );

  Positioned _timer() {
    final seconds = stage.q['sec'].floor();
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Positioned(
      left: 136.5,
      top: 12,
      child: Container(
        width: 120,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.pill,
          boxShadow: AppShadows.ver2,
        ),
        child: Text(
          '$mm:$ss',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
    );
  }

  // 게임 화면의 ZoneExitBanner와 같은 모양이다
  Positioned _zoneExitBanner(AppLocalizations l10n) => Positioned(
    left: 20,
    right: 20,
    top: 60 - 10 * (1 - stage.q['zb']),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.zoneExit,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.gameZoneExitBanner,
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LocationDot extends StatelessWidget {
  const _LocationDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      color: AppColors.blue,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.white, width: 3),
    ),
  );
}

class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 4.0;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(inset),
      const Radius.circular(32),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.blue500,
    );
    if (progress <= 0) return;
    final path = Path()..addRRect(rrect);
    final gauge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = AppColors.blue;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), gauge);
    }
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
