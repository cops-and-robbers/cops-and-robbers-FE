import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_icons.dart';
import '../core/services/lifecycle/lifecycle_provider.dart';
import '../core/widgets/navigation/app_bottom_nav.dart';
import '../l10n/app_localizations.dart';
import 'current_branch_index_provider.dart';

/// StatefulShellRoute의 쉘
///
/// 탭 전환 시 각 브랜치(홈/커뮤니티/마이페이지)의 네비게이션 스택을
/// 독립적으로 보존한 채 바텀 네비게이션 바를 함께 그린다.
///
/// 전환을 [currentBranchIndexProvider]로 발행한다 — 탭 화면이 "다시 보이게
/// 됐다"를 알아야 낡은 데이터를 갱신할 수 있기 때문이다.
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // 앱 복귀 이벤트는 observer가 등록돼야 온다. 커뮤니티 탭을 거치지 않아도
    // 소켓 Notifier가 resumed를 받도록 셸에서 켠다(idempotent).
    // 커뮤니티 소켓 Notifier의 복귀 재연결이 이 등록에 기댄다.
    ref.read(appLifecycleServiceProvider).activate();
    // 첫 진입 값. build 중이 아니라 여기서 넣어야 provider 쓰기가 안전하다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(currentBranchIndexProvider.notifier)
          .select(widget.navigationShell.currentIndex);
    });
  }

  @override
  void didUpdateWidget(covariant MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `currentIndex`는 위젯의 final 필드고 브랜치가 바뀌면 새 인스턴스가 온다
    // (go_router `route.dart`의 StatefulNavigationShell). 그래서 이전 값과
    // 정확히 비교할 수 있다.
    final next = widget.navigationShell.currentIndex;
    if (oldWidget.navigationShell.currentIndex == next) return;
    // didUpdateWidget은 위젯 트리가 빌드되는 도중에 불린다 — 여기서 바로
    // provider를 쓰면 Riverpod가 "빌드 중 provider 수정" 어서션으로 막는다.
    // initState와 같은 이유로 프레임이 끝난 뒤로 미룬다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(currentBranchIndexProvider.notifier).select(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        items: [
          BottomNavItem(
            activeIconAsset: AppIcons.homeActive,
            inactiveIconAsset: AppIcons.homeInactive,
            labelBuilder: (context) =>
                AppLocalizations.of(context).bottomNavHome,
          ),
          BottomNavItem(
            activeIconAsset: AppIcons.commuActive,
            inactiveIconAsset: AppIcons.commuInactive,
            labelBuilder: (context) =>
                AppLocalizations.of(context).bottomNavCommunity,
          ),
          BottomNavItem(
            activeIconAsset: AppIcons.mypageActive,
            inactiveIconAsset: AppIcons.mypageInactive,
            labelBuilder: (context) =>
                AppLocalizations.of(context).bottomNavMyPage,
          ),
        ],
      ),
    );
  }
}
