import 'dart:ui';

import 'package:cops_and_robbers/core/services/background/lock_screen_status.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/lock_screen_status_builder.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  final l10n = lookupAppLocalizations(const Locale('ko'));
  final start = DateTime(2026, 9, 30, 10);

  LockScreenStatus build({
    int? interval = 3,
    int? alive = 3,
    int? total = 5,
    bool isEventGame = false,
    bool isRobberTeam = false,
  }) => buildLockScreenStatus(
    start: start,
    roundMinutes: 30,
    policeWaitMinutes: 5,
    intervalMinutes: interval,
    now: DateTime(2026, 9, 30, 10, 12),
    aliveRobbers: alive,
    totalRobbers: total,
    isEventGame: isEventGame,
    isRobberTeam: isRobberTeam,
    l10n: l10n,
  );

  LockScreenStatus expected({
    DateTime? nextRevealAt,
    int? alive,
    int? total,
    String? robbersText,
    String? revealText,
    bool isRobberTeam = false,
    String teamLabel = '경찰',
  }) => LockScreenStatus(
    startAt: DateTime(2026, 9, 30, 10),
    endAt: DateTime(2026, 9, 30, 10, 30),
    nextRevealAt: nextRevealAt,
    aliveRobbers: alive,
    totalRobbers: total,
    title: l10n.appTitle,
    robbersText: robbersText,
    revealText: revealText,
    remainingTimeLabel: '남은 시간',
    remainingRobbersLabel: '남은 도둑',
    locationRevealLabel: '위치 공개',
    gameOverLabel: '게임 종료',
    isRobberTeam: isRobberTeam,
    teamLabel: teamLabel,
    localeCode: 'ko',
  );

  test('status_shows_robbers_and_reveal_when_normal_game_midway', () {
    expect(
      build(),
      expected(
        nextRevealAt: DateTime(2026, 9, 30, 10, 14),
        alive: 3,
        total: 5,
        robbersText: '남은 도둑 3/5',
        revealText: '10:14 위치 공개',
      ),
    );
  });

  test('status_hides_robbers_when_event_game', () {
    // 이벤트 모드는 체포돼도 도둑이 ALIVE로 남아 수가 의미 없다.
    expect(
      build(isEventGame: true),
      expected(
        nextRevealAt: DateTime(2026, 9, 30, 10, 14),
        revealText: '10:14 위치 공개',
      ),
    );
  });

  test('status_hides_robbers_when_count_unknown', () {
    expect(
      build(alive: null, total: null),
      expected(
        nextRevealAt: DateTime(2026, 9, 30, 10, 14),
        revealText: '10:14 위치 공개',
      ),
    );
  });

  test('status_hides_reveal_when_interval_is_zero', () {
    expect(
      build(interval: 0),
      expected(alive: 3, total: 5, robbersText: '남은 도둑 3/5'),
    );
  });

  test('status_uses_robber_theme_when_my_team_is_robber', () {
    // 잠금 화면 카드가 팀 테마(도둑=어두운 테마·도둑 캐릭터)로 그려지도록 팀을 넘긴다.
    expect(
      build(isRobberTeam: true),
      expected(
        nextRevealAt: DateTime(2026, 9, 30, 10, 14),
        alive: 3,
        total: 5,
        robbersText: '남은 도둑 3/5',
        revealText: '10:14 위치 공개',
        isRobberTeam: true,
        teamLabel: '도둑',
      ),
    );
  });
}
