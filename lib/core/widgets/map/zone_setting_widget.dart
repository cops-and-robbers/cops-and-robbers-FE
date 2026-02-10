import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../services/location/device_location_service.dart';
import '../chips/info_radius_chip.dart';
import '../inputs/app_slider.dart';
import 'models/circle_zone_shape.dart';
import 'models/zone_shape.dart';

/// 구역 설정 위젯 (지도 + 원형 오버레이 + 슬라이더)
/// Zone setting widget (map + circle overlay + slider)
///
/// **기능**:
/// - Google Maps 기반 지도 표시
/// - 드래그 가능한 중심점 마커
/// - Circle 기반 구역 시각화
/// - AppSlider로 반경 실시간 조절
///
/// **사용 예시**:
/// ```dart
/// ZoneSettingWidget(
///   initialRadius: 500,
///   minRadius: 100,
///   maxRadius: 1000,
///   onZoneChanged: (center, radius) {
///     print('구역 업데이트: $center, ${radius}m');
///   },
/// )
/// ```
class ZoneSettingWidget extends StatefulWidget {
  const ZoneSettingWidget({
    super.key,
    required this.initialRadius,
    required this.minRadius,
    required this.maxRadius,
    required this.onZoneChanged,
    this.centerColor,
    this.borderColor,
    this.fillColor,
    this.inactiveTrackColor,
    this.radiusChipBackgroundColor,
    this.locationButtonColor,
    this.mapHeight,
    this.initialCenter,
  });

  /// 초기 반경 (미터)
  /// Initial radius in meters
  final double initialRadius;

  /// 최소 반경 (미터)
  /// Minimum radius in meters
  final double minRadius;

  /// 최대 반경 (미터)
  /// Maximum radius in meters
  final double maxRadius;

  /// 구역 변경 콜백
  /// Zone changed callback
  final void Function(LatLng center, double radius) onZoneChanged;

  /// 중심점 마커 색상 (기본: AppColors.blue)
  /// Center marker color (default: AppColors.blue)
  final Color? centerColor;

  /// 외곽선 색상 (기본: AppColors.blue800)
  /// Border color (default: AppColors.blue800)
  final Color? borderColor;

  /// 중간 영역 색상 (기본: AppColors.blue500)
  /// Fill color (default: AppColors.blue500)
  final Color? fillColor;

  /// 슬라이더 비활성 트랙 색상 (기본: AppColors.blue100)
  /// Slider inactive track color (default: AppColors.blue100)
  final Color? inactiveTrackColor;

  /// 반경 인디케이터 배경색 (기본: centerColor)
  /// Radius indicator background color (default: centerColor)
  final Color? radiusChipBackgroundColor;

  /// 내 위치 버튼 아이콘 색상 (기본: AppColors.blue)
  /// My location button icon color (default: AppColors.blue)
  final Color? locationButtonColor;

  /// 지도 높이 (기본: 360)
  /// Map height (default: 360)
  final double? mapHeight;

  /// 초기 중심점 (null이면 현재 위치)
  /// Initial center (null = current location)
  final LatLng? initialCenter;

  @override
  State<ZoneSettingWidget> createState() => ZoneSettingWidgetState();
}

class ZoneSettingWidgetState extends State<ZoneSettingWidget> {
  GoogleMapController? _mapController;
  late LatLng _currentCenter;
  late double _currentRadius;
  late ZoneShape _shape;
  bool _isInitialized = false;

