import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 앱 전역 커스텀 스낵바
///
/// Overlay 기반으로 화면 하단에 표시되며,
/// 슬라이드업 + 페이드 애니메이션으로 진입/퇴장합니다.
///
/// 사용 예시:
/// ```dart
/// AppSnackbar.show(context, message: '저장되었습니다.');
/// AppSnackbar.show(context, message: '오류 발생', backgroundColor: AppColors.red);
/// AppSnackbar.show(context, message: '복사됨', iconPath: 'assets/icons/icon_copy.svg');
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
  }) {
    dismiss();

    final entry = OverlayEntry(
      builder: (_) => _SnackbarOverlay(
        message: message,
        backgroundColor: backgroundColor,
        iconPath: iconPath,
        iconSize: iconSize,
        duration: duration,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    Overlay.of(context).insert(entry);
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
    this.backgroundColor,
    this.iconPath,
    this.iconSize,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Color? backgroundColor;
  final String? iconPath;
  final double? iconSize;
  final Duration duration;
  final VoidCallback onDismissed;

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
      left: 20.w,
      right: 20.w,
      bottom: 105.h,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.black600,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    widget.iconPath ?? 'assets/icons/icon_siren.svg',
                    width: (widget.iconSize ?? 20).w,
                    height: (widget.iconSize ?? 20).w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
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
