import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/utils/path_simplifier.dart';

/// 교차점은 부동소수 계산값이라 점마다 허용오차로 비교한다.
void expectPath(List<Offset> actual, List<Offset> expected) {
  expect(actual, hasLength(expected.length));
  for (var i = 0; i < expected.length; i++) {
    expect(actual[i], within<Offset>(distance: 1e-6, from: expected[i]));
  }
}

void main() {
  group('simplifyPath', () {
    test('keeps_only_endpoints_when_points_are_collinear', () {
      final line = [for (var i = 0; i <= 10; i++) Offset(i * 10.0, 0)];

      final result = simplifyPath(line, tolerance: 2, maxPoints: 40);

      expect(result, [const Offset(0, 0), const Offset(100, 0)]);
    });

    test('keeps_corner_when_it_deviates_beyond_tolerance', () {
      const corner = [Offset(0, 0), Offset(50, 0), Offset(50, 50)];

      final result = simplifyPath(corner, tolerance: 2, maxPoints: 40);

      expect(result, corner);
    });

    test('drops_wobble_within_tolerance', () {
      const wobbly = [
        Offset(0, 0),
        Offset(25, 1),
        Offset(50, -1),
        Offset(75, 1),
        Offset(100, 0),
      ];

      final result = simplifyPath(wobbly, tolerance: 2, maxPoints: 40);

      expect(result, [const Offset(0, 0), const Offset(100, 0)]);
    });

    test('caps_vertex_count_at_max_points_preserving_order', () {
      // 원 위의 점 36개 — 허용오차 0이면 전부 살아남는 형태
      final circle = [
        for (var i = 0; i < 36; i++)
          Offset(
            100 * math.cos(i * 10 * math.pi / 180),
            100 * math.sin(i * 10 * math.pi / 180),
          ),
      ];

      final result = simplifyPath(circle, tolerance: 0, maxPoints: 12);

      expect(result.length, lessThanOrEqualTo(12));
      expect(result.first, circle.first);
      // 순서 보존 — 각 결과 점은 원본에서 앞선 결과 점보다 뒤에 있어야 한다
      var lastIndex = -1;
      for (final p in result) {
        final index = circle.indexOf(p);
        expect(index, greaterThan(lastIndex));
        lastIndex = index;
      }
    });

    test('returns_input_unchanged_when_fewer_than_three_points', () {
      const two = [Offset(0, 0), Offset(10, 10)];

      expect(simplifyPath(two, tolerance: 2, maxPoints: 40), two);
      expect(simplifyPath(const [], tolerance: 2, maxPoints: 40), isEmpty);
    });
  });

  group('closeLoopAtFirstCrossing', () {
    test(
      'returns_the_loop_between_the_crossing_when_the_tail_crosses_the_lead_in',
      () {
        // 진입선 (50,-30)→(50,100) 을 마지막 변 (150,0)→(0,0) 이 (50,0)에서 가로지른다.
        const path = [
          Offset(50, -30),
          Offset(50, 100),
          Offset(150, 100),
          Offset(150, 0),
          Offset(0, 0),
        ];

        final loop = closeLoopAtFirstCrossing(path, minLoopArea: 100);

        // 진입선 앞부분과 넘친 꼬리는 버리고, 교차점에서 닫힌 고리만 남는다
        expectPath(loop, const [
          Offset(50, 0),
          Offset(50, 100),
          Offset(150, 100),
          Offset(150, 0),
        ]);
      },
    );

    test('returns_path_unchanged_when_it_never_crosses_itself', () {
      const path = [Offset(0, 0), Offset(100, 0), Offset(100, 100)];

      expect(closeLoopAtFirstCrossing(path, minLoopArea: 100), path);
    });

    test('keeps_only_the_first_loop_when_path_is_a_figure_eight', () {
      const path = [
        Offset(0, 0),
        Offset(100, 100),
        Offset(100, 0),
        Offset(0, 100),
        Offset(0, 200),
        Offset(100, 200),
        Offset(-50, 50),
      ];

      final loop = closeLoopAtFirstCrossing(path, minLoopArea: 100);

      expectPath(loop, const [
        Offset(50, 50),
        Offset(100, 100),
        Offset(100, 0),
      ]);
    });

    test('skips_a_tiny_loop_and_closes_at_the_next_crossing', () {
      // 시작 직후 손 떨림으로 생긴 수 px짜리 고리 뒤에 실제 구역을 그린 경우
      const path = [
        Offset(0, 0),
        Offset(4, 0),
        Offset(4, 4),
        Offset(2, -2), // (4,4)→(2,-2) 가 첫 변을 가로질러 아주 작은 고리를 만든다
        Offset(200, -2),
        Offset(200, -200),
        Offset(100, -200),
        Offset(100, 50), // (2,-2)→(200,-2) 를 (100,-2)에서 가로지른다
      ];

      final loop = closeLoopAtFirstCrossing(path, minLoopArea: 100);

      expectPath(loop, const [
        Offset(100, -2),
        Offset(200, -2),
        Offset(200, -200),
        Offset(100, -200),
      ]);
    });
  });
}
