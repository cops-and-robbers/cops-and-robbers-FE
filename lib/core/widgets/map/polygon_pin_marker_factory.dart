import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgStringLoader + vg
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_icons.dart';

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
      SvgStringLoader(await rootBundle.loadString(AppIcons.polygonPin)),
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

  /// 투명 확장 히트박스 anchor — 핀과 동일하게 tip(bottom-center)을 좌표에 맞춤
  static const Offset hitboxAnchor = Offset(0.5, 1.0);

  /// 히트박스 논리 크기 (권장 최소 터치 타깃 44) — 핀(15×28)을 여유 있게 감쌈
  static double get _hitboxSize => 44.w;

  static BitmapDescriptor? _hitboxCache;

  /// 핀 근처 탭도 삭제로 인식되도록 하는 투명 확장 히트박스 비트맵.
  ///
  /// 마커의 터치 판정은 아이콘 사각형 전체(투명 픽셀 포함)라, 투명한 큰
  /// 정사각형을 핀 아래 겹쳐 두면 시각 변화 없이 터치 영역만 넓힐 수 있다.
  static Future<BitmapDescriptor> createHitbox() async {
    final cached = _hitboxCache;
    if (cached != null) return cached;

    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final phys = (_hitboxSize * dpr).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    // 완전 투명 사각형 — 보이진 않지만 사각형 영역 전체가 탭 가능
    canvas.drawRect(
      Rect.fromLTWH(0, 0, phys.toDouble(), phys.toDouble()),
      Paint()..color = AppColors.transparent,
    );
    final image = await recorder.endRecording().toImage(phys, phys);

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('히트박스 비트맵 인코딩 실패 (toByteData returned null)');
      }
      final descriptor = BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        imagePixelRatio: dpr,
      );
      _hitboxCache = descriptor;
      return descriptor;
    } finally {
      image.dispose();
    }
  }
}
