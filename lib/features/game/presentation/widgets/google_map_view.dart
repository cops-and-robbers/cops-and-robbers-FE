import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // SvgStringLoader + vg const re-export
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/map_styles.dart';
import '../../../../../core/services/location/device_location_service.dart';
import '../../domain/entities/ping.dart';
import 'map_error_widget.dart';
import 'ping_marker_factory.dart';

/// Google Maps 기반 게임 지도 뷰
///
/// - 내장 위치 마커 사용 (myLocationEnabled)
/// - [updateAreaCircles]로 플레이그라운드·감옥 원 추가
class GoogleMapView extends StatefulWidget {
  const GoogleMapView({
    super.key,
    this.onCameraMoveStarted,
    this.onLongPress,
    this.isDarkMode = false,
  });

  final VoidCallback? onCameraMoveStarted;
  final ValueChanged<LatLng>? onLongPress;
  final bool isDarkMode;

  @override
  State<GoogleMapView> createState() => GoogleMapViewState();
}

class GoogleMapViewState extends State<GoogleMapView> {
  GoogleMapController? _controller;

  static const LatLng _fallback = LatLng(37.5480, 127.0810);

  Set<Circle> _areaCircles = {};
  Set<Polygon> _areaPolygons = {};

  double _minZoom = 12.0;

  /// 카메라 이동 허용 범위 — 구역 로드 전에는 무제한
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;

  // 도둑 공개 위치 마커
  BitmapDescriptor? _redRobberMarker;
  BitmapDescriptor? _greenRobberMarker;
  Set<Marker> _robberMarkers = {};

  // 핑 마커 (도둑 마커와 별도 세트, build에서 병합)
  Set<Marker> _pingMarkers = {};

  // 페이드 애니메이션용 마커 원본 데이터 (alpha 재계산 시 사용)
  Map<int, LatLng> _robberLocations = {};
  bool _robberIsPolice = false;

  // 도둑별 발자국 회전 각도
  final _random = Random();

  /// 현재 화면에 표시 중인 회전값 (페이드 아웃 시 사용)
  Map<int, double> _robberRotations = {};

  /// 다음 페이드 인 시 적용할 회전값 — alpha=0 순간에 _robberRotations로 교체
  Map<int, double> _pendingRotations = {};

  // 페이드 깜빡임 애니메이션 (등장 시 3회, 1사이클 = 1400ms)
  Timer? _blinkTimer;
  static const _blinkCycles = 3;
  static const _fadeStepInterval = Duration(milliseconds: 140);

  // 아이콘 로드 전 수신된 업데이트 캐시
  ({Map<int, LatLng> locations, bool isPolice})? _pendingRobbers;

  @override
  void initState() {
    super.initState();
    debugPrint('========================================');
    debugPrint('🗺️ GoogleMapView initState 시작');
    debugPrint('🗺️ isDarkMode: ${widget.isDarkMode}');
    debugPrint('========================================');
    _preloadIcons();
  }

