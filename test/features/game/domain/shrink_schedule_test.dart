import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/shrink_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  const center = GeoPoint(latitude: 37.55, longitude: 127.07);

  CircleShape circle(GeoPoint c, double r) =>
      AreaShape.circle(center: c, radiusInMeters: r) as CircleShape;

  GameAreaEntity area(AreaShape playground, AreaShape jail) =>
      GameAreaEntity(playground: playground, jail: jail);

  double distance(GeoPoint a, GeoPoint b) => Geolocator.distanceBetween(
    a.latitude,
    a.longitude,
    b.latitude,
    b.longitude,
  );

  group('최종 반경', () {
    test('final_radius_is_200_for_500m_playground_with_100m_jail', () {
      // 기본 추천 구역: 500m 안에 감옥 100m
      expect(computeShrinkFinalRadius(startRadius: 500, jailRadius: 100), 200);
    });

    test('final_radius_is_140_for_350m_playground_with_10m_jail', () {
      expect(computeShrinkFinalRadius(startRadius: 350, jailRadius: 10), 140);
    });

    test('final_radius_caps_at_200_for_1km_playground', () {
      expect(computeShrinkFinalRadius(startRadius: 1000, jailRadius: 10), 200);
    });

    test('final_radius_is_floored_for_333m_playground', () {
      // 333 × 0.4 = 133.2 → 서버 필드가 정수라 내림
      expect(computeShrinkFinalRadius(startRadius: 333, jailRadius: 10), 133);
    });

    test('final_radius_treats_missing_jail_as_zero_for_hide_and_seek', () {
      // 술래잡기(감옥 없음) 대비: 감옥 반경 0으로 계산
      expect(computeShrinkFinalRadius(startRadius: 300, jailRadius: 0), 120);
    });
  });

  group('토글 잠금', () {
    test('lock_is_too_small_when_playground_is_jail_plus_100m', () {
      expect(
        shrinkLockFor(area(circle(center, 200), circle(center, 100))),
        ShrinkLock.tooSmall,
      );
    });

    test('lock_is_none_when_playground_is_one_meter_bigger', () {
      expect(
        shrinkLockFor(area(circle(center, 201), circle(center, 100))),
        ShrinkLock.none,
      );
    });

    test('lock_rounds_radius_like_server_for_200_4m_playground', () {
      // 서버엔 round()한 200이 저장된다 → 감옥 100 + 100과 같아 잠겨야 한다
      expect(
        shrinkLockFor(area(circle(center, 200.4), circle(center, 100))),
        ShrinkLock.tooSmall,
      );
    });

    test('lock_is_not_circle_for_pin_drawn_area', () {
      const p = AreaShape.polygon(
        points: [
          GeoPoint(latitude: 37.55, longitude: 127.07),
          GeoPoint(latitude: 37.56, longitude: 127.07),
          GeoPoint(latitude: 37.56, longitude: 127.08),
        ],
      );
      expect(shrinkLockFor(area(p, p)), ShrinkLock.notCircle);
    });
  });

  group('차수 계산', () {
    final start = DateTime(2026, 11, 8, 12);

    ShrinkState at(
      DateTime now, {
      int round = 30,
      int wait = 5,
      double r = 1000,
      CircleShape? jail,
      int fin = 200,
    }) => shrinkStateAt(
      start: start,
      roundDurationMinutes: round,
      policeWaitMinutes: wait,
      playground: circle(center, r),
      jail: jail ?? circle(center, 10),
      finalRadius: fin,
      now: now,
    );

    test(
      'thirty_minute_game_with_five_minute_police_wait_keeps_start_zone_before_police',
      () {
        final s = at(DateTime(2026, 11, 8, 12, 3));
        expect(s.stage, 0);
        expect(s.current.radiusInMeters, 1000);
        expect(s.nextAt, DateTime(2026, 11, 8, 12, 10));
      },
    );

    test('thirty_minute_game_shrinks_at_10_15_20_25_minutes', () {
      // 1ms 전은 이전 차수, 정각은 새 차수
      final justBefore = at(DateTime(2026, 11, 8, 12, 9, 59, 999));
      expect(justBefore.stage, 0);
      expect(justBefore.next!.radiusInMeters, 800);

      final first = at(DateTime(2026, 11, 8, 12, 10));
      expect(first.stage, 1);
      expect(first.current.radiusInMeters, 800);
      expect(first.nextAt, DateTime(2026, 11, 8, 12, 15));

      expect(at(DateTime(2026, 11, 8, 12, 15)).current.radiusInMeters, 600);
      expect(at(DateTime(2026, 11, 8, 12, 20)).current.radiusInMeters, 400);

      final last = at(DateTime(2026, 11, 8, 12, 25));
      expect(last.stage, 4);
      expect(last.current.radiusInMeters, 200);
      expect(last.nextAt, isNull);
      expect(last.next, isNull);

      expect(at(DateTime(2026, 11, 8, 12, 29)).stage, 4);
    });

    test(
      'ten_minute_game_with_one_minute_police_wait_shrinks_every_108_seconds',
      () {
        // 간격 (10 - 1) / 5 = 1분 48초 → 2:48, 4:36, 6:24, 8:12
        expect(
          at(DateTime(2026, 11, 8, 12, 2, 47), round: 10, wait: 1).stage,
          0,
        );
        expect(
          at(DateTime(2026, 11, 8, 12, 2, 48), round: 10, wait: 1).stage,
          1,
        );
        expect(
          at(DateTime(2026, 11, 8, 12, 4, 36), round: 10, wait: 1).stage,
          2,
        );
        expect(
          at(DateTime(2026, 11, 8, 12, 6, 24), round: 10, wait: 1).stage,
          3,
        );
        expect(
          at(DateTime(2026, 11, 8, 12, 8, 12), round: 10, wait: 1).stage,
          4,
        );
      },
    );

    test('no_shrink_when_police_wait_is_not_shorter_than_game_time', () {
      final s = at(DateTime(2026, 11, 8, 12, 9), round: 10, wait: 10);
      expect(s.stage, 0);
      expect(s.current.radiusInMeters, 1000);
      expect(s.nextAt, isNull);
    });

    test('final_circle_moves_toward_edge_jail_until_it_contains_the_jail', () {
      // 500m 구역 가장자리 쪽(북쪽 330m)에 감옥 60m — 최종 200m 원이 감옥을 품어야 한다
      const jailCenter = GeoPoint(
        latitude: 37.55 + 330 / 111320,
        longitude: 127.07,
      );
      final jail = circle(jailCenter, 60);
      ShrinkState s(int minute) =>
          at(DateTime(2026, 11, 8, 12, minute), r: 500, jail: jail, fin: 200);

      final last = s(25);
      expect(
        distance(last.current.center, jailCenter) + 60,
        lessThanOrEqualTo(200.5),
      );

      final total = distance(center, last.current.center);
      final second = distance(center, s(15).current.center);
      expect(second / total, closeTo(0.5, 0.01));
    });

    test('centered_jail_keeps_center_still', () {
      final s = at(DateTime(2026, 11, 8, 12, 25), jail: circle(center, 10));
      expect(distance(s.current.center, center), lessThan(0.01));
    });
  });

  group('축소 시계', () {
    final start = DateTime(2026, 11, 8, 12);
    final area = GameAreaEntity(
      playground: circle(center, 1000),
      jail: circle(center, 10),
    );

    test('room_with_final_radius_from_game_info_gets_a_shrink_clock', () {
      // 대기방을 거쳐 들어오면 참가자 상태에는 축소값이 없다 — 게임 정보 조회값으로 만든다
      final at = shrinkClockFor(
        area: area,
        finalRadius: 200,
        start: start,
        roundDurationMinutes: 30,
        policeWaitMinutes: 5,
      );
      expect(at!(DateTime(2026, 11, 8, 12, 10)).current.radiusInMeters, 800);
    });

    test('room_without_shrink_has_no_clock', () {
      expect(
        shrinkClockFor(
          area: area,
          finalRadius: null,
          start: start,
          roundDurationMinutes: 30,
          policeWaitMinutes: 5,
        ),
        isNull,
      );
    });

    test('unknown_start_time_keeps_original_zone', () {
      // 시작 시각을 모르면 잘못 줄인 원으로 억울하게 잡히지 않게 축소하지 않는다
      expect(
        shrinkClockFor(
          area: area,
          finalRadius: 200,
          start: null,
          roundDurationMinutes: 30,
          policeWaitMinutes: 5,
        ),
        isNull,
      );
    });

    test('pin_area_has_no_clock_even_if_admin_stored_a_radius', () {
      const p = AreaShape.polygon(
        points: [
          GeoPoint(latitude: 37.55, longitude: 127.07),
          GeoPoint(latitude: 37.56, longitude: 127.07),
          GeoPoint(latitude: 37.56, longitude: 127.08),
        ],
      );
      expect(
        shrinkClockFor(
          area: GameAreaEntity(playground: p, jail: p),
          finalRadius: 200,
          start: start,
          roundDurationMinutes: 30,
          policeWaitMinutes: 5,
        ),
        isNull,
      );
    });
  });

  group('축소 입력 고르기', () {
    test(
      'cold_restart_uses_game_info_when_participant_state_is_not_filled_yet',
      () {
        // 앱을 다시 켜면 참가자 상태는 아직 비어 있다 — 받아 온 게임 정보로 채운다
        final inputs = resolveShrinkInputs(
          eventStart: null,
          participantStart: null,
          participantRound: null,
          participantWait: null,
          infoStart: '2026-11-08T12:00:00+09:00',
          infoRound: 30,
          infoWait: 5,
        );
        expect(
          inputs.start,
          DateTime.parse('2026-11-08T12:00:00+09:00').toLocal(),
        );
        expect(inputs.round, 30);
        expect(inputs.wait, 5);
      },
    );

    test('start_event_time_wins_over_stored_strings', () {
      final event = DateTime(2026, 11, 8, 12, 0, 1);
      final inputs = resolveShrinkInputs(
        eventStart: event,
        participantStart: '2026-11-08T11:00:00+09:00',
        participantRound: 30,
        participantWait: 5,
        infoStart: null,
        infoRound: 30,
        infoWait: 5,
      );
      expect(inputs.start, event);
    });
  });

  group('줄어드는 중간 원', () {
    test('halfway_between_800m_and_600m_is_700m', () {
      // 축소 순간 원이 한 번에 바뀌지 않고 줄어드는 모습을 그리기 위한 중간 원
      final a = circle(center, 800);
      final b = circle(
        const GeoPoint(latitude: 37.551, longitude: 127.07),
        600,
      );
      final mid = lerpCircle(a, b, 0.5);
      expect(mid.radiusInMeters, 700);
      expect(mid.center.latitude, closeTo(37.5505, 1e-9));
    });

    test('ends_exactly_on_the_new_circle', () {
      final a = circle(center, 800);
      final b = circle(center, 600);
      expect(lerpCircle(a, b, 1).radiusInMeters, 600);
      expect(lerpCircle(a, b, 0).radiusInMeters, 800);
    });
  });

  group('다음 축소 시각만 (잠금 화면용)', () {
    final start = DateTime(2026, 11, 8, 12);
    DateTime? next(DateTime now, {int round = 30, int wait = 5}) =>
        nextShrinkAt(
          start: start,
          roundDurationMinutes: round,
          policeWaitMinutes: wait,
          now: now,
        );

    test(
      'lock_screen_shows_first_shrink_at_10_minutes_before_police_leaves',
      () {
        expect(
          next(DateTime(2026, 11, 8, 12, 3)),
          DateTime(2026, 11, 8, 12, 10),
        );
      },
    );

    test('lock_screen_moves_to_next_shrink_after_one_passes', () {
      expect(
        next(DateTime(2026, 11, 8, 12, 10)),
        DateTime(2026, 11, 8, 12, 15),
      );
    });

    test('lock_screen_hides_shrink_after_final_area', () {
      expect(next(DateTime(2026, 11, 8, 12, 25)), isNull);
    });
  });
}
