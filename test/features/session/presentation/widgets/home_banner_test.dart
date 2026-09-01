import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/constants/app_colors.dart';
import 'package:cops_and_robbers/core/constants/app_shadows.dart';
import 'package:cops_and_robbers/features/session/presentation/widgets/home_banner.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester, {
  required String imageUrl,
  VoidCallback? onTap,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: HomeBanner(imageUrl: imageUrl, onTap: onTap),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('HomeBanner', () {
    testWidgets('hides_without_reserved_space_when_image_url_is_empty', (
      tester,
    ) async {
      await _pump(tester, imageUrl: '');

      expect(find.byType(Image), findsNothing);
      expect(tester.getSize(find.byType(HomeBanner)).height, 0);
    });

    testWidgets('renders_v3_size_and_radius_when_image_url_exists', (
      tester,
    ) async {
      await _pump(tester, imageUrl: 'https://example.com/banner.webp');

      final image = tester.widget<Image>(find.byType(Image));
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));

      expect(image.width, double.infinity);
      expect(image.height, 68.h);
      expect(image.fit, BoxFit.cover);
      expect(clip.borderRadius, BorderRadius.circular(12.r));
      // 위 여백은 위젯 구조가 아니라 실제로 밀린 거리로 본다 — Container가
      // decoration만 있어도 내부에 Padding을 하나 더 만들어서, 구조로 재면
      // 시각 손질만 해도 테스트가 깨진다.
      expect(
        tester.getTopLeft(find.byType(ClipRRect)).dy -
            tester.getTopLeft(find.byType(HomeBanner)).dy,
        16.h,
      );
    });

    testWidgets('paints_a_white_card_behind_the_image', (tester) async {
      // 배너는 흰 카드 위에 이미지를 얹은 모양이다. 배경이 비어 있으면 그림자가
      // 카드 바깥이 아니라 안쪽에 낀 것처럼 보인다.
      await _pump(tester, imageUrl: 'https://example.com/banner.webp');

      final decoration =
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byType(HomeBanner),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration
              as BoxDecoration;

      expect(decoration.color, AppColors.white);
      expect(decoration.boxShadow, AppShadows.ver2);
    });

    testWidgets('invokes_onTap_when_link_action_is_available', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        imageUrl: 'https://example.com/banner.webp',
        onTap: () => tapped = true,
      );

      await tester.tap(find.byType(HomeBanner));

      expect(tapped, isTrue);
    });
  });
}
