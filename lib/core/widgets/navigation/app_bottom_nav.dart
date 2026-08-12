import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';

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
    // SafeArea 대신 직접 계산 — 홈 인디케이터 인셋에서 20 덜어낸 만큼만 하단 여백을 준다
    // 안드로이드는 제스처 인셋이 없거나 작아 위 계산이 0으로 클램프되는 경우가 많아 20을 더해준다
    final androidExtra = Theme.of(context).platform == TargetPlatform.android
        ? 20.h
        : 0.0;
    final bottomInset =
        (MediaQuery.viewPaddingOf(context).bottom - AppSpacing.vertical18)
            .clamp(0.0, double.infinity) +
        androidExtra;

    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 84.h,
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
      onTap: () {
        // 이미 선택된 탭이어도 진동은 준다 — 터치가 먹혔다는 확인이 목적이라
        // 화면이 안 바뀌는 경우에 오히려 더 필요하다.
        VibrationService.instance().buttonTap();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isActive ? item.activeIconAsset : item.inactiveIconAsset,
            height: 30.h,
          ),
          SizedBox(height: AppSpacing.vertical4),
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
