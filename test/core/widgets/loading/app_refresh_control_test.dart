import 'dart:async';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/widgets/loading/app_refresh_control.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// 당겨서 새로고침이 붙은 목록 하나.
///
/// [gate]를 넘기면 그걸 complete할 때까지 새로고침이 끝나지 않는다 — "새로고침
/// 중" 화면을 붙잡아 두고 확인하기 위한 손잡이다.
Widget _wrap({
  required List<String> log,
  Completer<void>? gate,
  bool disableAnimations = false,
  bool showList = true,
  ValueChanged<int>? onTapItem,
}) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, _) => MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Scaffold(
          body: Builder(
            builder: (_) => showList
                ? AppRefreshControl(
                    onRefresh: () async {
                      log.add('refresh');
                      if (gate != null) await gate.future;
                    },
                    child: ListView(
                      children: [
                        for (var i = 0; i < 20; i++)
                          GestureDetector(
                            onTap: onTapItem == null
                                ? null
                                : () => onTapItem(i),
                            child: SizedBox(height: 60, child: Text('항목 $i')),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ),
  ),
);

/// 실제 폰 크기(디자인 기준 393x852)로 띄운다.
///
/// 기본 뷰포트(800x600)에서는 `100.h`가 70px로 줄어 임계 거리가 실제 폰과 달라진다.
Future<void> _pumpList(
  WidgetTester tester, {
  List<String>? log,
  Completer<void>? gate,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _wrap(log: log ?? [], gate: gate, disableAnimations: disableAnimations),
  );
  await tester.pumpAndSettle();
}

/// 손가락을 [distance]만큼 내린 채로 두고 제스처를 돌려준다.
Future<TestGesture> _pull(WidgetTester tester, double distance) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('항목 0')),
  );
  await gesture.moveBy(Offset(0, distance));
  await tester.pump();
  return gesture;
}

/// 임계점을 넘겨 당겼다 놓는다 — 빛이 오버레이에 올라올 때까지 프레임을 준다.
Future<void> _pullAndRelease(WidgetTester tester) async {
  final gesture = await _pull(tester, 200);
  await gesture.up();
  await tester.pump();
  await tester.pump();
}

