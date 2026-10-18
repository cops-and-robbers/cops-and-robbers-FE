import 'dart:math' as math;

import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/entities/ping.dart';
import 'package:cops_and_robbers/features/game/domain/ping_chat_policy.dart';
import 'package:cops_and_robbers/features/game/domain/zone_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 어린이대공원 기본 500m 구역 — 100m 칸
  const park = GeoPoint(latitude: 37.5482, longitude: 127.0747);
  final grid = ZoneGrid.forArea(
    const AreaShape.circle(center: park, radiusInMeters: 500),
  );

  GeoPoint offset({double north = 0, double east = 0}) {
    const earthRadius = 6371000.0;
    return GeoPoint(
      latitude: park.latitude + north / earthRadius * 180 / math.pi,
      longitude:
          park.longitude +
          east /
              earthRadius *
              180 /
              math.pi /
              math.cos(park.latitude * math.pi / 180),
    );
  }

  // D4 칸 안의 두 지점 (같은 칸)
  final nearSlide = offset(north: 150, east: -150);
  final besideSlide = offset(north: 120, east: -180);
  final t0 = DateTime(2026, 10, 18, 14);

  test('announces_the_cell_when_grid_is_on_and_the_ping_is_inside', () {
    final policy = PingChatPolicy();

    expect(
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.found,
        point: nearSlide,
        now: t0,
      ),
      'D4',
    );
  });

  test('stays_silent_when_the_player_has_the_grid_off', () {
    final policy = PingChatPolicy();

    expect(
      policy.cellToAnnounce(
        grid: null,
        type: PingType.found,
        point: nearSlide,
        now: t0,
      ),
      isNull,
    );
  });

  test('stays_silent_when_the_ping_lands_outside_every_grid_cell', () {
    final policy = PingChatPolicy();

    expect(
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.suspect,
        point: offset(north: 470, east: 470),
        now: t0,
      ),
      isNull,
    );
  });

  test(
    'skips_the_chat_when_the_same_spot_is_pinged_again_within_10_seconds',
    () {
      final policy = PingChatPolicy();
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.found,
        point: nearSlide,
        now: t0,
      );

      // 같은 도둑을 계속 찍어 대는 상황 — 핑은 나가도 채팅은 한 줄만
      expect(
        policy.cellToAnnounce(
          grid: grid,
          type: PingType.found,
          point: besideSlide,
          now: t0.add(const Duration(seconds: 6)),
        ),
        isNull,
      );
    },
  );

  test('announces_again_when_10_seconds_have_passed_since_the_last_line', () {
    final policy = PingChatPolicy();
    policy.cellToAnnounce(
      grid: grid,
      type: PingType.found,
      point: nearSlide,
      now: t0,
    );

    expect(
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.found,
        point: nearSlide,
        now: t0.add(const Duration(seconds: 10)),
      ),
      'D4',
    );
  });

  test('announces_when_the_same_cell_changes_from_suspect_to_found', () {
    final policy = PingChatPolicy();
    policy.cellToAnnounce(
      grid: grid,
      type: PingType.suspect,
      point: nearSlide,
      now: t0,
    );

    // 의심하던 칸에서 실제로 봤다 — 새 정보라 보낸다
    expect(
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.found,
        point: nearSlide,
        now: t0.add(const Duration(seconds: 3)),
      ),
      'D4',
    );
  });

  test('announces_a_different_cell_right_away', () {
    final policy = PingChatPolicy();
    policy.cellToAnnounce(
      grid: grid,
      type: PingType.found,
      point: nearSlide,
      now: t0,
    );

    expect(
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.found,
        point: offset(north: -250, east: 350),
        now: t0.add(const Duration(seconds: 2)),
      ),
      'I8',
    );
  });

  test('does_not_use_up_the_window_when_nothing_was_announced', () {
    final policy = PingChatPolicy();
    // 격자를 끈 채 찍었다가 바로 켜고 다시 찍은 경우
    policy.cellToAnnounce(
      grid: null,
      type: PingType.found,
      point: nearSlide,
      now: t0,
    );

    expect(
      policy.cellToAnnounce(
        grid: grid,
        type: PingType.found,
        point: nearSlide,
        now: t0.add(const Duration(seconds: 1)),
      ),
      'D4',
    );
  });
}