  // Fallback 위치 (어린이대공원)
  static const LatLng _fallbackLocation = LatLng(37.5480, 127.0810);

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;
    _initializeZone();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 구역 초기화 (중심점 + Shape 생성)
  /// Initialize zone (center + shape creation)
  Future<void> _initializeZone() async {
    debugPrint('🗺️ ZoneSettingWidget: 구역 초기화 시작');

    // 위치 권한은 이미 main.dart에서 LocationPermissionService.ensurePermission()으로 요청됨
    // myLocationEnabled: true는 권한이 있으면 자동으로 현재 위치 표시

    // 1. 초기 중심점 설정
    _currentCenter =
        widget.initialCenter ??
        await _getCurrentLocation() ??
        _fallbackLocation;

    debugPrint(
      '📍 ZoneSettingWidget: 중심점 = ${_currentCenter.latitude}, ${_currentCenter.longitude}',
    );

    // 2. Shape 생성
    _shape = _createShape();
    _shape.setCenter(_currentCenter);
    _shape.setRadius(_currentRadius);

    // 3. 위젯이 여전히 마운트되어 있을 때만 상태 업데이트
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      // 초기화 완료 시 부모 위젯에 초기 중심점과 반경 알림
      // ⚠️ 빌드 중 setState 방지: 다음 프레임에서 콜백 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onZoneChanged(_currentCenter, _currentRadius);
        }
      });

      debugPrint('✅ ZoneSettingWidget: 구역 초기화 완료');
      debugPrint(
        '📤 초기 구역 정보 전달: center=$_currentCenter, radius=$_currentRadius',
      );
    } else {
      debugPrint('⚠️ ZoneSettingWidget: 위젯이 dispose되어 초기화 중단');
    }
  }

  /// Shape 생성 (Factory 패턴)
  /// Create shape using factory pattern
  ZoneShape _createShape() {
    final fillColor = widget.fillColor ?? AppColors.blue500;
    final strokeColor = widget.borderColor ?? AppColors.blue800;

    return CircleZoneShape(
      center: _currentCenter,
      radius: _currentRadius,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: 2,
    );
  }

  /// 현재 위치 조회 (DeviceLocationService 사용)
  /// Get current location using DeviceLocationService
  Future<LatLng?> _getCurrentLocation() async {
    try {
      final pos = await DeviceLocationService.getCurrentPosition();
      if (pos == null) {
        debugPrint('⚠️ ZoneSettingWidget: 현재 위치 조회 실패 → fallback 사용');
        return null;
      }
      return LatLng(pos.latitude, pos.longitude);
    } catch (e, stack) {
      debugPrint('❌ ZoneSettingWidget: 현재 위치 조회 에러 - $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return SizedBox(
        height: widget.mapHeight ?? 360.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        // 1. Google Map with info overlay
        SizedBox(
          height: widget.mapHeight ?? 360.h,
          child: Stack(
            children: [
              // Google Map
              _buildGoogleMap(),

              // 내 위치 버튼 (좌측하단 16, 20)
              Positioned(
                bottom: 16.h,
                left: 20.w,
                child: _buildMyLocationButton(),
              ),

              // Info card (우측하단 16, 20)
              Positioned(
                bottom: 16.h,
                right: 20.w,
                child: _buildRadiusIndicator(),
              ),
            ],
          ),
        ),

        // 2. 공간
        SizedBox(height: AppSpacing.vertical20),

        // 3. 반경 슬라이더
        Padding(padding: AppPadding.horizontal20, child: _buildRadiusSlider()),
      ],
    );
  }

  /// Google Map 위젯 (화면 중앙 고정 오버레이 포함)
  /// Google Map widget with center-fixed overlay
  Widget _buildGoogleMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final mapHeight = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Google Map (Circle 오버레이)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentCenter,
                zoom: _calculateZoom(_currentRadius),
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                debugPrint('✅ ZoneSettingWidget: Google Map 생성 완료');
              },

              // 지도 이동 완료 시 화면 중앙 좌표를 LatLng로 변환하여 업데이트
              onCameraIdle: () {
                _updateCenterFromScreenCenter();
              },

              // Circle 오버레이 (지도와 함께 이동)
              circles: _shape.toMapOverlay(),

              // 마커 제거 (커스텀 원으로 대체)
              markers: const {},

              // 제스처 인식기 설정 (기본 제스처 사용)
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
              },

              // 사용자 현재 위치 표시 (기본 스타일)
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
            ),

            // 2. 화면 중앙 고정 중심점 오버레이 (20x20)
            Positioned(
              left: (mapWidth / 2) - 10, // 화면 중앙 - 반지름
              top: (mapHeight / 2) - 10,
              child: _buildZoneCenterCircle(),
            ),
          ],
        );
      },
    );
  }

  /// 반경 슬라이더 위젯
  /// Radius slider widget
  Widget _buildRadiusSlider() {
    // divisions 계산: 10m 단위로 증가
    final divisions = ((widget.maxRadius - widget.minRadius) / 10).round();

    return AppSlider(
      label: '반경',
      value: _currentRadius,
      min: widget.minRadius,
      max: widget.maxRadius,
      unit: _currentRadius >= 1000 ? 'km' : 'm',
      divisions: divisions,
      valueFormatter: (value) {
        if (value >= 1000) {
          return (value / 1000).toStringAsFixed(2);
        } else {
          return value.toInt().toString();
        }
      },
      showContainer: false,
      activeTrackColor: widget.borderColor ?? AppColors.blue800,
      thumbColor: widget.centerColor ?? AppColors.blue,
      inactiveTrackColor: widget.inactiveTrackColor ?? AppColors.blue100,
      onChanged: _onRadiusChanged,
    );
  }

  /// 반경 표시 인디케이터
  /// Radius indicator widget
  Widget _buildRadiusIndicator() {
    final String displayValue;
    if (_currentRadius >= 1000) {
      final radiusInKm = (_currentRadius / 1000).toStringAsFixed(2);
      displayValue = '${radiusInKm}km';
    } else {
      displayValue = '${_currentRadius.toInt()}m';
    }

    return InfoRadiusChip(
      prefix: '반경',
      value: displayValue,
      backgroundColor:
          widget.radiusChipBackgroundColor ??
          widget.centerColor ??
          AppColors.blue,
    );
  }

  /// 슬라이더 Thumb 스타일의 구역 중심 원 (20x20, 화면 중앙 고정)
  /// Zone center circle widget (slider thumb style, fixed at screen center)
  Widget _buildZoneCenterCircle() {
    return IgnorePointer(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: widget.centerColor ?? AppColors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// 내 위치 버튼 (40x40 컨테이너 + 24x24 아이콘)
  /// My location button (40x40 container + 24x24 icon)
  Widget _buildMyLocationButton() {
    return GestureDetector(
      onTap: resetToCurrentLocation,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
        ),
        child: Icon(
          Icons.my_location,
          size: 24.w,
          color: widget.locationButtonColor ?? AppColors.blue,
        ),
      ),
    );
  }

  /// 반경 변경 처리
  /// Handle radius change
  void _onRadiusChanged(double newRadius) {
    setState(() {
      _currentRadius = newRadius;
      _shape.setRadius(newRadius);
    });

    // 카메라를 구역 중심으로 이동하면서 zoom 조정 (원형이 잘 보이도록)
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentCenter, zoom: _calculateZoom(newRadius)),
      ),
    );

    // 부모 위젯에 변경 알림
    widget.onZoneChanged(_currentCenter, _currentRadius);

    debugPrint('📏 구역 반경 변경: ${newRadius.toInt()}m');
  }

  /// 반경에 따른 적절한 zoom 레벨 계산
  /// Calculate appropriate zoom level based on radius
  double _calculateZoom(double radiusMeters) {
    if (radiusMeters <= 100) return 17;
    if (radiusMeters <= 300) return 16;
    if (radiusMeters <= 500) return 15;
    if (radiusMeters <= 1000) return 14;
    return 13;
  }

  /// 화면 중앙 좌표를 LatLng로 변환하여 중심점 업데이트
  /// Update center by converting screen center to LatLng
  Future<void> _updateCenterFromScreenCenter() async {
    if (_mapController == null || !mounted) return;

    try {
      // 현재 카메라가 보는 영역의 중심이 화면 중앙의 LatLng
      final visibleRegion = await _mapController!.getVisibleRegion();
      final centerLat =
          (visibleRegion.northeast.latitude +
              visibleRegion.southwest.latitude) /
          2;
      final centerLng =
          (visibleRegion.northeast.longitude +
              visibleRegion.southwest.longitude) /
          2;
      final screenCenterLatLng = LatLng(centerLat, centerLng);

      setState(() {
        _currentCenter = screenCenterLatLng;
        _shape.setCenter(screenCenterLatLng);
      });

      // 부모 위젯에 변경 알림
      widget.onZoneChanged(_currentCenter, _currentRadius);

      debugPrint('🗺️ [CAMERA IDLE] 중심점 업데이트: $screenCenterLatLng');
    } catch (e) {
      debugPrint('❌ 화면 중앙 좌표 변환 실패: $e');
    }
  }

  /// 구역 중심을 현재 위치로 이동 (Public API)
  /// Reset zone center to current location (Public API)
  Future<void> resetToCurrentLocation() async {
    debugPrint('📍 구역 중심을 현재 위치로 이동 시작');

    try {
      // 현재 위치 조회
      final currentLocation = await _getCurrentLocation();

      if (currentLocation == null) {
        debugPrint('⚠️ 현재 위치를 가져올 수 없습니다');
        return;
      }

      // 위젯이 마운트되어 있을 때만 중심 이동
      if (mounted) {
        // 구역 중심 업데이트
        setState(() {
          _currentCenter = currentLocation;
          _shape.setCenter(currentLocation);
        });

        // 카메라 애니메이션으로 이동
        await _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: _calculateZoom(_currentRadius),
            ),
          ),
        );

        // 부모 위젯에 변경 알림
        widget.onZoneChanged(_currentCenter, _currentRadius);

        debugPrint('✅ 구역 중심 이동 완료: $currentLocation');
      } else {
        debugPrint('⚠️ 위젯이 dispose되어 중심 이동 중단');
      }
    } catch (e, stack) {
      debugPrint('❌ 구역 중심 이동 실패: $e');
      debugPrint('Stack: $stack');
    }
  }
}
