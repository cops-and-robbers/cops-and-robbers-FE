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
    test('true_when_400_and_game_not_in_progress_code', () {
      expect(
        GameOverGuard.isGameNotInProgressError(
          statusCode: 400,
          errorCode: 'GAME_NOT_IN_PROGRESS',
        ),
        isTrue,
      );
    });

    test('false_when_other_errorCode', () {
      expect(
        GameOverGuard.isGameNotInProgressError(
          statusCode: 400,
          errorCode: 'GAME_FULL',
        ),
        isFalse,
      );
    });

    test('false_when_status_not_400', () {
      expect(
        GameOverGuard.isGameNotInProgressError(
          statusCode: 409,
          errorCode: 'GAME_NOT_IN_PROGRESS',
        ),
        isFalse,
      );
    });
  });

  group('GameOverGuard.shouldRequestLeaveGameAfterGameOver', () {
    test(
      'returns_true_because_server_keeps_user_in_waiting_lobby_after_game_over',
      () {
        // 서버는 게임 종료 후 세션을 WAITING 재대결 대기방으로 되돌리고 참가자를
        // 유지하므로, 퇴장하지 않으면 활성 게임 복귀 안전망(스플래시·홈·resume)이
        // 사용자를 대기방으로 되돌린다
        expect(GameOverGuard.shouldRequestLeaveGameAfterGameOver(), isTrue);
      },
    );
  });
}
