import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// [boundaryKey]가 가리키는 RepaintBoundary를 PNG 바이트로 캡처한다.
///
/// 호출 전 해당 위젯이 레이아웃 완료 상태여야 한다(첫 프레임 이후).
/// 캡처 실패 시 null 반환(크래시 금지).
Future<Uint8List?> captureBoundaryToPng(
  GlobalKey boundaryKey, {
  double pixelRatio = 3.0,
}) async {
  try {
    final obj = boundaryKey.currentContext?.findRenderObject();
    if (obj is! RenderRepaintBoundary) return null;
    final image = await obj.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } catch (e) {
    debugPrint('[capture] 위젯 캡처 실패: $e');
    return null;
  }
}
