import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';

/// 타이머 전용 다이얼로그
///
/// 버튼 없이 타이머 + 설명 텍스트만 표시하는 다이얼로그.
/// AppDialog와 동일한 컨테이너 스타일(white, 24r, 36 마진)과
/// 애니메이션(스케일 + 페이드)을 공유합니다.
///
/// **사용 예시**:
/// ```dart
/// AppTimerDialog.show(
///   context: context,
///   content: TimerWidget(),
/// );
/// ```
class AppTimerDialog extends StatelessWidget {
  const AppTimerDialog({super.key, required this.content});

  /// 타이머 콘텐츠 위젯
  final Widget content;

  static const _animationDuration = Duration(milliseconds: 250);
  static const _animationCurve = Curves.easeOutBack;

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: _animationCurve),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// 타이머 다이얼로그 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'TimerDialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: _animationDuration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppTimerDialog(content: content);
      },
      transitionBuilder: _buildTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: AppPadding.horizontal36,
        padding: EdgeInsets.symmetric(vertical: 42.w, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(color: Colors.transparent, child: content),
      ),
    );
  }
}
