import 'package:flutter/material.dart';
import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/start/chase_scene_rules.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  List<String> rules(GameMode mode, ChaseSceneMode scene) => chaseSceneRules(
    l10n,
    gameMode: mode,
    mode: scene,
    isPolice: false,
    revealMinutes: 3,
  );

  test('start_rules_hide_jailbreak_line_when_playing_hide_and_seek', () {
    expect(
      rules(GameMode.hideAndSeek, ChaseSceneMode.rulesReplay),
      isNot(contains(l10n.startRuleJailbreakReplay)),
    );
    expect(
      rules(GameMode.hideAndSeek, ChaseSceneMode.robberExplainer),
      isNot(contains(l10n.startRuleJailbreak)),
    );
  });

  test('start_rules_keep_jailbreak_line_when_playing_cops_and_robbers', () {
    expect(
      rules(GameMode.copsAndRobbers, ChaseSceneMode.rulesReplay),
      contains(l10n.startRuleJailbreakReplay),
    );
    expect(
      rules(GameMode.copsAndRobbers, ChaseSceneMode.robberExplainer),
      contains(l10n.startRuleJailbreak),
    );
  });
}
