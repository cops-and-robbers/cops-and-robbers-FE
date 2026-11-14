import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/core/constants/game_result_reason.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('gameOverReasonMessage', () {
    test('returns_all_arrested_text_when_all_arrested', () {
      expect(
        gameOverReasonMessage(
          l10n,
          GameResultReason.allArrested,
          mode: GameMode.copsAndRobbers,
        ),
        l10n.gameOverReasonAllArrested,
      );
    });

    test('returns_time_up_text_when_time_over', () {
      expect(
        gameOverReasonMessage(
          l10n,
          GameResultReason.timeOver,
          mode: GameMode.copsAndRobbers,
        ),
        l10n.gameOverReasonTimeUp,
      );
    });

    test('returns_police_forfeit_text_when_police_forfeited', () {
      expect(
        gameOverReasonMessage(
          l10n,
          GameResultReason.policeForfeited,
          mode: GameMode.copsAndRobbers,
        ),
        l10n.gameOverReasonPoliceForfeited,
      );
    });

    test('returns_robber_forfeit_text_when_robber_forfeited', () {
      expect(
        gameOverReasonMessage(
          l10n,
          GameResultReason.robberForfeited,
          mode: GameMode.copsAndRobbers,
        ),
        l10n.gameOverReasonRobberForfeited,
      );
    });

    test('returns_fallback_text_when_reason_is_unknown', () {
      expect(
        gameOverReasonMessage(l10n, null, mode: GameMode.copsAndRobbers),
        l10n.gameOverFallbackMessage,
      );
    });

    test('game_over_reason_says_seeker_wins_when_all_hiders_caught', () {
      final message = gameOverReasonMessage(
        l10n,
        GameResultReason.allArrested,
        mode: GameMode.hideAndSeek,
      );

      expect(message, contains('도망자'));
      expect(message, isNot(contains('경찰')));
      expect(message, isNot(contains('도둑')));
      expect(message, isNot(contains('체포')));
    });

    test('game_over_reason_names_seekers_when_all_seekers_left_in_tag', () {
      final message = gameOverReasonMessage(
        l10n,
        GameResultReason.policeForfeited,
        mode: GameMode.hideAndSeek,
      );

      expect(message, contains('술래'));
    });
  });
}
