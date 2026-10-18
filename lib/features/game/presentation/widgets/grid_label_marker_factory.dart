import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';

/// 좌표 격자 칸 라벨("C3") 마커 BitmapDescriptor 생성기 (#636)
///
/// 지도 위 글자는 타일 색과 겹치므로 배경색 테두리(헤일로)를 둘러 읽히게 한다.
class GridLabelMarkerFactory {
  GridLabelMarkerFactory._();

  static const Offset anchor = Offset(0.5, 0.5);

  /// (라벨, 테마)별 캐시 — 라벨은 최대 26×26종이고 게임이 바뀌어도 같은 글자라 재사용한다
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> create(
    String label, {
    required bool isDark,
  }) async {
    final cacheKey = '${label}_$isDark';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final style = AppTextStyles.tag12Semibold;
    final halo = isDark ? AppColors.black : AppColors.white;

    TextPainter painter(TextStyle s) => TextPainter(
      text: TextSpan(text: label, style: s),
      textDirection: TextDirection.ltr,
    )..layout();

    final outline = painter(
      style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = halo,
      ),
    );
    final fill = painter(
      style.copyWith(color: isDark ? AppColors.black200 : AppColors.black700),
    );

    const pad = 2.0;
    final width = (outline.width + pad * 2) * dpr;
    final height = (outline.height + pad * 2) * dpr;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(dpr);
    outline.paint(canvas, const Offset(pad, pad));
    fill.paint(canvas, const Offset(pad, pad));
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.ceil(), height.ceil());
    picture.dispose();

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('격자 라벨 비트맵 인코딩 실패 (toByteData returned null)');
      }
      final descriptor = BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        imagePixelRatio: dpr,
      );
      _cache[cacheKey] = descriptor;
      return descriptor;
    } finally {
      image.dispose();
    }
  }
}
