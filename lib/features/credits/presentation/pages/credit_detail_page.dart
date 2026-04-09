import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../domain/credit_member.dart';

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
        surfaceTintColor: Colors.transparent,
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
              // Hero 프로필 이미지 (카드보다 큰 140.w)
              Hero(
                tag: 'credit_${member.name}',
                child: _buildProfileImage(140.w),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: member.links
                      .map(
                        (link) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.horizontal8,
                          ),
                          child: _buildSocialButton(link),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
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
