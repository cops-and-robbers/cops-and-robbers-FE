import 'package:cops_and_robbers/features/community/presentation/pages/community_create_page.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_headcount_sheet.dart';
import 'package:cops_and_robbers/features/community/presentation/widgets/community_sheet_scaffold.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// 기본 테스트 뷰포트(800×600)는 디자인 기준(393×852)보다 넓고 낮아, 글자가 2배로
/// 커진 채 아래 항목이 화면 밖으로 밀린다 — 탭이 빗나가는 원인이라 실기기 크기로 맞춘다.
Future<void> _pumpPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap());
  await tester.pumpAndSettle();
}

Widget _wrap() => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, _) => MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const CommunityCreatePage(),
  ),
);

/// AppBar 완료 라벨의 색 — 활성/비활성 판정을 이 색 하나로 읽는다.
Color _doneColor(WidgetTester tester) {
  return tester.widget<Text>(find.text('완료')).style!.color!;
}

/// 시트가 열려 있으면 AppBar와 시트 양쪽에 "완료"가 있다. 시트 쪽만 누른다.
Future<void> _tapSheetDone(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(CommunitySheetScaffold),
      matching: find.text('완료'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillTextFields(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), '퇴근하고 한 판');
  await tester.enterText(find.byType(TextField).at(1), '규칙은 현장에서 정해요');
  // 인덱스 2는 날짜(읽기 전용), 3이 장소.
  await tester.enterText(find.byType(TextField).at(3), '어린이대공원 정문');
  await tester.pump();
}

void main() {
  group('CommunityCreatePage', () {
    testWidgets('renders_every_section_without_overflow_when_opened', (
      tester,
    ) async {
      await _pumpPage(tester);

      for (final label in ['제목', '설명', '날짜', '장소', '모집 인원']) {
        expect(find.text(label), findsOneWidget);
      }
      // 제목 / 설명 / 날짜 / 장소
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.text('10명'), findsOneWidget);
    });

    testWidgets('keeps_done_disabled_when_date_is_not_picked', (tester) async {
      await _pumpPage(tester);

      await _fillTextFields(tester);

      // 텍스트 세 칸이 다 차도 날짜가 비면 완료는 죽어 있다.
      expect(_doneColor(tester), const Color(0xFFB1BCC8));
    });

    testWidgets('enables_done_when_date_is_picked_after_text_fields', (
      tester,
    ) async {
      await _pumpPage(tester);

      await _fillTextFields(tester);
      // 힌트 Text는 AbsorbPointer 안이라 스스로 탭을 못 받는다 — 탭은 바깥
      // GestureDetector가 처리하므로 빗나감 경고만 끈다.
      await tester.tap(find.text('모임 날짜를 골라주세요'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await _tapSheetDone(tester);

      expect(_doneColor(tester), const Color(0xFF4D63FF));
    });

    testWidgets('shows_date_and_time_rows_when_date_sheet_opens', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.text('모임 날짜를 골라주세요'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('모임 날짜 및 시간'), findsOneWidget);
      expect(find.text('시간'), findsOneWidget);
      // 처음에는 두 행만 보이고 휠은 접혀 있다.
      expect(find.byType(CupertinoDatePicker), findsNothing);
    });

    testWidgets('expands_only_the_tapped_wheel_when_a_row_is_tapped', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.text('모임 날짜를 골라주세요'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.tap(find.text('시간'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsOneWidget);

      // 같은 행을 다시 누르면 접힌다.
      await tester.tap(find.text('시간'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsNothing);
    });

    testWidgets('moves_focus_to_content_when_title_is_submitted', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.byType(TextField).at(0));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      final content = tester.widget<TextField>(find.byType(TextField).at(1));
      expect(content.focusNode!.hasFocus, isTrue);
    });

    testWidgets('applies_picked_headcount_when_number_is_tapped', (
      tester,
    ) async {
      await _pumpPage(tester);

      await tester.tap(find.text('10명'));
      await tester.pumpAndSettle();

      // 시트의 "+ 5명" 칩으로 15명까지 올린 뒤 확정한다.
      await tester.tap(find.text('+ 5명'));
      await tester.pumpAndSettle();
      await _tapSheetDone(tester);

      expect(find.text('15명'), findsOneWidget);
    });

    testWidgets('stops_decreasing_headcount_at_backend_minimum', (
      tester,
    ) async {
      await _pumpPage(tester);

      // 기본 10에서 하한 2까지 여덟 번, 그 뒤로는 더 내려가지 않는다.
      for (int i = 0; i < 12; i++) {
        await tester.tap(find.text('-'));
        await tester.pump();
      }

      expect(find.text('${CommunityHeadcountSheet.min}명'), findsOneWidget);
    });
  });
}