  @override
  void dispose() {
    debugPrint('🗺️ GoogleMapView dispose');
    _blinkTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 아이콘 사전 로드
  // ---------------------------------------------------------------------------

  /// 발자국 마커 가로·세로 크기 (logical px) — 개별 조절 가능
  static const _shoeprintWidth = 54.0;
  static const _shoeprintHeight = 38.0;

  /// 발자국(shoeprint) SVG 기반 도둑 공개 위치 마커 BitmapDescriptor 생성
  ///
  /// SVG fill 색상을 교체한 뒤 flutter_svg로 렌더링하여 PNG 바이트로 변환.
  /// [color] 경찰 시점: AppColors.red / 도둑 시점: AppColors.green
  Future<BitmapDescriptor> _createShoeprintDescriptor(Color color) async {
    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    final physWidth = (_shoeprintWidth * dpr).round();
    final physHeight = (_shoeprintHeight * dpr).round();

    // SVG 로드 후 fill 색상 교체 (#080A0C → 타겟 색상)
    final svgString = await rootBundle.loadString('assets/icons/shoeprint.svg');
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    final colorized = svgString.replaceAll('fill="#080A0C"', 'fill="$hex"');

    // flutter_svg → vector_graphics Picture 생성
    final pictureInfo = await vg.loadPicture(SvgStringLoader(colorized), null);

    // 물리 픽셀 크기로 스케일 조정 후 캔버스에 렌더링
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(
      physWidth / pictureInfo.size.width,
      physHeight / pictureInfo.size.height,
    );
    canvas.drawPicture(pictureInfo.picture);
    pictureInfo.picture.dispose();

    final picture = recorder.endRecording();
    final image = await picture.toImage(physWidth, physHeight);
    picture.dispose(); // ui.Picture는 toImage 후 불필요 — 즉시 해제

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('마커 비트맵 인코딩 실패 (toByteData returned null)');
      }
      return BitmapDescriptor.bytes(
        bytes.buffer.asUint8List(),
        imagePixelRatio: dpr,
      );
    } finally {
      image.dispose(); // ui.Image는 네이티브 리소스 — 예외 여부 무관하게 해제
    }
  }

  /// 도둑 공개 위치 마커 아이콘 사전 로드
  ///
  /// SVG 렌더링 실패 시 기본 마커로 폴백하여 [_pendingRobbers]가 막히지 않도록 보장.
  Future<void> _preloadIcons() async {
    try {
      _redRobberMarker = await _createShoeprintDescriptor(AppColors.red);
      _greenRobberMarker = await _createShoeprintDescriptor(AppColors.green);
      debugPrint('✅ GoogleMapView: 발자국 마커 아이콘 로드 완료');
    } catch (e) {
      // SVG 로드 실패 시 기본 마커로 대체 — null 상태로 두면 pendingRobbers가 영구 대기
      debugPrint('❌ GoogleMapView: 마커 아이콘 로드 실패, 기본 마커 사용 - $e');
      _redRobberMarker ??= BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      );
      _greenRobberMarker ??= BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      );
    } finally {
      _applyPendingUpdates();
    }
  }

  void _applyPendingUpdates() {
    if (_pendingRobbers case final p?) {
      _pendingRobbers = null;
      updateRobberMarkers(p.locations, isPolice: p.isPolice);
    }
  }

  // ---------------------------------------------------------------------------
  // 공개 메서드
  // ---------------------------------------------------------------------------

  Future<void> moveCameraToCurrentLocation() async {
    debugPrint('📍 GoogleMap: 현재 위치로 카메라 이동 시작');
    try {
      final pos = await DeviceLocationService.getCurrentPosition();

      if (pos == null) {
        debugPrint('[지도/Google] 위치 조회 실패 → fallback 사용');
        return;
      }

      debugPrint('[지도/Google] 초기 위치: ${pos.latitude}, ${pos.longitude}');

      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 16),
        ),
      );
      debugPrint('✅ GoogleMap: 카메라 이동 완료');
    } catch (e, stack) {
      debugPrint('❌ GoogleMap: 카메라 이동 실패 - $e');
      debugPrint('Stack: $stack');
    }
  }

  /// 플레이그라운드 반경(미터)에 따라 지도 최소 줌 레벨을 갱신합니다.
  ///
  /// [playgroundRadiusInMeters] 게임 구역 반경 (단위: 미터).
  /// 반경이 클수록 낮은 최소 줌이 적용되어 더 넓은 범위를 볼 수 있습니다.
  void updateMinZoom(double playgroundRadiusInMeters) {
    if (!mounted) return;
    setState(() => _minZoom = _minZoomForRadius(playgroundRadiusInMeters));
  }

  /// 플레이그라운드 반경(미터)으로부터 최소 줌 레벨을 계산합니다.
  static double _minZoomForRadius(double radiusInMeters) =>
      switch (radiusInMeters) {
        <= 200 => 15.0,
        <= 500 => 14.0,
        <= 1000 => 13.0,
        _ => 12.0,
      };

  /// 카메라 이동 허용 범위를 갱신합니다 (플레이그라운드 주변 제한).
  void updateCameraBounds(LatLngBounds bounds) {
    if (!mounted) return;
    setState(() => _cameraTargetBounds = CameraTargetBounds(bounds));
  }

  void updateAreaCircles(Set<Circle> circles) {
    if (!mounted) return;
    setState(() => _areaCircles = circles);
    debugPrint('🗺️ GoogleMap: 영역 원 ${circles.length}개 업데이트');
  }

  /// 플레이그라운드 외부 오버레이 폴리곤 업데이트
  void updateAreaPolygons(Set<Polygon> polygons) {
    if (!mounted) return;
    setState(() => _areaPolygons = polygons);
  }

  /// 도둑 공개 위치 마커 업데이트
  ///
  /// 새 위치를 받으면 페이드 깜빡임 [_blinkCycles]회 후 영구 표시.
  /// [isPolice] true → 빨간 발자국, false → 초록 발자국.
  void updateRobberMarkers(
    Map<int, LatLng> locations, {
    required bool isPolice,
  }) {
    if (_redRobberMarker == null || !mounted) {
      _pendingRobbers = (locations: locations, isPolice: isPolice);
      return;
    }

    // 첫 등장 여부 확인 (locations 갱신 전에 판단)
    final isFirstAppearance = _robberLocations.isEmpty;

    _blinkTimer?.cancel();
    _blinkTimer = null;
    _robberLocations = locations;
    _robberIsPolice = isPolice;

    // 새 랜덤 회전값을 pending으로 준비
    _pendingRotations = {
      for (final id in locations.keys) id: _random.nextDouble() * 360,
    };
    // 첫 등장: 즉시 적용 (기존에 보이는 마커 없으므로 교체 불필요)
    // 갱신: alpha=0 순간에 교체 (페이드 아웃 후 보이지 않을 때 회전)
    if (isFirstAppearance) _robberRotations = Map.from(_pendingRotations);

    debugPrint('🗺️ GoogleMap: 도둑 위치 마커 ${locations.length}개 업데이트');
    _startFadeAnimation(rotationApplied: isFirstAppearance);
  }

  /// LatLng → Flutter logical-pixel Offset 변환
  ///
  /// `getScreenCoordinate`가 반환하는 좌표 단위는 플랫폼마다 다르다:
  /// - **Android**: device(physical) pixels → Positioned(logical)에 쓰려면 dpr로 나눠야 함
  /// - **iOS**: 이미 logical pixels → 그대로 사용
  ///
  /// 이 차이를 무시하면 Android에서 카드가 dpr배 아래/오른쪽으로 밀린다(#405).
  Future<Offset?> latLngToScreenOffset(
    LatLng latLng,
    double devicePixelRatio,
  ) async {
    final controller = _controller;
    if (controller == null) return null;
    final sc = await controller.getScreenCoordinate(latLng);
    final divisor = defaultTargetPlatform == TargetPlatform.android
        ? devicePixelRatio
        : 1.0;
    return Offset(sc.x / divisor, sc.y / divisor);
  }

  /// 핑 마커 갱신 (도둑 마커와 독립 — build에서 병합)
  Future<void> updatePingMarkers(
    List<Ping> pings, {
    required bool isDark,
  }) async {
    final markers = <Marker>{};
    for (final p in pings) {
      final icon = await PingMarkerFactory.create(type: p.type, isDark: isDark);
      markers.add(
        Marker(
          markerId: MarkerId('ping_${p.id}'),
          position: LatLng(p.latitude, p.longitude),
          icon: icon,
          anchor: PingMarkerFactory.anchor,
          consumeTapEvents: false,
          zIndexInt: 1,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _pingMarkers = markers);
  }

  /// 1사이클(1400ms): 페이드 아웃 → 완전 비표시 → 페이드 인 → 완전 표시
  /// [_blinkCycles]회 반복 후 영구 표시
  ///
  /// [rotationApplied] 첫 등장 시 true — 이미 _robberRotations에 새 값이 적용돼 있음.
  ///                   갱신 시 false — alpha=0 첫 도달 시 _pendingRotations로 교체.
  void _startFadeAnimation({required bool rotationApplied}) {
    const cycle = [
      0.6, 0.2, 0.0, // 페이드 아웃  (3 × 140ms = 420ms)
      0.0, 0.0, // 완전 비표시  (2 × 140ms = 280ms)
      0.4, 0.8, 1.0, // 페이드 인    (3 × 140ms = 420ms)
      1.0, 1.0, // 완전 표시    (2 × 140ms = 280ms)
    ]; // 1사이클 = 10 × 140ms = 1400ms

    final sequence = <double>[for (var i = 0; i < _blinkCycles; i++) ...cycle];

    int step = 0;
    _setRobberAlpha(1.0);

    _blinkTimer = Timer.periodic(_fadeStepInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (step >= sequence.length) {
        timer.cancel();
        _blinkTimer = null;
        _setRobberAlpha(1.0);
        return;
      }
      final alpha = sequence[step++];
      // 마커가 완전히 사라진 첫 순간에 새 회전값 교체 → 페이드 인 시 이미 회전된 상태
      if (!rotationApplied && alpha == 0.0) {
        _robberRotations = Map.from(_pendingRotations);
        rotationApplied = true;
      }
      _setRobberAlpha(alpha);
    });
  }

  /// [alpha]를 적용한 도둑 마커 세트를 빌드하여 setState로 반영
  void _setRobberAlpha(double alpha) {
    final icon = _robberIsPolice ? _redRobberMarker : _greenRobberMarker;
    if (icon == null || !mounted) return;
    setState(() {
      _robberMarkers = _robberLocations.entries
          .map(
            (e) => Marker(
              markerId: MarkerId('robber_${e.key}'),
              position: e.value,
              icon: icon,
              alpha: alpha,
              rotation: _robberRotations[e.key] ?? 0,
              anchor: const Offset(0.5, 0.5),
              flat: true,
              consumeTapEvents: false,
              zIndexInt: 0,
            ),
          )
          .toSet();
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    try {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _fallback,
          zoom: 15,
        ),
        // Cloud Map ID는 콜드 스타트 시 회색 타일 영구 실패 가능성으로 미사용 — JSON 다크 스타일로 통일
        style: widget.isDarkMode ? MapStyles.dark : null,
        onMapCreated: (controller) {
          debugPrint('🗺️ GoogleMap onMapCreated 콜백 시작');
          try {
            _controller = controller;
            moveCameraToCurrentLocation();
            debugPrint('✅ google map ready');
          } catch (e, stack) {
            debugPrint('❌ GoogleMap onMapCreated 에러: $e');
            debugPrint('Stack: $stack');
          }
        },

        onCameraMoveStarted: widget.onCameraMoveStarted,
        onLongPress: widget.onLongPress,

        // OS 내장 위치 마커 사용 — 커스텀 마커 대비 반응성 우수
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // 커스텀 내 위치 버튼 사용

        minMaxZoomPreference: MinMaxZoomPreference(_minZoom, 20),
        cameraTargetBounds: _cameraTargetBounds,
        zoomControlsEnabled: false,
        compassEnabled: false,
        circles: _areaCircles,
        polygons: _areaPolygons,
        markers: {..._robberMarkers, ..._pingMarkers},
      );
    } catch (e, stack) {
      debugPrint('❌ GoogleMap 생성 실패: $e');
      debugPrint('Stack: $stack');
      return MapErrorWidget(mapName: 'Google Map', error: e);
    }
  }
}
