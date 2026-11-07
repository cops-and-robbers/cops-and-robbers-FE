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

  // 14:00에 시작한 5분 대기 방 — 경찰은 14:05:00에 출동한다
  group('dispatchCountdownFrame', () {
    final release = DateTime(2026, 10, 16, 14, 5);
    DispatchCountdownFrame at(Duration offset) =>
        dispatchCountdownFrame(releaseAt: release, now: release.add(offset));

    // 들어올 때: 지도·대기 화면이 보이는 구멍이 가장자리에서 사이렌 쪽으로 닫힌다(1초)
    test('screen_starts_closing_in_when_six_seconds_before_dispatch', () {
      expect(at(const Duration(seconds: -6)).cover, 0);
    });

    test(
      'screen_is_half_covered_when_five_and_half_seconds_before_dispatch',
      () {
        expect(
          at(const Duration(milliseconds: -5500)).cover,
          closeTo(0.5, 1e-9),
        );
      },
    );

    test('shows_five_without_effect_when_five_seconds_before_dispatch', () {
      final f = at(const Duration(seconds: -5));
      expect(f.seconds, 5);
      expect(f.cover, 1); // 숫자는 다 덮인 검은 화면에서 시작
      expect(f.intensity, 0);
      expect(f.iris, 0);
      expect(f.done, isFalse);
    });

    test('screen_is_ready_one_second_before_counting_when_overlay_starts', () {
      expect(
        dispatchOverlayLead,
        dispatchCountdownLead + dispatchCoverDuration,
      );
    });

    test('starts_effect_faintly_when_four_seconds_turn', () {
      final f = at(const Duration(milliseconds: -3900));
      expect(f.seconds, 4);
      expect(f.intensity, greaterThan(0));
      expect(f.intensity, lessThan(0.01));
    });

    test('shows_three_when_app_opened_three_seconds_before_dispatch', () {
      expect(at(const Duration(milliseconds: -2500)).seconds, 3);
    });

    test('effect_is_strongest_when_dispatch_arrives', () {
      final f = at(Duration.zero);
      expect(f.seconds, isNull); // 숫자 대신 "출동!"
      expect(f.intensity, 1);
      expect(f.iris, 0);
    });

    test('circle_is_half_open_when_half_second_into_iris', () {
      expect(at(const Duration(milliseconds: 1700)).iris, closeTo(0.5, 1e-9));
    });

    test('finishes_when_go_and_iris_are_over', () {
      expect(at(const Duration(milliseconds: 2199)).done, isFalse);
      expect(at(const Duration(milliseconds: 2200)).done, isTrue);
    });
  });
}
