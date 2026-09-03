import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../i18n/locale_brand_assets.dart';
import '../buttons/app_button.dart';

/// 서버 장애 안내 페이지
///
/// 기기 연결은 살아 있는데 서버에 닿지 못하거나 5xx가 올 때 표시된다.
/// [MaintenancePage]·[ForceUpdatePage]와 같은 구성(로고·제목·본문·하단 버튼)이며,
/// 점검 페이지와 달리 사용자가 [onRetry]로 다시 시도할 수 있다.
class ServerErrorPage extends StatelessWidget {
  const ServerErrorPage({super.key, required this.onRetry});

  /// 재시도 버튼 핸들러 — 호출자가 진입 플로우를 처음부터 다시 돌린다.
  final VoidCallback onRetry;

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
                        l10n.pageServerErrorTitle,
                        style: AppTextStyles.heading_24.copyWith(
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.vertical16),
                      Text(
                        l10n.pageServerErrorMessage,
                        style: AppTextStyles.subHeading_18.copyWith(
                          color: AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(text: l10n.buttonRetry, onPressed: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
