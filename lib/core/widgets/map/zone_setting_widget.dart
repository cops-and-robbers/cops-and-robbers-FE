import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// 지도 높이 (기본: 360)
  /// Map height (default: 360)
  final double? mapHeight;

  /// 초기 중심점 (null이면 현재 위치)
  /// Initial center (null = current location)
  final LatLng? initialCenter;

  @override
  State<ZoneSettingWidget> createState() => _ZoneSettingWidgetState();
}

class _ZoneSettingWidgetState extends State<ZoneSettingWidget> {
  GoogleMapController? _mapController;
  late LatLng _currentCenter;
  late double _currentRadius;
  late ZoneShape _shape;
  bool _isInitialized = false;

  /// 드래그 모드 활성화 여부
  /// Drag mode active flag
  bool _isDragging = false;

  /// 구역 중심의 화면 좌표 (실시간 업데이트)
  /// Center screen position (real-time updated)
  Offset _centerScreenPosition = Offset.zero;

  /// 드래그 시작 시 터치 위치와 원 중심 사이의 오프셋
  /// Offset between touch position and circle center at drag start
  Offset _dragOffset = Offset.zero;

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

    setState(() {
      _isInitialized = true;
    });

    // 초기화 완료 시 부모 위젯에 초기 중심점과 반경 알림
    widget.onZoneChanged(_currentCenter, _currentRadius);

    debugPrint('✅ ZoneSettingWidget: 구역 초기화 완료');
    debugPrint(
      '📤 초기 구역 정보 전달: center=$_currentCenter, radius=$_currentRadius',
    );
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

