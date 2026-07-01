import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/dialogs/app_dialog.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// AppDialog 확인/취소 버튼이 하드코딩 한국어가 아니라 현지화 문구를 쓰는지 회귀 검증.
///
/// 배경: `cancelText`/`confirmText` 기본값이 '취소'/'확인'으로 하드코딩되어 있어
/// 영어 기기에서 나가기 다이얼로그에 "취소"가 그대로 노출 → Apple Guideline 4 리젝(2026-07-01).
/// 근본 수정으로 기본값을 AppLocalizations(buttonCancel/buttonConfirm)로 대체했다.
Future<BuildContext> _pump(WidgetTester tester, Locale locale) async {
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
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
  );
  await tester.pumpAndSettle();
  return ctx;
}

void main() {
  group('AppDialog 버튼 현지화 (Guideline 4 재리젝 회귀 방지)', () {
    testWidgets('영어 로케일 + cancelText 생략 → "Cancel" 노출, "취소" 아님', (
      tester,
    ) async {
      final ctx = await _pump(tester, const Locale('en'));

      // 나가기 다이얼로그와 동일: title/confirmText만 넘기고 cancelText 생략
      AppDialog.confirm(context: ctx, title: 'Leave?', confirmText: 'Leave');
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('취소'), findsNothing);
      expect(find.text('Leave'), findsOneWidget);
    });

    testWidgets('한국어 로케일 + cancelText 생략 → "취소" 노출', (tester) async {
      final ctx = await _pump(tester, const Locale('ko'));

      AppDialog.confirm(context: ctx, title: '나갈까요?', confirmText: '나가기');
      await tester.pumpAndSettle();

      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('영어 로케일 + confirmText도 생략 → "Confirm" 노출, "확인" 아님', (
      tester,
    ) async {
      final ctx = await _pump(tester, const Locale('en'));

      AppDialog.confirm(context: ctx, title: 'Proceed?');
      await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('확인'), findsNothing);
    });
  });
}
