import 'package:cops_and_robbers/core/constants/game_event_messages.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('resolveGameEventMessage playerLeftNotice', () {
    test('includes_nickname_and_team_label', () {
      final msg = resolveGameEventMessage(
        l10n,
        GameEventMessageKey.playerLeftNotice,
        ['도둑1', '도둑'],
      );

      expect(msg, l10n.gameEventPlayerLeftNotice('도둑1', '도둑'));
      expect(msg, contains('도둑1'));
      expect(msg, contains('도둑'));
    });
  });
}
