import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/credit_member.dart';
import '../widgets/credit_card_widget.dart';
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
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
              '경찰과 도둑을 만든 사람들',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black400,
              ),
            ),
            SizedBox(height: AppSpacing.vertical40),
            // 멤버 카드 가로 스크롤 목록
            SizedBox(
              height: 240.h,
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
