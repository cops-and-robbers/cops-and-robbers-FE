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

  group('GameOverGuard.shouldShowMissedGameOverFallback', () {
    test('returns_true_when_user_is_no_longer_participating', () {
      expect(
        GameOverGuard.shouldShowMissedGameOverFallback(
          isParticipating: false,
          gameStatus: null,
        ),
        isTrue,
      );
    });

    test('returns_true_when_active_game_status_is_finished', () {
      expect(
        GameOverGuard.shouldShowMissedGameOverFallback(
          isParticipating: true,
          gameStatus: 'FINISHED',
        ),
        isTrue,
      );
    });

    test('returns_true_when_active_game_status_is_canceled', () {
      expect(
        GameOverGuard.shouldShowMissedGameOverFallback(
          isParticipating: true,
          gameStatus: 'CANCELED',
        ),
        isTrue,
      );
    });

    test('returns_false_when_game_is_waiting_or_in_progress', () {
      expect(
        GameOverGuard.shouldShowMissedGameOverFallback(
          isParticipating: true,
          gameStatus: 'WAITING',
        ),
        isFalse,
      );
      expect(
        GameOverGuard.shouldShowMissedGameOverFallback(
          isParticipating: true,
          gameStatus: 'IN_PROGRESS',
        ),
        isFalse,
      );
    });
  });

  group('GameOverGuard.isGameNotInProgressError', () {
    test('returns_true_for_state_api_game_not_in_progress_400', () {
      expect(
        GameOverGuard.isGameNotInProgressError(
          statusCode: 400,
          title: '게임 진행 중 아님',
        ),
        isTrue,
      );
    });

    test('returns_false_for_other_400_errors', () {
      expect(
        GameOverGuard.isGameNotInProgressError(
          statusCode: 400,
          title: '유효하지 않은 입력값',
        ),
        isFalse,
      );
    });
  });

  group('GameOverGuard.shouldRequestLeaveGameAfterGameOver', () {
    test(
      'returns_false_because_game_over_cleanup_is_local_navigation_only',
      () {
        expect(GameOverGuard.shouldRequestLeaveGameAfterGameOver(), isFalse);
      },
    );
  });
}
