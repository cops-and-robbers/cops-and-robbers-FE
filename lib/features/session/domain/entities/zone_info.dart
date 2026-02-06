import 'package:freezed_annotation/freezed_annotation.dart';

part 'zone_info.freezed.dart';

/// 구역 정보 엔티티
///
/// 플레이그라운드, 감옥 등 게임 내 구역 정보를 표현합니다.
@freezed
class ZoneInfo with _$ZoneInfo {
  const factory ZoneInfo({
    required String id,
    required String name,
    required int radiusMeters,
  }) = _ZoneInfo;

  const ZoneInfo._();

  /// 화면 표시용 거리 문자열
  ///
  /// 1000m 미만: "반경 400m"
  /// 1000m 이상: "반경 1.50km" (소수점 2자리 고정)
  String get displayDistance {
    if (radiusMeters >= 1000) {
      final km = (radiusMeters / 1000).toStringAsFixed(2);
      return '반경 ${km}km';
    }
    return '반경 ${radiusMeters}m';
  }
}
