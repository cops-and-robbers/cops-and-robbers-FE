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
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  GoogleMapController? _controller;

  // 위치 조회 실패 대비 fallback (어린이대공원)
  static const LatLng _fallback = LatLng(37.5480, 127.0810);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _moveCameraToCurrentLocation() async {
    final pos = await DeviceLocationService.getCurrentPosition();

    if (pos == null) {
      debugPrint('[지도/Google] 위치 조회 실패 → fallback 사용');
      return;
    }

    debugPrint('[지도/Google] 초기 위치: ${pos.latitude}, ${pos.longitude}');

    final target = LatLng(pos.latitude, pos.longitude);
    _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _fallback,
        zoom: 15,
      ),
      onMapCreated: (controller) {
        _controller = controller;
        _moveCameraToCurrentLocation();
      },

      // 기본 제공 내 위치 마커 상황에 따라 커스텀 마커 적용 예정
      myLocationEnabled: true,
      myLocationButtonEnabled: false,

      zoomControlsEnabled: false,
      compassEnabled: false,
    );
  }
}