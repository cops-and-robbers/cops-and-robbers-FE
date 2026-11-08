import 'package:clock/clock.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_timer_text.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../session/presentation/pages/creation_flow_fakes.dart';

/// 375pt 폰의 앱바 가운데 칸(좌우 아이콘 56 + 여백 16씩 뺀 폭)에서 구역 축소 문구가
/// 잘리거나 두 줄이 되지 않는지 실제 글꼴(Pretendard)로 잰다 (#668).
void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(
    WidgetTester tester,
    String locale, {
    bool outside = false,
  }) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 230,
                child: GameTimerText(
                  startTime: DateTime(2026, 11, 8, 12),
                  totalDuration: const Duration(minutes: 60),
                  policeWaitMinutes: 5,
                  locationRevealIntervalMinutes: 10,
                  nextShrinkAt: (_) => DateTime(2026, 11, 8, 12, 45, 59),
                  zoneWarningAt: outside
                      ? (_) => (count: 2, untilNext: const Duration(seconds: 59))
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 축소·경고 줄(두 번째 Text)이 한 줄에 다 들어갔는지
  void expectOneLine(WidgetTester tester) {
    final lines = tester
        .renderObjectList<RenderParagraph>(find.byType(RichText))
        .skip(1);
    for (final p in lines) {
      expect(p.didExceedMaxLines, isFalse, reason: p.text.toPlainText());
      expect(
        p.size.height,
        lessThan(p.text.style!.fontSize! * 2),
        reason: '두 줄로 넘어감: ${p.text.toPlainText()}',
      );
    }
  }

  for (final locale in ['ko', 'en', 'ja']) {
    testWidgets('reveal_and_shrink_line_fits_app_bar_in_$locale', (
      tester,
    ) async {
      await withClock(Clock.fixed(DateTime(2026, 11, 8, 12, 6)), () async {
        await pump(tester, locale);
        expectOneLine(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    });

    testWidgets('warning_line_fits_app_bar_in_$locale', (tester) async {
      await withClock(Clock.fixed(DateTime(2026, 11, 8, 12, 6)), () async {
        await pump(tester, locale, outside: true);
        expectOneLine(tester);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    });
  }
}
