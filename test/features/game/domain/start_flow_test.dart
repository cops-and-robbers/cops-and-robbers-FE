import 'package:cops_and_robbers/features/game/domain/start_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 14:00:00에 시작한 5분 대기 방
  final start = DateTime(2026, 10, 16, 14);

  List<StartIntroStep> steps({
    required bool isPolice,
    required Duration after,
    int? wait = 5,
    bool isEventGame = false,
    DateTime? gameStartTime,
  }) => startIntroSteps(
    isPolice: isPolice,
    isEventGame: isEventGame,
    gameStartTime: gameStartTime ?? start,
    policeWaitMinutes: wait,
    now: start.add(after),
  );

  group('startIntroSteps', () {
    test(
      'police_sees_role_banner_then_wait_screen_when_entering_right_after_start',
      () {
        expect(steps(isPolice: true, after: const Duration(seconds: 3)), [
          StartIntroStep.roleBanner,
          StartIntroStep.policeWait,
        ]);
      },
    );

    test(
      'robber_sees_role_banner_then_explainer_when_entering_right_after_start',
      () {
        expect(steps(isPolice: false, after: const Duration(seconds: 3)), [
          StartIntroStep.roleBanner,
          StartIntroStep.robberExplainer,
        ]);
      },
    );

    test('police_sees_only_wait_screen_when_app_relaunched_two_minutes_in', () {
      expect(steps(isPolice: true, after: const Duration(minutes: 2)), [
        StartIntroStep.policeWait,
      ]);
    });

    test('robber_sees_nothing_when_app_relaunched_two_minutes_in', () {
      expect(
        steps(isPolice: false, after: const Duration(minutes: 2)),
        isEmpty,
      );
    });

    test('nobody_sees_intro_when_relaunched_after_police_dispatch', () {
      for (final isPolice in [true, false]) {
        expect(
          steps(isPolice: isPolice, after: const Duration(minutes: 6)),
          isEmpty,
        );
      }
    });

    test('only_role_banner_shows_when_room_has_no_police_wait', () {
      for (final isPolice in [true, false]) {
        expect(
          steps(isPolice: isPolice, after: const Duration(seconds: 2), wait: 0),
          [StartIntroStep.roleBanner],
        );
      }
    });

    test('event_game_shows_nothing_when_just_started', () {
      expect(
        steps(
          isPolice: true,
          after: const Duration(seconds: 2),
          isEventGame: true,
        ),
        isEmpty,
      );
    });

    test('nothing_shows_when_start_time_not_loaded_yet', () {
      expect(
        startIntroSteps(
          isPolice: true,
          isEventGame: false,
          gameStartTime: null,
          policeWaitMinutes: 5,
          now: start,
        ),
        isEmpty,
      );
    });

    test(
      'role_banner_still_shows_when_entering_exactly_twenty_seconds_after_start',
      () {
        expect(
          steps(isPolice: false, after: const Duration(seconds: 20)).first,
          StartIntroStep.roleBanner,
        );
        expect(
          steps(isPolice: false, after: const Duration(seconds: 21)),
          isEmpty,
        );
      },
    );
  });

  group('waitProgress', () {
    test('progress_is_half_when_two_and_a_half_of_five_minutes_passed', () {
      expect(
        waitProgress(
          gameStartTime: start,
          policeWaitMinutes: 5,
          now: start.add(const Duration(minutes: 2, seconds: 30)),
        ),
        0.5,
      );
    });

    test('progress_stays_at_one_when_police_already_dispatched', () {
      expect(
        waitProgress(
          gameStartTime: start,
          policeWaitMinutes: 5,
          now: start.add(const Duration(minutes: 9)),
        ),
        1,
      );
    });

    test('progress_is_one_when_room_has_no_police_wait', () {
      expect(
        waitProgress(gameStartTime: start, policeWaitMinutes: 0, now: start),
        1,
      );
    });
  });

  group('policeReleaseAt', () {
    test('release_is_start_plus_wait_when_room_waits_three_minutes', () {
      expect(
        policeReleaseAt(gameStartTime: start, policeWaitMinutes: 3),
        DateTime(2026, 10, 16, 14, 3),
      );
    });
  });

  group('startWaitScene', () {
    test('every_phone_in_same_game_shows_same_scene_when_game_id_matches', () {
      expect(startWaitScene(1048), startWaitScene(1048));
      expect(startWaitScene(1048), StartScene.town); // 1048 % 3 == 1
    });

    test('three_games_created_in_a_row_show_all_three_scenes', () {
      expect(
        {
          for (final id in [1047, 1048, 1049]) startWaitScene(id),
        },
        {StartScene.hills, StartScene.town, StartScene.city},
      );
    });
  });
}
