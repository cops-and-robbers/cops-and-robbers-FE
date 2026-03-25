import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/chips/info_radius_chip.dart';
import '../../../../core/widgets/map/models/circle_zone_shape.dart';

/// 구역 읽기전용 프리뷰 페이지
///
/// 플레이그라운드와 감옥 구역을 지도 위에 동시에 표시합니다.
/// 비방장 참가자가 현재 설정된 구역을 확인하는 용도입니다.
class ZonePreviewPage extends StatefulWidget {
  const ZonePreviewPage({
    super.key,
    required this.playgroundCenter,
    required this.playgroundRadius,
    required this.jailCenter,
    required this.jailRadius,
  });

  /// 플레이그라운드 중심 좌표
  final LatLng playgroundCenter;

  /// 플레이그라운드 반경 (미터)
  final double playgroundRadius;

  /// 감옥 중심 좌표
  final LatLng jailCenter;

  /// 감옥 반경 (미터)
  final double jailRadius;

  @override
  State<ZonePreviewPage> createState() => _ZonePreviewPageState();
}

class _ZonePreviewPageState extends State<ZonePreviewPage> {
  GoogleMapController? _mapController;
  bool _isCentered = true;
  bool _isProgrammaticMove = true;

  late final CircleZoneShape _playgroundZone;
  late final CircleZoneShape _jailZone;

  @override
  void initState() {
    super.initState();
    _playgroundZone = CircleZoneShape(
      center: widget.playgroundCenter,
      radius: widget.playgroundRadius,
      fillColor: AppColors.blue500,
      strokeColor: AppColors.blue800,
      strokeWidth: 2,
      circleId: 'playground_preview',
    );
    _jailZone = CircleZoneShape(
      center: widget.jailCenter,
      radius: widget.jailRadius,
      fillColor: AppColors.red500,
      strokeColor: AppColors.red800,
      strokeWidth: 2,
      circleId: 'jail_preview',
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 반경에 따른 적절한 zoom 레벨 계산
  double _calculateZoom(double radiusMeters) {
    if (radiusMeters <= 100) return 17;
    if (radiusMeters <= 300) return 16;
    if (radiusMeters <= 500) return 15;
    if (radiusMeters <= 1000) return 14;
    return 13;
  }

  /// 플레이그라운드 반경 기준 최소 줌 레벨 (축소 잠금, 읽기전용이므로 타이트하게)
  double _minZoomForRadius(double radiusInMeters) => switch (radiusInMeters) {
    <= 200 => 16.0,
    <= 500 => 15.0,
    <= 1000 => 14.0,
    _ => 13.0,
  };

  /// 반경을 표시 문자열로 변환
  String _formatRadius(double radius) {
    if (radius >= 1000) {
      return '${(radius / 1000).toStringAsFixed(2)}km';
    }
    return '${radius.toInt()}m';
  }

  /// 플레이그라운드 중심으로 카메라 이동
  Future<void> _moveToPlaygroundCenter() async {
    _isProgrammaticMove = true;
    setState(() => _isCentered = true);
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: widget.playgroundCenter,
          zoom: _calculateZoom(widget.playgroundRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          '구역 확인',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black800),
        centerTitle: true,
        leading: PreviousButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: AppSpacing.vertical20),

            // 설명 텍스트
            Padding(
              padding: AppPadding.horizontal24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '현재 설정된 게임 구역이에요',
                  style: AppTextStyles.label16Medium.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.vertical20),

            // 지도 영역
            SizedBox(
              height: 360.h,
              child: Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.playgroundCenter,
                      zoom: _calculateZoom(widget.playgroundRadius),
                    ),
                    minMaxZoomPreference: MinMaxZoomPreference(
                      _minZoomForRadius(widget.playgroundRadius),
                      null,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onCameraMove: (_) {
                      if (_isProgrammaticMove) return;
                      if (_isCentered) {
                        setState(() => _isCentered = false);
                      }
                    },
                    onCameraIdle: () {
                      _isProgrammaticMove = false;
                    },
                    circles: {
                      ..._playgroundZone.toMapOverlay(),
                      ..._jailZone.toMapOverlay(),
                    },
                    markers: const {},
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<PanGestureRecognizer>(
                        () => PanGestureRecognizer(),
                      ),
                      Factory<ScaleGestureRecognizer>(
                        () => ScaleGestureRecognizer(),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                  ),

                  // 구역 중심 버튼 (좌측 하단)
                  Positioned(
                    bottom: 16.h,
                    left: 20.w,
                    child: MyLocationButton(
                      onPressed: _moveToPlaygroundCenter,
                      isFocused: _isCentered,
                      containerSize: 40,
                      iconSize: 24,
                      focusedColor: AppColors.blue,
                      unfocusedColor: AppColors.blue500,
                    ),
                  ),

                  // 플레이그라운드 반경 칩 (우측, 감옥 칩 위)
                  Positioned(
                    bottom: 16.h + 40.h + 8.h, // MyLocationButton 위에 간격 8px
                    right: 20.w,
                    child: InfoRadiusChip(
                      prefix: '구역',
                      value: _formatRadius(widget.playgroundRadius),
                      backgroundColor: AppColors.blue,
                    ),
                  ),

                  // 감옥 반경 칩 (우측 하단)
                  Positioned(
                    bottom: 16.h,
                    right: 20.w,
                    child: InfoRadiusChip(
                      prefix: '감옥',
                      value: _formatRadius(widget.jailRadius),
                      backgroundColor: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.vertical20),
          ],
        ),
      ),
    );
  }
}
