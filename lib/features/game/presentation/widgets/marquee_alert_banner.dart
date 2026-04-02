import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
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
    super.key,
  });

  final String message;
  final bool isDarkMode;
  final Duration displayDuration;
  final Duration fadeOutDuration;
  final Duration slideInDuration;

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

  // ── 마퀴 (텍스트 우→좌 반복) ──
  late AnimationController _marqueeController;

  /// displayDuration 동안 마퀴 반복 횟수
  static const int _marqueeRepeats = 2;

  /// 텍스트 스타일 (라이트: paragraph14Semibold, 다크: robberParagraph)
  TextStyle get _textStyle =>
      (widget.isDarkMode
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

    // 마퀴 — 항상 우→좌 반복 (1사이클 6초)
    _marqueeController = AnimationController(
      vsync: this,
      duration: widget.displayDuration ~/ _marqueeRepeats,
    )..repeat();
  }

  @override
  void didUpdateWidget(MarqueeAlertBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _slideController.forward(from: 0);
      _fadeController.reset();
      _scheduleFadeOut();
      _marqueeController.forward(from: 0);
    }
  }

  void _scheduleFadeOut() {
    Future.delayed(widget.displayDuration, () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
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
          padding: AppPadding.horizontal20,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: AppRadius.large,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/Loudspeaker.svg',
                  width: 20.w,
                  height: 20.w,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: AppSpacing.horizontal8),
                Expanded(
                  child: Builder(
                    builder: (context) {
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
                            child: _buildMarquee(),
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

  /// 텍스트가 우측 밖에서 시작 → 좌측 밖으로 나감 → 반복
  ///
  /// 부모: Expanded → ClipRect → OverflowBox(maxWidth: infinity)
  /// OverflowBox가 레이아웃 제약을 해제하여 텍스트 전체 렌더링,
  /// ClipRect가 컨테이너 밖은 시각적으로 클리핑한다.
  Widget _buildMarquee() {
    final containerWidth = 1.sw - 40.w - 32.w - 20.w - 8.w;
    final textWidth = _measureTextWidth(widget.message);
    final totalDistance = containerWidth + textWidth;

    return AnimatedBuilder(
      animation: _marqueeController,
      builder: (context, child) {
        final offset =
            containerWidth - (totalDistance * _marqueeController.value);
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
