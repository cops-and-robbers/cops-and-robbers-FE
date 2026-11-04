import 'dart:async';

import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../i18n/locale_brand_assets.dart';
import '../../services/remote_config/remote_config_service.dart';
import '../dialogs/app_dialog.dart';

/// 서버 점검 중 안내 페이지
///
/// Remote Config의 `maintenance`가 `true`일 때 표시된다.
/// `maintenance_message`가 설정되어 있으면 점검 시간 등을 추가 표시한다.
/// 뒤로가기 스택이 없는 상태로 이동(`context.go`)되므로
/// 사용자가 앱을 빠져나갈 수 없다.
/// 글을 쓰는 중에 점검이 시작되면 쓴 내용을 챙길 수 있게 알린다.
///
/// 스낵바는 키보드에 가려서 다이얼로그로 띄운다.
void showMaintenanceWritingDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  unawaited(
    AppDialog.show<void>(
      context: context,
      title: l10n.pageMaintenanceWritingTitle,
      message: l10n.pageMaintenanceWritingMessage,
    ),
  );
}

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
                      SvgPicture.asset(
                        localizedAppSplash(Localizations.localeOf(context)),
                        width: 302.w,
                      ),
                      SizedBox(height: AppSpacing.vertical40),
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
                      // 점검 중에 끝나는 시각을 고치면 바로 바뀌게 한다.
                      StreamBuilder<void>(
                        stream: RemoteConfigService.instance.onConfigUpdated,
                        builder: (context, _) {
                          final message =
                              RemoteConfigService.instance.maintenanceMessage;
                          if (message.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: EdgeInsets.only(
                              top: AppSpacing.vertical16,
                            ),
                            // 바뀐 시각을 스크린 리더도 읽어 주게 한다.
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                message,
                                style: AppTextStyles.paragraph_14.copyWith(
                                  color: AppColors.black400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
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
