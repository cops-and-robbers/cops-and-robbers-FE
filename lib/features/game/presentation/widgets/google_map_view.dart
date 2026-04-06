import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/map_styles.dart';
import '../../../../../core/services/location/device_location_service.dart';
import 'map_error_widget.dart';

/// Google Maps 기반 게임 지도 뷰
///
/// - 내장 위치 마커 사용 (myLocationEnabled)
/// - [updateAreaCircles]로 플레이그라운드·감옥 원 추가
class GoogleMapView extends StatefulWidget {
  const GoogleMapView({
    super.key,
    this.onCameraMoveStarted,
    this.isDarkMode = false,
  });

  final VoidCallback? onCameraMoveStarted;
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

  // 도둑 공개 위치 마커
  BitmapDescriptor? _redRobberDot;
  BitmapDescriptor? _greenRobberDot;
  Set<Marker> _robberMarkers = {};

  // 아이콘 로드 전 수신된 업데이트 캐시
  ({Map<int, LatLng> locations, bool isPolice})? _pendingRobbers;

  @override
  void initState() {
    super.initState();
    debugPrint('========================================');
    debugPrint('🗺️ GoogleMapView initState 시작');
    debugPrint('========================================');
    _preloadIcons();
  }

  @override
  void dispose() {
    debugPrint('🗺️ GoogleMapView dispose');
    _controller?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 아이콘 사전 로드
  // ---------------------------------------------------------------------------

  /// 도둑 공개 위치용 고정 크기 dot BitmapDescriptor 생성
  ///
  /// 내장 위치 마커와 시각적으로 구분되도록 12dp 원형 사용.
  Future<BitmapDescriptor> _createRobberDotDescriptor(Color color) async {
    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    const diameter = 12.0;
    final physSize = (diameter * dpr).round();
    final s = dpr;
    final center = Offset(diameter / 2 * s, diameter / 2 * s);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(center, diameter / 2 * s, Paint()..color = color);

    final picture = recorder.endRecording();
    final image = await picture.toImage(physSize, physSize);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw StateError('마커 비트맵 인코딩 실패 (toByteData returned null)');
    }

    return BitmapDescriptor.bytes(
      bytes.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }

  /// 도둑 공개 위치 마커 아이콘 사전 로드
  Future<void> _preloadIcons() async {
    try {
      _redRobberDot = await _createRobberDotDescriptor(AppColors.red);
      _greenRobberDot = await _createRobberDotDescriptor(AppColors.green);
      debugPrint('✅ GoogleMapView: 마커 아이콘 로드 완료');
      _applyPendingUpdates();
    } catch (e) {
      debugPrint('❌ GoogleMapView: 마커 아이콘 로드 실패 - $e');
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
  /// [isPolice] true → 빨간 dot, false → 초록 dot.
  void updateRobberMarkers(
    Map<int, LatLng> locations, {
    required bool isPolice,
  }) {
    final icon = isPolice ? _redRobberDot : _greenRobberDot;
    if (icon == null || !mounted) {
      _pendingRobbers = (locations: locations, isPolice: isPolice);
      return;
    }

    setState(() {
      _robberMarkers = locations.entries
          .map(
            (e) => Marker(
              markerId: MarkerId('robber_${e.key}'),
              position: e.value,
              icon: icon,
              anchor: const Offset(0.5, 0.5),
              flat: true,
              consumeTapEvents: false,
              zIndexInt: 0,
            ),
          )
          .toSet();
    });
    debugPrint('🗺️ GoogleMap: 도둑 위치 마커 ${locations.length}개 업데이트');
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
        // 도둑 팀: 기기 설정 무관하게 항상 어두운 스타일 강제
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

        // OS 내장 위치 마커 사용 — 커스텀 마커 대비 반응성 우수
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // 커스텀 내 위치 버튼 사용

        minMaxZoomPreference: MinMaxZoomPreference(_minZoom, 20),
        zoomControlsEnabled: false,
        compassEnabled: false,
        circles: _areaCircles,
        polygons: _areaPolygons,
        markers: _robberMarkers,
      );
    } catch (e, stack) {
      debugPrint('❌ GoogleMap 생성 실패: $e');
      debugPrint('Stack: $stack');
      return MapErrorWidget(mapName: 'Google Map', error: e);
    }
  }
}
