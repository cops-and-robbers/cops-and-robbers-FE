import 'package:cops_and_robbers/core/constants/app_sounds.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // pubspec에 sounds/ 등록이 빠지면 빌드는 통과하고 출동 때 조용히 소리만 안 난다
  test('siren_is_bundled_when_app_builds', () async {
    final data = await rootBundle.load(AppSounds.siren);
    expect(data.lengthInBytes, greaterThan(0));
  });
}
