import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';

/// 서버 점검 중 안내 페이지
///
/// Remote Config의 `maintenance`가 `true`일 때 표시된다.
/// 뒤로가기 스택이 없는 상태로 이동(`context.go`)되므로
/// 사용자가 앱을 빠져나갈 수 없다.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 64.w,
                        color: AppColors.black400,
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      Text(
                        '서버 점검 중',
                        style: AppTextStyles.heading_20.copyWith(
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical8),
                      Text(
                        '더 나은 서비스를 위해 점검 중이에요.\n잠시 후 다시 접속해 주세요.',
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 56.h),
            ],
          ),
        ),
      ),
    );
  }
}
