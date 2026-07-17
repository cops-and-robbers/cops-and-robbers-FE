import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(
        find.text('지금 앱을 끄면 합류가 취소돼요. 잠시만 기다려주세요'),
        findsOneWidget,
      );
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

    testWidgets('shows_custom_message_when_using_show_message', (tester) async {
      final ctx = await _pump(tester);

      AppLoading.showMessage(ctx, message: '공지사항을 불러오는 중...');
      await _settleOverlayIn(tester);

      expect(find.text('공지사항을 불러오는 중...'), findsOneWidget);
    });
  });
}
