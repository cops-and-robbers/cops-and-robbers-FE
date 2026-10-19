import 'package:cops_and_robbers/core/constants/character_assets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 디자이너가 그림을 갈아 끼우다 파일이 빠지거나 pubspec 폴더 선언이 빠지면
  // 게임 시작 때 캐릭터·배경 자리가 빈 칸으로 뜬다.
  test('start_screen_pictures_load_from_app_bundle_when_game_starts', () async {
    final paths = [
      for (final team in ['police', 'robber']) ...[
        startRoleCharacterAssetPath(team: team),
        startChaseCharacterAssetPath(team: team),
      ],
      for (final scene in ['hills', 'town', 'city'])
        for (final isNight in [false, true])
          startWaitBackgroundAssetPath(scene: scene, isNight: isNight),
    ];
    expect(paths, hasLength(10));
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });
}
