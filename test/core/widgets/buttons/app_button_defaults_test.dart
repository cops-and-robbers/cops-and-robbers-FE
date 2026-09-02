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
}
