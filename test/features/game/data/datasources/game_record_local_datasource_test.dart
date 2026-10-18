import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/data/datasources/game_record_local_datasource.dart';
import 'package:cops_and_robbers/features/game/data/models/game_area_model.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('game_record_test');
    file = File('${dir.path}/game_record.txt');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  const a = LatLngModel(latitude: 37.5665, longitude: 126.978);
  const b = LatLngModel(latitude: 37.5675, longitude: 126.979);

  // 같은 방(gameId 7)의 1라운드·2라운드 서버 시작 시각
  final round1 = DateTime.utc(2026, 10, 19, 5);
  final round2 = round1.add(const Duration(minutes: 25));

  group('GameRecordLocalDatasource', () {
    test('openForGame_returns_saved_events_when_same_game_reopened', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7, startedAt: round1)
        ..append((type: GameRecordEventType.point, location: a))
        ..append((type: GameRecordEventType.arrest, location: a))
        ..append((type: GameRecordEventType.resume, location: null))
        ..append((type: GameRecordEventType.point, location: b));

      // 앱 재시작 = 새 인스턴스
      final events = GameRecordLocalDatasource(
        file,
      ).openForGame(7, startedAt: round1);

      expect(events, [
        (type: GameRecordEventType.point, location: a),
        (type: GameRecordEventType.arrest, location: a),
        (type: GameRecordEventType.resume, location: null),
        (type: GameRecordEventType.point, location: b),
      ]);
    });

    test('openForGame_discards_record_when_it_belongs_to_other_game', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7, startedAt: round1)
        ..append((type: GameRecordEventType.point, location: a));

      final other = GameRecordLocalDatasource(
        file,
      ).openForGame(8, startedAt: round1);
      final reopened = GameRecordLocalDatasource(
        file,
      ).openForGame(8, startedAt: round1);

      expect(other, isNull);
      expect(reopened, isEmpty);
    });

    test('openForGame_skips_line_truncated_by_crash', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7, startedAt: round1)
        ..append((type: GameRecordEventType.point, location: a));
      // 쓰는 도중 프로세스가 죽어 마지막 줄이 잘린 상태
      file.writeAsStringSync('p 37.56', mode: FileMode.append);

      final events = GameRecordLocalDatasource(
        file,
      ).openForGame(7, startedAt: round1);

      expect(events, [(type: GameRecordEventType.point, location: a)]);
    });

    test(
      'openForGame_discards_previous_round_record_when_same_room_starts_next_round',
      () {
        // 1라운드 중 앱이 꺼진 채 판이 끝나 markEnd(clear)가 실행되지 않은 상태
        GameRecordLocalDatasource(file)
          ..openForGame(7, startedAt: round1)
          ..append((type: GameRecordEventType.point, location: a));

        // 같은 방에서 2라운드 시작 — 방 id는 같고 시작 시각만 다르다
        final next = GameRecordLocalDatasource(
          file,
        ).openForGame(7, startedAt: round2);

        expect(next, isNull);
      },
    );

    test(
      'openForGame_restores_record_when_start_time_differs_only_in_precision',
      () {
        // 대기실 진입은 GAME_START의 startTime, 앱 재실행은 설정 API의 gameStartTime으로
        // 시작 시각을 받는다 — 같은 라운드라도 소수점 이하 자리가 다를 수 있다.
        GameRecordLocalDatasource(file)
          ..openForGame(
            7,
            startedAt: round1.add(const Duration(microseconds: 412345)),
          )
          ..append((type: GameRecordEventType.point, location: a));

        final events = GameRecordLocalDatasource(file).openForGame(
          7,
          startedAt: round1.add(const Duration(milliseconds: 412)),
        );

        expect(events, [(type: GameRecordEventType.point, location: a)]);
      },
    );

    test('openForGame_starts_fresh_when_round_start_time_is_unknown', () {
      // 앱 재실행 시 설정 API가 실패해 시작 시각을 못 받으면 어느 라운드 기록인지 알 수 없다.
      GameRecordLocalDatasource(file)
        ..openForGame(7, startedAt: round1)
        ..append((type: GameRecordEventType.point, location: a));

      final events = GameRecordLocalDatasource(
        file,
      ).openForGame(7, startedAt: null);

      expect(events, isNull);
    });

    test('clear_removes_record_so_same_game_reopens_empty', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7, startedAt: round1)
        ..append((type: GameRecordEventType.point, location: a))
        ..clear();

      expect(
        GameRecordLocalDatasource(file).openForGame(7, startedAt: round1),
        isNull,
      );
    });
  });
}
