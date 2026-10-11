import 'dart:io';

import '../models/game_area_model.dart';

/// 기기에 남기는 내 게임 기록 이벤트 종류.
enum GameRecordEventType {
  /// 경로에 추가된 점
  point,

  /// 경찰: 내가 도둑을 잡은 위치
  arrest,

  /// 도둑: 내가 잡힌 위치
  caught,

  /// 앱 재시작 후 복원 지점 — 이후 첫 점은 새 구간으로 시작한다
  resume,
}

typedef GameRecordEvent = ({GameRecordEventType type, LatLngModel? location});

/// 진행 중인 게임의 내 기록을 기기 파일에 한 줄씩 덧붙여 보관한다.
///
/// 앱 프로세스가 죽어도(크래시·OS 종료) 같은 게임에 재진입하면 복원하기 위함이다.
/// 서버로는 보내지 않는다. 파일은 하나만 쓰며, 다른 게임을 열면 덮어쓴다.
///
/// 형식: 첫 줄 `g <gameId>`, 이후 `p|a|c <lat> <lng>` 또는 `r`.
/// 매 줄을 개행까지 한 번에 쓰므로, 개행으로 끝나지 않은 마지막 줄은 쓰다 죽은 것으로 보고 버린다.
class GameRecordLocalDatasource {
  GameRecordLocalDatasource(this._file);

  final File _file;

  static const _codes = {
    GameRecordEventType.point: 'p',
    GameRecordEventType.arrest: 'a',
    GameRecordEventType.caught: 'c',
    GameRecordEventType.resume: 'r',
  };

  /// [gameId]의 저장된 이벤트를 돌려준다.
  ///
  /// 저장된 기록이 없거나 다른 게임 것이면 파일을 [gameId]용으로 새로 쓰고 null을 돌려준다.
  List<GameRecordEvent>? openForGame(int gameId) {
    final header = 'g $gameId';
    if (_file.existsSync()) {
      final content = _file.readAsStringSync();
      final complete = content.substring(0, content.lastIndexOf('\n') + 1);
      final lines = complete.split('\n')..removeLast();
      if (lines.isNotEmpty && lines.first == header) {
        // 잘린 꼬리를 잘라내야 이후 덧붙인 줄이 그 뒤에 붙어 깨지지 않는다.
        if (complete.length != content.length) {
          _file.writeAsStringSync(complete);
        }
        return [for (final line in lines.skip(1)) ?_parse(line)];
      }
    }
    _file.parent.createSync(recursive: true);
    _file.writeAsStringSync('$header\n');
    return null;
  }

  void append(GameRecordEvent event) {
    final loc = event.location;
    final line = loc == null
        ? _codes[event.type]!
        : '${_codes[event.type]} ${loc.latitude} ${loc.longitude}';
    _file.writeAsStringSync('$line\n', mode: FileMode.append);
  }

  void clear() {
    if (_file.existsSync()) _file.deleteSync();
  }

  GameRecordEvent? _parse(String line) {
    final parts = line.split(' ');
    final type = _codes.entries
        .where((e) => e.value == parts.first)
        .map((e) => e.key)
        .firstOrNull;
    if (type == null) return null;
    if (type == GameRecordEventType.resume) return (type: type, location: null);
    if (parts.length != 3) return null;
    final lat = double.tryParse(parts[1]);
    final lng = double.tryParse(parts[2]);
    if (lat == null || lng == null) return null;
    return (type: type, location: LatLngModel(latitude: lat, longitude: lng));
  }
}
