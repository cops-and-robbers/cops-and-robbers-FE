import 'package:cops_and_robbers/core/constants/game_result_reason.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('gameOverReasonMessage', () {
    test('returns_all_arrested_text_when_all_arrested', () {
      expect(
        gameOverReasonMessage(l10n, GameResultReason.allArrested),
        l10n.gameOverReasonAllArrested,
      );
    });

    test('returns_time_up_text_when_time_over', () {
      expect(
        gameOverReasonMessage(l10n, GameResultReason.timeOver),
        l10n.gameOverReasonTimeUp,
      );
    });

    test('returns_police_forfeit_text_when_police_forfeited', () {
      expect(
        gameOverReasonMessage(l10n, GameResultReason.policeForfeited),
        l10n.gameOverReasonPoliceForfeited,
      );
    });

    test('returns_robber_forfeit_text_when_robber_forfeited', () {
      expect(
        gameOverReasonMessage(l10n, GameResultReason.robberForfeited),
        l10n.gameOverReasonRobberForfeited,
      );
    });

    test('returns_fallback_text_when_reason_is_unknown', () {
      expect(gameOverReasonMessage(l10n, null), l10n.gameOverFallbackMessage);
    });
  });
}
