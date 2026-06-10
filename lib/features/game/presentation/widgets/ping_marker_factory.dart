import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  /// 마커 논리 크기 (24×24 기준, 기기 폭에 비례 — 튜토리얼 위젯과 동일 스케일)
  ///
  /// 위젯이 아닌 비트맵 렌더 컨텍스트지만, ScreenUtil의 `.w`는 전역 싱글턴이라
  /// 위젯 밖에서도 동작한다(앱 루트 ScreenUtilInit 이후 항상 초기화됨).
  static double get _size => 24.w;

  /// 좌표를 가리키는 anchor — 심볼 단독이라 중심 정렬 (기존 robber 마커와 동일)
  static const Offset anchor = Offset(0.5, 0.5);

  /// (type, theme)별 비트맵 캐시.
  /// 결과는 4종(found/suspect × light/dark)뿐이고 dpr·논리 크기(24.w)가 기기 상수라
  /// 한 번 렌더한 디스크립터를 재사용한다 — 핑 갱신마다 SVG 로드·래스터화를 반복하지 않는다.
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> create({
    required PingType type,
    required bool isDark,
  }) async {
    final theme = isDark ? 'darkmode' : 'lightmode';
    final typeName = type == PingType.found ? 'found' : 'suspect';

    // 이미 렌더한 (type, theme) 비트맵이면 즉시 재사용 — 반복 SVG 로드·래스터화 회피
    final cacheKey = '${typeName}_$theme';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
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
