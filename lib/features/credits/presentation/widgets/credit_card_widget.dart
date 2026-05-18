import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/credit_member.dart';
import 'flipping_profile_image.dart';

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
            // 프로필 이미지 — 카드 내부를 꽉 채우는 둥근 사각형 (168×180)
            Hero(
              tag: 'credit_${member.name}',
              child: FlippingProfileImage(
                assets: member.profileAssets,
                width: 168.w,
                height: 180.h,
                borderRadius: AppRadius.xlarge,
              ),
            ),
            SizedBox(height: AppSpacing.vertical16),
            // 이름
            Text(
              localizedMemberName(AppLocalizations.of(context), member.name),
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
            if (member.links.isNotEmpty) ...[
              SizedBox(height: AppSpacing.vertical12),
              // 소셜 아이콘 한 줄 (라벨 없이 아이콘만, 탭은 카드 전체로)
              _SocialIconRow(links: member.links),
            ],
          ],
        ),
      ),
    );
  }
}

/// 카드에 표시되는 아이콘 전용 소셜 링크 Row
///
/// 상세 페이지의 라벨형 버튼과 달리, 카드에서는 공간 절약을 위해
/// 아이콘만 가로 정렬로 보여준다. 개별 탭 동작은 없고 카드 전체 탭으로 상세로 이동.
class _SocialIconRow extends StatelessWidget {
  const _SocialIconRow({required this.links});

  final List<SocialLink> links;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < links.length; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.horizontal6),
          _buildIcon(links[i]),
        ],
      ],
    );
  }

  Widget _buildIcon(SocialLink link) {
    final size = 16.w;
    return SvgPicture.asset(
      link.type.svgAsset,
      width: size,
      height: size,
      colorFilter: link.type.tintColor != null
          ? ColorFilter.mode(link.type.tintColor!, BlendMode.srcIn)
          : null,
    );
  }
}
