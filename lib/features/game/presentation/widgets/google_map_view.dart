import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/services/location/device_location_service.dart';

/// Google Maps 기반 게임 지도 뷰
///
/// - 기본 내 위치 마커 표시 (myLocationEnabled)
/// - 초기 진입 시 현재 위치 1회 조회 후 카메라 이동
class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => GoogleMapViewState();
}

class GoogleMapViewState extends State<GoogleMapView> {
  GoogleMapController? _controller;

  // 위치 조회 실패 대비 fallback (어린이대공원)
  static const LatLng _fallback = LatLng(37.5480, 127.0810);

  @override
  void initState() {
    super.initState();
    debugPrint('========================================');
    debugPrint('🗺️ GoogleMapView initState 시작');
    debugPrint('========================================');
  }

  @override
  void dispose() {
    debugPrint('🗺️ GoogleMapView dispose');
    _controller?.dispose();
    super.dispose();
  }

  Future<void> moveCameraToCurrentLocation() async {
    debugPrint('📍 GoogleMap: 현재 위치로 카메라 이동 시작');
    try {
      final pos = await DeviceLocationService.getCurrentPosition();

      if (pos == null) {
        debugPrint('[지도/Google] 위치 조회 실패 → fallback 사용');
        return;
      }

      debugPrint('[지도/Google] 초기 위치: ${pos.latitude}, ${pos.longitude}');

      final target = LatLng(pos.latitude, pos.longitude);
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16),
        ),
      );
      debugPrint('✅ GoogleMap: 카메라 이동 완료');
    } catch (e, stack) {
      debugPrint('❌ GoogleMap: 카메라 이동 실패 - $e');
      debugPrint('Stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🗺️ GoogleMapView build 호출');

    try {
      return GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _fallback,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          debugPrint('🗺️ GoogleMap onMapCreated 콜백 시작');
          try {
            _controller = controller;
            moveCameraToCurrentLocation();
            debugPrint('✅ google map ready');
          } catch (e, stack) {
            debugPrint('❌ GoogleMap onMapCreated 에러: $e');
            debugPrint('Stack: $stack');
          }
        },

        // 기본 제공 내 위치 마커 상황에 따라 커스텀 마커 적용 예정
        myLocationEnabled: true,
        myLocationButtonEnabled: false,

        zoomControlsEnabled: false,
        compassEnabled: false,
      );
    } catch (e, stack) {
      debugPrint('❌ GoogleMap 생성 실패: $e');
      debugPrint('Stack: $stack');

      // 에러 발생 시 대체 UI 표시
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Google Map 로드 실패'),
            const SizedBox(height: 8),
            Text('Error: $e', style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }
  }
}
