import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_config.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../utils/url_launcher_util.dart';
import '../buttons/app_button.dart';

/// 강제 업데이트 안내 페이지
///
/// Remote Config에서 현재 앱 버전이 `minimum_version`보다 낮고
/// `force_update`가 `true`일 때 표시된다.
/// 뒤로가기 스택이 없는 상태로 이동(`context.go`)되므로
/// 사용자가 업데이트 없이 앱을 사용할 수 없다.
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({super.key});

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
                      Image.asset(
                        'assets/app_icon_512.png',
                        width: 223.w,
                        height: 260.w,
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      Text(
                        '업데이트 필요',
                        style: AppTextStyles.heading_24.copyWith(
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical16),
                      Text(
                        '새로운 버전이 출시되었어요\n업데이트 후 이용해 주세요!',
                        style: AppTextStyles.subHeading_18.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                text: '업데이트',
                onPressed: () => launchExternalUrl(AppConfig.storeUrl),
                showBorder: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
