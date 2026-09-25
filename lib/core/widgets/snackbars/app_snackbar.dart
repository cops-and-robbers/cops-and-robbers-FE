import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../navigation/app_bottom_nav.dart';

/// 앱 전역 커스텀 스낵바
///
/// Overlay 기반으로 화면 하단에 표시되며,
/// 슬라이드업 + 페이드 애니메이션으로 진입/퇴장합니다.
///
/// 사용 예시:
/// ```dart
/// AppSnackbar.show(context, message: '저장되었습니다.');
/// AppSnackbar.show(context, message: '오류 발생', backgroundColor: AppColors.red);
/// AppSnackbar.show(context, message: '복사됨', iconPath: AppIcons.copy);
/// ```
class AppSnackbar {
  AppSnackbar._();

  static OverlayEntry? _currentEntry;
  static AnimationController? _currentController;
  static Timer? _dismissTimer;

  /// 스낵바 표시
  ///
  /// [message] 표시할 메시지 텍스트.
  /// [backgroundColor] 배경색 (기본: AppColors.black600).
  /// [iconPath] SVG 아이콘 경로 (기본: icon_siren.svg).
  /// [iconSize] 아이콘 크기 (기본: 20).
  /// [duration] 표시 시간 (기본: 3초).
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    String? iconPath,
    double? iconSize,
    Duration duration = const Duration(seconds: 3),
    bool isDarkMode = false,
    OverlayState? overlay,
  }) {
    dismiss();

    final base = 105.h; // 피그마 시안: 화면 하단 105
    // 탭 화면에서는 바텀 네비 위로 띄운다 — 안드로이드는 바가 높아 105.h만으론 겹친다
    final bottom = StatefulNavigationShell.maybeOf(context) != null
        ? math.max(base, AppBottomNav.heightOf(context) + AppSpacing.vertical12)
        : base;

    final entry = OverlayEntry(
      builder: (_) => _SnackbarOverlay(
        message: message,
        bottom: bottom,
        backgroundColor: backgroundColor,
        iconPath: iconPath,
        iconSize: iconSize,
        duration: duration,
        isDarkMode: isDarkMode,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    // 탭(StatefulShellRoute) 안에서는 가장 가까운 Overlay가 탭바 위에서 끝나므로,
    // 화면 바닥 기준으로 위치를 맞추려고 루트 Overlay에 띄운다.
    (overlay ?? Overlay.of(context, rootOverlay: true)).insert(entry);
  }

  /// 현재 표시 중인 스낵바 즉시 제거
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentController?.dispose();
    _currentController = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// 스낵바 Overlay 위젯 (애니메이션 포함)
class _SnackbarOverlay extends StatefulWidget {
  const _SnackbarOverlay({
    required this.message,
    required this.bottom,
    this.backgroundColor,
    this.iconPath,
    this.iconSize,
    required this.duration,
    required this.onDismissed,
    this.isDarkMode = false,
  });

  final String message;
  final double bottom;
  final Color? backgroundColor;
  final String? iconPath;
  final double? iconSize;
  final Duration duration;
  final VoidCallback onDismissed;
  final bool isDarkMode;

  @override
  State<_SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<_SnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.horizontal20,
      right: AppSpacing.horizontal20,
      bottom: widget.bottom,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal16,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    (widget.isDarkMode ? AppColors.black : AppColors.black600),
                borderRadius: AppRadius.large,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    widget.iconPath ?? AppIcons.siren,
                    width: (widget.iconSize ?? 20).w,
                    height: (widget.iconSize ?? 20).w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: AppSpacing.horizontal8),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.paragraph14Semibold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
