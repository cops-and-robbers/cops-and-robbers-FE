import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 온보딩 일러스트가 번들에 실제로 들어갔는지 확인한다.
///
/// 경로 오타나 `pubspec.yaml` 의 `assets:` 누락은 컴파일에서 걸리지 않고
/// 실행 시 빈 화면으로만 드러난다 — 설치 후 1회뿐인 화면이라 놓치기 쉽다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const paths = [
    'assets/onboarding/onboarding1.svg',
    'assets/onboarding/onboarding2_1.svg',
    'assets/onboarding/onboarding2_2.svg',
    'assets/onboarding/onboarding3.svg',
    'assets/onboarding/onboarding4.svg',
  ];

  for (final path in paths) {
    test(
      'loads_${path.split('/').last.split('.').first}_svg_when_bundled',
      () async {
        final data = await rootBundle.loadString(path);
        expect(data, contains('<svg'), reason: '$path 가 번들에 없거나 SVG 형식이 아님');
      },
    );
  }
}
