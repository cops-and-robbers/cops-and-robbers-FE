import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/loading/custom_progress_bar.dart';
import 'package:cops_and_robbers/core/widgets/loading/loading_content_view.dart';
import 'package:cops_and_robbers/core/widgets/loading/loading_page.dart';

/// LoadingPage(스플래시·딥링크 진입점)가 오버레이와 같은 뷰를 공유하는지 검증.
Future<void> _pump(WidgetTester tester, LoadingPage page) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => page,
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('LoadingPage', () {
    testWidgets('renders_shared_loading_content_view', (tester) async {
      await _pump(
        tester,
        const LoadingPage(message: '작전 지역으로 복귀 중...', subtitle: '잠시만 기다려주세요'),
      );

      expect(find.byType(LoadingContentView), findsOneWidget);
      expect(find.text('작전 지역으로 복귀 중...'), findsOneWidget);
      expect(find.text('잠시만 기다려주세요'), findsOneWidget);
    });

    testWidgets('hides_progress_bar_when_progress_is_null', (tester) async {
      await _pump(tester, const LoadingPage(message: '로딩 중'));

      expect(find.byType(CustomProgressBar), findsNothing);
    });

    testWidgets('shows_progress_bar_when_progress_is_given', (tester) async {
      await _pump(
        tester,
        const LoadingPage(message: '방 입장 중...', progress: 0.7),
      );

      expect(find.byType(CustomProgressBar), findsOneWidget);
    });
  });
}
