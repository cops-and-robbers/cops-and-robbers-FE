import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(HomeBanner),
          matching: find.byType(Padding),
        ),
      );

      expect(image.width, double.infinity);
      expect(image.height, 68.h);
      expect(image.fit, BoxFit.cover);
      expect(clip.borderRadius, BorderRadius.circular(12.r));
      expect(padding.padding.resolve(TextDirection.ltr).top, 16.h);
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
