import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

/// 아이콘 우상단에 얹는 빨간 점 배지 (새 공지·안 읽은 알림)
///
/// 아이콘 자체를 바꾸지 않고 배지만 얹는다 — icon_noti_on.svg로 통째로 바꾸면
/// 두 svg의 내부 여백이 달라 전환할 때 종 모양이 미세하게 움직여 보였다(실측).
class BadgeDot extends StatelessWidget {
  const BadgeDot({super.key, required this.child, required this.show});

  final Widget child;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            right: -3.w,
            top: -3.h,
            child: Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.w),
              ),
            ),
          ),
      ],
    );
  }
}
