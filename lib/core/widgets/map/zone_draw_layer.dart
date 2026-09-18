import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 지도 위에 겹치는 "꾹 눌러 끌기" 레이어
///
/// 꾹 누른 자리가 꼭짓점 손잡이([handles]) 근처면 그 꼭짓점을 끌어 옮기고,
/// 아니면 새 궤적을 [stroke]에 쌓아 그린다. 롱프레스가 아닌 터치(이동·확대)는
/// 아래의 지도로 그대로 내려가야 하므로, 이 레이어는 hit test에서 자신을
/// "맞았다"고 보고하지 않는다.
class ZoneDrawLayer extends StatefulWidget {
  const ZoneDrawLayer({
    super.key,
    required this.stroke,
    required this.fillColor,
    required this.strokeColor,
    required this.handles,
    required this.onLongPressRecognized,
    required this.onDrawEnd,
    required this.onVertexDragStart,
    required this.onVertexDragEnd,
    required this.onVertexDragCancel,
    this.handleHitRadius = 24,
  });

  /// 그리는 중인 궤적 (레이어 로컬 화면 좌표). 부모가 소유하고 손을 떼면 비운다.
  final ValueNotifier<List<Offset>> stroke;

  final Color fillColor;
  final Color strokeColor;

  /// 꼭짓점 화면 좌표 (레이어 로컬, 링 순서). 비어 있으면 그리기만 한다.
  final List<Offset> handles;

  /// 롱프레스 인식 시점 — 그리기·꼭짓점 이동 공통 (햅틱 등)
  final VoidCallback onLongPressRecognized;

  /// 그리기에서 손을 뗀 시점 — 완성된 궤적을 넘긴다. [stroke]는 호출 전에 이미 비워져 있다.
  final ValueChanged<List<Offset>> onDrawEnd;

  /// 꼭짓점을 잡은 순간
  final VoidCallback onVertexDragStart;

  /// 꼭짓점 이동에서 손을 뗀 시점. 이 Future가 끝날 때까지 미리보기를 유지해,
  /// 부모가 새 구역을 반영하기 전에 화면이 비어 보이지 않게 한다.
  final Future<void> Function(int index, Offset position) onVertexDragEnd;

  /// 끌던 중 OS가 포인터를 취소한 경우(전화 수신 등) — 이동 없이 끝났음을 알린다.
  /// 부모는 끄는 동안 숨겼던 다각형을 되살린다.
  final VoidCallback onVertexDragCancel;

  /// 손잡이를 잡았다고 볼 반경 (논리 픽셀)
  final double handleHitRadius;

  @override
  State<ZoneDrawLayer> createState() => _ZoneDrawLayerState();
}

class _ZoneDrawLayerState extends State<ZoneDrawLayer> {
  /// 끌고 있는(또는 반영을 기다리는) 꼭짓점과 그 화면 위치. 미리보기의 재료다.
  final ValueNotifier<({int index, Offset position})?> _drag = ValueNotifier(
    null,
  );

  /// 손가락이 아직 꼭짓점을 끌고 있는지. 손을 떼면 false지만 [_drag]는 반영이 끝날 때까지 남는다.
  bool _isDragging = false;

  /// 잡는 순간 손잡이 − 손가락. 유지해야 꼭짓점이 손가락 밑으로 튀지 않는다.
  Offset _grabOffset = Offset.zero;

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  int? _nearestHandle(Offset position) {
    int? nearest;
    var best = widget.handleHitRadius;
    for (var i = 0; i < widget.handles.length; i++) {
      final distance = (widget.handles[i] - position).distance;
      if (distance <= best) {
        best = distance;
        nearest = i;
      }
    }
    return nearest;
  }

  void _onStart(LongPressStartDetails details) {
    widget.onLongPressRecognized();
    final index = _nearestHandle(details.localPosition);
    if (index == null) {
      widget.stroke.value = [details.localPosition];
      return;
    }
    _isDragging = true;
    _grabOffset = widget.handles[index] - details.localPosition;
    _drag.value = (index: index, position: widget.handles[index]);
    widget.onVertexDragStart();
  }

  void _onUpdate(LongPressMoveUpdateDetails details) {
    if (_isDragging) {
      _drag.value = (
        index: _drag.value!.index,
        position: details.localPosition + _grabOffset,
      );
      return;
    }
    // 정지 상태의 미세 떨림으로 점이 쌓이지 않게 2px 미만 이동은 버린다
    final stroke = widget.stroke.value;
    // stroke는 부모 소유라 비어 있을 수 있다 — 그때는 이 점에서 다시 시작한다
    if (stroke.isEmpty) {
      widget.stroke.value = [details.localPosition];
      return;
    }
    if ((details.localPosition - stroke.last).distance < 2) return;
    widget.stroke.value = [...stroke, details.localPosition];
  }

