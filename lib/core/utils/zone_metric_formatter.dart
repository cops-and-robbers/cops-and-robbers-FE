import 'package:intl/intl.dart';

import '../../features/game/domain/entities/area_shape.dart';
import '../../features/game/domain/polygon_geometry.dart';
import '../../l10n/app_localizations.dart';

/// 천단위 구분자 포맷 — 지원 로케일(ko/en/ja)이 모두 콤마이고, 앱이 시스템 로케일이 아닌
/// appLocaleProvider로 언어를 관리하므로 Intl.defaultLocale 기반 자동 선택은 쓰지 않는다.
/// '#,##0'은 값이 0일 때도 최소 한 자리를 보장한다.
final NumberFormat _thousands = NumberFormat('#,##0');

/// 킬로미터 전환 임계값(m)
const double _kilometerThreshold = 1000;

/// 제곱킬로미터 전환 임계값(㎡) — 1km². 1ha 기준으로 잡으면 감옥(반경 100m 상당,
/// 약 31,000㎡)이 "0.03km²"로 뭉개져 구분이 불가능하다.
const double _squareKilometerThreshold = 1000000;

/// 반경 값 문자열 — "523m" / "1.50km"
String formatRadiusValue(double meters) {
  if (meters >= _kilometerThreshold) {
    return '${(meters / _kilometerThreshold).toStringAsFixed(2)}km';
  }
  return '${meters.round()}m';
}

/// 면적 값 문자열 — "31,416m²" / "0.79km²"
String formatAreaValue(double squareMeters) {
  if (squareMeters >= _squareKilometerThreshold) {
    return '${(squareMeters / _squareKilometerThreshold).toStringAsFixed(2)}km²';
  }
  return '${_thousands.format(squareMeters.round())}m²';
}

/// 구역 도형의 크기 표시 문장 — 원형은 반경, 폴리곤은 면적
///
/// 단위 기호는 위 포맷 함수가 단일 소스로 갖고, 어순("반경 …"/"면적 …")은 ARB가 갖는다.
extension ZoneMetricDisplay on AreaShape {
  String metricText(AppLocalizations l10n) => when(
    circle: (_, radiusInMeters) =>
        l10n.zoneRadiusValue(formatRadiusValue(radiusInMeters)),
    // 저장·응답의 꼭짓점 순서를 신뢰하지 않고 정렬 후 계산한다. shoelace는 자기교차
    // 다각형에서 잘못된 값을 내지만 표시 시점에는 isValidPolygon 검증을 거칠 수 없다.
    // n ≤ 10이라 정렬 비용은 무의미하다.
    polygon: (points) => l10n.zoneAreaValue(
      formatAreaValue(
        polygonAreaInSquareMeters(sortByAngleAroundCentroid(points)),
      ),
    ),
  );
}
