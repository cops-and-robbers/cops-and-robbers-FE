import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../../../core/services/location/device_location_service.dart';
import 'map_error_widget.dart';

/// Naver Maps 기반 게임 지도 뷰
///
/// - 기본 내 위치 표시
/// - 초기 진입 시 현재 위치 1회 조회 후 카메라 이동
/// - [updateAreaOverlays]로 플레이그라운드·감옥 원 추가
class NaverMapView extends StatefulWidget {
  const NaverMapView({super.key, this.isDarkMode = false});

  /// 다크 모드 여부 (도둑팀 다크 스타일 적용)
  final bool isDarkMode;

  @override
  State<NaverMapView> createState() => NaverMapViewState();
}

class NaverMapViewState extends State<NaverMapView> {
  NaverMapController? _controller;

  // 위치 조회 실패 대비 fallback (어린이대공원)
  static const NLatLng _fallback = NLatLng(37.5479, 127.0746);

  Set<NCircleOverlay> _areaOverlays = {};
  Set<NCircleOverlay> _pendingAreaOverlays = {};
  Set<NCircleOverlay> _robberOverlays = {};

  @override
  void initState() {
    super.initState();
    debugPrint('========================================');
    debugPrint('🗺️ NaverMapView initState 시작');
    debugPrint('========================================');
  }

  @override
  void dispose() {
    debugPrint('🗺️ NaverMapView dispose');
    super.dispose();
  }

  Future<void> moveCameraToCurrentLocation() async {
    debugPrint('📍 NaverMap: 현재 위치로 카메라 이동 시작');
    try {
      final pos = await DeviceLocationService.getCurrentPosition();

      if (pos == null) {
        debugPrint('[지도/Naver] 위치 조회 실패 → fallback 사용');
        return;
      }

      debugPrint('[지도/Naver] 초기 위치: ${pos.latitude}, ${pos.longitude}');

      final target = NLatLng(pos.latitude, pos.longitude);
      final cameraUpdate = NCameraUpdate.withParams(target: target, zoom: 16);
      cameraUpdate.setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 800),
      );
      await _controller?.updateCamera(cameraUpdate);
      debugPrint('✅ NaverMap: 카메라 이동 완료');
    } catch (e, stack) {
      debugPrint('❌ NaverMap: 카메라 이동 실패 - $e');
      debugPrint('Stack: $stack');
    }
  }

  /// 맵 영역 원(플레이그라운드·감옥) 업데이트
  void updateAreaOverlays(Set<NCircleOverlay> overlays) {
    if (!mounted) return;
    _areaOverlays = overlays;
    if (_controller != null) {
      _refreshAllCircleOverlays();
    } else {
      _pendingAreaOverlays = overlays;
    }
    debugPrint('🗺️ NaverMap: 영역 원 ${overlays.length}개 업데이트');
  }

  /// 도둑 위치 빨간 원 업데이트 (LOCATION_REVEAL 이벤트 시 호출)
  void updateRobberOverlays(Set<NCircleOverlay> overlays) {
    if (!mounted) return;
    _robberOverlays = overlays;
    if (_controller != null) _refreshAllCircleOverlays();
    debugPrint('🗺️ NaverMap: 도둑 위치 원 ${overlays.length}개 업데이트');
  }

  void _refreshAllCircleOverlays() {
    if (_controller == null) return;
    _controller!.clearOverlays(type: NOverlayType.circleOverlay);
    final all = {..._areaOverlays, ..._robberOverlays};
    if (all.isNotEmpty) _controller!.addOverlayAll(all);
    _pendingAreaOverlays = {};
  }

  @override
  Widget build(BuildContext context) {
    try {
      return NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: const NCameraPosition(
            target: _fallback,
            zoom: 15,
          ),
          mapType: widget.isDarkMode ? NMapType.navi : NMapType.basic,
          nightModeEnable: widget.isDarkMode,
          locationButtonEnable: false,
          indoorEnable: false,
        ),
        onMapReady: (controller) {
          debugPrint('🗺️ NaverMap onMapReady 콜백 시작');
          try {
            _controller = controller;

            // 내 위치 오버레이 활성화
            debugPrint('📍 NaverMap: setLocationTrackingMode 호출');
            controller.setLocationTrackingMode(NLocationTrackingMode.noFollow);
            // TODO: 다른 플레이어 실시간 위치 마커 표시 (백엔드 스펙 확정 후)
            //       controller.addOverlayAll(_playerMarkers);

            // 초기 1회 카메라 이동
            moveCameraToCurrentLocation();

            // 대기 중인 영역 오버레이 적용
            if (_pendingAreaOverlays.isNotEmpty) {
              _areaOverlays = _pendingAreaOverlays;
              _refreshAllCircleOverlays();
            }

            debugPrint('✅ naver map ready');
          } catch (e, stack) {
            debugPrint('❌ NaverMap onMapReady 에러: $e');
            debugPrint('Stack: $stack');
          }
        },
      );
    } catch (e, stack) {
      debugPrint('❌ NaverMap 생성 실패: $e');
      debugPrint('Stack: $stack');

      // 에러 발생 시 대체 UI 표시
      return MapErrorWidget(mapName: 'Naver Map', error: e);
    }
  }
}
