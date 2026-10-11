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

  group('GameRecordLocalDatasource', () {
    test('openForGame_returns_saved_events_when_same_game_reopened', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7)
        ..append((type: GameRecordEventType.point, location: a))
        ..append((type: GameRecordEventType.arrest, location: a))
        ..append((type: GameRecordEventType.resume, location: null))
        ..append((type: GameRecordEventType.point, location: b));

      // 앱 재시작 = 새 인스턴스
      final events = GameRecordLocalDatasource(file).openForGame(7);

      expect(events, [
        (type: GameRecordEventType.point, location: a),
        (type: GameRecordEventType.arrest, location: a),
        (type: GameRecordEventType.resume, location: null),
        (type: GameRecordEventType.point, location: b),
      ]);
    });

    test('openForGame_discards_record_when_it_belongs_to_other_game', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7)
        ..append((type: GameRecordEventType.point, location: a));

      final other = GameRecordLocalDatasource(file).openForGame(8);
      final reopened = GameRecordLocalDatasource(file).openForGame(8);

      expect(other, isNull);
      expect(reopened, isEmpty);
    });

    test('openForGame_skips_line_truncated_by_crash', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7)
        ..append((type: GameRecordEventType.point, location: a));
      // 쓰는 도중 프로세스가 죽어 마지막 줄이 잘린 상태
      file.writeAsStringSync('p 37.56', mode: FileMode.append);

      final events = GameRecordLocalDatasource(file).openForGame(7);

      expect(events, [(type: GameRecordEventType.point, location: a)]);
    });

    test('clear_removes_record_so_same_game_reopens_empty', () {
      GameRecordLocalDatasource(file)
        ..openForGame(7)
        ..append((type: GameRecordEventType.point, location: a))
        ..clear();

      expect(GameRecordLocalDatasource(file).openForGame(7), isNull);
    });
  });
}
