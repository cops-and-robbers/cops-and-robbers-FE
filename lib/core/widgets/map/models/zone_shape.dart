import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 구역 도형 추상 인터페이스
/// Zone shape abstract interface
///
/// **확장성**: Circle 기반 구역 설정
/// **책임**: 지도 오버레이 렌더링 로직 캡슐화
abstract class ZoneShape {
  /// 지도에 렌더링할 오버레이 반환
  /// Returns map overlay to be rendered (Circle)
  Set<Circle> toMapOverlay();

  /// 반경(미터) 설정
  /// Set radius in meters
  void setRadius(double radiusMeters);

  /// 중심점 설정
  /// Set center position
  void setCenter(LatLng center);

  /// 현재 중심점 가져오기
  /// Get current center position
  LatLng getCenter();

  /// 현재 반경 가져오기
  /// Get current radius in meters
  double getRadius();
}
