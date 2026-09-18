import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/widgets/map/zone_draw_layer.dart';

/// 테스트가 들여다보는 레이어의 출력들
class _Probe {
  final stroke = ValueNotifier<List<Offset>>(const []);
  final finishedStrokes = <List<Offset>>[];
  final movedVertices = <(int, Offset)>[];
  var vertexDragStarts = 0;
  var vertexDragCancels = 0;
  var mapPointerDowns = 0;
}

void main() {
  /// 아래에 "지도 자리"(포인터를 세는 Listener)를 두고 그 위에 그리기 레이어를 겹친다.
  Future<_Probe> pumpLayer(
    WidgetTester tester, {
    List<Offset> handles = const [],
    Future<void> Function(int index, Offset position)? onVertexDragEnd,
  }) async {
    final probe = _Probe();
    addTearDown(probe.stroke.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => probe.mapPointerDowns++,
              ),
            ),
            Positioned.fill(
              child: ZoneDrawLayer(
                stroke: probe.stroke,
                fillColor: const Color(0x33000000),
                strokeColor: const Color(0xFF000000),
                handles: handles,
                onLongPressRecognized: () {},
                onDrawEnd: probe.finishedStrokes.add,
                onVertexDragStart: () => probe.vertexDragStarts++,
                onVertexDragEnd:
                    onVertexDragEnd ??
                    (index, position) async =>
                        probe.movedVertices.add((index, position)),
                onVertexDragCancel: () => probe.vertexDragCancels++,
              ),
            ),
          ],
        ),
      ),
    );
    return probe;
  }

  /// [from]에서 꾹 누른 뒤 [path]를 따라 끌고 손을 뗀다.
  Future<void> longPressDrag(
    WidgetTester tester,
    Offset from,
    List<Offset> path,
  ) async {
    final gesture = await tester.startGesture(from);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    for (final p in path) {
      await gesture.moveTo(p);
    }
    await gesture.up();
    await tester.pump();
  }

  const triangle = [Offset(100, 100), Offset(200, 100), Offset(200, 200)];

  testWidgets('passes_touches_to_the_map_below_when_not_long_pressing', (
    tester,
  ) async {
    final probe = await pumpLayer(tester, handles: triangle);

    await tester.tapAt(const Offset(100, 100));

    expect(probe.mapPointerDowns, 1);
  });

  testWidgets(
    'reports_the_drawn_stroke_when_long_press_starts_away_from_handles',
    (tester) async {
      final probe = await pumpLayer(tester, handles: triangle);

      await longPressDrag(tester, const Offset(400, 400), const [
        Offset(500, 400),
        Offset(500, 500),
      ]);

      expect(probe.finishedStrokes, [
        const [Offset(400, 400), Offset(500, 400), Offset(500, 500)],
      ]);
      expect(probe.stroke.value, isEmpty);
      expect(probe.vertexDragStarts, 0);
      expect(probe.movedVertices, isEmpty);
    },
  );

  testWidgets(
    'moves_the_vertex_keeping_the_grab_offset_when_long_press_starts_on_a_handle',
    (tester) async {
      final probe = await pumpLayer(tester, handles: triangle);

      // 손잡이 (100,100)에서 오른쪽으로 5px 어긋난 곳을 잡는다 → 그 어긋남이 끝까지 유지된다
      await longPressDrag(tester, const Offset(105, 100), const [
        Offset(155, 130),
      ]);

      expect(probe.vertexDragStarts, 1);
      expect(probe.movedVertices, [(0, const Offset(150, 130))]);
      expect(probe.finishedStrokes, isEmpty);
      expect(probe.stroke.value, isEmpty);
    },
  );

  testWidgets('picks_the_closest_handle_when_two_are_within_reach', (
    tester,
  ) async {
    final probe = await pumpLayer(
      tester,
      handles: const [Offset(100, 100), Offset(120, 100), Offset(200, 200)],
    );

    // (112,100): 0번까지 12px, 1번까지 8px → 1번을 잡는다. 어긋남은 (+8, 0)
    await longPressDrag(tester, const Offset(112, 100), const [
      Offset(112, 150),
    ]);

    expect(probe.movedVertices, [(1, const Offset(120, 150))]);
  });

  testWidgets('starts_drawing_when_long_press_is_just_outside_the_hit_radius', (
    tester,
  ) async {
    final probe = await pumpLayer(tester, handles: triangle);

    // (100,100)에서 25px — 반경 24 바깥
    await longPressDrag(tester, const Offset(75, 100), const [
      Offset(75, 300),
      Offset(60, 300),
    ]);

    expect(probe.movedVertices, isEmpty);
    expect(probe.finishedStrokes, hasLength(1));
  });

  testWidgets(
    'reports_cancel_and_no_move_when_pointer_is_cancelled_during_a_vertex_drag',
    (tester) async {
      final probe = await pumpLayer(tester, handles: triangle);

      final gesture = await tester.startGesture(const Offset(105, 100));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture.moveTo(const Offset(155, 130));
      await gesture.cancel();
      await tester.pump();

      expect(probe.vertexDragCancels, 1);
      expect(probe.movedVertices, isEmpty);
    },
  );

  testWidgets('draws_normally_when_the_previous_vertex_drag_was_cancelled', (
    tester,
  ) async {
    final probe = await pumpLayer(tester, handles: triangle);

    final gesture = await tester.startGesture(const Offset(105, 100));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(const Offset(155, 130));
    await gesture.cancel();
    await tester.pump();

    await longPressDrag(tester, const Offset(400, 400), const [
      Offset(500, 400),
      Offset(500, 500),
    ]);

    expect(probe.finishedStrokes, [
      const [Offset(400, 400), Offset(500, 400), Offset(500, 500)],
    ]);
    expect(probe.movedVertices, isEmpty);
  });

  testWidgets('clears_the_stroke_when_pointer_is_cancelled_while_drawing', (
    tester,
  ) async {
    final probe = await pumpLayer(tester, handles: triangle);

    final gesture = await tester.startGesture(const Offset(400, 400));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(const Offset(500, 400));
    await gesture.cancel();
    await tester.pump();

    expect(probe.stroke.value, isEmpty);
    expect(probe.finishedStrokes, isEmpty);
  });

  testWidgets(
    'keeps_the_new_drag_when_the_previous_move_is_still_being_applied',
    (tester) async {
      const handles = [Offset(100, 100), Offset(300, 100)];

      // 첫 번째 반영은 completer가 완료될 때까지 멈춰 있는다 — 그동안 두 번째 끌기가
      // 시작돼도 첫 번째가 끝나며 그 상태를 지우면 안 된다는 걸 확인하기 위함.
      final firstCallCompleter = Completer<void>();
      var callCount = 0;
      _Probe? probeRef;
      Future<void> onVertexDragEnd(int index, Offset position) async {
        callCount++;
        probeRef!.movedVertices.add((index, position));
        if (callCount == 1) {
          await firstCallCompleter.future;
        }
      }

      final probe = await pumpLayer(
        tester,
        handles: handles,
        onVertexDragEnd: onVertexDragEnd,
      );
      probeRef = probe;

      // 첫 번째 끌기: 손잡이 0을 잡고 옮긴 뒤 손을 뗀다 → 반영(Future #1)은 아직 안 끝남
      final gesture1 = await tester.startGesture(const Offset(100, 100));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture1.moveTo(const Offset(100, 160));
      await gesture1.up();
      await tester.pump();

      // 두 번째 끌기 시작: 손잡이 1에서 (5,5) 어긋나게 잡는다 → 그 어긋남이 끝까지 유지
      final gesture2 = await tester.startGesture(const Offset(305, 105));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture2.moveTo(const Offset(305, 160));

      // Future #1이 이제 끝난다 — _onEnd의 finally 가드가 `_isDragging`(현재 true,
      // 두 번째 끌기가 잡고 있음)을 보고 두 번째 끌기의 상태를 지우지 않아야 한다.
      firstCallCompleter.complete();
      await tester.pump();

      // 두 번째 끌기를 마저 움직이고 손을 뗀다
      await gesture2.moveTo(const Offset(315, 170));
      await gesture2.up();
      await tester.pump();

      expect(probe.movedVertices, [
        (0, const Offset(100, 160)),
        (1, const Offset(310, 165)),
      ]);
    },
  );
}
