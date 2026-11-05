import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';
import '../../../l10n/app_localizations.dart';
import '../buttons/app_button.dart';
import 'tutorial_camera.dart';
import 'tutorial_map_data.dart';
import 'tutorial_map_painter.dart';
import 'tutorial_overlays.dart';
import 'tutorial_script.dart';
import 'tutorial_stage.dart';

class TutorialCopy {
  const TutorialCopy(this.title, this.body);

  final String title;
  final String body;
}

/// 드래그 영역을 찾는 키. 스캔 장면에서 폰을 움직이는 입력을 받는다.
const tutorialStageKey = ValueKey('tutorial_stage');

/// 폰을 돌린 양을 무대 좌표로 바꾼 입력.
///
/// 튜토리얼에서 카메라 권한을 묻지 않으려고 자이로를 쓴다. 폰을 오른쪽으로 돌리면 QR은
/// 왼쪽으로 간다. 센서가 없는 기기에서는 끌기로 움직인다.
Stream<Offset> deviceTiltStream() {
  const interval = SensorInterval.gameInterval;
  final seconds = interval.inMicroseconds / Duration.microsecondsPerSecond;
  const pixelsPerRadian = 250.0;
  return gyroscopeEventStream(samplingPeriod: interval).map(
    (event) => Offset(
      -event.y * pixelsPerRadian * seconds,
      -event.x * pixelsPerRadian * seconds,
    ),
  );
}

/// 지도 한 장에서 카메라와 표시만 바뀌는 튜토리얼 화면.
///
/// 첫 실행 온보딩과 방 입장 튜토리얼이 장면 목록만 달리해 함께 쓴다.
class TutorialPlayer extends StatefulWidget {
  const TutorialPlayer({
    required this.scenes,
    required this.copyOf,
    required this.finishLabel,
    required this.onFinished,
    this.canSkip = true,
    this.tiltStream = deviceTiltStream,
    super.key,
  });

  final List<TutorialScene> scenes;
  final TutorialCopy Function(AppLocalizations l10n, TutorialScene scene)
  copyOf;
  final String Function(AppLocalizations l10n) finishLabel;

  /// 마지막 장면을 넘기거나 건너뛰었을 때.
  final VoidCallback onFinished;
  final bool canSkip;
  final Stream<Offset> Function() tiltStream;

  @override
  State<TutorialPlayer> createState() => _TutorialPlayerState();
}

