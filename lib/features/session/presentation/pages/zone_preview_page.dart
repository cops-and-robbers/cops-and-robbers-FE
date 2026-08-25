import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/theme/role_theme_provider.dart';
import '../../../../core/widgets/buttons/my_location_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/map/models/circle_zone_shape.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../../../l10n/app_localizations.dart';

/// 구역 읽기전용 프리뷰 페이지
///
/// 플레이그라운드와 감옥 구역(원형/폴리곤)을 지도 위에 동시에 표시합니다.
/// 비방장 참가자가 현재 설정된 구역을 확인하는 용도입니다.
class ZonePreviewPage extends ConsumerStatefulWidget {
  const ZonePreviewPage({super.key, required this.area});

  /// 표시할 게임 구역 (원형/폴리곤 공통)
  final GameAreaEntity area;

  @override
  ConsumerState<ZonePreviewPage> createState() => _ZonePreviewPageState();
}

class _ZonePreviewPageState extends ConsumerState<ZonePreviewPage> {
  GoogleMapController? _mapController;
  bool _isCentered = true;
  bool _isProgrammaticMove = true;

  /// 플레이그라운드 중심 (카메라 타겟)
  LatLng get _playgroundCenter {
    final c = widget.area.playground.centroid;
    return LatLng(c.latitude, c.longitude);
  }

  /// 플레이그라운드 외접 반경 (줌 계산)
  double get _playgroundRadius => widget.area.playground.boundingRadiusInMeters;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// 구역 경계 원 오버레이 (원형 구역만)
  Set<Circle> _buildCircles() {
    final circles = <Circle>{};
    final pg = widget.area.playground;
    if (pg is CircleShape) {
      circles.addAll(
        CircleZoneShape(
          center: LatLng(pg.center.latitude, pg.center.longitude),
          radius: pg.radiusInMeters,
          fillColor: AppColors.blue500,
          strokeColor: AppColors.blue800,
          strokeWidth: 2,
          circleId: 'playground_preview',
        ).toMapOverlay(),
      );
    }
    final jail = widget.area.jail;
    if (jail is CircleShape) {
      circles.addAll(
        CircleZoneShape(
          center: LatLng(jail.center.latitude, jail.center.longitude),
          radius: jail.radiusInMeters,
          fillColor: AppColors.red500,
          strokeColor: AppColors.red800,
          strokeWidth: 2,
          circleId: 'jail_preview',
        ).toMapOverlay(),
      );
    }
    return circles;
  }

  /// 구역 경계 다각형 오버레이 (폴리곤 구역만)
  Set<Polygon> _buildPolygons() {
    final polygons = <Polygon>{};
    final pg = widget.area.playground;
    if (pg is PolygonShape) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('playground_preview'),
          points: [for (final p in pg.points) LatLng(p.latitude, p.longitude)],
          fillColor: AppColors.blue500Alpha20,
          strokeColor: AppColors.blue800,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    final jail = widget.area.jail;
    if (jail is PolygonShape) {
      polygons.add(
        Polygon(
          polygonId: const PolygonId('jail_preview'),
          points: [
            for (final p in jail.points) LatLng(p.latitude, p.longitude),
          ],
          fillColor: AppColors.red500Alpha20,
          strokeColor: AppColors.red800,
          strokeWidth: 2,
          consumeTapEvents: false,
        ),
      );
    }
    return polygons;
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

  /// 플레이그라운드 중심으로 카메라 이동
  Future<void> _moveToPlaygroundCenter() async {
    _isProgrammaticMove = true;
    setState(() => _isCentered = true);
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _playgroundCenter,
          zoom: _calculateZoom(_playgroundRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(roleThemeProvider);
    final bgColor = isDark ? AppColors.black900 : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.black;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppTopBar(
        title: l10n.pageZonePreviewTitle,
        isDarkMode: isDark,
        // 도둑 모드에서도 Pretendard를 유지하는 의도된 예외 (게임 설정과 한 쌍).
        useRobberFont: false,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: AppSpacing.vertical20),

            // 설명 텍스트
            Padding(
              padding: AppPadding.horizontal24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.zonePreviewSubtitle,
                  style: AppTextStyles.label16Medium.copyWith(color: textColor),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.vertical20),

            // 지도 영역 (남은 공간 전체)
            Expanded(
              child: Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _playgroundCenter,
                      zoom: _calculateZoom(_playgroundRadius),
                    ),
                    style: isDark ? MapStyles.dark : null,
                    minMaxZoomPreference: MinMaxZoomPreference(
                      _minZoomForRadius(_playgroundRadius),
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
                    circles: _buildCircles(),
                    polygons: _buildPolygons(),
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

                  // 구역 중심 버튼 (우측 하단)
                  Positioned(
                    bottom: 55.h,
                    right: 20.w,
                    child: MyLocationButton(
                      onPressed: _moveToPlaygroundCenter,
                      isFocused: _isCentered,
                      containerSize: 56,
                      iconSize: 32,
                      focusedColor: isDark ? AppColors.green : AppColors.blue,
                      unfocusedColor: isDark
                          ? AppColors.green800
                          : AppColors.blue500,
                      backgroundColor: isDark ? AppColors.black : null,
                      isDarkMode: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