/// 실제 프레임처럼 잘게 흘린다 — 한 번에 크게 pump하면 상태 전이가 다 흐르지 않는다.
Future<void> _advance(WidgetTester tester, int milliseconds) async {
  for (var elapsed = 0; elapsed < milliseconds; elapsed += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// 앱이 요청한 진동을 기록한다.
List<String> _recordHaptics(WidgetTester tester) {
  final haptics = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add(call.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return haptics;
}

Finder get _sirenFinder => find.byKey(AppRefreshControl.sirenKey);
Finder get _waveFinder => find.byKey(AppRefreshControl.waveKey);

RefreshSirenPainter _siren(WidgetTester tester) =>
    tester.widget<CustomPaint>(_sirenFinder).painter! as RefreshSirenPainter;

double _firstItemTop(WidgetTester tester) =>
    tester.getTopLeft(find.text('항목 0')).dy;

void main() {
  group('AppRefreshControl', () {
    testWidgets('runs_onRefresh_when_pulled_past_the_trigger', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(_wrap(log: log));
      await tester.pumpAndSettle();

      await tester.fling(find.text('항목 0'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(log, ['refresh']);
    });

    testWidgets('ignores_a_pull_that_stops_short_of_the_trigger', (
      tester,
    ) async {
      // 살짝 당겼다 놓은 것까지 새로고침으로 치면 스크롤 한 번에 목록이 계속
      // 다시 그려진다.
      final log = <String>[];
      await tester.pumpWidget(_wrap(log: log));
      await tester.pumpAndSettle();

      await tester.drag(find.text('항목 0'), const Offset(0, 30));
      await tester.pumpAndSettle();

      expect(log, isEmpty);
    });

    testWidgets('grows_the_rays_one_by_one_as_the_finger_pulls_down', (
      tester,
    ) async {
      // 당긴 만큼 윗부분 빗살이 하나씩 생기고, 색도 회색에서 파랑으로 넘어간다.
      await _pumpList(tester);

      final gesture = await _pull(tester, 20);
      var siren = tester.renderObject(_sirenFinder);
      expect(siren, paintsExactlyCountTimes(#drawRRect, 1));
      expect(siren, paints..path(color: AppColors.black300));

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      siren = tester.renderObject(_sirenFinder);
      expect(siren, paintsExactlyCountTimes(#drawRRect, 2));
      expect(siren, paints..path(color: AppColors.blue500));

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      siren = tester.renderObject(_sirenFinder);
      expect(siren, paintsExactlyCountTimes(#drawRRect, 3));
      expect(siren, paints..path(color: AppColors.blueVer2Rich));

      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      siren = tester.renderObject(_sirenFinder);
      expect(siren, paintsExactlyCountTimes(#drawRRect, 3));
      expect(siren, paints..path(color: AppColors.blueVer2Basic));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('repeats_the_siren_every_second_while_the_finger_holds', (
      tester,
    ) async {
      // 피드를 당긴 채 고민하는 경우. 손을 안 놓으면 1초 주기로 계속 돌지만,
      // 새로고침과 파동은 아직 없다 — 되돌릴 수 있는 순간이다.
      final log = <String>[];
      await _pumpList(tester, log: log);

      final gesture = await _pull(tester, 200);
      expect(_siren(tester).phase, closeTo(0.6, 0.01));

      await _advance(tester, 500);
      expect(_siren(tester).phase, closeTo(0.1, 0.06));
      expect(
        tester.renderObject(_sirenFinder),
        paints..path(color: AppColors.black300),
      );

      await _advance(tester, 500);
      expect(_siren(tester).phase, closeTo(0.6, 0.06));

      // 다시 다 켜진 지점을 지난 뒤에도 파동이 없어야 한다.
      await _advance(tester, 100);
      expect(log, isEmpty);
      expect(_waveFinder, findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('repeats_the_siren_until_the_refresh_finishes', (tester) async {
      final semantics = tester.ensureSemantics();
      final gate = Completer<void>();
      await _pumpList(tester, gate: gate);

      await _pullAndRelease(tester);
      await _advance(tester, 300);

      final phase = _siren(tester).phase;
      expect(find.bySemanticsLabel('불러오는 중이에요'), findsOneWidget);

      // 서 있는 게 아니라 실제로 움직이는 중이어야 한다.
      await _advance(tester, 100);
      expect(_siren(tester).phase, isNot(phase));

      gate.complete();
      await tester.pumpAndSettle();
      expect(_sirenFinder, findsNothing);
      semantics.dispose();
    });

    testWidgets('keeps_the_siren_a_beat_when_the_refresh_is_instant', (
      tester,
    ) async {
      // 캐시처럼 즉시 끝나면 표시가 번쩍이고 사라져 아무 일도 안 일어난 것처럼
      // 보인다. 최소 시간만큼은 붙잡아 둔다 (AppLoading과 같은 판단).
      await _pumpList(tester);

      await _pullAndRelease(tester);

      // 최소 유지가 없으면 settle 150ms + 접힘 100ms로 250ms 언저리에 사라진다.
      await _advance(tester, 420);
      expect(_sirenFinder, findsOneWidget);

      await tester.pumpAndSettle();
      expect(_sirenFinder, findsNothing);
    });

    testWidgets('spreads_the_wave_when_released_past_the_trigger', (
      tester,
    ) async {
      final gate = Completer<void>();
      await _pumpList(tester, gate: gate);

      // 놓기 전까지는 임계점을 넘겼어도 파동이 없다.
      final gesture = await _pull(tester, 200);
      expect(_waveFinder, findsNothing);

      await gesture.up();
      await tester.pump();
      await tester.pump();
      expect(_waveFinder, findsOneWidget);

      // 띠 안이 아니라 화면 전체를 칠한다.
      await tester.pump(const Duration(milliseconds: 100));
      const screen = Size(393, 852);
      expect(tester.getSize(_waveFinder), screen);
      expect(
        tester.renderObject(
          find.descendant(of: _waveFinder, matching: find.byType(CustomPaint)),
        ),
        paints..rect(rect: Offset.zero & screen),
      );

      gate.complete();
      await tester.pumpAndSettle();
      expect(_waveFinder, findsNothing);
    });

    test('wave_front_reaches_the_farthest_corner_at_the_end', () {
      // 점이 위쪽에 있어 가장 먼 귀퉁이는 아래쪽이다. 거기까지 닿아야 "끝까지"다.
      const screen = Size(393, 852);
      const center = Offset(196.5, 145);
      final farthest = (Offset(393, 852) - center).distance;

      expect(
        waveFrontRadius(1, center: center, size: screen, startRadius: 16),
        closeTo(farthest, 0.01),
      );
      expect(
        waveFrontRadius(0, center: center, size: screen, startRadius: 16),
        16,
      );
    });

    testWidgets('spreads_the_wave_past_the_tab_bar_when_inside_a_tab', (
      tester,
    ) async {
      // 탭 안 화면은 가장 가까운 Overlay가 탭바 위에서 끝난다. 거기 띄우면 파동이
      // 하단 탭을 넘지 못한다.
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (_, _) => MaterialApp(
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Column(
              children: [
                Expanded(
                  child: Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        body: AppRefreshControl(
                          onRefresh: () async {},
                          child: ListView(
                            children: [
                              for (var i = 0; i < 20; i++)
                                SizedBox(height: 60, child: Text('항목 $i')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _pullAndRelease(tester);

      expect(tester.getSize(_waveFinder), const Size(393, 852));

      await tester.pumpAndSettle();
    });

    testWidgets('spreads_only_one_wave_when_the_response_is_slow', (
      tester,
    ) async {
      // 응답이 늦어도 파동은 손을 뗄 때 한 번뿐이다. 그 뒤로는 사이렌만 반복한다.
      final gate = Completer<void>();
      await _pumpList(tester, gate: gate);

      await _pullAndRelease(tester);
      await _advance(tester, 500);
      expect(_waveFinder, findsOneWidget);

      for (var checked = 0; checked < 6; checked++) {
        await _advance(tester, 500);
        expect(_waveFinder, findsNothing);
      }
      expect(_sirenFinder, findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('spreads_one_wave_for_800ms_when_the_refresh_is_instant', (
      tester,
    ) async {
      // 캐시가 물려 응답이 바로 와도 파동은 화면 끝까지 간다.
      await _pumpList(tester);

      await _pullAndRelease(tester);

      await _advance(tester, 600);
      expect(_sirenFinder, findsNothing);
      expect(_waveFinder, findsOneWidget);

      await _advance(tester, 150);
      expect(_waveFinder, findsOneWidget);

      await _advance(tester, 100);
      expect(_waveFinder, findsNothing);
    });

    testWidgets('lets_the_list_take_taps_while_the_wave_is_up', (tester) async {
      // 파동이 지나가는 동안에도 게시글을 바로 누를 수 있어야 한다.
      final log = <String>[];
      final taps = <int>[];
      final gate = Completer<void>();
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(log: log, gate: gate, onTapItem: taps.add));
      await tester.pumpAndSettle();

      // 항목에 탭이 걸려 있으면 첫 이동은 제스처 판정에 쓰여 당김으로 안 들어간다.
      final gesture = await _pull(tester, 20);
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      await tester.pump();
      await _advance(tester, 300);
      expect(_waveFinder, findsOneWidget);

      await tester.tap(find.text('항목 3'));
      await tester.pump();
      expect(taps, [3]);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'shows_no_wave_when_the_pull_is_taken_back',
      (tester) async {
        // 피드에서 당겼다가 마음이 바뀌어 되돌린 경우. 안드로이드는 armed에서 바로
        // canceling으로, iOS는 dragging으로 간다.
        final log = <String>[];
        await _pumpList(tester, log: log);

        final gesture = await _pull(tester, 120);
        await tester.pump(const Duration(milliseconds: 50));
        expect(_siren(tester).phase, greaterThan(0.6));

        await gesture.moveBy(const Offset(0, -150));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        // 안드로이드는 접히는 동안 값이 잠시 1에 머문다. 사이클이 돌고 있으면 0.6을 넘는다.
        expect(_siren(tester).phase, lessThanOrEqualTo(0.6));

        await gesture.up();
        await tester.pumpAndSettle();

        expect(log, isEmpty);
        expect(_waveFinder, findsNothing);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );

    testWidgets(
      'plays_one_haptic_each_time_it_arms',
      (tester) async {
        final haptics = _recordHaptics(tester);
        await _pumpList(tester);

        // iOS 바운스에서는 손을 떼지 않고 임계점을 왔다 갔다 할 수 있다.
        final gesture = await _pull(tester, 120);
        await gesture.moveBy(const Offset(0, -150));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 150));
        await tester.pump();
        expect(haptics, hasLength(2));

        await gesture.moveBy(const Offset(0, -200));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('plays_a_second_haptic_halfway_through_the_wave', (
      tester,
    ) async {
      // 임계점에서 한 번, 파동의 절반(400ms)에서 한 번. 응답이 늦어도 더 떨리지 않는다.
      final haptics = _recordHaptics(tester);
      final gate = Completer<void>();
      await _pumpList(tester, gate: gate);

      await _pullAndRelease(tester);
      expect(haptics, hasLength(1));

      await _advance(tester, 350);
      expect(haptics, hasLength(1));

      await _advance(tester, 150);
      expect(haptics, hasLength(2));

      await _advance(tester, 2500);
      expect(haptics, hasLength(2));

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('plays_the_second_haptic_when_the_refresh_is_instant', (
      tester,
    ) async {
      // 캐시로 바로 끝나 표시가 먼저 접혀도 파동은 끝까지 가므로 진동도 그대로다.
      final haptics = _recordHaptics(tester);
      await _pumpList(tester);

      await _pullAndRelease(tester);
      await tester.pumpAndSettle();

      expect(haptics, hasLength(2));
    });

    testWidgets('shows_a_still_siren_when_animations_are_disabled', (
      tester,
    ) async {
      // 어지러움 때문에 동작 줄이기를 켠 사용자에게 화면 전체가 번쩍이면 안 된다.
      final gate = Completer<void>();
      await _pumpList(tester, gate: gate, disableAnimations: true);

      await _pullAndRelease(tester);
      await _advance(tester, 300);
      final phase = _siren(tester).phase;
      await _advance(tester, 300);

      expect(_siren(tester).phase, phase);
      expect(
        tester.renderObject(_sirenFinder),
        paintsExactlyCountTimes(#drawRRect, 3),
      );
      expect(_waveFinder, findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('cleans_up_when_removed_during_refresh', (tester) async {
      // 새로고침 중 빈 상태와 목록이 바뀌며 위젯이 사라지는 경우. 이미 띄운 파동은
      // 끝까지 간다.
      final log = <String>[];
      final gate = Completer<void>();
      await _pumpList(tester, log: log, gate: gate);

      await _pullAndRelease(tester);
      await _advance(tester, 300);

      await tester.pumpWidget(_wrap(log: log, gate: gate, showList: false));
      await tester.pump();
      expect(_waveFinder, findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_waveFinder, findsNothing);
    });

    testWidgets('closes_without_error_when_removed_as_the_finger_lifts', (
      tester,
    ) async {
      // 손을 떼는 순간 목록이 빈 상태로 바뀌는 경우. 파동을 띄우려던 다음 프레임에는
      // 위젯이 이미 없다.
      final log = <String>[];
      final gate = Completer<void>();
      await _pumpList(tester, log: log, gate: gate);

      final gesture = await _pull(tester, 200);
      await gesture.up();
      await tester.pumpWidget(_wrap(log: log, gate: gate, showList: false));

      expect(tester.takeException(), isNull);
      expect(_waveFinder, findsNothing);
    });

    testWidgets('closes_without_error_when_the_list_was_never_pulled', (
      tester,
    ) async {
      // 목록만 보고 당기지 않은 채 화면을 닫는 대부분의 경우.
      final log = <String>[];
      await _pumpList(tester, log: log);

      await tester.pumpWidget(_wrap(log: log, showList: false));

      expect(tester.takeException(), isNull);
    });

    testWidgets('pushes_the_list_with_the_pull_on_android', (tester) async {
      final gate = Completer<void>();
      await _pumpList(tester, gate: gate);
      final top = _firstItemTop(tester);

      final gesture = await _pull(tester, 50);
      expect(_firstItemTop(tester), closeTo(top + 30, 0.01));

      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();
      await gesture.up();
      await _advance(tester, 300);
      expect(_firstItemTop(tester), closeTo(top + 60, 0.01));

      gate.complete();
      await tester.pumpAndSettle();
      expect(_firstItemTop(tester), closeTo(top, 0.01));
    });

    testWidgets(
      'lets_the_bounce_settle_into_the_band_without_a_jump_on_ios',
      (tester) async {
        // 손을 떼는 프레임에 목록이 튀면 안 된다. 바운스로 되감기다가 띠 높이에서
        // 멈춰, 점을 가리지 않는다.
        final gate = Completer<void>();
        await _pumpList(tester, gate: gate);
        final top = _firstItemTop(tester);

        final gesture = await _pull(tester, 150);
        var previous = _firstItemTop(tester);
        await gesture.up();

        for (var frame = 0; frame < 90; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          final current = _firstItemTop(tester);
          expect(current, lessThanOrEqualTo(previous + 0.01));
          expect(current, greaterThanOrEqualTo(top + 60 - 0.01));
          previous = current;
        }

        gate.complete();
        await tester.pumpAndSettle();
        expect(_firstItemTop(tester), closeTo(top, 0.01));
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'moves_the_list_only_by_the_bounce_while_dragging_on_ios',
      (tester) async {
        // 바운스가 이미 내용을 내리고 있어 드래그 중에 또 밀면 두 배로 움직인다.
        final gate = Completer<void>();
        await _pumpList(tester, gate: gate);
        final top = _firstItemTop(tester);

        final gesture = await _pull(tester, 300);
        final pixels = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position
            .pixels;
        expect(pixels, lessThan(0));
        expect(_firstItemTop(tester), closeTo(top - pixels, 0.01));

        await gesture.up();
        await _advance(tester, 1000);
        expect(_firstItemTop(tester), closeTo(top + 60, 0.01));

        gate.complete();
        await tester.pumpAndSettle();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  });
}
