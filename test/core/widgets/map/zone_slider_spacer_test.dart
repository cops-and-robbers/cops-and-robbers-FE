import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/inputs/app_slider.dart';
import 'package:cops_and_robbers/core/widgets/map/zone_slider_spacer.dart';

void main() {
  testWidgets('takes_the_same_height_as_the_radius_slider_when_laid_out', (
    tester,
  ) async {
    const sliderKey = Key('slider');
    const spacerKey = Key('spacer');
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // 거리 모드가 지도 아래에 두는 슬라이더와 같은 구성
                AppSlider(
                  key: sliderKey,
                  label: '반경',
                  value: 500,
                  min: 100,
                  max: 1000,
                  unit: 'm',
                  showContainer: false,
                  onChanged: (_) {},
                ),
                const ZoneSliderSpacer(key: spacerKey),
              ],
            ),
          ),
        ),
      ),
    );

    final sliderHeight = tester.getSize(find.byKey(sliderKey)).height;
    expect(sliderHeight, greaterThan(0));
    expect(tester.getSize(find.byKey(spacerKey)).height, sliderHeight);
    // 자리만 차지한다 — 보이지도 눌리지도 않는다
    expect(find.byType(Slider).hitTestable(), findsOneWidget);
  });
}
