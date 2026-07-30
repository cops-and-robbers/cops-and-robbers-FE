import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../features/game/domain/entities/area_shape.dart';
import '../../../features/game/domain/polygon_geometry.dart';
import '../../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/game_config.dart';
import '../../constants/map_styles.dart';
import '../../constants/spacing_and_radius.dart';
import '../../services/location/device_location_service.dart';
import '../../services/vibration_service.dart';
import '../../utils/zone_metric_formatter.dart';
import '../buttons/my_location_button.dart';
import '../chips/action_chip.dart' as custom_chip;
import '../chips/info_radius_chip.dart';
import '../snackbars/app_snackbar.dart';
import 'polygon_pin_marker_factory.dart';

/// 핀 기반 폴리곤 구역 설정 위젯 (지도 탭으로 꼭짓점 편집)
///
/// 지도를 탭하면 핀을 추가하고, 핀을 탭하면 삭제한다. 핀은 매번 중심 각도
/// 기준으로 정렬되어 자기교차 없는 단순 다각형 미리보기를 만든다.
/// 정렬된 목록은 [onPointsChanged]로 부모에 전달된다(전송·검증에 사용).
class PinZoneSettingWidget extends StatefulWidget {
  const PinZoneSettingWidget({
    super.key,
    required this.initialPoints,
    required this.pinColor,
    required this.fillColor,
    required this.strokeColor,
    required this.onPointsChanged,
    this.referencePolygon,
    this.locationButtonColor,
    this.areaChipBackgroundColor,
    this.isDarkMode = false,
    this.mapHeight,
  });

  /// 초기 핀 목록 (편집/복원용, 찍은 순서)
  final List<LatLng> initialPoints;

  /// 핀 마커 색상 (플레이그라운드 blue / 감옥 red)
  final Color pinColor;

  /// 미리보기 다각형 채움 색상
  final Color fillColor;

  /// 미리보기 다각형 외곽선 색상
  final Color strokeColor;

  /// 정렬된 꼭짓점 목록 콜백 (경계 순서)
  final void Function(List<LatLng> sortedPoints) onPointsChanged;

  /// 읽기 전용 참조 다각형 (감옥 설정 시 플레이그라운드 표시용)
  final List<LatLng>? referencePolygon;

  /// 내 위치 버튼 아이콘 색상 (기본: pinColor)
  final Color? locationButtonColor;

  /// 면적 칩 배경색 (기본: pinColor)
  final Color? areaChipBackgroundColor;

  /// 다크 모드 여부 (지도 스타일)
  final bool isDarkMode;

  /// 지도 높이 (기본: 360)
  final double? mapHeight;

  @override
  State<PinZoneSettingWidget> createState() => PinZoneSettingWidgetState();
}

class PinZoneSettingWidgetState extends State<PinZoneSettingWidget> {
  final List<LatLng> _points = [];
  BitmapDescriptor? _pinIcon;
  BitmapDescriptor? _hitboxIcon;
  GoogleMapController? _mapController;
  LatLng? _locationFocusTarget;
  bool _isLocationFocused = false;
  bool _isProgrammaticMove = false;
  bool _isInitialized = false;

  /// 최근 카메라 위치 — 마커 삭제 시 카메라 튐을 상쇄해 복원하는 데 쓴다
  CameraPosition? _lastCamera;

  // Fallback 위치 (어린이대공원)
  static const LatLng _fallbackLocation = LatLng(37.5480, 127.0810);
  static const double _initialZoom = 15;
  static const double _locationFocusToleranceInMeters = 5;
  late LatLng _initialCamera;

  @override
  void initState() {
    super.initState();
    _points.addAll(widget.initialPoints);
    _initialize();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    // 마커 아이콘 + 투명 확장 히트박스 로드
    _pinIcon = await PolygonPinMarkerFactory.create(color: widget.pinColor);
    _hitboxIcon = await PolygonPinMarkerFactory.createHitbox();

    final currentLocation = await _currentLocation();
    _locationFocusTarget = currentLocation;

    // 초기 카메라: 기존 핀 있으면 그 중심, 없으면 현재 위치 → fallback
    if (_points.isNotEmpty) {
      _initialCamera = _centroidOf(_points);
    } else {
      _initialCamera = currentLocation ?? _fallbackLocation;
    }
    _lastCamera = CameraPosition(target: _initialCamera, zoom: _initialZoom);
    _isLocationFocused = _isCameraFocusedOnLocation(_lastCamera!);

    if (mounted) setState(() => _isInitialized = true);
  }

