import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/profile_icon_provider.dart';

/// 홈 상단 프로필 카드
///
/// 선택된 프로필 아이콘과 닉네임을 보여준다.
/// 우측은 날씨 정보 자리로 비워둔다 — 날씨 API가 준비되면 채운다.
class HomeProfileCard extends ConsumerWidget {
  const HomeProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconId = ref.watch(profileIconProvider);
    final nickname = ref.watch(authNotifierProvider).value?.nickname ?? '';

    return Container(
      width: double.infinity,
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.ver2,
      ),
      child: Row(
        children: [
          SvgPicture.asset(profileIconAsset(iconId), width: 34.w, height: 34.w),
          SizedBox(width: AppSpacing.horizontal8),
          Expanded(
            child: Text(
              nickname,
              style: AppTextStyles.label_16.copyWith(color: AppColors.black800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
