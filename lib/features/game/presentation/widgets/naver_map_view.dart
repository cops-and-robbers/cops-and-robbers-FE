import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../../../../core/services/location/device_location_service.dart';

/// Naver Maps 기반 게임 지도 뷰
///
/// - 기본 내 위치 표시
/// - 초기 진입 시 현재 위치 1회 조회 후 카메라 이동
class NaverMapView extends StatefulWidget {
  const NaverMapView({super.key});

  @override
  State<NaverMapView> createState() => NaverMapViewState();
}

class NaverMapViewState extends State<NaverMapView> {
  NaverMapController? _controller;

  // 위치 조회 실패 대비 fallback (어린이대공원)
  static const NLatLng _fallback = NLatLng(37.5479, 127.0746);

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

  @override
  Widget build(BuildContext context) {
    debugPrint('🗺️ NaverMapView build 호출');

    try {
      return NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(target: _fallback, zoom: 15),

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

            // 초기 1회 카메라 이동
            moveCameraToCurrentLocation();
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Naver Map 로드 실패'),
            const SizedBox(height: 8),
            Text('Error: $e', style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }
  }
}