class _TutorialPlayerState extends State<TutorialPlayer>
    with SingleTickerProviderStateMixin {
  final TutorialStage _stage = TutorialStage();
  late final Ticker _ticker;
  TutorialMapData? _map;
  StreamSubscription<Offset>? _tilt;
  Duration _last = Duration.zero;
  int _index = 0;

  bool get _isLast => _index == widget.scenes.length - 1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _stage.addListener(_onStageChanged);
    _load();
  }

  Future<void> _load() async {
    for (final asset in tutorialSvgAssets) {
      final loader = SvgAssetLoader(asset);
      unawaited(
        svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        ),
      );
    }
    final map = await TutorialMapData.load();
    if (!mounted) return;
    setState(() => _map = map);
    _play(widget.scenes.first);
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _last;
    _last = elapsed;
    if (_stage.needsFrame) _stage.update(delta.inMilliseconds);
  }

  void _onStageChanged() => setState(() {});

  void _play(TutorialScene scene) {
    _tilt?.cancel();
    _tilt = null;
    if (scene == TutorialScene.scan) {
      // 스캔 장면에서만 센서를 켠다. 오류가 나도 끌기로 이어 갈 수 있다.
      try {
        _tilt = widget.tiltStream().listen(
          (delta) => _stage.moveQr(delta.dx, delta.dy),
          onError: (Object _) {},
          cancelOnError: true,
        );
      } on Object catch (_) {
        _tilt = null;
      }
    }
    playScene(scene, _stage);
  }

  void _next() {
    if (_stage.timeline.isPlaying) return;
    if (_isLast) {
      widget.onFinished();
      return;
    }
    final scene = widget.scenes[_index + 1];
    _stage.beginScene(keepQr: scene == TutorialScene.scan);
    setState(() => _index++);
    _play(scene);
  }

  void _skip() {
    VibrationService.instance().buttonTap();
    widget.onFinished();
  }

  @override
  void dispose() {
    _tilt?.cancel();
    _ticker.dispose();
    _stage
      ..removeListener(_onStageChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = _map;
    if (map == null) return const Scaffold(backgroundColor: AppColors.white);

    final theme = _stage.theme;
    final darkVisible = theme['r'] > 0 && theme['h'] < 950;
    final lightVisible = theme['r'] < 950 || theme['h'] > 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (lightVisible) _layer(map, isDark: false),
          if (darkVisible)
            IgnorePointer(
              ignoring: !_stage.dark,
              child: ClipPath(
                clipper: _ThemeClipper(
                  x: theme['x'],
                  y: theme['y'],
                  radius: theme['r'],
                  hole: theme['h'],
                ),
                child: _layer(map, isDark: true),
              ),
            ),
          _frame(
            stageChild: GestureDetector(
              key: tutorialStageKey,
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) =>
                  _stage.moveQr(details.delta.dx, details.delta.dy),
              child: _fitted(
                IgnorePointer(child: TutorialOverlays(stage: _stage)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 무대는 393×486 기준으로 그리고 잘리지 않게 맞춘다. 표시가 모두 이 안에 있어야 한다.
  /// 남는 옆자리는 지도가 그대로 이어져 비어 보이지 않는다.
  Widget _fitted(Widget child) => ClipRect(
    child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: tutorialStageWidth,
        height: tutorialStageHeight,
        child: child,
      ),
    ),
  );

  /// 라이트·다크·표시 레이어가 같은 자리에 맞도록 뼈대를 하나로 둔다.
  ///
  /// 무대 높이는 폭에 맞춘 값을 넘지 않는다. 더 키우면 무대가 늘어나 구역 원 양옆이
  /// 잘린다. 남는 높이는 문구와 버튼 사이로 간다.
  Widget _frame({
    Widget? top,
    required Widget stageChild,
    Widget? copy,
    Widget? button,
  }) => SafeArea(
    child: LayoutBuilder(
      builder: (context, box) {
        final topHeight = AppSpacing.vertical48;
        final gapHeight = AppSpacing.vertical24;
        final copyHeight = 92.h;
        final buttonHeight = 56.h;
        final bottomHeight = AppSpacing.vertical20;
        final fixed =
            topHeight + gapHeight + copyHeight + buttonHeight + bottomHeight;
        final stageHeight = math.min(
          box.maxHeight - fixed,
          box.maxWidth * tutorialStageHeight / tutorialStageWidth,
        );
        return Column(
          children: [
            SizedBox(height: topHeight, child: top),
            SizedBox(height: stageHeight, child: stageChild),
            SizedBox(height: gapHeight),
            SizedBox(height: copyHeight, child: copy),
            const Spacer(),
            SizedBox(height: buttonHeight, child: button),
            SizedBox(height: bottomHeight),
          ],
        );
      },
    ),
  );

  Widget _layer(TutorialMapData map, {required bool isDark}) {
    final l10n = AppLocalizations.of(context);
    final copy = widget.copyOf(l10n, widget.scenes[_index]);
    final playing = _stage.timeline.isPlaying;
    return ColoredBox(
      color: isDark ? AppColors.black : AppColors.white,
      child: _frame(
        top: _topBar(l10n, isDark),
        stageChild: _fitted(
          Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: TutorialMapPainter(
                    stage: _stage,
                    map: map,
                    isDark: isDark,
                  ),
                ),
              ),
              if (_stage.art['op'] > 0)
                Opacity(
                  opacity: _stage.art['op'].clamp(0.0, 1.0),
                  child: Center(
                    child: Transform.scale(
                      scale: _stage.art['sc'],
                      child: SvgPicture.asset(
                        'assets/onboarding/onboarding4.svg',
                        width: 255,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 작은 폰이나 긴 번역에서도 넘치지 않도록 공간에 맞춰 줄인다
        copy: Padding(
          padding: AppPadding.horizontal20,
          child: LayoutBuilder(
            builder: (context, box) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: box.maxWidth,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  // 키를 Opacity에 둬서 앞 장면 문구는 제 값 그대로 사라지게 한다
                  child: Opacity(
                    key: ValueKey(_index),
                    opacity: _stage.view['copy'].clamp(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          copy.title,
                          style:
                              (isDark
                                      ? AppTextStyles.robberHeading24
                                      : AppTextStyles.heading_24)
                                  .copyWith(
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.vertical12),
                        Text(
                          copy.body,
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: isDark
                                ? AppColors.black400
                                : AppColors.black600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        button: Padding(
          padding: AppPadding.horizontal20,
          child: AppButton(
            text: _isLast ? widget.finishLabel(l10n) : l10n.buttonNext,
            onPressed: playing ? null : _next,
            backgroundColor: isDark ? AppColors.green : AppColors.blue,
            foregroundColor: isDark ? AppColors.black : AppColors.white,
            disabledBackgroundColor: isDark
                ? AppColors.black800
                : AppColors.black200,
            disabledForegroundColor: isDark
                ? AppColors.green
                : AppColors.black400,
            textStyle: isDark ? AppTextStyles.robberLabel : null,
          ),
        ),
      ),
    );
  }

  Widget _topBar(AppLocalizations l10n, bool isDark) => Padding(
    padding: AppPadding.horizontal20,
    child: Row(
      children: [
        const Spacer(),
        AnimatedSmoothIndicator(
          activeIndex: _index,
          count: widget.scenes.length,
          effect: ExpandingDotsEffect(
            dotWidth: AppSpacing.horizontal8,
            dotHeight: AppSpacing.horizontal8,
            expansionFactor: 3,
            spacing: AppSpacing.horizontal6,
            dotColor: isDark ? AppColors.black800 : AppColors.black200,
            activeDotColor: isDark ? AppColors.green : AppColors.blue,
          ),
        ),
        // 건너뛰기는 마지막 장에서도 자리를 지킨다. 사라지면 진행 표시가 밀려 보인다.
        Expanded(
          child: widget.canSkip
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: _isLast ? 0 : 1,
                    child: TextButton(
                      onPressed: _isLast ? null : _skip,
                      child: Text(
                        l10n.buttonSkip,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: isDark
                              ? AppColors.black400
                              : AppColors.black500,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );
}

/// 다크 레이어를 드러내는 원. 라이트로 돌아갈 때는 가운데가 뚫린다.
///
/// 무대 좌표를 화면 비율로 옮긴 값이라 작은 폰에서는 중심이 조금 어긋난다.
/// 전환 시작점일 뿐이라 정확히 맞추지 않는다.
class _ThemeClipper extends CustomClipper<Path> {
  const _ThemeClipper({
    required this.x,
    required this.y,
    required this.radius,
    required this.hole,
  });

  static const double _designHeight = 852;
  static const double _stageTop = 107;

  final double x;
  final double y;
  final double radius;
  final double hole;

  @override
  Path getClip(Size size) {
    final center = Offset(
      x / tutorialStageWidth * size.width,
      (y + _stageTop) / _designHeight * size.height,
    );
    final scale = size.height / _designHeight;
    if (hole > 0) {
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addOval(Rect.fromCircle(center: center, radius: hole * scale));
    }
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * scale));
  }

  @override
  bool shouldReclip(_ThemeClipper old) =>
      old.x != x || old.y != y || old.radius != radius || old.hole != hole;
}
