import 'dart:ui';

import 'package:cops_and_robbers/core/constants/game_mode.dart';
import 'package:cops_and_robbers/core/i18n/role_names.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

AppLocalizations _l10n(String code) => lookupAppLocalizations(Locale(code));

void main() {
  test('role_label_is_seeker_when_police_plays_hide_and_seek', () {
    expect(roleLabel(_l10n('ko'), GameMode.hideAndSeek, isPolice: true), '술래');
    expect(
      roleLabel(_l10n('en'), GameMode.hideAndSeek, isPolice: true),
      'Seeker',
    );
    expect(roleLabel(_l10n('ja'), GameMode.hideAndSeek, isPolice: true), '鬼');
  });

  test('role_label_is_hider_when_robber_plays_hide_and_seek', () {
    expect(
      roleLabel(_l10n('ko'), GameMode.hideAndSeek, isPolice: false),
      '도망자',
    );
    expect(
      roleLabel(_l10n('en'), GameMode.hideAndSeek, isPolice: false),
      'Hider',
    );
    expect(
      roleLabel(_l10n('ja'), GameMode.hideAndSeek, isPolice: false),
      '隠れる人',
    );
  });

  test('team_name_keeps_cop_and_robber_when_mode_is_cops_and_robbers', () {
    final ko = _l10n('ko');
    expect(teamName(ko, GameMode.copsAndRobbers, isPolice: true), '경찰팀');
    expect(teamName(ko, GameMode.copsAndRobbers, isPolice: false), '도둑팀');
    expect(roleLabel(ko, GameMode.copsAndRobbers, isPolice: true), '경찰');
    expect(roleLabel(ko, GameMode.copsAndRobbers, isPolice: false), '도둑');
  });

  test('team_name_is_seeker_team_when_police_plays_hide_and_seek', () {
    expect(teamName(_l10n('ko'), GameMode.hideAndSeek, isPolice: true), '술래팀');
    expect(
      teamName(_l10n('ko'), GameMode.hideAndSeek, isPolice: false),
      '도망자팀',
    );
    expect(
      teamName(_l10n('en'), GameMode.hideAndSeek, isPolice: true),
      'Seeker team',
    );
    expect(
      teamName(_l10n('ja'), GameMode.hideAndSeek, isPolice: false),
      '隠れる人チーム',
    );
  });

  test('mode_name_shows_localized_title_when_host_picks_mode', () {
    expect(modeName(_l10n('ko'), GameMode.copsAndRobbers), '경찰과 도둑');
    expect(modeName(_l10n('ko'), GameMode.hideAndSeek), '술래잡기');
    expect(modeName(_l10n('en'), GameMode.hideAndSeek), 'Hide and Seek');
    expect(modeName(_l10n('ja'), GameMode.copsAndRobbers), '警察と泥棒');
  });
}
