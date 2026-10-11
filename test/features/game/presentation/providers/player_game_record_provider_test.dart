import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/player_game_record_provider.dart';

void main() {
  late Directory dir;
  late ProviderContainer container;

  // 기록 파일 위치만 실제 임시 디렉터리로 바꾼다 (파일 시스템 경계).
  ProviderContainer newContainer() => ProviderContainer(
    overrides: [gameRecordDirProvider.overrideWith((ref) async => dir)],
  );

  /// 앱 프로세스 종료 후 재실행 — 메모리 상태는 사라지고 기기 파일만 남는다.
  void restartApp() {
    container.dispose();
    container = newContainer();
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('player_game_record_test');
    container = newContainer();
  });
  tearDown(() {
    container.dispose();
    dir.deleteSync(recursive: true);
  });

  PlayerGameRecordNotifier notifier() =>
      container.read(playerGameRecordNotifierProvider.notifier);

  group('PlayerGameRecordNotifier', () {
    const a = LatLngModel(latitude: 37.5665, longitude: 126.9780);
    const b = LatLngModel(latitude: 37.5675, longitude: 126.9790); // 약 130m
    const c = LatLngModel(
      latitude: 37.5765,
      longitude: 126.9890,
    ); // b에서 약 1.3km

    double distance(LatLngModel p, LatLngModel q) => Geolocator.distanceBetween(
      p.latitude,
      p.longitude,
      q.latitude,
      q.longitude,
    );

    test('accumulates_distance_between_consecutive_points', () {
      notifier()
        ..addPoint(a)
        ..addPoint(b);

      final expected = Geolocator.distanceBetween(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      );
      final state = container.read(playerGameRecordNotifierProvider);
      expect(state.route.length, 2);
      expect(state.distanceMeters, closeTo(expected, 0.001));
    });

    test('skips_point_within_2m_to_filter_gps_noise', () {
      const near = LatLngModel(
        latitude: 37.56650,
        longitude: 126.97801,
      ); // a에서 1m 미만
      notifier()
        ..addPoint(a)
        ..addPoint(near);

      final state = container.read(playerGameRecordNotifierProvider);
      expect(state.route.length, 1); // near는 2m 미만 → 제외
      expect(state.distanceMeters, 0.0);
    });

    test(
      'restores_route_distance_and_markers_when_reentering_same_game_after_restart',
      () async {
        await notifier().begin(7);
        notifier()
          ..addPoint(a)
          ..addPoint(b)
          ..recordArrest();

        restartApp();
        await notifier().begin(7);

        expect(
          container.read(playerGameRecordNotifierProvider),
          PlayerGameRecord(
            route: const [a, b],
            distanceMeters: distance(a, b),
            arrestLocations: const [b],
          ),
        );
      },
    );

    test('discards_previous_record_when_entering_different_game', () async {
      await notifier().begin(7);
      notifier()
        ..addPoint(a)
        ..addPoint(b);

      await notifier().begin(8);
      expect(container.read(playerGameRecordNotifierProvider).route, isEmpty);

      restartApp();
      await notifier().begin(7);
      expect(container.read(playerGameRecordNotifierProvider).route, isEmpty);
    });

    test(
      'starts_new_segment_without_gap_distance_when_point_follows_restore',
      () async {
        await notifier().begin(7);
        notifier()
          ..addPoint(a)
          ..addPoint(b);

        restartApp();
        await notifier().begin(7);
        notifier().addPoint(c);

        final state = container.read(playerGameRecordNotifierProvider);
        expect(state.route, const [a, b, c]);
        expect(state.segmentStarts, const [2]);
        // 앱이 꺼져 있던 b→c 구간은 모르는 이동이라 거리에 넣지 않는다.
        expect(state.distanceMeters, distance(a, b));
      },
    );

    test(
      'keeps_segment_break_when_restored_again_after_second_restart',
      () async {
        await notifier().begin(7);
        notifier()
          ..addPoint(a)
          ..addPoint(b);
        restartApp();
        await notifier().begin(7);
        notifier().addPoint(c);

        restartApp();
        await notifier().begin(7);

        final state = container.read(playerGameRecordNotifierProvider);
        expect(state.route, const [a, b, c]);
        expect(state.segmentStarts, const [2]);
      },
    );

    test('discards_saved_record_when_game_ends', () async {
      await notifier().begin(7);
      notifier()
        ..addPoint(a)
        ..addPoint(b)
        ..markEnd(DateTime(2026, 10, 12));

      restartApp();
      await notifier().begin(7);

      expect(container.read(playerGameRecordNotifierProvider).route, isEmpty);
    });
  });
}
