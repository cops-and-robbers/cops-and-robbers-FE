import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 68.h,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return Semantics(
          label: AppLocalizations.of(context).homeBannerSemanticsLabel,
          button: onTap != null,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacing.vertical16),
                child: ClipRRect(borderRadius: AppRadius.large, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
