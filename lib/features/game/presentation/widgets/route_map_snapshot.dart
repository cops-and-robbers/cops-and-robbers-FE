import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/map_styles.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../data/models/game_area_model.dart';

/// 경로 좌표들을 모두 포함하는 [LatLngBounds]를 만든다.
///
/// 단일/동일 좌표(면적 0)는 `newLatLngBounds`가 동작하도록 작은 패딩(~11m)으로
/// 확장한다.
LatLngBounds routeBounds(List<LatLngModel> route) {
  assert(route.isNotEmpty, 'routeBounds: 비어있지 않은 경로가 필요합니다');
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
  const eps = 0.0001; // 약 11m
  if (maxLat - minLat < eps) {
    minLat -= eps;
    maxLat += eps;
  }
  if (maxLng - minLng < eps) {
    minLng -= eps;
    maxLng += eps;
  }
  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}

/// 경로/마커를 실제 구글 지도 스냅샷으로 표시하고, 오프라인·실패 시 [fallback]으로 폴백.
///
/// 흐름: 연결 확인 → (온라인) GoogleMap 렌더 → 카메라를 경로 범위에 맞춤 →
/// onCameraIdle + 지연 후 takeSnapshot → 성공 시 정적 이미지로 교체.
/// 어느 경우든 확정되면 [onResolved]를 1회 호출한다(부모의 버튼 게이팅용).
class RouteMapSnapshot extends ConsumerStatefulWidget {
  const RouteMapSnapshot({
    super.key,
    required this.route,
    required this.markerPoints,
    required this.isDarkMode,
    required this.lineColor,
    required this.fallback,
    required this.onResolved,
  }) : assert(route.length > 0, 'RouteMapSnapshot은 비어있지 않은 경로에만 사용');

  final List<LatLngModel> route;

  /// 강조 마커 위치(경찰=체포 지점, 도둑=잡힌 지점). 모두 빨강 핀.
  final List<LatLngModel> markerPoints;
  final bool isDarkMode;
  final Color lineColor;

  /// 오프라인/실패 시 표시할 위젯(스타일라이즈드 경로).
  final Widget fallback;

  /// 이미지/폴백으로 확정된 순간 1회 호출.
  final VoidCallback onResolved;

  @override
  ConsumerState<RouteMapSnapshot> createState() => _RouteMapSnapshotState();
}

class _RouteMapSnapshotState extends ConsumerState<RouteMapSnapshot> {
  GoogleMapController? _controller;
  Uint8List? _image;
  bool _failed = false;
  bool _online = false; // 연결 확인 완료 + 온라인 → 라이브 맵 렌더
  bool _cameraFitted = false; // 카메라 핏 완료 후에만 스냅샷 허용
  bool _snapshotRequested = false;
  bool _resolvedNotified = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 오프라인 또는 플러그인 부재(테스트 등) → 즉시 폴백.
    // 연결 확인이 멈춰도 onResolved가 영영 안 뜨지 않도록 3초 타임아웃.
    bool connected;
    try {
      connected = await ref
          .read(connectivityServiceProvider)
          .isConnected()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {
      connected = false;
    }
    if (!mounted) return;
    if (!connected) {
      _resolveFallback();
      return;
    }
    setState(() => _online = true);
    // 타일 로딩/스냅샷이 4초 내 확정 안 되면 폴백.
    _timeoutTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _image == null && !_failed) _resolveFallback();
    });
  }

  void _resolveFallback() {
    if (!mounted) return;
    setState(() => _failed = true);
    _notifyResolved();
  }

  void _notifyResolved() {
    if (_resolvedNotified) return;
    _resolvedNotified = true;
    _timeoutTimer?.cancel();
    // 이미지/폴백이 실제 렌더(정적화)된 다음 프레임에 통지 — 부모가 캡처해도
    // 라이브 플랫폼 뷰가 아닌 정적 콘텐츠를 잡도록 보장.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onResolved();
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    try {
      // 경로 범위에 맞춰 카메라 핏(픽셀 패딩 36).
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(routeBounds(widget.route), 36),
      );
    } catch (e) {
      debugPrint('[RouteMapSnapshot] 카메라 핏 실패: $e');
    } finally {
      // 핏 성공/실패와 무관하게 스냅샷 단계로 진입 허용(실패 시 초기 뷰로 촬영).
      _cameraFitted = true;
    }
  }

  Future<void> _onCameraIdle() async {
    // 카메라 핏 전에 발생한 idle은 무시(잘못된 뷰포트 촬영 방지).
    if (!_cameraFitted || _snapshotRequested || _image != null || _failed) {
      return;
    }
    _snapshotRequested = true;
    // 타일 안정화 대기 후 스냅샷.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted || _failed) return;
    try {
      final bytes = await _controller?.takeSnapshot();
      if (!mounted) return;
      // takeSnapshot 도중 타임아웃이 먼저 폴백을 확정했으면 이미지 무시.
      if (_failed) return;
      if (bytes == null) {
        _resolveFallback();
        return;
      }
      setState(() => _image = bytes);
      _notifyResolved();
    } catch (e) {
      debugPrint('[RouteMapSnapshot] takeSnapshot 실패: $e');
      _resolveFallback();
    }
  }

  Set<Polyline> get _polylines => {
    Polyline(
      polylineId: const PolylineId('route'),
      points: [for (final p in widget.route) LatLng(p.latitude, p.longitude)],
      color: widget.lineColor,
      width: 5,
    ),
  };

  Set<Marker> get _markers => {
    for (var i = 0; i < widget.markerPoints.length; i++)
      Marker(
        markerId: MarkerId('mark_$i'),
        position: LatLng(
          widget.markerPoints[i].latitude,
          widget.markerPoints[i].longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
  };

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// 라이브 GoogleMap(스냅샷 대상). 부모 Stack이 위에 캐릭터를 얹는다.
  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.route.first.latitude,
          widget.route.first.longitude,
        ),
        zoom: 15,
      ),
      style: widget.isDarkMode ? MapStyles.dark : null,
      onMapCreated: _onMapCreated,
      onCameraIdle: _onCameraIdle,
      polylines: _polylines,
      markers: _markers,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomGesturesEnabled: false,
      scrollGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.fallback;

    if (_image != null) {
      return ClipRRect(
        borderRadius: AppRadius.large,
        child: Image.memory(_image!, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }

    // 로딩 중에는 부모(_MyRecordBody)가 카드 전체를 로딩 인디케이터로 가린다.
    // 온라인이면 스냅샷을 위해 맵을 렌더하고(가려진 채 타일 로딩·촬영), 연결 확인
    // 중이면 자리만 차지한다.
    if (!_online) return const SizedBox.expand();
    return ClipRRect(borderRadius: AppRadius.large, child: _buildMap());
  }
}
