import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/credit_member.dart';

/// 크레딧 멤버 카드
///
/// 가로 스크롤 목록에서 개별 멤버를 표시하는 카드 위젯.
/// Hero 애니메이션으로 상세 페이지 전환 시 프로필 이미지가 연결된다.
class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    super.key,
    required this.member,
    required this.onTap,
  });

  final CreditMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical24,
          horizontal: AppSpacing.horizontal16,
        ),
        decoration: BoxDecoration(
          color: AppColors.black900,
          borderRadius: AppRadius.xlarge,
          border: Border.all(color: AppColors.black800),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 프로필 이미지 (Hero로 상세 페이지와 연결)
            Hero(
              tag: 'credit_${member.name}',
              child: _buildProfileImage(110.w),
            ),
            SizedBox(height: AppSpacing.vertical16),
            // 이름
            Text(
              member.name,
              style: AppTextStyles.label_16.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical4),
            // 역할
            Text(
              member.role,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지 (에셋 로드 실패 시 아이콘 fallback)
  Widget _buildProfileImage(double size) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          member.profileAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.black800,
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                size: size * 0.5,
                color: AppColors.black400,
              ),
            );
          },
        ),
      ),
    );
  }
}
