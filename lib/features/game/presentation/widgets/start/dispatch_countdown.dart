import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/services/sound_service.dart';
import '../../../../../core/services/vibration_service.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/start_flow.dart';

/// ④ 출동 카운팅 — 출동 5초 전부터 화면 전체를 덮고 5, 4, 3, 2, 1, "출동!"을 센 뒤
/// 사이렌 자리에서 원형으로 열리며 아래 지도를 드러낸다.
///
/// 4초부터 사이렌 뒤에서 빨강·파랑 빛줄기가 옅게 돌기 시작해 1초에 가장 세진다.
/// 모든 시각은 [releaseAt]과 기기 시계로 정한다 — 여러 폰이 같은 순간에 같은 숫자를 보인다.
/// 좌표는 앱 기준 크기(393×852) 시안 값(피그마 9085:22970·9085:24486)이다.
class DispatchCountdown extends StatefulWidget {
  const DispatchCountdown({
    super.key,
    required this.releaseAt,
    required this.onDone,
    this.now,
    this.siren,
  });

  final DateTime releaseAt;
  final VoidCallback onDone;

  /// 기기 시계. 테스트가 시계를 대신 넣을 때만 쓴다.
  final DateTime Function()? now;

  /// 사이렌 켜기·끄기. 테스트가 스피커를 대신 넣을 때만 쓴다.
  final void Function(bool on)? siren;

  static const designWidth = 393.0;

  @override
  State<DispatchCountdown> createState() => _DispatchCountdownState();
}

