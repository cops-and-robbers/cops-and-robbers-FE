import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

/// 바텀 네비게이션 탭 1개를 표현하는 데이터
///
/// 라벨은 l10n 지연 평가를 위해 [BuildContext]를 받는 빌더로 전달한다.
class BottomNavItem {
  const BottomNavItem({
    required this.activeIconAsset,
    required this.inactiveIconAsset,
    required this.labelBuilder,
  });

  final String activeIconAsset;
  final String inactiveIconAsset;
  final String Function(BuildContext context) labelBuilder;
}

/// 하단 탭 네비게이션 바
///
/// [items]에 항목을 추가/삭제하는 것만으로 탭 개수를 조절할 수 있다.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 92.h,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavTab(
                    item: items[i],
                    isActive: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isActive ? item.activeIconAsset : item.inactiveIconAsset,
            height: 30.h,
          ),
          SizedBox(height: 4.h),
          Text(
            item.labelBuilder(context),
            style: AppTextStyles.tag_12.copyWith(
              color: isActive ? AppColors.blueVer2Basic : AppColors.black300,
            ),
          ),
        ],
      ),
    );
  }
}
