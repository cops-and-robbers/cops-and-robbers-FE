/// 구역 도형 타입
/// Zone shape type
enum ZoneShapeType {
  /// 원형 (google_maps_flutter Circle 사용)
  /// Circle shape using google_maps_flutter Circle widget
  circle,

  /// Polyline 기반 커스텀 도형 (원형 근사)
  /// Custom shape using Polyline (circle approximation)
  polyline,
}
