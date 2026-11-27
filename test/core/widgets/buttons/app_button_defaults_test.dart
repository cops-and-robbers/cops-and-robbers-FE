import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/widgets/buttons/app_button.dart';
import 'package:cops_and_robbers/core/widgets/dialogs/app_dialog.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// AppButton·AppDialog 기본 스펙(blue · radius 12 · 테두리 없음) 회귀 검증.
///
/// 배경: FE #520에서 기본값을 black/16px/테두리 있음 → blue/12px/테두리 없음으로 바꾸고
/// 호출부 오버라이드 70여 개를 지웠다. 기본값이 되돌아가면 그 호출부 전부가 조용히 틀어진다.
Future<BuildContext> _pump(WidgetTester tester) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return AppButton(text: '확인', onPressed: () {});
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ctx;
}

void main() {
  testWidgets('AppButton 기본값 — 배경 blue · radius 12 · 테두리 없음', (tester) async {
    await _pump(tester);

    final style = tester
        .widget<ElevatedButton>(find.byType(ElevatedButton))
        .style!;
    expect(style.backgroundColor!.resolve({}), AppColors.blue);
    expect(style.foregroundColor!.resolve({}), AppColors.white);
    expect(
      (style.shape!.resolve({}) as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(12.r),
    );

    final box = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppButton),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((box.decoration as BoxDecoration).border, isNull);
  });

  testWidgets('AppDialog 확인 버튼 기본값 — 라이트는 blue', (tester) async {
    final ctx = await _pump(tester);

    AppDialog.confirm(context: ctx, title: '나갈까요?', confirmText: '나가기');
    await tester.pumpAndSettle();

    final confirm = tester
        .widgetList<AppButton>(find.byType(AppButton))
        .firstWhere((b) => b.text == '나가기');
    expect(confirm.backgroundColor, AppColors.blue);
  });

  // 공용 다이얼로그는 따로 만든 모달(결과·재연결·QR)과 같은 24 모서리를 쓴다 (#713)
  testWidgets('dialog_card_has_24_radius_when_opened_with_defaults', (
    tester,
  ) async {
    final ctx = await _pump(tester);

    AppDialog.confirm(context: ctx, title: '나갈까요?', confirmText: '나가기');
    await tester.pumpAndSettle();

    final card = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppDialog),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (card.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(24.r),
    );
  });

  // 다이얼로그 버튼 글자는 16 — 화면 하단 버튼(AppButton 기본 18)보다 한 단계 작다 (#713)
  testWidgets('dialog_buttons_use_16_label_in_light_mode', (tester) async {
    final ctx = await _pump(tester);

    AppDialog.confirm(
      context: ctx,
      title: '나갈까요?',
      confirmText: '나가기',
      cancelText: '닫기',
    );
    await tester.pumpAndSettle();

    final sizes = tester
        .widgetList<AppButton>(
          find.descendant(
            of: find.byType(AppDialog),
            matching: find.byType(AppButton),
          ),
        )
        .map((b) => b.textStyle?.fontSize)
        .toList();
    expect(sizes, [16.sp, 16.sp]);
  });

  // 디자인 모달_GUI: 제목 18, 설명 14, 안쪽 여백 24, 제목-설명 8, 설명-버튼 24
  testWidgets(
    'dialog_layout_matches_modal_gui_spec_when_opened_with_defaults',
    (tester) async {
      final ctx = await _pump(tester);

      AppDialog.confirm(
        context: ctx,
        title: '이대로 방을 만들까요?',
        message: '게임 모드와 세부 설정을 확인했나요?',
        confirmText: '만들기',
        cancelText: '닫기',
      );
      await tester.pumpAndSettle();

      // 카드 바깥 여백(margin)을 빼고 흰 배경이 칠해진 영역만 잰다
      final card = tester.getRect(
        find
            .descendant(
              of: find.byType(AppDialog),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final title = find.text('이대로 방을 만들까요?');
      final message = find.text('게임 모드와 세부 설정을 확인했나요?');
      final close = tester.getRect(
        find.ancestor(of: find.text('닫기'), matching: find.byType(AppButton)),
      );
      final create = tester.getRect(
        find.ancestor(of: find.text('만들기'), matching: find.byType(AppButton)),
      );

      expect(tester.widget<Text>(title).style?.fontSize, 18.sp);
      expect(tester.widget<Text>(message).style?.fontSize, 14.sp);
      expect(tester.getRect(title).top - card.top, closeTo(24.w, 0.01));
      expect(
        tester.getRect(message).top - tester.getRect(title).bottom,
        closeTo(8.h, 0.01),
      );
      expect(close.top - tester.getRect(message).bottom, closeTo(24.h, 0.01));
      expect(close.left - card.left, closeTo(24.w, 0.01));
      expect(card.right - create.right, closeTo(24.w, 0.01));
      expect(card.bottom - close.bottom, closeTo(24.w, 0.01));
    },
  );

  // 다이얼로그 버튼이 하나뿐일 때(확인만)도 같은 16을 쓴다
  testWidgets('single_button_dialog_uses_16_label', (tester) async {
    final ctx = await _pump(tester);

    AppDialog.show(context: ctx, title: '업데이트 안내', confirmText: '확인');
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(
      find.descendant(
        of: find.byType(AppDialog),
        matching: find.byType(AppButton),
      ),
    );
    expect(button.textStyle?.fontSize, 16.sp);
  });
}
