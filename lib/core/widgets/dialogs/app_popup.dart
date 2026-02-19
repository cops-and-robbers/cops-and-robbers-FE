import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import 'dialog_animation.dart';

/// 버튼 없이 콘텐츠만 표시하는 팝업
///
/// 타이머, 게임 종료, 카운트다운 등 인터랙션 없이
/// 정보만 보여주는 용도로 사용합니다.
/// AppDialog와 동일한 컨테이너 스타일(white, 24r, 36 마진)과
/// 애니메이션(스케일 + 페이드)을 공유합니다.
///
/// **사용 예시**:
/// ```dart
/// AppPopup.show(
///   context: context,
///   content: TimerWidget(),
/// );
/// ```
class AppPopup extends StatelessWidget {
  const AppPopup({super.key, required this.content});

  /// 팝업 콘텐츠 위젯
  final Widget content;

  /// 팝업 표시
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Popup',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppPopup(content: content);
      },
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: AppPadding.horizontal36,
        padding: EdgeInsets.symmetric(vertical: 42.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Material(color: Colors.transparent, child: content),
      ),
    );
  }
}
