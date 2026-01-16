import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google Maps 기반 게임 지도 뷰
///
/// - Google Maps SDK 구현체
/// - 현재는 지도 표시 여부 확인용
/// - 추후 위치 추적, 마커, 카메라 제어 로직 추가 예정
class GoogleMapView extends StatelessWidget {
  const GoogleMapView({super.key});

  // 임시 초기 위치: 어린이대공원
  static const LatLng _initialPosition = LatLng(37.5480, 127.0810);

  @override
  Widget build(BuildContext context) {
    return const GoogleMap(
      initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }
}
