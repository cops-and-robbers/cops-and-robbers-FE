import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cops_and_robbers/core/services/loading_message_service.dart';
import 'package:cops_and_robbers/core/widgets/loading/app_loading.dart';
import 'package:cops_and_robbers/core/widgets/loading/loading_content_view.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// 로딩 오버레이의 표시/닫기 계약 검증.
///
/// 핵심: 닫기 책임이 호출부(navigator.pop)가 아니라 핸들에 있다.
/// 최소 표시 시간(600ms)은 핸들이 보장하므로, API가 즉시 끝나도 화면이 번쩍이지 않는다.
///
/// 주의: LoadingVisual의 파동 애니메이션은 무한 반복(..repeat())이라
/// pumpAndSettle()은 절대 settle되지 않는다. 오버레이가 떠 있는 동안에는
/// 명시적 pump(Duration)으로 프레임을 진행시킨다. (DialogAnimation fade = 250ms)
Future<BuildContext> _pump(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => Scaffold(
            body: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    ),
  );
  // 기반 화면에는 무한 애니메이션이 없어 settle 가능
  await tester.pumpAndSettle();
  return ctx;
}

/// 오버레이가 뜬 뒤 fade transition(250ms) 완료까지 프레임 진행.
/// pumpAndSettle 대신 사용 (무한 애니메이션 때문).
Future<void> _settleOverlayIn(WidgetTester tester) async {
  await tester.pump(); // 다이얼로그 라우트 삽입
  await tester.pump(const Duration(milliseconds: 300)); // fade in 완료
}

void main() {
  group('remainingVisibleDuration', () {
    final shownAt = DateTime(2026, 7, 14, 12, 0, 0);

    test('returns_full_minimum_when_no_time_elapsed', () {
      expect(
        remainingVisibleDuration(shownAt: shownAt, now: shownAt),
        const Duration(milliseconds: 600),
      );
    });

    test('returns_remaining_gap_when_task_finished_early', () {
      expect(
        remainingVisibleDuration(
          shownAt: shownAt,
          now: shownAt.add(const Duration(milliseconds: 100)),
        ),
        const Duration(milliseconds: 500),
      );
    });

    test('returns_zero_when_task_took_longer_than_minimum', () {
      expect(
        remainingVisibleDuration(
          shownAt: shownAt,
          now: shownAt.add(const Duration(milliseconds: 800)),
        ),
        Duration.zero,
      );
    });
  });

  group('AppLoading', () {
    testWidgets('shows_fullscreen_loading_with_category_subtitle', (
      tester,
    ) async {
      final ctx = await _pump(tester);

      AppLoading.show(ctx, LoadingCategory.joinRoom);
      await _settleOverlayIn(tester);

      expect(find.byType(LoadingContentView), findsOneWidget);
      expect(find.text('지금 앱을 끄면 합류가 취소돼요. 잠시만 기다려주세요'), findsOneWidget);
    });

    testWidgets('keeps_loading_visible_until_minimum_duration_elapses', (
      tester,
    ) async {
      final ctx = await _pump(tester);

      final handle = AppLoading.show(ctx, LoadingCategory.changeTeam);
      await _settleOverlayIn(tester);
      expect(find.byType(LoadingContentView), findsOneWidget);

      // 작업이 즉시 끝난 상황: close()를 바로 호출해도 600ms 전에는 닫히지 않는다
      handle.close();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LoadingContentView), findsOneWidget);

      // 누적 600ms → 최소 표시 시간 경과 → pop 시작
      await tester.pump(const Duration(milliseconds: 300));
      // 종료 트랜지션(fade out 250ms) 완료
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LoadingContentView), findsNothing);
    });

    testWidgets('closes_only_once_when_close_called_twice', (tester) async {
      final ctx = await _pump(tester);

      final handle = AppLoading.show(ctx, LoadingCategory.startGame);
      await _settleOverlayIn(tester);

      handle.close();
      handle.close();
      await tester.pump(const Duration(milliseconds: 300)); // 300ms
      await tester.pump(const Duration(milliseconds: 300)); // 누적 600ms → pop
      await tester.pump(const Duration(milliseconds: 300)); // 종료 트랜지션 완료

      expect(find.byType(LoadingContentView), findsNothing);
      // 두 번째 close가 그 아래 화면까지 pop하지 않았는지 확인
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('blocks_system_back_button_while_loading', (tester) async {
      final ctx = await _pump(tester);

      AppLoading.show(ctx, LoadingCategory.deleteAccount);
      await _settleOverlayIn(tester);

      // 안드로이드 뒤로가기
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LoadingContentView), findsOneWidget);
    });

    // 방장이 게임 시작: 시작 API 응답보다 소켓 GAME_START가 먼저 와 게임 화면으로 go한 직후
    // 응답이 와서 close()가 불리는 상황. 로딩은 이미 대기실과 함께 빠지는 중이다.
    testWidgets(
      'keeps_game_page_when_loading_closes_after_page_replaced_by_go',
      (tester) async {
        late BuildContext waitingCtx;
        final router = GoRouter(
          initialLocation: '/waiting',
          routes: [
            GoRoute(
              path: '/waiting',
              builder: (_, _) => Builder(
                builder: (c) {
                  waitingCtx = c;
                  return const Scaffold(body: Text('waiting'));
                },
              ),
            ),
            GoRoute(
              path: '/game',
              builder: (_, _) => const Scaffold(body: Text('game')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (_, _) => MaterialApp.router(
                locale: const Locale('ko'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final handle = AppLoading.show(waitingCtx, LoadingCategory.startGame);
        await _settleOverlayIn(tester);
        // 최소 표시 시간은 실제 시계로 재므로 실제로 흘려보낸다
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 700)),
        );

        router.go('/game');
        await tester.pump(); // 대기실과 로딩이 빠지기 시작 (로딩은 아직 붙어 있다)
        await handle.close();
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull);
        expect(find.text('game'), findsOneWidget);
      },
    );

    // 로딩 중 세션 만료 안내 같은 다이얼로그가 위에 뜬 뒤 로딩이 닫히는 상황
    testWidgets('keeps_dialog_above_when_loading_closes_beneath_it', (
      tester,
    ) async {
      final ctx = await _pump(tester);

      final handle = AppLoading.show(ctx, LoadingCategory.startGame);
      await _settleOverlayIn(tester);
      showDialog<void>(
        context: ctx,
        builder: (_) => const AlertDialog(content: Text('session expired')),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 700)),
      );
      await handle.close();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(LoadingContentView), findsNothing);
      expect(find.text('session expired'), findsOneWidget);
    });

    testWidgets('shows_custom_message_when_using_show_message', (tester) async {
      final ctx = await _pump(tester);

      AppLoading.showMessage(ctx, message: '공지사항을 불러오는 중...');
      await _settleOverlayIn(tester);

      expect(find.text('공지사항을 불러오는 중...'), findsOneWidget);
    });
  });
}
