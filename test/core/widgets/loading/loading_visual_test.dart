import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/loading/loading_visuals.dart';

/// 로딩 비주얼이 팀 테마에 맞는 캐릭터를 그리는지 검증.
///
/// 디자이너 자산 교체 시 이 테스트의 기대 경로도 함께 바꾼다.
Future<void> _pump(WidgetTester tester, {required bool isDarkMode}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) =>
            Scaffold(body: Center(child: LoadingVisual(isDarkMode: isDarkMode))),
      ),
    ),
  );
  await tester.pump();
}

String _assetOf(WidgetTester tester) {
  final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
  return (svg.bytesLoader as SvgAssetLoader).assetName;
}

void main() {
  group('LoadingVisual', () {
    testWidgets('renders_police_character_when_light_mode', (tester) async {
      await _pump(tester, isDarkMode: false);

      expect(_assetOf(tester), 'assets/loading/police.svg');
    });

    testWidgets('renders_robber_character_when_dark_mode', (tester) async {
      await _pump(tester, isDarkMode: true);

      expect(_assetOf(tester), 'assets/loading/robber.svg');
    });

    testWidgets('disposes_animation_without_error_when_removed', (tester) async {
      await _pump(tester, isDarkMode: false);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(tester.takeException(), isNull);
    });
  });
}
