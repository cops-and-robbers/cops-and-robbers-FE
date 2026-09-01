import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../l10n/app_localizations.dart';

/// 홈 화면의 원격 이미지 배너.
class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key, required this.imageUrl, this.onTap});

  /// 표시할 네트워크 이미지 주소.
  final String imageUrl;

  /// 배너 탭 동작. 없으면 이미지로만 표시한다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: AppLocalizations.of(context).homeBannerSemanticsLabel,
      button: onTap != null,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(top: AppSpacing.vertical16),
            // 흰 카드 위에 이미지를 얹는다. 배경이 비어 있으면 그림자가 카드
            // 바깥이 아니라 안쪽에 낀 것처럼 보이고, 이미지가 아직 안 왔거나
            // 투명한 부분이 있으면 뒤 배경이 그대로 비친다.
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.ver2,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.large,
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 68.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
