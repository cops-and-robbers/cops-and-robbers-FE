import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// Naver Maps 기반 게임 지도 뷰
///
/// - Naver Maps SDK 구현체
/// - 현재는 지도 표시 여부 확인용
/// - 추후 위치 추적, 마커, 카메라 제어 로직 추가 예정
class NaverMapView extends StatelessWidget {
  const NaverMapView({super.key});

  // 임시 초기 위치: 어린이대공원
  static const NLatLng _initial = NLatLng(
    37.5479,
    127.0746,
  );

  @override
  Widget build(BuildContext context) {
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: _initial,
          zoom: 15,
        ),
      ),
      onMapReady: (_) {
        debugPrint('✅ naver map ready');
      },
    );
  }
}