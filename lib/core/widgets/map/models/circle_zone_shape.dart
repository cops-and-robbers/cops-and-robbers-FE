import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'zone_shape.dart';

/// Circle 기반 구역 도형 구현체
/// Circle-based zone shape implementation
///
/// **성능**: Native Circle 렌더링, 매우 빠름
/// **정확도**: 완벽한 원형
class CircleZoneShape implements ZoneShape {
  CircleZoneShape({
    required LatLng center,
    required double radius,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  }) : _center = center,
       _radius = radius;

  LatLng _center;
  double _radius;

  /// 중간 영역 색상
  /// Fill color for the zone area
  final Color fillColor;

  /// 외곽선 색상
  /// Stroke color for the zone border
  final Color strokeColor;

  /// 외곽선 두께
  /// Stroke width for the zone border
  final int strokeWidth;

  @override
  Set<Circle> toMapOverlay() {
    return {
      Circle(
        circleId: const CircleId('zone_circle'),
        center: _center,
        radius: _radius,
        fillColor: fillColor.withValues(alpha: 0.2),
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        consumeTapEvents: false, // Circle 터치 이벤트 비활성화 (마커 드래그 우선)
      ),
    };
  }

  @override
  void setRadius(double radiusMeters) {
    _radius = radiusMeters;
  }

  @override
  void setCenter(LatLng center) {
    _center = center;
  }

  @override
  LatLng getCenter() => _center;

  @override
  double getRadius() => _radius;
}
