import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/navigation/app_bottom_nav.dart';
import '../l10n/app_localizations.dart';

/// StatefulShellRoute의 쉘
///
/// 탭 전환 시 각 브랜치(홈/커뮤니티/마이페이지)의 네비게이션 스택을
/// 독립적으로 보존한 채 바텀 네비게이션 바를 함께 그린다.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          BottomNavItem(
            activeIconAsset: 'assets/icons/icon_home_active.svg',
            inactiveIconAsset: 'assets/icons/icon_home_inactive.svg',
            labelBuilder: (context) =>
                AppLocalizations.of(context).bottomNavHome,
          ),
          BottomNavItem(
            activeIconAsset: 'assets/icons/icon_commu_active.svg',
            inactiveIconAsset: 'assets/icons/icon_commu_inactive.svg',
            labelBuilder: (context) =>
                AppLocalizations.of(context).bottomNavCommunity,
          ),
          BottomNavItem(
            activeIconAsset: 'assets/icons/icon_mypage_active.svg',
            inactiveIconAsset: 'assets/icons/icon_mypage_inactive.svg',
            labelBuilder: (context) =>
                AppLocalizations.of(context).bottomNavMyPage,
          ),
        ],
      ),
    );
  }
}
