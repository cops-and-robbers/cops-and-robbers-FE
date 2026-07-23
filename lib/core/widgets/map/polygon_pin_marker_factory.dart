import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgStringLoader + vg
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 폴리곤 꼭짓점 핀 마커 BitmapDescriptor 생성기
///
/// `polygon_pin.svg`(15×28, 단색)를 팀 색상으로 틴트해 렌더한다.
/// 색상별(플레이그라운드 blue / 감옥 red)로 한 번만 래스터화 후 캐시한다.
class PolygonPinMarkerFactory {
  PolygonPinMarkerFactory._();

  /// 핀 꼬리 끝이 실제 좌표를 가리키도록 하단 중앙 anchor
  static const Offset anchor = Offset(0.5, 1.0);

  /// SVG 원본 종횡비(15:28) 유지 — 폭 기준 스케일
  static double get _width => 15.w;
  static double get _height => 28.w;

  /// 색상별 비트맵 캐시. 결과는 2종(blue/red)뿐이고 dpr·논리 크기가 기기 상수라
  /// 한 번 렌더한 디스크립터를 재사용한다.
  static final Map<Color, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> create({required Color color}) async {
    final cached = _cache[color];
    if (cached != null) return cached;

    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final physWidth = (_width * dpr).round();
    final physHeight = (_height * dpr).round();

    final pic = await vg.loadPicture(
      SvgStringLoader(
        await rootBundle.loadString('assets/icons/polygon_pin.svg'),
      ),
      null,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // 색상 틴트: SVG 원본 alpha를 마스크로 지정 색을 채운다(srcIn).
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, physWidth.toDouble(), physHeight.toDouble()),
      Paint()..colorFilter = ui.ColorFilter.mode(color, BlendMode.srcIn),
    );
    canvas.scale(physWidth / pic.size.width, physHeight / pic.size.height);
    canvas.drawPicture(pic.picture);
    canvas.restore();
    pic.picture.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(physWidth, physHeight);
    picture.dispose();

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('폴리곤 핀 마커 비트맵 인코딩 실패 (toByteData returned null)');
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
