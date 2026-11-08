import 'package:cops_and_robbers/core/constants/character_assets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('character asset bundle', () {
    test('loads_police_ready_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'police', state: 'ready');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'), reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });

    test('loads_robber_ready_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'robber', state: 'ready');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'), reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });

    // 준비 상태는 없어졌지만(#661) 이 그림은 술래잡기 튜토리얼의 탈락 장면(`tutorial_overlays.dart` `_outed`)이 쓴다
    test('loads_robber_not_ready_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'robber', state: 'not_ready');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'), reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });

    test('loads_robber_jailed_svg_when_bundled', () async {
      final path = characterAssetPath(team: 'robber', state: 'jailed');
      final data = await rootBundle.loadString(path);
      expect(data, contains('<svg'), reason: '$path 가 번들에 없거나 SVG 형식이 아님');
    });
  });
}
