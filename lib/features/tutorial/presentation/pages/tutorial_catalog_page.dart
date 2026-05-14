import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';

/// 튜토리얼 카탈로그 페이지
///
/// 5개 항목을 카드 리스트로 노출. 현재는 인게임만 활성, 나머지는
/// "준비 중" 배지로 비활성. 활성 카드 탭 시 해당 라우트로 push.
class TutorialCatalogPage extends StatelessWidget {
  const TutorialCatalogPage({super.key});

  static const _items = <_TutorialCatalogItem>[
    _TutorialCatalogItem(
      title: '방 만들기',
      subtitle: '플레이그라운드·감옥 설정과 슬라이더 조작',
      icon: Icons.add_box_outlined,
    ),
    _TutorialCatalogItem(
      title: '방 참여하기',
      subtitle: '초대 코드 입력과 QR 스캔',
      icon: Icons.qr_code_scanner_outlined,
    ),
    _TutorialCatalogItem(
      title: '대기방',
      subtitle: '팀 변경, 게임 설정, 준비 완료',
      icon: Icons.groups_outlined,
    ),
    _TutorialCatalogItem(
      title: '인게임',
      subtitle: '타이머·지도·참가자·채팅·QR',
      icon: Icons.map_outlined,
      route: '/tutorial/in-game',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: AppPadding.all20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontal4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '튜토리얼',
                          style: AppTextStyles.heading_24.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: AppSpacing.vertical16),
                        Text(
                          '게임을 처음 한다면 한 번씩 보고 시작해보세요',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.black600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: AppSpacing.vertical12),
                      itemBuilder: (_, i) =>
                          _TutorialCatalogCard(item: _items[i]),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: PreviousButton(onPressed: () => context.pop()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialCatalogItem {
  const _TutorialCatalogItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;

  bool get isActive => route != null;
}

class _TutorialCatalogCard extends StatelessWidget {
  const _TutorialCatalogCard({required this.item});

  final _TutorialCatalogItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isActive ? () => context.push(item.route!) : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal16,
          vertical: AppSpacing.vertical16,
        ),
        decoration: BoxDecoration(
          color: item.isActive ? AppColors.white : AppColors.black100,
          borderRadius: AppRadius.xl20,
          boxShadow: item.isActive
              ? [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                    color: AppColors.black100,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: item.isActive ? AppColors.blue100 : AppColors.black200,
                borderRadius: AppRadius.large,
              ),
              child: Icon(
                item.icon,
                size: 24.w,
                color: item.isActive ? AppColors.blue : AppColors.black400,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.label_16.copyWith(
                      color: item.isActive
                          ? AppColors.black
                          : AppColors.black500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.vertical4),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.tag_12.copyWith(
                      color: item.isActive
                          ? AppColors.black600
                          : AppColors.black400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            if (item.isActive)
              Icon(Icons.chevron_right, size: 24.w, color: AppColors.black800)
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal8,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black200,
                  borderRadius: AppRadius.medium,
                ),
                child: Text(
                  '준비 중',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
