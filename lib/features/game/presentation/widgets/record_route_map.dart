import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/game_area_model.dart';

/// 경로 전체를 담는 카메라 경계.
///
/// 점이 2개 미만이거나 모든 점이 같은 좌표면 null — 남서/북동이 같으면
/// `newLatLngBounds`가 카메라를 잡지 못하므로 호출 측이 고정 줌으로 폴백한다.
LatLngBounds? routeBounds(List<LatLngModel> route) {
  if (route.length < 2) return null;

  var minLat = route.first.latitude;
  var maxLat = route.first.latitude;
  var minLng = route.first.longitude;
  var maxLng = route.first.longitude;

  for (final p in route) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }

  if (minLat == maxLat && minLng == maxLng) return null;

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

/// 결과 카드 전용 읽기 전용 경로 지도.
///
/// 인게임 [GoogleMapView]는 마커 애니메이션·구역·핑까지 얹은 큰 위젯이라 재사용하지 않고,
/// 내 궤적만 그리는 얇은 지도를 따로 둔다. 모든 제스처를 끈 정적 표시용이다.
class RecordRouteMap extends StatefulWidget {
  const RecordRouteMap({
    super.key,
    required this.route,
    required this.markerPoints,
    required this.lineColor,
    required this.isDarkMode,
  });

  /// 내 이동 경로 (누적 순서)
  final List<LatLngModel> route;

  /// 강조 지점 — 경찰은 체포한 곳, 도둑은 잡힌 곳
  final List<LatLngModel> markerPoints;

  /// 폴리라인 색 — 경찰 blue / 도둑 green
  final Color lineColor;

  final bool isDarkMode;

  @override
  State<RecordRouteMap> createState() => _RecordRouteMapState();
}

class _RecordRouteMapState extends State<RecordRouteMap> {
  GoogleMapController? _controller;

  /// 경로가 비었을 때의 폴백 중심 (인게임 GoogleMapView와 동일 좌표)
  static const LatLng _fallbackCenter = LatLng(37.5480, 127.0810);

  /// 경계 여백(px) — 궤적이 지도 가장자리에 붙지 않게
  static const double _boundsPadding = 24;

  /// 카드 안 지도 높이
  static const double _mapHeight = 172;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// 지도 생성 직후 경로 전체가 보이도록 카메라를 맞춘다.
  ///
  /// onMapCreated 시점에는 아직 지도 크기가 확정되지 않아 newLatLngBounds가
  /// "map size should not be null"로 실패할 수 있다. 한 박자 뒤로 미뤄 회피한다.
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;

    final bounds = routeBounds(widget.route);
    if (bounds == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    await controller.moveCamera(
      CameraUpdate.newLatLngBounds(bounds, _boundsPadding),
    );
  }

  LatLng get _initialTarget {
    if (widget.route.isEmpty) return _fallbackCenter;
    final p = widget.route.first;
    return LatLng(p.latitude, p.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDarkMode ? AppColors.black900 : AppColors.black100;

    // 경로가 비면(권한 거부·실내 등) 지도를 띄우지 않고 안내 문구만 보여준다.
    if (widget.route.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Container(
        height: _mapHeight.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.large),
        child: Text(
          l10n.labelNoRoute,
          style: AppTextStyles.tag_12.copyWith(
            color: widget.isDarkMode ? AppColors.black400 : AppColors.black600,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: AppRadius.large,
      child: SizedBox(
        height: _mapHeight.h,
        child: ColoredBox(
          color: bg,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialTarget,
              zoom: 16,
            ),
            style: widget.isDarkMode ? MapStyles.dark : null,
            onMapCreated: _onMapCreated,
            polylines: {
              Polyline(
                polylineId: const PolylineId('my_route'),
                points: [
                  for (final p in widget.route) LatLng(p.latitude, p.longitude),
                ],
                color: widget.lineColor,
                width: 5,
              ),
            },
            markers: {
              for (var i = 0; i < widget.markerPoints.length; i++)
                Marker(
                  markerId: MarkerId('highlight_$i'),
                  position: LatLng(
                    widget.markerPoints[i].latitude,
                    widget.markerPoints[i].longitude,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
            },
            // 정적 표시용 — 모든 조작과 오버레이를 끈다.
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),
        ),
      ),
    );
  }
}