  Future<void> _onEnd(LongPressEndDetails _) async {
    if (!_isDragging) {
      final finished = widget.stroke.value;
      widget.stroke.value = const [];
      widget.onDrawEnd(finished);
      return;
    }
    _isDragging = false;
    final drag = _drag.value!;
    try {
      await widget.onVertexDragEnd(drag.index, drag.position);
    } finally {
      // 반영을 기다리는 사이 새 끌기가 시작됐으면 그 미리보기를 지우지 않는다.
      // 핸들러가 예외를 던져도 미리보기가 영구히 남지 않도록 finally에서 정리한다.
      if (mounted && !_isDragging) _drag.value = null;
    }
  }

  /// 롱프레스가 인식된 뒤 OS가 포인터를 취소하면(전화 수신 등) 인식기는
  /// onLongPressEnd도 onLongPressCancel도 부르지 않는다 — 취소는 인식(possible)
  /// 단계에서만 보고되기 때문이다(flutter LongPressGestureRecognizer). 그래서 이
  /// 레이어가 직접 PointerCancelEvent를 받아 남은 상태를 정리해야 한다.
  void _onPointerCancel(PointerCancelEvent _) {
    widget.stroke.value = const [];
    if (_isDragging) {
      _isDragging = false;
      _drag.value = null;
      widget.onVertexDragCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // 기본값(deferToChild)이면 이 Listener는 hit-test 경로에 아예 들어가지 못한다:
      // 안쪽 GestureDetector(translucent)는 자기 자신은 경로에 추가되면서도 부모에게는
      // "안 맞았다"고 보고하는데(RenderProxyBoxWithHitTestBehavior.hitTest), deferToChild는
      // hitTestSelf가 false라 그 "안 맞았다"를 그대로 물려받아 이 Listener 자체가 경로에서
      // 빠진다 — PointerCancelEvent가 아예 오지 않는다. translucent로 두면 스스로는 경로에
      // 포함되면서도(취소 이벤트 수신) 여전히 false를 반환해, 아래 Stack의 지도로 터치가
      // 계속 내려간다(기존 통과 동작 유지).
      behavior: HitTestBehavior.translucent,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: _onStart,
        onLongPressMoveUpdate: _onUpdate,
        onLongPressEnd: _onEnd,
        onLongPressCancel: () => widget.stroke.value = const [],
        child: CustomPaint(
          painter: _LayerPainter(
            stroke: widget.stroke,
            drag: _drag,
            handles: widget.handles,
            fillColor: widget.fillColor,
            strokeColor: widget.strokeColor,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// 그리는 중인 궤적, 또는 꼭짓점을 끄는 중인 다각형을 화면 좌표 그대로 그린다.
///
/// 채움까지 닫아 그려서 "손을 떼면 첫 점과 이어진다"는 것을 미리 보여 준다.
/// notifier를 repaint로 물려 점이 바뀔 때마다 이 레이어만 다시 그린다.
class _LayerPainter extends CustomPainter {
  _LayerPainter({
    required this.stroke,
    required this.drag,
    required this.handles,
    required this.fillColor,
    required this.strokeColor,
  }) : super(repaint: Listenable.merge([stroke, drag]));

  final ValueListenable<List<Offset>> stroke;
  final ValueListenable<({int index, Offset position})?> drag;
  final List<Offset> handles;
  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final dragging = drag.value;
    final points = dragging == null
        ? stroke.value
        : [
            for (var i = 0; i < handles.length; i++)
              i == dragging.index ? dragging.position : handles[i],
          ];
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fillColor);
    final outline = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outline);
    // 끄는 꼭짓점은 손가락에 가려지므로 조금 크게 표시한다
    if (dragging != null) {
      canvas.drawCircle(dragging.position, 8, Paint()..color = strokeColor);
    }
  }

  /// CustomPaint는 painter가 있으면 기본으로 "맞았다"고 보고해 Stack 아래의 지도로
  /// 터치가 내려가지 않는다(이동·확대 불가). 제스처는 GestureDetector(translucent)가
  /// 받으므로 painter는 hit을 주장하지 않는다.
  @override
  bool? hitTest(Offset position) => false;

  @override
  bool shouldRepaint(_LayerPainter oldDelegate) =>
      oldDelegate.stroke != stroke ||
      oldDelegate.drag != drag ||
      oldDelegate.handles != handles ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeColor != strokeColor;
}