  Future<LatLng?> _currentLocation() async {
    try {
      final pos = await DeviceLocationService.getCurrentPosition();
      if (pos == null) return null;
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  LatLng _centroidOf(List<LatLng> pts) {
    final lat = pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length;
    final lng =
        pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length;
    return LatLng(lat, lng);
  }

  /// 지정된 핀 배치의 경계 반경 (중심 → 가장 먼 핀, 미터)
  double _boundingRadius(List<LatLng> points) {
    final center = _centroidOf(points);
    var radius = 0.0;
    for (final p in points) {
      final d = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        p.latitude,
        p.longitude,
      );
      if (d > radius) radius = d;
    }
    return radius;
  }

  /// 축소 하한 — 인게임(google_map_view)과 같은 반경 기반 동적 패턴.
  /// 값은 원형 편집(zone_setting_widget)과 동일한 완화 테이블 — 설정 편의.
  /// 표시할 핀 2개 미만이면 반경 0으로 취급해 최저 하한(14)부터 시작한다 —
  /// 원형 편집이 기본 반경으로 진입 즉시 제한되는 것과 동일한 UX.
  /// 편집 핀과 참조 폴리곤이 벌어질수록 하한이 단계적으로 풀린다.
  double get _minZoom {
    final ref = widget.referencePolygon;
    final visiblePoints = [
      ..._points,
      // 렌더링(_buildPolygons)과 같은 조건 — 3점 미만의 미완성 참조 폴리곤은
      // 화면에 그리지 않으므로, 보이지 않는 핀이 줌 하한을 정하지 않게 제외한다.
      if (ref != null && ref.length >= GameConfig.minPolygonVertexCount) ...ref,
    ];
    return _minZoomForRadius(
      visiblePoints.length < 2 ? 0 : _boundingRadius(visiblePoints),
    );
  }

  static double _minZoomForRadius(double radiusInMeters) =>
      switch (radiusInMeters) {
        <= 200 => 14.0,
        <= 500 => 13.0,
        <= 1000 => 12.0,
        _ => 11.0,
      };

  bool _isCameraFocusedOnLocation(CameraPosition camera) {
    final location = _locationFocusTarget;
    if (location == null) return false;
    return Geolocator.distanceBetween(
          camera.target.latitude,
          camera.target.longitude,
          location.latitude,
          location.longitude,
        ) <=
        _locationFocusToleranceInMeters;
  }

  void _updateLocationFocus(CameraPosition camera) {
    final isFocused = _isCameraFocusedOnLocation(camera);
    if (isFocused == _isLocationFocused) return;
    setState(() => _isLocationFocused = isFocused);
  }

  List<GeoPoint> get _geoPoints => [
    for (final p in _points)
      GeoPoint(latitude: p.latitude, longitude: p.longitude),
  ];

  /// 각도 정렬된 경계 순서 핀 목록 (미리보기·콜백·전송 공용)
  List<LatLng> get sortedPoints => [
    for (final p in sortByAngleAroundCentroid(_geoPoints))
      LatLng(p.latitude, p.longitude),
  ];

  void _onMapTap(LatLng pos) {
    final l10n = AppLocalizations.of(context);
    if (_points.length >= GameConfig.maxPolygonVertexCount) {
      AppSnackbar.show(
        context,
        message: l10n.pinMaxCountMessage(GameConfig.maxPolygonVertexCount),
        backgroundColor: AppColors.red,
        isDarkMode: widget.isDarkMode,
      );
      return;
    }
    final tooClose = _points.any(
      (p) =>
          Geolocator.distanceBetween(
            p.latitude,
            p.longitude,
            pos.latitude,
            pos.longitude,
          ) <
          GameConfig.minPinSpacingInMeters,
    );
    if (tooClose) {
      AppSnackbar.show(
        context,
        message: l10n.pinTooCloseMessage,
        backgroundColor: AppColors.red,
        isDarkMode: widget.isDarkMode,
      );
      return;
    }
    VibrationService.instance().buttonTap();
    setState(() => _points.add(pos));
    widget.onPointsChanged(sortedPoints);
  }

  /// 모든 핀 제거 (전체 해제)
  void _clearAll() {
    if (_points.isEmpty) return;
    VibrationService.instance().buttonTap();
    setState(() => _points.clear());
    widget.onPointsChanged(const []);
  }

  void _removePin(int index) {
    // 마커 탭 시 지도가 그 마커로 카메라를 옮기는 기본 동작이 있어,
    // 삭제 직전 카메라 위치를 다음 프레임에 즉시(moveCamera) 복원해 화면 튐을 막는다.
    final restore = _lastCamera;
    VibrationService.instance().buttonTap();
    setState(() => _points.removeAt(index));
    widget.onPointsChanged(sortedPoints);
    if (restore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.moveCamera(CameraUpdate.newCameraPosition(restore));
      });
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    for (var i = 0; i < _points.length; i++) {
      final p = _points[i];
      // 식별자를 인덱스가 아닌 위치 기반으로 — 중간 핀 삭제 시 뒤 핀들의
      // 인덱스가 당겨지며 SDK가 "id가 이동했다"고 오해해 마커가 미끄러지는
      // 현상을 막는다(핀 간 최소 간격 보장으로 위치는 항상 고유).
      final id = '${p.latitude}_${p.longitude}';

      // 투명 확장 히트박스 — 핀 근처를 눌러도 삭제되게 (터치 영역 확대).
      // 로드 전(null)엔 기본 마커가 잠깐 보이지 않도록 생략한다.
      if (_hitboxIcon != null) {
        markers.add(
          Marker(
            markerId: MarkerId('polygon_pin_hit_$id'),
            position: p,
            icon: _hitboxIcon!,
            anchor: PolygonPinMarkerFactory.hitboxAnchor,
            onTap: () => _removePin(i),
          ),
        );
      }

      // 보이는 핀
      markers.add(
        Marker(
          markerId: MarkerId('polygon_pin_$id'),
          position: p,
          icon: _pinIcon ?? BitmapDescriptor.defaultMarker,
          anchor: PolygonPinMarkerFactory.anchor,
          onTap: () => _removePin(i),
        ),
      );
    }
    return markers;
  }

