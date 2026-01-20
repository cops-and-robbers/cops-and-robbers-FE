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
  State<NaverMapView> createState() => _NaverMapViewState();
}

class _NaverMapViewState extends State<NaverMapView> {
  NaverMapController? _controller;

  // 위치 조회 실패 대비 fallback (어린이대공원)
  static const NLatLng _fallback = NLatLng(37.5479, 127.0746);

  Future<void> _moveCameraToCurrentLocation() async {
    final pos = await DeviceLocationService.getCurrentPosition();

    if (pos == null) {
      debugPrint('[지도/Naver] 위치 조회 실패 → fallback 사용');
      return;
    }

    debugPrint('[지도/Naver] 초기 위치: ${pos.latitude}, ${pos.longitude}');

    final target = NLatLng(pos.latitude, pos.longitude);
    await _controller?.updateCamera(
      NCameraUpdate.withParams(target: target, zoom: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(target: _fallback, zoom: 15),

        locationButtonEnable: false,
        indoorEnable: false,
      ),
      onMapReady: (controller) {
        _controller = controller;

        // 내 위치 오버레이 활성화
        controller.setLocationTrackingMode(NLocationTrackingMode.noFollow);

        // 초기 1회 카메라 이동
        _moveCameraToCurrentLocation();
        debugPrint('✅ naver map ready');
      },
    );
  }
}
