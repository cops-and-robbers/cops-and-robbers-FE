import 'package:cops_and_robbers/features/game/presentation/helpers/game_over_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameOverGuard.shouldSkipResume', () {
    test('returns_true_when_game_over_dialog_shown', () {
      expect(GameOverGuard.shouldSkipResume(gameOverDialogShown: true), isTrue);
    });

    test('returns_false_when_game_in_progress', () {
      expect(
        GameOverGuard.shouldSkipResume(gameOverDialogShown: false),
        isFalse,
      );
    });
  });

  group('GameOverGuard.shouldSkipSync', () {
    test('returns_true_when_game_over_dialog_shown', () {
      expect(GameOverGuard.shouldSkipSync(gameOverDialogShown: true), isTrue);
    });

    test('returns_false_when_game_in_progress', () {
      expect(GameOverGuard.shouldSkipSync(gameOverDialogShown: false), isFalse);
    });
  });

  group('GameOverGuard.shouldSkipDialogCallback', () {
    test('returns_true_when_unmounted', () {
      expect(GameOverGuard.shouldSkipDialogCallback(isMounted: false), isTrue);
    });

    test('returns_false_when_mounted', () {
      expect(GameOverGuard.shouldSkipDialogCallback(isMounted: true), isFalse);
    });
  });
}
