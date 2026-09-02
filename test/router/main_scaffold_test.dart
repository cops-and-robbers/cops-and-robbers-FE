import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/current_branch_index_provider.dart';
import 'package:cops_and_robbers/router/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 브랜치 둘짜리 최소 셸. 실제 앱 라우터를 끌어오지 않고 MainScaffold의
/// 인덱스 발행만 확인한다.
GoRouter _shellRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    // provider 기본값(0)과 다른 브랜치(1)에서 시작한다 — 초기값이 기본값과
    // 같으면 initState 콜백이 실제로 실행됐는지 우연히 구별되지 않는다.
    initialLocation: '/b',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/a', builder: (_, _) => const Text('A'))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/b', builder: (_, _) => const Text('B'))],
          ),
        ],
      ),
    ],
  );
}

Widget _wrap(GoRouter router) => ProviderScope(
  child: ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp.router(
      routerConfig: router,
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ),
);

void main() {
  testWidgets('publishes_the_branch_index_when_the_tab_changes', (
    tester,
  ) async {
    final router = _shellRouter();
    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainScaffold)),
    );
    // 셸이 브랜치 1(/b)에서 시작했으므로 initState 콜백이 실제로 돌았다면
    // 1이 읽힌다 — provider 기본값 0과 겹치지 않아 콜백 미실행과 구별된다.
    expect(container.read(currentBranchIndexProvider), 1);

    router.go('/a');
    await tester.pumpAndSettle();

    expect(container.read(currentBranchIndexProvider), 0);
  });

  testWidgets('keeps_the_branch_index_when_navigating_to_the_same_tab', (
    tester,
  ) async {
    final router = _shellRouter();
    await tester.pumpWidget(_wrap(router));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainScaffold)),
    );

    // 같은 브랜치(/b, 인덱스 1)로 다시 이동해도 인덱스는 그대로다.
    //
    // `didUpdateWidget`의 `if (oldWidget... == next) return;` 가드는 이 경우
    // select() 호출 자체를 건너뛰지만, 그 효과는 이 층위(provider 상태값)에서는
    // 관측되지 않는다 — Riverpod Notifier의 기본 업데이트 판정이 `identical()`
    // 비교이고 Dart의 int는 같은 값이면 항상 identical이라, 가드 없이
    // select(1)을 매번 호출해도 리스너 통지가 Riverpod 내부에서 걸러지기
    // 때문이다(가드를 임시로 지우고 돌려도 이 테스트는 그대로 통과함을 확인함).
    // 그래도 가드를 남겨두는 이유는 재빌드마다 불필요한
    // addPostFrameCallback 스케줄을 피하기 위해서다 — 이 테스트는 그 최적화가
    // 아니라 "인덱스가 유지된다"는 관측 가능한 결과만 증명한다.
    router.go('/b');
    await tester.pumpAndSettle();

    expect(container.read(currentBranchIndexProvider), 1);
  });
}
