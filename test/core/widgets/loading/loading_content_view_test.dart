import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/widgets/loading/loading_content_view.dart';
import 'package:cops_and_robbers/core/widgets/loading/loading_visuals.dart';

/// 풀스크린 로딩 콘텐츠 렌더링 검증.
Future<void> _pump(
  WidgetTester tester, {
  required String message,
  String? subtitle,
  bool isDarkMode = false,
  Widget? bottom,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => LoadingContentView(
          message: message,
          subtitle: subtitle,
          isDarkMode: isDarkMode,
          bottom: bottom,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('LoadingContentView', () {
    testWidgets('renders_message_and_subtitle', (tester) async {
      await _pump(
        tester,
        message: '잠입 준비 중...',
        subtitle: '지금 앱을 끄면 합류가 취소돼요',
      );

      expect(find.text('잠입 준비 중...'), findsOneWidget);
      expect(find.text('지금 앱을 끄면 합류가 취소돼요'), findsOneWidget);
      expect(find.byType(LoadingVisual), findsOneWidget);
    });

    testWidgets('renders_without_subtitle_when_subtitle_is_null', (
      tester,
    ) async {
      await _pump(tester, message: '로딩 중');

      expect(find.text('로딩 중'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses_black_background_when_dark_mode', (tester) async {
      await _pump(tester, message: '변장 중...', isDarkMode: true);

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(LoadingContentView),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppColors.black);
    });

    testWidgets('uses_white_background_when_light_mode', (tester) async {
      await _pump(tester, message: '잠입 준비 중...');

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(LoadingContentView),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppColors.white);
    });

    testWidgets('renders_bottom_slot_when_provided', (tester) async {
      await _pump(
        tester,
        message: '방 입장 중...',
        bottom: const Text('진행률 70%'),
      );

      expect(find.text('진행률 70%'), findsOneWidget);
    });
  });
}
