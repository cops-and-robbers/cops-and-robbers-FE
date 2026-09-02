import 'package:cops_and_robbers/core/constants/app_icons.dart';
import 'package:cops_and_robbers/core/widgets/buttons/app_button.dart';
import 'package:cops_and_robbers/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
  designSize: const Size(393, 852),
  builder: (_, _) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

SvgPicture _icon(WidgetTester tester) =>
    tester.widget<SvgPicture>(find.byType(SvgPicture));

void main() {
  group('EmptyState', () {
    testWidgets('draws_the_not_found_character_with_the_message', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const EmptyState(message: '등록된 공지가 없어요')));

      expect(find.text('등록된 공지가 없어요'), findsOneWidget);
      expect(
        (_icon(tester).bytesLoader as SvgAssetLoader).assetName,
        AppIcons.notFound,
      );
    });

    testWidgets('offers_no_button_when_there_is_nothing_to_do', (tester) async {
      // 빈 목록 대부분은 사용자가 할 일이 없다 — 버튼 자리를 늘 잡아 두면
      // 화면마다 빈 공간이 생긴다.
      await tester.pumpWidget(_wrap(const EmptyState(message: '받은 알림이 없어요')));

      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('runs_the_action_when_the_button_is_tapped', (tester) async {
      var tapped = 0;

      await tester.pumpWidget(
        _wrap(
          EmptyState(
            message: '글을 불러오지 못했어요',
            actionText: '다시 시도',
            onAction: () => tapped++,
          ),
        ),
      );
      await tester.tap(find.text('다시 시도'));

      expect(tapped, 1);
    });

    testWidgets('hides_the_button_when_only_its_label_is_given', (
      tester,
    ) async {
      // 라벨만 있고 할 일이 없으면 눌리지 않는 버튼이 남는다.
      await tester.pumpWidget(
        _wrap(const EmptyState(message: '글을 불러오지 못했어요', actionText: '다시 시도')),
      );

      expect(find.byType(AppButton), findsNothing);
    });
  });
}
