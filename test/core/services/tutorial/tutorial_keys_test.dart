import 'package:cops_and_robbers/core/services/tutorial/tutorial_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TutorialKeys.waitingRoom', () {
    test('단일 키 상수 값', () {
      expect(TutorialKeys.waitingRoom, 'tutorial_waiting_room');
    });

    test('TutorialKeys.all 에 포함된다', () {
      expect(TutorialKeys.all, contains(TutorialKeys.waitingRoom));
    });
  });

  group('TutorialKeys.inGamePrompt', () {
    test('단일 키 상수 값', () {
      expect(TutorialKeys.inGamePrompt, 'tutorial_in_game_prompt');
    });

    test('TutorialKeys.all 에 포함된다', () {
      expect(TutorialKeys.all, contains(TutorialKeys.inGamePrompt));
    });
  });
}