class _DispatchCountdownState extends State<DispatchCountdown>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // 시안 크기: 사이렌 185×229, 사이렌 아래 46 띄우고 숫자 80
  static const _sirenWidth = 185.0;
  static const _sirenHeight = 229.0;
  static const _gap = 46.0;
  static const _numberHeight = 80.0;

  /// 빛줄기가 도는 중심 — 사이렌 몸통 가운데(사이렌 위에서 152)
  static const _pivotFromSirenTop = 152.0;

  late final Ticker _ticker;
  late DispatchCountdownFrame _frame;

  /// 마지막으로 진동한 초. 나올 수 없는 값(0)에서 시작해 첫 프레임의 초도 울린다.
  int? _seconds = 0;
  Duration _elapsed = Duration.zero;
  Duration _secondStartedAt = Duration.zero;
  double _angle = 0;
  bool _doneCalled = false;
  bool _sirenOn = false;
  final _random = math.Random();

  DateTime _now() => (widget.now ?? clock.now)();

  @override
  void initState() {
    super.initState();
    _frame = dispatchCountdownFrame(releaseAt: widget.releaseAt, now: _now());
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addObserver(this);
    // 덮는 1초 동안 꺼내 두면 "출동!"과 소리가 같이 나온다
    if (widget.siren == null) SoundService.instance().preloadSiren();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setSiren(false);
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _elapsed).inMicroseconds / 1e6;
    _elapsed = elapsed;
    final frame = dispatchCountdownFrame(
      releaseAt: widget.releaseAt,
      now: _now(),
    );
    if (frame.seconds != _seconds) {
      _seconds = frame.seconds;
      _secondStartedAt = elapsed;
      // 화면을 덮는 동안(6)은 아직 세지 않는다 — 대기 화면이 6까지 울린다
      if (!_covering(frame)) _cue(frame.seconds);
    }
    // 세질수록 빨리 돈다(초당 80° → 840°)
    _angle += dt * (80 + 760 * frame.intensity);
    setState(() => _frame = frame);
    if (frame.done && !_doneCalled) {
      _doneCalled = true;
      widget.onDone();
    }
  }

  bool _covering(DispatchCountdownFrame f) => f.cover < 1;

  bool get _appVisible {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  // 주머니 속에서 울리지 않게 끈다. 한 번만 트는 소리라 돌아와도 다시 틀지 않는다
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _setSiren(false);
  }

  /// 바뀔 때만 스피커에 알린다.
  void _setSiren(bool on) {
    if (on == _sirenOn) return;
    _sirenOn = on;
    (widget.siren ?? SoundService.instance().siren)(on);
  }

  /// 5~1초는 초마다 점점 세게 진동, "출동!"에는 가장 센 진동과 사이렌 한 번. 경찰·도둑 같다.
  /// 사이렌 음원은 "출동!"부터 원형 열기 끝까지(2.2초)에 맞춰 잘라 둬서 스스로 끝난다.
  /// 화면을 끈 채면 울리지 않는다 — 주머니 속에서 울리지 않게.
  void _cue(int? seconds) {
    if (!_appVisible) return;
    final vibration = VibrationService.instance();
    if (seconds == null) {
      vibration.dispatchGo();
      _setSiren(true);
    } else {
      vibration.dispatchCountdownBeat(seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final f = _frame;
    final intensity = reduce ? 0.0 : f.intensity;
    final sinceSecond = (_elapsed - _secondStartedAt).inMicroseconds / 1e6;
    final go = f.seconds == null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final s = size.width / DispatchCountdown.designWidth;
        // 사이렌 + 간격 + 숫자 묶음을 세로 가운데에 둔다(시안 852 높이에서 사이렌 위 252)
        final groupTop =
            (size.height - (_sirenHeight + _gap + _numberHeight) * s) / 2;
        final pivot = Offset(size.width / 2, groupTop + _pivotFromSirenTop * s);
        // 초가 바뀌면 숫자가 1.2배로 커졌다 0.25초에 돌아온다(대기 화면과 같은 강조)
        final pop = reduce
            ? 1.0
            : 1 + 0.2 * math.max(0, 1 - sinceSecond / 0.25);
        // 사이렌이 초마다 번쩍 달아올랐다 가라앉는다
        final flare = math.max(0.0, 1 - sinceSecond / (go ? 0.3 : 0.45));
        final glow = intensity > 0
            ? (4 + 62 * intensity) * (0.6 + 0.4 * flare) * s
            : 0.0;

        // 1초 구간에만 살짝 떨린다
        var shake = Offset.zero;
        if (!reduce && f.seconds == 1) {
          final a = 3 * s * (1 - math.min(1.0, sinceSecond) * 0.5);
          shake = Offset(
            (_random.nextDouble() - 0.5) * 2 * a,
            (_random.nextDouble() - 0.5) * 2 * a,
          );
        }

        final content = Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppColors.pureBlack),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _BeamPainter(
                  pivot: pivot,
                  angleDegrees: _angle,
                  intensity: intensity,
                  scale: s,
                ),
              ),
            ),
            // 1초 구간의 떨림은 사이렌·숫자만 — 바탕까지 밀면 가장자리 틈으로 아래 화면이 비친다
            Positioned.fill(
              child: Transform.translate(
                offset: shake,
                child: Stack(
                  children: [
                    // 사이렌 모양을 따라 빨갛게 번진다 — 초가 바뀔 때 커졌다 가라앉는다
                    if (glow > 0)
                      Positioned(
                        left: (size.width - _sirenWidth * s) / 2,
                        top: groupTop,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: glow / 2,
                            sigmaY: glow / 2,
                            tileMode: TileMode.decal,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.sirenCounting,
                            width: _sirenWidth * s,
                            height: _sirenHeight * s,
                            colorFilter: const ColorFilter.mode(
                              AppColors.red,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: (size.width - _sirenWidth * s) / 2,
                      top: groupTop,
                      child: SvgPicture.asset(
                        AppIcons.sirenCounting,
                        width: _sirenWidth * s,
                        height: _sirenHeight * s,
                      ),
                    ),
                    Positioned(
                      left: 16 * s,
                      right: 16 * s,
                      top: groupTop + (_sirenHeight + _gap) * s,
                      height: _numberHeight * s,
                      child: Center(
                        child: Transform.scale(
                          scale: pop,
                          // 긴 문구(큰 글씨 설정 등)도 좌우 16 안에 들어오게 줄인다
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              go
                                  ? l10n.dispatchCountdownGo
                                  : _covering(f)
                                  ? ''
                                  : '${f.seconds}',
                              maxLines: 1,
                              style: AppTextStyles.scoreDreamExtrabold_80
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        // 구멍은 사이렌에서 가장 먼 화면 모서리까지 커져야 화면 전체다
        final farthest = [
          Offset.zero,
          Offset(size.width, 0),
          Offset(0, size.height),
          Offset(size.width, size.height),
        ].map((c) => (c - pivot).distance).reduce(math.max);

        // 들어올 때: 장면·지도가 보이는 구멍이 사이렌 쪽으로 닫힌다(나갈 때를 거꾸로).
        // 덮는 동안에도 보이는 장면은 누르지 못하게 막는다 — 곧 가려진다.
        if (_covering(f) && !reduce) {
          final radius = (1 - Curves.easeInOut.transform(f.cover)) * farthest;
          return AbsorbPointer(
            child: ClipPath(
              clipper: _IrisClipper(center: pivot, radius: radius),
              child: content,
            ),
          );
        }

        // 원형 열기 동안은 아래 지도를 바로 만질 수 있게 터치를 넘긴다.
        // 그 전에는 검은 화면 아래(보이지 않는 지도·장면)를 누르지 않게 막는다.
        if (f.iris > 0 && !reduce) {
          final radius = Curves.easeInOut.transform(f.iris) * farthest;
          return IgnorePointer(
            child: ClipPath(
              clipper: _IrisClipper(center: pivot, radius: radius),
              child: content,
            ),
          );
        }
        return AbsorbPointer(child: content);
      },
    );
  }
}

/// 사이렌 뒤에서 도는 빨강·파랑 빛줄기와 화면 물듦.
class _BeamPainter extends CustomPainter {
  const _BeamPainter({
    required this.pivot,
    required this.angleDegrees,
    required this.intensity,
    required this.scale,
  });

  final Offset pivot;
  final double angleDegrees;
  final double intensity;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final full = Offset.zero & size;

    // 빛줄기가 향한 쪽 화면을 그 색으로 물들인다(빨강이 위, 파랑이 반대편에서 출발)
    final toward = (angleDegrees - 90) * math.pi / 180;
    final reach = size.longestSide * 0.55;
    final redAt = Offset(
      size.width * (0.5 + 0.6 * math.cos(toward)),
      size.height * (0.47 + 0.6 * math.sin(toward)),
    );
    final blueAt = Offset(size.width - redAt.dx, size.height * 0.94 - redAt.dy);
    final tint = 0.5 * intensity * intensity;
    for (final (at, color) in [
      (redAt, AppColors.red),
      (blueAt, AppColors.blueVer2Strong),
    ]) {
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: tint),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: at, radius: reach)),
      );
    }

    // 빛줄기: 좁고 진한 심지 + 뒤에서 겹쳐 들어오는 넓은 번짐. 바깥으로 갈수록 사라진다
    final beamRadius = 900 * scale;
    final beamRect = Rect.fromCircle(center: pivot, radius: beamRadius);
    final rotation = GradientRotation(
      angleDegrees * math.pi / 180 - math.pi / 2,
    );
    canvas.saveLayer(beamRect, Paint());
    _drawBeams(
      canvas,
      beamRect,
      rotation,
      widthDeg: 26,
      alpha: 0.18 + 0.82 * intensity,
    );
    final spread = ((intensity - 0.25) / 0.6).clamp(0.0, 1.0);
    if (spread > 0) {
      _drawBeams(
        canvas,
        beamRect,
        rotation,
        widthDeg: 70,
        alpha: 0.55 * spread,
      );
    }
    canvas.drawRect(
      beamRect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const RadialGradient(
          colors: [Color(0xFF000000), Color(0xD9000000), Color(0x00000000)],
          stops: [0.06, 0.3, 0.7],
        ).createShader(beamRect),
    );
    canvas.restore();
  }

  /// 빨강·파랑 빛줄기 한 쌍(180° 반대편)을 원 하나에 그린다.
  void _drawBeams(
    Canvas canvas,
    Rect rect,
    GradientRotation rotation, {
    required double widthDeg,
    required double alpha,
  }) {
    final w = widthDeg / 360;
    final red = AppColors.red.withValues(alpha: alpha);
    final blue = AppColors.blueVer2Strong.withValues(alpha: alpha);
    const clear = Color(0x00000000);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = SweepGradient(
          transform: rotation,
          colors: [clear, red, clear, clear, blue, clear, clear],
          stops: [0, w / 2, w, 0.5, 0.5 + w / 2, 0.5 + w, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BeamPainter old) =>
      old.angleDegrees != angleDegrees ||
      old.intensity != intensity ||
      old.pivot != pivot ||
      old.scale != scale;
}

/// 화면에서 원 하나를 뚫는다 — 뚫린 자리로 아래 지도가 보인다.
class _IrisClipper extends CustomClipper<Path> {
  const _IrisClipper({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_IrisClipper old) =>
      old.radius != radius || old.center != center;
}