  Set<Polygon> _buildPolygons() {
    final polygons = <Polygon>{};

    // 참조 다각형 (감옥 설정 시 플레이그라운드) — 파란 계열 고정
    final ref = widget.referencePolygon;
    if (ref != null && ref.length >= GameConfig.minPolygonVertexCount) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('reference_polygon'),
          points: ref,
          fillColor: AppColors.blue500Alpha20,
          strokeColor: AppColors.blue800,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }

    // 편집 중인 다각형 (꼭짓점 3개 이상일 때만)
    final sorted = sortedPoints;
    if (sorted.length >= GameConfig.minPolygonVertexCount) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('editing_polygon'),
          points: sorted,
          fillColor: widget.fillColor,
          strokeColor: widget.strokeColor,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    return polygons;
  }

  Future<void> _resetToCurrentLocation() async {
    final loc = await _currentLocation();
    if (loc == null || !mounted) return;
    _locationFocusTarget = loc;
    _isProgrammaticMove = true;
    setState(() => _isLocationFocused = true);
    await _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
  }

  /// 지도 높이를 고정한 채 상단 정렬한다.
  ///
  /// 부모가 tight 높이 제약을 주면(setup 페이지의 `IndexedStack(StackFit.expand)`)
  /// `SizedBox`는 들어온 제약이 우선이라 그대로 늘어난다. `Align`이 자식에게
  /// loose 제약을 넘겨 원형 위젯과 지도 크기를 동일하게 유지한다.
  Widget _fixedHeight(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(height: widget.mapHeight ?? 360.h, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _fixedHeight(const Center(child: CircularProgressIndicator()));
    }

    return _fixedHeight(
      Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCamera,
              zoom: _initialZoom,
            ),
            // 폴리곤이 화면 밖으로 벗어날 만큼 과도하게 축소되는 것을 막는다.
            // 핀 배치의 경계 반경으로 하한을 동적 계산 — 핀이 바뀌는 setState마다 갱신.
            minMaxZoomPreference: MinMaxZoomPreference(_minZoom, 20),
            style: widget.isDarkMode ? MapStyles.dark : null,
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            onCameraMove: (pos) {
              _lastCamera = pos;
              if (_isProgrammaticMove) return;
              _updateLocationFocus(pos);
            },
            onCameraIdle: () {
              _isProgrammaticMove = false;
              final camera = _lastCamera;
              if (camera != null) _updateLocationFocus(camera);
            },
            markers: _buildMarkers(),
            polygons: _buildPolygons(),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
              Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
          ),

          // 전체 해제 (우상단) — 핀이 있을 때만. 면적 칩과 동일하게 조건부로 두어
          // 쓸 수 없는 상태에서 지도를 가리지 않게 한다.
          // radius는 같은 오버레이의 내 위치 버튼·면적 칩(12.r)에 맞춘다.
          // ActionChip은 전달값에 .r을 적용하지 않으므로 12.r을 직접 넘긴다.
          if (_points.isNotEmpty)
            Positioned(
              top: AppSpacing.vertical16,
              right: AppSpacing.horizontal20,
              child: custom_chip.ActionChip(
                text: AppLocalizations.of(context).zoneClearAllPins,
                icon: Icons.close,
                onTap: _clearAll,
                backgroundColor: widget.pinColor,
                borderRadius: 12.r,
              ),
            ),

          // 내 위치 버튼 (좌하단)
          Positioned(
            bottom: AppSpacing.vertical16,
            left: AppSpacing.horizontal20,
            child: MyLocationButton(
              onPressed: _resetToCurrentLocation,
              isFocused: _isLocationFocused,
              containerSize: 40,
              iconSize: 24,
              borderRadius: 12,
              focusedColor: widget.locationButtonColor ?? widget.pinColor,
              unfocusedColor: AppColors.black400,
              backgroundColor: widget.isDarkMode ? AppColors.black : null,
              isDarkMode: widget.isDarkMode,
            ),
          ),

          // 면적 칩 (꼭짓점 3개 이상일 때만, 우하단)
          if (sortedPoints.length >= GameConfig.minPolygonVertexCount)
            Positioned(
              bottom: AppSpacing.vertical16,
              right: AppSpacing.horizontal20,
              child: InfoRadiusChip(
                prefix: AppLocalizations.of(context).zoneAreaLabel,
                value: formatAreaValue(
                  polygonAreaInSquareMeters(
                    sortByAngleAroundCentroid(_geoPoints),
                  ),
                ),
                backgroundColor:
                    widget.areaChipBackgroundColor ?? widget.pinColor,
                isDarkMode: widget.isDarkMode,
              ),
            ),
        ],
      ),
    );
  }
}
