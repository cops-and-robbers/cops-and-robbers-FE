import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/utils/zone_metric_formatter.dart';
import 'package:cops_and_robbers/features/game/domain/entities/area_shape.dart';
import 'package:cops_and_robbers/features/game/domain/polygon_geometry.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

// lookupAppLocalizations은 WidgetsFlutterBinding 없이도 동기적으로 동작한다.
final l10n = lookupAppLocalizations(const Locale('ko'));

/// 서울 시청 부근 — 중위도 좌표에서 검증한다.
const _origin = GeoPoint(latitude: 37.5665, longitude: 126.9780);

/// 약 100m x 100m 사각형 (위도 0.0009° ≈ 100m)
const _squarePoints = [
  GeoPoint(latitude: 37.5665, longitude: 126.9780),
  GeoPoint(latitude: 37.5674, longitude: 126.9780),
  GeoPoint(latitude: 37.5674, longitude: 126.9791),
  GeoPoint(latitude: 37.5665, longitude: 126.9791),
];

void main() {
  group('formatRadiusValue', () {
    test('shows_meters_when_below_one_kilometer', () {
      expect(formatRadiusValue(523), '523m');
      expect(formatRadiusValue(999), '999m');
    });

    test('shows_kilometers_when_one_kilometer_or_above', () {
      expect(formatRadiusValue(1000), '1.00km');
      expect(formatRadiusValue(1500), '1.50km');
    });

    test('rounds_fractional_meters', () {
      expect(formatRadiusValue(523.6), '524m');
    });
  });

  group('formatAreaValue', () {
    test('groups_thousands_when_below_one_square_kilometer', () {
      expect(formatAreaValue(2340), '2,340m²');
      expect(formatAreaValue(31416), '31,416m²');
      expect(formatAreaValue(999999), '999,999m²');
    });

    test('shows_square_kilometers_when_one_square_kilometer_or_above', () {
      expect(formatAreaValue(1000000), '1.00km²');
      expect(formatAreaValue(1200000), '1.20km²');
    });

    test('keeps_at_least_one_digit_when_area_is_zero', () {
      expect(formatAreaValue(0), '0m²');
    });
  });

  group('AreaShape.metricText', () {
    test('shows_radius_when_shape_is_circle', () {
      const shape = AreaShape.circle(center: _origin, radiusInMeters: 523);

      expect(shape.metricText(l10n), '반경 523m');
    });

    test('shows_area_when_shape_is_polygon', () {
      const shape = AreaShape.polygon(points: _squarePoints);

      // 약 100m x 100m → 만 단위 ㎡. 정확한 측지 면적은 평면 근사에 따라 흔들리므로
      // 단위·접두어만 단정하고 수치 포맷은 formatAreaValue 테스트가 담당한다.
      expect(shape.metricText(l10n), matches(RegExp(r'^면적 [\d,]+m²$')));
    });

    test('area_follows_vertex_ring_order_for_concave_polygon', () {
      // 화살촉(오목) — 링 순서 (0,0)→(4,2)→(0,4)→(1.5,2.5) 면적 5 단위,
      // 중심 각도로 재정렬하면 (0,0)→(4,2)→(1.5,2.5)→(0,4) 면적 6.5 단위가 된다.
      // 저장·응답의 꼭짓점 순서가 곧 경계 순서이므로 재정렬 없이 계산해야 한다.
      const unit = 0.001;
      const arrowhead = [
        GeoPoint(latitude: 37.5665, longitude: 126.9780),
        GeoPoint(latitude: 37.5665 + 2 * unit, longitude: 126.9780 + 4 * unit),
        GeoPoint(latitude: 37.5665 + 4 * unit, longitude: 126.9780),
        GeoPoint(
          latitude: 37.5665 + 2.5 * unit,
          longitude: 126.9780 + 1.5 * unit,
        ),
      ];
      const shape = AreaShape.polygon(points: arrowhead);

      expect(
        shape.metricText(l10n),
        '면적 ${formatAreaValue(polygonAreaInSquareMeters(arrowhead))}',
      );
    });
  });
}
