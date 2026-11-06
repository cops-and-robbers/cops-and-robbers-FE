import 'package:cops_and_robbers/features/game/presentation/widgets/marquee_alert_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 시작 장면은 카드 줄이 양옆 16씩 안쪽이라 배너 칸이 화면 폭보다 좁다 —
  // 공지 글자는 그 칸의 오른쪽 끝에서 바로 들어와야 늦게 보이지 않는다
  testWidgets(
    'notice_text_starts_at_text_area_edge_when_banner_sits_in_card_row',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const message = '도둑 한 명이 체포됐어요';
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (_, _) => const MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: MarqueeAlertBanner(
                  message: message,
                  isDarkMode: false,
                  horizontalMargin: 0,
                ),
              ),
            ),
          ),
        ),
      );

      final textArea = tester.getRect(
        find
            .descendant(
              of: find.byType(MarqueeAlertBanner),
              matching: find.byType(ClipRect),
            )
            .last,
      );
      expect(tester.getTopLeft(find.text(message)).dx, textArea.right);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 10));
    },
  );
}
