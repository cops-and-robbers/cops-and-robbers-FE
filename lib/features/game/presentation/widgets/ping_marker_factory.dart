import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgStringLoader + vg
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/ping.dart';

/// 핑 마커 BitmapDescriptor 생성기
///
/// 맵에 찍히는 핑 마커는 종류별 심볼(`icon_ping_{type}_marker`, 24×24) **단독**으로
/// 표시한다(핀 꼬리 `icon_ping_pin`은 선택 카드 전용이라 마커에는 합성하지 않는다).
/// 테마(`isDark`)에 맞는 `_{light,dark}mode` 파일을 선택한다.
class PingMarkerFactory {
  PingMarkerFactory._();

  /// 마커 논리 크기 (24×24)
  static const double _size = 24.0;

  /// 좌표를 가리키는 anchor — 심볼 단독이라 중심 정렬 (기존 robber 마커와 동일)
  static const Offset anchor = Offset(0.5, 0.5);

  static Future<BitmapDescriptor> create({
    required PingType type,
    required bool isDark,
  }) async {
    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final theme = isDark ? 'darkmode' : 'lightmode';
    final typeName = type == PingType.found ? 'found' : 'suspect';

    final physSize = (_size * dpr).round();

    final symbolPic = await vg.loadPicture(
      SvgStringLoader(
        await rootBundle.loadString(
          'assets/icons/icon_ping_${typeName}_marker_$theme.svg',
        ),
      ),
      null,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // 심볼을 물리 픽셀 크기로 스케일 조정 후 렌더링
    canvas.scale(
      physSize / symbolPic.size.width,
      physSize / symbolPic.size.height,
    );
    canvas.drawPicture(symbolPic.picture);
    symbolPic.picture.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(physSize, physSize);
    picture.dispose();

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('핑 마커 비트맵 인코딩 실패 (toByteData returned null)');
      }
      return BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        imagePixelRatio: dpr,
      );
    } finally {
      image.dispose();
    }
  }
}
