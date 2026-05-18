import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/remote_config/remote_config_service.dart';

/// 서버 점검 중 안내 페이지
///
/// Remote Config의 `maintenance`가 `true`일 때 표시된다.
/// `maintenance_message`가 설정되어 있으면 점검 시간 등을 추가 표시한다.
/// 뒤로가기 스택이 없는 상태로 이동(`context.go`)되므로
/// 사용자가 앱을 빠져나갈 수 없다.
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                        'assets/app_icon.png',
                        width: 223.w,
                        height: 260.w,
                      ),
                      SizedBox(height: AppSpacing.vertical24),
                      Text(
                        l10n.pageMaintenanceTitle,
                        style: AppTextStyles.heading_24.copyWith(
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical16),
                      Text(
                        l10n.pageMaintenanceMessage,
                        style: AppTextStyles.subHeading_18.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (RemoteConfigService
                          .instance
                          .maintenanceMessage
                          .isNotEmpty) ...[
                        SizedBox(height: AppSpacing.vertical16),
                        Text(
                          RemoteConfigService.instance.maintenanceMessage,
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.black400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
