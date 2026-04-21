import 'package:cops_and_robbers/core/constants/character_assets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('character asset bundle', () {
    test('loads_police_default_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'police');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'),
          reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });

    test('loads_robber_default_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'robber');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'),
          reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });

    test('loads_robber_jailed_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'robber', state: 'jailed');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'),
          reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });
  });
}
