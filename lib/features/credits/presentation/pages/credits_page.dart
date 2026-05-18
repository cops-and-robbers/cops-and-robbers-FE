import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/credit_member.dart';
import '../widgets/credit_card_widget.dart';
import '../widgets/marquee_widget.dart';
import 'credit_detail_page.dart';

/// 크레딧 페이지
///
/// 설정 > 앱 버전 5탭으로 진입하는 히든 페이지.
/// 프로젝트에 기여한 멤버들을 가로 스크롤 카드 목록으로 보여준다.
class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

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
        child: Column(
          children: [
            SizedBox(height: AppSpacing.vertical40),
            // 타이틀
            Text(
              'Made with ❤️',
              style: AppTextStyles.heading_24.copyWith(color: AppColors.white),
            ),
            SizedBox(height: AppSpacing.vertical12),
            // 서브타이틀
            Text(
              AppLocalizations.of(context).pageCreditsTitle,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black400,
              ),
            ),
            SizedBox(height: AppSpacing.vertical32),
            // 멤버 카드 가로 스크롤 목록
            SizedBox(
              height: 310.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: AppPadding.horizontal20,
                itemCount: creditMembers.length,
                itemBuilder: (context, index) {
                  final member = creditMembers[index];
                  return Padding(
                    // 카드 간 간격
                    padding: EdgeInsets.only(
                      right: index < creditMembers.length - 1
                          ? AppSpacing.horizontal12
                          : 0,
                    ),
                    child: CreditCardWidget(
                      member: member,
                      onTap: () => _navigateToDetail(context, member),
                    ),
                  );
                },
              ),
            ),
            // 하단으로 밀어내기
            const Spacer(),
            // Special Thanks 마키 텍스트
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.vertical32),
              child: Column(
                children: [
                  Text(
                    'Special Thanks',
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.black600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.vertical12),
                  MarqueeWidget(
                    child: Row(
                      children: [
                        // 첫 항목이 화면에 진입하기 전 시각적 휴지 — 화면 너비만큼
                        // spacer를 두어 첫 텍스트(tier4)가 화면 오른쪽 밖에서
                        // 들어오도록 하고, 한 사이클 사이에도 호흡을 만든다.
                        SizedBox(width: 0.7.sw),
                        ...creditHelpers.map(
                          (helper) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.horizontal16,
                            ),
                            child: Text(
                              '${localizedMemberName(AppLocalizations.of(context), helper.name)} (${helper.role})',
                              style:
                                  (helper.tier == ContributionTier.tier5
                                          ? AppTextStyles.paragraph14Semibold
                                          : AppTextStyles.paragraph_14)
                                      .copyWith(color: helper.tier.color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상세 페이지로 FadeTransition 전환
  void _navigateToDetail(BuildContext context, CreditMember member) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return CreditDetailPage(member: member);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
