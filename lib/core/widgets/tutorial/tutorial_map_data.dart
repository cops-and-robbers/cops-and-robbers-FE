import 'dart:convert';

import 'package:flutter/services.dart';

class TutorialBuilding {
  const TutorialBuilding(this.points, this.height);

  /// [x0, y0, x1, y1, ...]
  final List<double> points;
  final double height;
}

class TutorialRoad {
  const TutorialRoad(this.points, this.width);

  final List<double> points;
  final double width;
}

/// 튜토리얼 지도 데이터. 세종대 일대 OpenStreetMap을 앱 좌표로 구워 둔 파일이다.
///
/// 구글 지도를 쓰지 않으므로 지도 비용·로딩·위치 권한이 필요 없다.
class TutorialMapData {
  const TutorialMapData(this.buildings, this.roads, this.parks);

  static const String _asset = 'assets/onboarding/tutorial_map.json';

  final List<TutorialBuilding> buildings;
  final List<TutorialRoad> roads;
  final List<List<double>> parks;

  static Future<TutorialMapData> load() async {
    final bytes = await rootBundle.load(_asset);
    final json =
        jsonDecode(utf8.decode(bytes.buffer.asUint8List()))
            as Map<String, dynamic>;
    return TutorialMapData(
      [
        for (final b in json['b'] as List)
          TutorialBuilding(_flatten(b['g']), (b['h'] as num).toDouble()),
      ],
      [
        for (final r in json['r'] as List)
          TutorialRoad(_flatten(r['g']), (r['w'] as num).toDouble()),
      ],
      [for (final p in json['p'] as List) _flatten(p['g'])],
    );
  }

  static List<double> _flatten(dynamic geometry) => [
    for (final point in geometry as List)
      for (final value in point as List) (value as num).toDouble(),
  ];
}
