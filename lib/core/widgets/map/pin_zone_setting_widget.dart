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
import '../../services/location/device_location_service.dart';
import '../buttons/my_location_button.dart';
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

  /// 미리보기 다각형 채움 색상 (alpha 0.2 적용)
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
  GoogleMapController? _mapController;
  bool _isLocationFocused = true;
  bool _isInitialized = false;

  // Fallback 위치 (어린이대공원)
  static const LatLng _fallbackLocation = LatLng(37.5480, 127.0810);
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
    // 마커 아이콘 로드
    _pinIcon = await PolygonPinMarkerFactory.create(color: widget.pinColor);

    // 초기 카메라: 기존 핀 있으면 그 중심, 없으면 현재 위치 → fallback
    if (_points.isNotEmpty) {
      _initialCamera = _centroidOf(_points);
    } else {
      _initialCamera = await _currentLocation() ?? _fallbackLocation;
    }

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
    setState(() => _points.add(pos));
    widget.onPointsChanged(sortedPoints);
  }

  void _removePin(int index) {
    setState(() => _points.removeAt(index));
    widget.onPointsChanged(sortedPoints);
  }

  Set<Marker> _buildMarkers() => {
    for (var i = 0; i < _points.length; i++)
      Marker(
        markerId: MarkerId('polygon_pin_$i'),
        position: _points[i],
        icon: _pinIcon ?? BitmapDescriptor.defaultMarker,
        anchor: PolygonPinMarkerFactory.anchor,
        onTap: () => _removePin(i),
      ),
  };

  Set<Polygon> _buildPolygons() {
    final polygons = <Polygon>{};

    // 참조 다각형 (감옥 설정 시 플레이그라운드) — 파란 계열 고정
    final ref = widget.referencePolygon;
    if (ref != null && ref.length >= GameConfig.minPolygonVertexCount) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('reference_polygon'),
          points: ref,
          fillColor: AppColors.blue500.withValues(alpha: 0.2),
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
          fillColor: widget.fillColor.withValues(alpha: 0.2),
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
    setState(() => _isLocationFocused = true);
    await _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        height: widget.mapHeight ?? 360.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: widget.mapHeight ?? 360.h,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCamera,
              zoom: 15,
            ),
            style: widget.isDarkMode ? MapStyles.dark : null,
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            onCameraMove: (_) {
              if (_isLocationFocused) {
                setState(() => _isLocationFocused = false);
              }
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

          // 내 위치 버튼 (좌하단)
          Positioned(
            bottom: 16.h,
            left: 20.w,
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
              bottom: 16.h,
              right: 20.w,
              child: InfoRadiusChip(
                prefix: AppLocalizations.of(context).zoneAreaLabel,
                value:
                    '${polygonAreaInSquareMeters(sortByAngleAroundCentroid(_geoPoints)).round()}m²',
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
