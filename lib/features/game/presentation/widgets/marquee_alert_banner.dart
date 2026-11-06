import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 인게임 알림 배너 — 슬라이드 인 + 텍스트 항상 우→좌 마퀴 + 페이드아웃
///
/// 배너 컨테이너는 고정, 내부 텍스트만 우측에서 좌측으로 반복 스크롤.
class MarqueeAlertBanner extends StatefulWidget {
  const MarqueeAlertBanner({
    required this.message,
    this.isDarkMode = false,
    this.displayDuration = const Duration(seconds: 8),
    this.fadeOutDuration = const Duration(milliseconds: 800),
    this.slideInDuration = const Duration(milliseconds: 300),
    this.horizontalMargin,
    super.key,
  });

  final String message;
  final bool isDarkMode;
  final Duration displayDuration;
  final Duration fadeOutDuration;
  final Duration slideInDuration;

  /// 화면 가장자리와 배너 사이 여백. 없으면 20 — 시작 장면은 카드 줄에 맞춰 바꾼다.
  final double? horizontalMargin;

  /// 배너 한 장의 높이(위아래 여백 12 + 아이콘 20과 글자 한 줄 중 큰 쪽).
  /// 시작 장면이 공지가 없을 때도 이만큼 자리를 비워 둬 카드가 움직이지 않게 한다.
  static double heightFor({required bool isDarkMode}) {
    final painter = TextPainter(
      text: TextSpan(
        text: ' ',
        style: _MarqueeAlertBannerState._styleFor(isDarkMode),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final line = painter.height;
    painter.dispose();
    return 12.h * 2 + (line > 20.w ? line : 20.w);
  }

  @override
  State<MarqueeAlertBanner> createState() => _MarqueeAlertBannerState();
}

class _MarqueeAlertBannerState extends State<MarqueeAlertBanner>
    with TickerProviderStateMixin {
  // ── 슬라이드 인 (배너 등장) ──
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  // ── 페이드 아웃 (배너 퇴장) ──
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  Timer? _fadeOutTimer;

  // ── 마퀴 (텍스트 우→좌 반복) ──
  late AnimationController _marqueeController;

  double get _margin => widget.horizontalMargin ?? 20.w;

  /// 마퀴 1사이클 시간 (초)
  static const int _cycleSeconds = 8;

  /// 텍스트 스타일 (라이트: paragraph14Semibold, 다크: robberParagraph)
  TextStyle get _textStyle => _styleFor(widget.isDarkMode);

  static TextStyle _styleFor(bool isDarkMode) =>
      (isDarkMode
              ? AppTextStyles.robberParagraph
              : AppTextStyles.paragraph14Semibold)
          .copyWith(color: AppColors.white);

  @override
  void initState() {
    super.initState();

    // 슬라이드 인
    _slideController = AnimationController(
      vsync: this,
      duration: widget.slideInDuration,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();

    // 페이드 아웃
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeOutDuration,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scheduleFadeOut();

    // 마퀴 — 항상 우→좌 반복 (1사이클 _cycleSeconds초)
    _marqueeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _cycleSeconds),
    )..repeat();
  }

  @override
  void didUpdateWidget(MarqueeAlertBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _slideController.forward(from: 0);
      _fadeController.reset();
      _scheduleFadeOut();
      // repeat 모드 유지 (forward는 1회 재생으로 바뀌므로 repeat 재호출)
      _marqueeController
        ..reset()
        ..repeat();
    }
  }

  void _scheduleFadeOut() {
    _fadeOutTimer?.cancel();
    _fadeOutTimer = Timer(widget.displayDuration, () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeOutTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _margin),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.red900,
              borderRadius: AppRadius.large,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                // 다색 svg라 틴트하지 않고 원본 색 그대로 그린다.
                SvgPicture.asset(
                  AppIcons.loudspeaker,
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: AppSpacing.horizontal8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textHeight = _measureTextSize(
                        widget.message,
                      ).height;
                      return SizedBox(
                        height: textHeight,
                        child: ClipRect(
                          child: OverflowBox(
                            maxWidth: double.infinity,
                            maxHeight: textHeight,
                            alignment: Alignment.centerLeft,
                            child: _buildMarquee(constraints.maxWidth),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 텍스트가 칸 오른쪽 끝에서 시작 → 왼쪽 밖으로 나감 → 반복
  ///
  /// [areaWidth]는 Expanded가 실제로 준 글자 칸 너비다 — 시작 장면처럼 바깥 여백이
  /// 화면 폭과 다를 때도 글자가 칸 끝에서 바로 들어온다.
  Widget _buildMarquee(double areaWidth) {
    final textWidth = _measureTextWidth(widget.message);
    final totalDistance = areaWidth + textWidth;

    return AnimatedBuilder(
      animation: _marqueeController,
      builder: (context, child) {
        final offset = areaWidth - (totalDistance * _marqueeController.value);
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Text(
        widget.message,
        style: _textStyle,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  Size _measureTextSize(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: _textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  }

  double _measureTextWidth(String text) => _measureTextSize(text).width;
}
