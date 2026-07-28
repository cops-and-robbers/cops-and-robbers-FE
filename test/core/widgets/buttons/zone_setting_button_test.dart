import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/buttons/zone_setting_button.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

const _origin = GeoPoint(latitude: 37.5665, longitude: 126.9780);

Future<void> _pump(WidgetTester tester, AreaShape? shape) async {
  // 버튼은 56h/76h 고정 높이라 기본 테스트 표면(800x600)에서는 ScreenUtil이
  // 높이는 줄이고 텍스트(.sp)는 너비 기준으로 키워 오버플로가 난다.
  // 설계 크기와 동일한 표면에서 검증한다.
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
          body: ZoneSettingButton(
            zoneType: ZoneType.playground,
            title: '플레이그라운드',
            shape: shape,
            onPressed: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ZoneSettingButton', () {
    testWidgets('shows_radius_subtitle_when_shape_is_circle', (tester) async {
      await _pump(
        tester,
        const AreaShape.circle(center: _origin, radiusInMeters: 400),
      );

      expect(find.text('반경 400m'), findsOneWidget);
    });

    testWidgets('shows_area_subtitle_when_shape_is_polygon', (tester) async {
      await _pump(
        tester,
        const AreaShape.polygon(
          points: [
            GeoPoint(latitude: 37.5665, longitude: 126.9780),
            GeoPoint(latitude: 37.5674, longitude: 126.9780),
            GeoPoint(latitude: 37.5674, longitude: 126.9791),
          ],
        ),
      );

      expect(find.textContaining('면적'), findsOneWidget);
      expect(find.textContaining('반경'), findsNothing);
    });

    testWidgets('shows_no_subtitle_when_shape_is_null', (tester) async {
      await _pump(tester, null);

      expect(find.text('플레이그라운드'), findsOneWidget);
      expect(find.textContaining('반경'), findsNothing);
      expect(find.textContaining('면적'), findsNothing);
    });
  });
}
