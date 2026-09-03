import 'package:cops_and_robbers/core/widgets/inputs/number_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('emits_digit_quick_add_and_backspace_events', (tester) async {
    final digits = <int>[];
    final quicks = <int>[];
    var backspaces = 0;

    await tester.pumpWidget(
      _wrap(
        NumberPad(
          quickAmounts: const [5, 10, 20],
          unit: '명',
          onDigit: digits.add,
          onQuickAdd: quicks.add,
          onBackspace: () => backspaces++,
        ),
      ),
    );

    await tester.tap(find.text('7'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('10명'));
    await tester.tap(find.byIcon(Icons.backspace_outlined));

    expect(digits, [7, 0]);
    expect(quicks, [10]);
    expect(backspaces, 1);
  });

  testWidgets('renders_all_digits_and_quick_chips', (tester) async {
    await tester.pumpWidget(
      _wrap(
        NumberPad(
          quickAmounts: const [3, 5, 10],
          unit: '분',
          onDigit: (_) {},
          onQuickAdd: (_) {},
          onBackspace: () {},
        ),
      ),
    );

    for (var d = 0; d <= 9; d++) {
      expect(find.text('$d'), findsOneWidget);
    }
    expect(find.text('+'), findsNWidgets(3));
    expect(find.text('3분'), findsOneWidget);
    expect(find.text('5분'), findsOneWidget);
    expect(find.text('10분'), findsOneWidget);
  });

  testWidgets(
    'keeps_full_inset_on_android_and_reduces_it_on_ios',
    (tester) async {
      tester.view.viewPadding = FakeViewPadding(
        bottom: 34 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetViewPadding);

      await tester.pumpWidget(
        _wrap(
          NumberPad(
            quickAmounts: const [5, 10, 20],
            unit: '명',
            onDigit: (_) {},
            onQuickAdd: (_) {},
            onBackspace: () {},
          ),
        ),
      );
      final context = tester.element(find.byType(NumberPad));
      final deviceBottomInset = MediaQuery.viewPaddingOf(context).bottom;
      final expectedBottomInset =
          Theme.of(context).platform == TargetPlatform.iOS
          ? deviceBottomInset - 18.h
          : deviceBottomInset;
      final numberPadSurface = find
          .descendant(
            of: find.byType(NumberPad),
            matching: find.byType(Container),
          )
          .first;

      expect(
        tester.getSize(numberPadSurface).height,
        closeTo(361.h + expectedBottomInset, 0.001),
      );
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
