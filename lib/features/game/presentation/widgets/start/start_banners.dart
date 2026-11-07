import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/character_assets.dart';
import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import 'stripe_banner.dart';

/// ① 역할 배너 — 미션 제목, 내 역할, 크게 잘린 내 팀 캐릭터. 탭해도 넘어가지 않는다.
///
/// 들어오기 0.9초 + 머묾 2.35초 + 나가기 0.7초. 속도선은 머무는 도중에 먼저 빠진다. 다음 장면은 첫 줄이 빠지기 시작하는
/// 3.37초에 [onRevealNext]로 띠 자리에 비친다. 좌표는 앱 기준 크기(393×852)와 같은 시안 값이다.
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

  /// 띠 모양(300 폭 목업 기준). 다음 장면이 같은 모양에서 펼쳐진다([BandTransition]).
  static const bandHeight = 224.4;
  static const bandAngleDegrees = -9.5;
  static const bandOffsetY = -48.1;

  @override
  Widget build(BuildContext context) {
    final band = isPolice ? AppColors.white : AppColors.pureBlack;
    return StripeBanner(
      color: band,
      bandHeight: bandHeight,
      angleDegrees: bandAngleDegrees,
      bandOffsetY: bandOffsetY,
      backdropColor: AppColors.black700,
      // 경찰 시안은 #EAEAEA인데 토큰에 없어 가장 가까운 black100을 쓴다
      edgeColor: isPolice ? AppColors.black100 : AppColors.black800,
      hold: const Duration(milliseconds: 2350),
      onDone: onDone,
      onRevealNext: onRevealNext,
      // 글과 달리 페이드 없이 그어져야 해서 내용 층과 따로 둔다
      decor: (context, _, enter, exit) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            for (final (i, line) in _speedLines.indexed)
              _SpeedLine(
                drawnKey: ValueKey('roleSpeedLine$i'),
                line: line,
                color: band,
                centerY: constraints.maxHeight / 2,
                exit: exit,
              ),
            // 페이드 없이 튀어 올라야 해서 글이 아니라 이 층에 둔다
            _character(constraints.maxHeight, enter, exit),
          ],
        ),
      ),
      overlay: (context, _, enter, exit) => LayoutBuilder(
        builder: (context, constraints) {
          final centerY = constraints.maxHeight / 2;
          return Stack(
            children: [
              Positioned(
                left: 30.w,
                right: AppSpacing.horizontal20,
                top: centerY + (273 - 426).w,
                child: _RoleBannerText(isPolice: isPolice),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 띠와 나란한 속도선. 왼쪽 위는 왼쪽에서, 오른쪽 아래는 오른쪽에서 그어지고, 약 1초 천천히
  /// 흐른 뒤 같은 방향으로 화면 밖으로 빠진다. 앞선 짧은 선이 먼저 나간다. 시간은 배너 시작 기준 밀리초.
  static const _speedLines = [
    (
      x: 84.0,
      y: 208.0,
      length: 224.0,
      fromLeft: true,
      start: 300,
      end: 560,
      outAt: 1620,
    ),
    (
      x: 231.5,
      y: 181.8,
      length: 42.0,
      fromLeft: true,
      start: 520,
      end: 660,
      outAt: 1560,
    ),
    (
      x: 256.6,
      y: 534.6,
      length: 238.0,
      fromLeft: false,
      start: 380,
      end: 640,
      outAt: 1700,
    ),
    (
      x: 102.8,
      y: 560.0,
      length: 42.0,
      fromLeft: false,
      start: 600,
      end: 740,
      outAt: 1640,
    ),
  ];

  /// 아래에서 올라와 오른쪽 아래가 잘린다. 키 큰 폰에서도 같은 만큼 보이게 바닥 기준으로 둔다.
  Widget _character(
    double height,
    Animation<double> enter,
    Animation<double> exit,
  ) {
    final visibleHeight = isPolice ? 317.0 : 305.0;
    return Positioned(
      left: (isPolice ? 29 : 23).w,
      // 짧은 폰에서 모자가 글에 닿지 않게 시안 위치보다 위로는 올리지 않는다
      top: math.max(
        height - visibleHeight.w,
        height / 2 + (426 - visibleHeight).w,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([enter, exit]),
        builder: (context, child) {
          final pose = exit.value > 0
              ? _dropPose(const Interval(0, .43).transform(exit.value))
              : _popPose(const Interval(.33, 1).transform(enter.value));
          return Transform.translate(
            offset: Offset(0, pose.y * visibleHeight.w),
            // 화면 아래 가장자리 부근을 축으로 늘고 눌려야 발이 뜨지 않아 보인다
            child: Transform.scale(
              scaleX: pose.sx,
              scaleY: pose.sy,
              alignment: const Alignment(0, .25),
              child: child,
            ),
          );
        },
        child: SvgPicture.asset(
          startRoleCharacterAssetPath(team: isPolice ? 'police' : 'robber'),
          width: (isPolice ? 427 : 493).w,
        ),
      ),
    );
  }
}

typedef _PopPose = ({double y, double sx, double sy});

_PopPose _lerpPop(_PopPose a, _PopPose b, double t) => (
  y: a.y + (b.y - a.y) * t,
  sx: a.sx + (b.sx - a.sx) * t,
  sy: a.sy + (b.sy - a.sy) * t,
);

/// 쫀득한 등장: 길게 늘어나며 튀어 올라 제자리를 지나치고, 눌리며 내려앉았다가 탱 하고 멈춘다.
/// y는 보이는 높이 대비 비율(1 = 화면 아래, 음수 = 제자리보다 위).
/// 시작 y가 1보다 큰 건 세로로 늘어난 만큼 올라간 윗변까지 화면 밖에 두기 위해서다.
_PopPose _popPose(double t) {
  const start = (y: 1.12, sx: .92, sy: 1.1);
  const peak = (y: -.05, sx: .97, sy: 1.04);
  const squash = (y: .012, sx: 1.05, sy: .94);
  const rebound = (y: -.006, sx: .985, sy: 1.015);
  const rest = (y: 0.0, sx: 1.0, sy: 1.0);
  if (t < .42) {
    return _lerpPop(start, peak, Curves.easeOutCubic.transform(t / .42));
  }
  if (t < .68) {
    return _lerpPop(peak, squash, Curves.easeInOut.transform((t - .42) / .26));
  }
  if (t < .85) {
    return _lerpPop(
      squash,
      rebound,
      Curves.easeInOut.transform((t - .68) / .17),
    );
  }
  // t = 1에서 부동소수 오차로 1을 살짝 넘으면 Curve가 예외를 던진다
  return _lerpPop(
    rebound,
    rest,
    Curves.easeOut.transform(((t - .85) / .15).clamp(0.0, 1.0)),
  );
}

/// 쫀득한 퇴장: 위로 살짝 움찔하며 눌렸다가 길쭉하게 늘어나며 화면 아래로 빠진다.
/// 늘어난 만큼 머리가 올라가므로 1보다 더 내려야 화면 밖으로 완전히 나간다.
_PopPose _dropPose(double t) {
  const rest = (y: 0.0, sx: 1.0, sy: 1.0);
  const rise = (y: -.06, sx: 1.03, sy: .97);
  const gone = (y: 1.2, sx: .94, sy: 1.1);
  if (t < .35) return _lerpPop(rest, rise, Curves.easeOut.transform(t / .35));
  return _lerpPop(
    rise,
    gone,
    const Cubic(.64, 0, .78, 0).transform(((t - .35) / .65).clamp(0.0, 1.0)),
  );
}

typedef _SpeedLineSpec = ({
  double x,
  double y,
  double length,
  bool fromLeft,
  int start,
  int end,
  int outAt,
});

/// 시작점에서 길어지며 그어진 뒤 천천히 흐르다가 진행 방향으로 화면 밖으로 빠진다.
///
/// 글을 읽는 동안 먼저 빠지도록 배너의 머묾과 별개인 자기 시간표로 움직인다.
/// 배너가 탭으로 먼저 나가면 시간표를 기다리지 않고 함께 빠진다.
class _SpeedLine extends StatefulWidget {
  const _SpeedLine({
    required this.drawnKey,
    required this.line,
    required this.color,
    required this.centerY,
    required this.exit,
  });

  final Key drawnKey;
  final _SpeedLineSpec line;
  final Color color;
  final double centerY;
  final Animation<double> exit;

  static const _timeline = Duration(milliseconds: 2100);
  static const _outDuration = 360;

  /// 천천히 흐르는 거리. 가운데에서 시안 자리를 지난다.
  static const _drift = 18.0;

  @override
  State<_SpeedLine> createState() => _SpeedLineState();
}

class _SpeedLineState extends State<_SpeedLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
    vsync: this,
    duration: _SpeedLine._timeline,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!MediaQuery.disableAnimationsOf(context)) _time.forward();
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  double _at(int ms) => ms / _SpeedLine._timeline.inMilliseconds;

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final length = line.length.w;
    final thickness = 18.w;
    final reduce = MediaQuery.disableAnimationsOf(context);
    const outCurve = Cubic(.5, 0, .8, .3);
    return Positioned(
      left: (line.x - line.length / 2).w,
      top: widget.centerY + (line.y - 9 - 426).w,
      child: Transform.rotate(
        angle: RoleBanner.bandAngleDegrees * math.pi / 180,
        child: SizedBox(
          width: length,
          height: thickness,
          child: AnimatedBuilder(
            animation: Listenable.merge([_time, widget.exit]),
            builder: (context, _) {
              final t = _time.value;
              final drawn = reduce
                  ? 1.0
                  : Interval(
                      _at(line.start),
                      _at(line.end),
                      curve: const Cubic(.3, 0, .2, 1),
                    ).transform(t);
              final drift = reduce
                  ? 0.5
                  : Interval(_at(line.end), _at(line.outAt)).transform(t);
              final out = math.max(
                Interval(
                  _at(line.outAt),
                  _at(line.outAt + _SpeedLine._outDuration),
                  curve: outCurve,
                ).transform(t),
                const Interval(
                  0,
                  .4,
                  curve: outCurve,
                ).transform(widget.exit.value),
              );
              final travel =
                  (drift - .5) * _SpeedLine._drift.w +
                  out * (393 + line.length).w;
              return Align(
                alignment: line.fromLeft
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Transform.translate(
                  offset: Offset(line.fromLeft ? travel : -travel, 0),
                  child: Container(
                    key: widget.drawnKey,
                    width: length * drawn,
                    height: thickness,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoleBannerText extends StatelessWidget {
  const _RoleBannerText({required this.isPolice});

  final bool isPolice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = isPolice ? AppColors.blue : AppColors.green;
    final role = isPolice ? l10n.gameRoleCopLabel : l10n.gameRoleRobberLabel;
    final onBand = isPolice ? AppColors.black800 : AppColors.white;
    final title = (isPolice ? l10n.startTitlePolice : l10n.startTitleRobber)
        .split('\n');
    final titleAccent = isPolice
        ? l10n.startTitlePoliceAccent
        : l10n.startTitleRobberAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.startRoleLabel,
          style: AppTextStyles.label16Medium.copyWith(
            color: isPolice ? AppColors.black600 : AppColors.black200,
          ),
        ),
        SizedBox(height: 22.h),
        // 번역 제목이 길면 넘치지 않게 줄인다. 시안의 줄 간격은 토큰 행간과 달라 줄을 따로 놓는다.
        // S-Core Dream은 글자 왼쪽 여백이 Pretendard보다 커서 시작선을 라벨에 맞춘다
        Transform.translate(
          offset: Offset(-5.w, 0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, line) in title.indexed) ...[
                  if (i > 0) SizedBox(height: AppSpacing.vertical18),
                  Text.rich(
                    _accented(line, titleAccent, accent),
                    style: AppTextStyles.scoreDreamExtrabold_45.copyWith(
                      color: onBand,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.vertical24),
        Text.rich(
          _accented(l10n.startRoleSentence(role), role, accent),
          style: AppTextStyles.heading_24.copyWith(color: onBand),
        ),
      ],
    );
  }

  /// [text] 안의 [accent] 부분만 색을 바꾼다. 없으면(앞 줄 등) 그대로 둔다.
  TextSpan _accented(String text, String accent, Color color) {
    final at = text.indexOf(accent);
    if (at < 0) return TextSpan(text: text);
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(
          text: accent,
          style: TextStyle(color: color),
        ),
        TextSpan(text: text.substring(at + accent.length)),
      ],
    );
  }
}
