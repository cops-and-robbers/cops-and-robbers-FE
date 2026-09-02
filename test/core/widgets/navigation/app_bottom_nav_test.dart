import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/navigation/app_bottom_nav.dart';

List<BottomNavItem> _twoItems() => [
  BottomNavItem(
    activeIconAsset: 'assets/icons/icon_home_active.svg',
    inactiveIconAsset: 'assets/icons/icon_home_inactive.svg',
    labelBuilder: (_) => '홈',
  ),
  BottomNavItem(
    activeIconAsset: 'assets/icons/icon_commu_active.svg',
    inactiveIconAsset: 'assets/icons/icon_commu_inactive.svg',
    labelBuilder: (_) => '커뮤니티',
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required int currentIndex,
  required ValueChanged<int> onTap,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(
          bottomNavigationBar: AppBottomNav(
            currentIndex: currentIndex,
            onTap: onTap,
            items: _twoItems(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('AppBottomNav', () {
    testWidgets('renders_all_item_labels', (tester) async {
      await _pump(tester, currentIndex: 0, onTap: (_) {});

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('커뮤니티'), findsOneWidget);
    });

    testWidgets('invokes_onTap_with_tapped_index_when_second_tab_tapped', (
      tester,
    ) async {
      int? tappedIndex;
      await _pump(
        tester,
        currentIndex: 0,
        onTap: (index) => tappedIndex = index,
      );

      await tester.tap(find.text('커뮤니티'));
      await tester.pump();

      expect(tappedIndex, 1);
    });
  });
}
