import 'dart:convert';

import 'package:flutter/services.dart';

class TutorialBuilding {
  const TutorialBuilding(
    this.points,
    this.height, {
    this.base = 0,
    this.hasFloors = false,
    this.roofTone = 0,
  });

  /// [x0, y0, x1, y1, ...]
  final List<double> points;

  /// 벽과 지붕의 위 높이. [base]가 있으면 아래 건물 위에 얹힌 층이다.
  final double height;
  final double base;

  /// 벽에 층 줄을 그린다.
  final bool hasFloors;
  final int roofTone;
}

class TutorialRoad {
  const TutorialRoad(this.points, this.width);

  final List<double> points;
  final double width;
}

class TutorialTree {
  const TutorialTree(this.x, this.y, this.radius, this.height);

  final double x;
  final double y;
  final double radius;
  final double height;
}

/// 튜토리얼 지도 데이터. 실제 지역이 아니라 가상으로 만든 도심과 숲 공원이다.
///
/// 구글 지도를 쓰지 않으므로 지도 비용·로딩·위치 권한이 필요 없다.
class TutorialMapData {
  const TutorialMapData(this.buildings, this.roads, this.parks, this.trees);

  static const String _asset = 'assets/onboarding/tutorial_map.json';

  final List<TutorialBuilding> buildings;
  final List<TutorialRoad> roads;
  final List<List<double>> parks;

  /// 먼 나무부터 들어 있다. 지도 방향이 고정이라 매번 정렬하지 않는다.
  final List<TutorialTree> trees;

  static Future<TutorialMapData> load() async {
    final bytes = await rootBundle.load(_asset);
    final json =
        jsonDecode(utf8.decode(bytes.buffer.asUint8List()))
            as Map<String, dynamic>;
    return TutorialMapData(
      [
        for (final b in json['b'] as List)
          TutorialBuilding(
            _flatten(b['g']),
            (b['h'] as num).toDouble(),
            base: (b['z'] as num).toDouble(),
            hasFloors: b['k'] == 1,
            roofTone: b['c'] as int,
          ),
      ],
      [
        for (final r in json['r'] as List)
          TutorialRoad(_flatten(r['g']), (r['w'] as num).toDouble()),
      ],
      [for (final p in json['p'] as List) _flatten(p['g'])],
      [
        for (final t in json['t'] as List)
          TutorialTree(
            (t[0] as num).toDouble(),
            (t[1] as num).toDouble(),
            (t[2] as num).toDouble(),
            (t[3] as num).toDouble(),
          ),
      ],
    );
  }

  static List<double> _flatten(dynamic geometry) => [
    for (final point in geometry as List)
      for (final value in point as List) (value as num).toDouble(),
  ];
}