              // Info card (우측하단 16, 16)
              Positioned(
                bottom: 16.h,
                right: 16.w,
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

  /// Google Map 위젯 (커스텀 원 오버레이 포함)
  /// Google Map widget with custom circle overlay
  Widget _buildGoogleMap() {
    return Stack(
      children: [
        // 1. Google Map (Circle 오버레이, 마커 제거)
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentCenter,
            zoom: _calculateZoom(_currentRadius),
          ),
          onMapCreated: (controller) async {
            _mapController = controller;
            debugPrint('✅ ZoneSettingWidget: Google Map 생성 완료');

            // 초기 화면 좌표 계산
            await _updateCenterScreenPosition();
          },

          // 지도 카메라 이동 시 원 위치 실시간 업데이트
          onCameraMove: (CameraPosition position) {
            if (_isDragging) return; // 드래그 중에는 동기화 스킵
            _updateCenterScreenPosition();
          },

          // 지도 카메라 이동 완료 시 최종 위치 확정
          onCameraIdle: () {
            if (!_isDragging) {
              _updateCenterScreenPosition();
            }
          },

          // Circle 오버레이
          circles: _shape.toMapOverlay(),

          // 마커 제거 (커스텀 원으로 대체)
          markers: const {},

          // 제스처 인식기 설정 (기본 제스처만 허용)
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

        // 2. 커스텀 구역 중심 원 오버레이 (20x20)
        if (_centerScreenPosition != Offset.zero)
          Positioned(
            left: _centerScreenPosition.dx - 10, // 반지름만큼 빼서 중앙 정렬
            top: _centerScreenPosition.dy - 10,
            child: _buildZoneCenterCircle(),
          ),

        // 3. 전체 원 영역 제스처 감지기 (투명)
        if (_centerScreenPosition != Offset.zero)
          Positioned(
            left: _centerScreenPosition.dx - _getCircleRadiusInPixels(),
            top: _centerScreenPosition.dy - _getCircleRadiusInPixels(),
            child: _buildCircleGestureDetector(),
          ),
      ],
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

  /// 슬라이더 Thumb 스타일의 구역 중심 원 (20x20, 시각적 표시만)
  /// Zone center circle widget (slider thumb style, visual only)
  Widget _buildZoneCenterCircle() {
    return IgnorePointer(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: widget.centerColor ?? AppColors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  /// 전체 원 영역 제스처 감지기 (투명)
  /// Full circle area gesture detector (transparent)
  Widget _buildCircleGestureDetector() {
    final circleRadius = _getCircleRadiusInPixels();
    final circleDiameter = circleRadius * 2;

    return GestureDetector(
      onLongPressStart: (details) {
        // 햅틱 피드백 (진동)
        HapticFeedback.mediumImpact();

        setState(() => _isDragging = true);

        // 터치 위치와 원 중심 사이의 오프셋 저장
        _dragOffset = details.globalPosition - _centerScreenPosition;

        debugPrint('🎯 [LONG PRESS START] 드래그 모드 활성화');
        debugPrint('   터치 위치: ${details.globalPosition}');
        debugPrint('   원 중심: $_centerScreenPosition');
        debugPrint('   오프셋: $_dragOffset');
      },
      onLongPressMoveUpdate: (details) async {
        if (!_isDragging) return;

        // 터치 위치에서 초기 오프셋을 빼서 실제 원 중심 위치 계산
        final adjustedPosition = details.globalPosition - _dragOffset;

        // 화면 좌표 → 지리 좌표 변환
        final newLatLng = await _screenPositionToLatLng(adjustedPosition);
        if (newLatLng != null && mounted) {
          setState(() {
            _currentCenter = newLatLng;
            _shape.setCenter(newLatLng);
          });

          // 화면 좌표도 즉시 업데이트
          await _updateCenterScreenPosition();

          // 부모 위젯에 변경 알림
          widget.onZoneChanged(_currentCenter, _currentRadius);

          debugPrint('🎯 [DRAGGING] 구역 이동 중: $newLatLng');
        }
      },
      onLongPressEnd: (details) {
        setState(() {
          _isDragging = false;
          _dragOffset = Offset.zero;
        });
        debugPrint(
          '🎯 [LONG PRESS END] 드래그 완료: ${_currentCenter.latitude}, ${_currentCenter.longitude}',
        );
      },
      child: Container(
        width: circleDiameter,
        height: circleDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // 디버그용: 투명 컨테이너 (터치 영역 확인하려면 주석 해제)
          // color: Colors.red.withValues(alpha: 0.1),
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
        CameraPosition(
          target: _currentCenter,
          zoom: _calculateZoom(newRadius),
        ),
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

  /// 지리 좌표(LatLng) → 화면 좌표(Offset) 변환
  /// Convert geographic coordinate to screen coordinate
  Future<Offset?> _latLngToScreenPosition(LatLng latLng) async {
    if (_mapController == null) {
      debugPrint('⚠️ MapController가 아직 초기화되지 않음');
      return null;
    }

    try {
      final screenCoordinate = await _mapController!.getScreenCoordinate(
        latLng,
      );
      return Offset(
        screenCoordinate.x.toDouble(),
        screenCoordinate.y.toDouble(),
      );
    } catch (e) {
      debugPrint('⚠️ 좌표 변환 실패 (LatLng → Screen): $e');
      return null;
    }
  }

  /// 화면 좌표(Offset) → 지리 좌표(LatLng) 변환
  /// Convert screen coordinate to geographic coordinate
  Future<LatLng?> _screenPositionToLatLng(Offset offset) async {
    if (_mapController == null) {
      debugPrint('⚠️ MapController가 아직 초기화되지 않음');
      return null;
    }

    try {
      final screenCoordinate = ScreenCoordinate(
        x: offset.dx.toInt(),
        y: offset.dy.toInt(),
      );
      return await _mapController!.getLatLng(screenCoordinate);
    } catch (e) {
      debugPrint('⚠️ 좌표 변환 실패 (Screen → LatLng): $e');
      return null;
    }
  }

  /// 중심점의 화면 좌표를 실시간으로 업데이트
  /// Update center screen position in real-time
  Future<void> _updateCenterScreenPosition() async {
    final newPosition = await _latLngToScreenPosition(_currentCenter);
    if (newPosition != null && mounted) {
      setState(() {
        _centerScreenPosition = newPosition;
      });
    }
  }

  /// 원의 화면상 반지름(픽셀) 계산
  /// Calculate circle radius in screen pixels
  double _getCircleRadiusInPixels() {
    // 줌 레벨에 따른 대략적인 픽셀 계산
    // 정확한 계산을 위해서는 지도의 현재 줌 레벨과 위도를 고려해야 하지만
    // 여기서는 현재 반경에 비례하는 충분히 큰 영역을 제공
    final zoom = _calculateZoom(_currentRadius);

    // 줌 레벨별 미터당 픽셀 비율 (대략적)
    final metersPerPixel = 156543.03392 * (1 / (1 << zoom.toInt())) / 2;

    // 원의 반지름을 픽셀로 변환
    final radiusInPixels = _currentRadius / metersPerPixel;

    // 최소 50px, 최대 200px로 제한하여 제스처 감지 영역 확보
    return radiusInPixels.clamp(50.0, 200.0);
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

      // 구역 중심 업데이트
      setState(() {
        _currentCenter = currentLocation;
        _shape.setCenter(currentLocation);
      });

      // 화면 좌표 업데이트
      await _updateCenterScreenPosition();

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
    } catch (e, stack) {
      debugPrint('❌ 구역 중심 이동 실패: $e');
      debugPrint('Stack: $stack');
    }
  }
}
