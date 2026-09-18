import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/app_colors.dart';

/// 폴리곤 꼭짓점 손잡이 마커 BitmapDescriptor 생성기
///
/// 흰 원 + 구역 색 테두리. 네이티브 마커로 올려 지도와 함께 움직이게 한다 —
/// 지도 좌표를 매 프레임 화면 좌표로 추적하지 않는다(#66).
class ZoneVertexHandleIcon {
  ZoneVertexHandleIcon._();

  /// 원의 중심이 꼭짓점 좌표를 가리키도록 중앙 anchor
  static const Offset anchor = Offset(0.5, 0.5);

  static double get _diameter => 14.w;
  static const double _ringWidth = 2;

  /// 색상별 비트맵 캐시 — 결과는 2종(플레이그라운드 blue / 감옥 red)뿐이다.
  static final Map<Color, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> create({required Color color}) async {
    final cached = _cache[color];
    if (cached != null) return cached;

    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final physSize = (_diameter * dpr).round();
    final center = Offset(physSize / 2, physSize / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(center, physSize / 2, Paint()..color = color);
    canvas.drawCircle(
      center,
      physSize / 2 - _ringWidth * dpr,
      Paint()..color = AppColors.white,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(physSize, physSize);
    picture.dispose();

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('꼭짓점 손잡이 비트맵 인코딩 실패 (toByteData returned null)');
      }
      final descriptor = BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        imagePixelRatio: dpr,
      );
      _cache[color] = descriptor;
      return descriptor;
    } finally {
      image.dispose();
    }
  }
}
