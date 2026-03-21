import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/location/device_location_service.dart';
import 'map_error_widget.dart';

/// Google Maps 기반 게임 지도 뷰
///
/// - 팀 색상 커스텀 내 위치 마커 (경찰: 파랑, 도둑: 초록)
/// - 방향 인디케이터 삼각형 (heading 방향을 가리킴)
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

  // 내 위치 + 방향 통합 마커
  Marker? _locationMarker;

  // 사전 로드된 BitmapDescriptor (내 위치 통합 마커)
  BitmapDescriptor? _policeMarker;
  BitmapDescriptor? _robberMarker;

  // 도둑 공개 위치 마커
  BitmapDescriptor? _redRobberDot;
  BitmapDescriptor? _greenRobberDot;
  Set<Marker> _robberMarkers = {};

  // 아이콘 로드 전 수신된 업데이트 캐시
  ({LatLng position, double heading, bool isPolice})? _pendingHeading;
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

  /// 방향 화살표 + 위치 원을 단일 비트맵으로 통합한 BitmapDescriptor 생성
  ///
  /// 비율 (dp 기준):
  ///  - 원: 12×12
  ///  - 화살표: 8×5 (이미지 TOP = heading 방향)
  ///  - 원 테두리 ~ 화살표 밑변 간격: 2
  ///  - 전체 이미지: 12(W) × 19(H)
  ///
  /// anchor = (0.5, 13/19) → 원 중심(y=13)이 마커 좌표에 고정.
  /// rotation = heading → 화살표가 이동 방향을 가리킴.
  Future<BitmapDescriptor> _createLocationMarkerDescriptor(Color color) async {
    final dpr =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    const dotDiameter = 12.0;
    const arrowW = 8.0;
    const arrowH = 5.0;
    const gap = 2.0;
    const imgW = dotDiameter;
    const imgH = arrowH + gap + dotDiameter;

    final physW = (imgW * dpr).round();
    final physH = (imgH * dpr).round();
    final s = dpr;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final fillPaint = Paint()..color = color;

    final arrowPath = Path()
      ..moveTo(imgW / 2 * s, 0)
      ..lineTo((imgW - arrowW) / 2 * s, arrowH * s)
      ..lineTo((imgW + arrowW) / 2 * s, arrowH * s)
      ..close();
    canvas.drawPath(arrowPath, fillPaint);

    final cx = imgW / 2 * s;
    final cy = (arrowH + gap + dotDiameter / 2) * s;
    canvas.drawCircle(Offset(cx, cy), dotDiameter / 2 * s, fillPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(physW, physH);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw StateError('마커 비트맵 인코딩 실패 (toByteData returned null)');
    }

    return BitmapDescriptor.bytes(
      bytes.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }

  /// 도둑 공개 위치용 고정 크기 dot BitmapDescriptor 생성
  ///
  /// 내 위치 원과 동일한 12dp.
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

  /// 모든 마커 아이콘 사전 로드
  ///
  /// 로드 완료 후 대기 중인 캐시가 있으면 즉시 적용한다.
  Future<void> _preloadIcons() async {
    try {
      _policeMarker = await _createLocationMarkerDescriptor(AppColors.blue);
      _robberMarker = await _createLocationMarkerDescriptor(AppColors.green);
      _redRobberDot = await _createRobberDotDescriptor(AppColors.red);
      _greenRobberDot = await _createRobberDotDescriptor(AppColors.green);
      debugPrint('✅ GoogleMapView: 마커 아이콘 로드 완료');
      _applyPendingUpdates();
    } catch (e) {
      debugPrint('❌ GoogleMapView: 마커 아이콘 로드 실패 - $e');
    }
  }

  void _applyPendingUpdates() {
    if (_pendingHeading case final p?) {
      _pendingHeading = null;
      updateHeadingMarker(p.position, p.heading, p.isPolice);
    }
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

  void updateAreaCircles(Set<Circle> circles) {
    if (!mounted) return;
    setState(() => _areaCircles = circles);
    debugPrint('🗺️ GoogleMap: 영역 원 ${circles.length}개 업데이트');
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

  /// 내 위치 + 방향 통합 마커 업데이트
  ///
  /// 단일 비트맵(화살표 + 원)을 rotation=heading으로 회전시켜
  /// 화살표가 이동 방향을 가리키도록 함.
  ///
  /// anchor = (0.5, 13/19): 이미지 높이 19dp 중 원 중심 y=13dp → 13/19
  /// → 원 중심이 [position] 좌표에 고정.
  ///
  /// [position] 현재 위치, [heading] 방향각(0=북, 시계방향), [isPolice] 팀 여부
  void updateHeadingMarker(LatLng position, double heading, bool isPolice) {
    final icon = isPolice ? _policeMarker : _robberMarker;
    if (icon == null || !mounted) {
      _pendingHeading = (
        position: position,
        heading: heading,
        isPolice: isPolice,
      );
      return;
    }

    setState(() {
      _locationMarker = Marker(
        markerId: const MarkerId('player_location'),
        position: position,
        icon: icon,
        rotation: heading.isNaN ? 0.0 : heading,
        anchor: const Offset(0.5, 13 / 19),
        flat: false,
        consumeTapEvents: false,
        zIndexInt: 1,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      if (_locationMarker != null) _locationMarker!,
      ..._robberMarkers,
    };

    try {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _fallback,
          zoom: 15,
        ),
        style: widget.isDarkMode ? _darkMapStyle : null,
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

        // 기본 파란 점 비활성화 → 팀 컬러 통합 마커(_locationMarker)로 대체
        myLocationEnabled: false,
        myLocationButtonEnabled: false,

        zoomControlsEnabled: false,
        compassEnabled: false,
        circles: _areaCircles,
        markers: markers,
      );
    } catch (e, stack) {
      debugPrint('❌ GoogleMap 생성 실패: $e');
      debugPrint('Stack: $stack');
      return MapErrorWidget(mapName: 'Google Map', error: e);
    }
  }

  /// Google Maps 다크 스타일 JSON
  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#181818"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}
]
''';
}
