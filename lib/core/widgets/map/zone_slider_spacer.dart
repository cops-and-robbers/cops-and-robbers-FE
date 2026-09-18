import 'package:flutter/material.dart';

import '../inputs/app_slider.dart';

/// 핀(폴리곤) 편집에서 거리(원형) 편집의 반경 슬라이더 자리만큼을 비워 두는 위젯
///
/// 두 편집 위젯이 남는 높이를 지도로 채울 때, 거리 모드는 지도 아래에 슬라이더가 있고
/// 핀 모드는 없다. 자리를 똑같이 비워야 토글할 때 지도 크기가 튀지 않는다(DEC-0001이
/// 고친 "두 모드의 지도 크기가 다르다"를 되돌리지 않는다). 슬라이더 높이는 테마·터치
/// 영역에서 나오는 값이라 상수로 베끼지 않고, 같은 구성의 슬라이더를 보이지 않게 배치해
/// 높이를 그대로 빌린다.
class ZoneSliderSpacer extends StatelessWidget {
  const ZoneSliderSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: false,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: AppSlider(
        label: '',
        value: 0,
        min: 0,
        max: 1,
        unit: '',
        showContainer: false,
        onChanged: (_) {},
      ),
    );
  }
}
