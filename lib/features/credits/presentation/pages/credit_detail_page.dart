import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../domain/credit_member.dart';
import '../widgets/flipping_profile_image.dart';

/// 크레딧 멤버 상세 페이지
///
/// Hero 애니메이션으로 프로필 이미지가 확대되며,
/// 소셜 링크 버튼을 통해 외부 브라우저로 이동할 수 있다.
class CreditDetailPage extends StatelessWidget {
  const CreditDetailPage({super.key, required this.member});

  final CreditMember member;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        surfaceTintColor: AppColors.black,
        elevation: 0,
        leading: PreviousButton(
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.white,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero 프로필 이미지 — 상세에서는 카드보다 크게(220 원형)
              Hero(
                tag: 'credit_${member.name}',
                child: FlippingProfileImage(
                  assets: member.profileAssets,
                  width: 220.w,
                  height: 220.w,
                ),
              ),
              SizedBox(height: AppSpacing.vertical24),
              // 이름
              Text(
                member.name,
                style: AppTextStyles.heading_24.copyWith(
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: AppSpacing.vertical8),
              // 역할
              Text(
                member.role,
                style: AppTextStyles.label_16.copyWith(
                  color: AppColors.black400,
                ),
              ),
              SizedBox(height: AppSpacing.vertical32),
              // 소셜 링크 버튼 목록
              if (member.links.isNotEmpty)
                Padding(
                  padding: AppPadding.horizontal24,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.horizontal12,
                    runSpacing: AppSpacing.vertical12,
                    children: member.links
                        .map((link) => _buildSocialButton(link))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 소셜 링크 버튼 (아이콘 + 라벨)
  Widget _buildSocialButton(SocialLink link) {
    return GestureDetector(
      onTap: () => _openUrl(link.url),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical8,
          horizontal: AppSpacing.horizontal12,
        ),
        decoration: BoxDecoration(
          color: AppColors.black900,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.black800),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG 아이콘이 있으면 SVG, 없으면 FontAwesome Icon
            if (link.type.svgAsset != null)
              SvgPicture.asset(link.type.svgAsset!, width: 20.w, height: 20.w)
            else
              Icon(link.type.iconData, size: 18.w, color: AppColors.white),
            SizedBox(width: AppSpacing.horizontal6),
            Text(
              link.type.label,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// 외부 브라우저로 URL 열기
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
