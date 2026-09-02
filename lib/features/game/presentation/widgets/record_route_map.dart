import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/location/device_location_service.dart';
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
  State<RecordRouteMap> createState() => RecordRouteMapState();
}

/// 공유 캡처를 위해 부모가 [prepareForCapture]/[endCapture]를 호출할 수 있도록
/// 상태를 공개한다 ([GlobalKey]로 접근 — FormState 패턴).
class RecordRouteMapState extends State<RecordRouteMap> {
  GoogleMapController? _controller;

  /// 캡처 중 지도 위에 덮을 네이티브 스냅샷.
  ///
  /// GoogleMap은 OS가 합성하는 플랫폼 뷰라 RepaintBoundary.toImage에
  /// 절대 찍히지 않는다. 캡처 직전 takeSnapshot으로 뜬 PNG를 Flutter
  /// Image로 겹쳐 캡처에 포함시킨다.
  ImageProvider? _snapshot;

  /// 경로가 비었을 때의 폴백 중심 (인게임 GoogleMapView와 동일 좌표)

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
    try {
      await controller.moveCamera(
        CameraUpdate.newLatLngBounds(bounds, _boundsPadding),
      );
    } catch (e) {
      // mounted 체크와 실제 호출 사이 위젯이 dispose되면 이미 정리된 컨트롤러를
      // 건드리게 될 수 있다. 카메라 위치는 화면 표시용일 뿐이라 실패해도
      // 초기 카메라(_initialTarget)로 남겨두고 무시한다.
      debugPrint('[RecordRouteMap] 카메라 이동 실패: $e');
    }
  }

  LatLng get _initialTarget {
    if (widget.route.isEmpty) return DeviceLocationService.fallbackLocation;
    final p = widget.route.first;
    return LatLng(p.latitude, p.longitude);
  }

  /// 캡처 직전 호출 — 네이티브 스냅샷을 떠서 지도 위에 겹쳐 둔다.
  ///
  /// precacheImage까지 await해야 다음 프레임에 동기로 그려져 캡처에 포함된다.
  /// 지도가 없거나(빈 경로) 스냅샷 실패 시 조용히 넘어간다 — 캡처 자체는
  /// 진행되고 지도 자리만 배경색으로 남는다(현재와 동일한 폴백).
  Future<void> prepareForCapture() async {
    try {
      final bytes = await _controller?.takeSnapshot();
      if (bytes == null || !mounted) return;
      final provider = MemoryImage(bytes);
      await precacheImage(provider, context);
      if (!mounted) return;
      setState(() => _snapshot = provider);
    } catch (e) {
      debugPrint('[RecordRouteMap] 지도 스냅샷 실패: $e');
    }
  }

  /// 캡처 종료 후 호출 — 스냅샷 오버레이를 걷어내 라이브 지도로 복귀.
  void endCapture() {
    if (!mounted || _snapshot == null) return;
    setState(() => _snapshot = null);
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
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
                      for (final p in widget.route)
                        LatLng(p.latitude, p.longitude),
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
            // 캡처 중에만 존재 — 같은 화면의 스냅샷이라 사용자에겐 전환이 안 보인다.
            if (_snapshot != null) Image(image: _snapshot!, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
