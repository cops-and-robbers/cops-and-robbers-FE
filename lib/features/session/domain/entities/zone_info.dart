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
  /// 예: "반경 400m"
  String get displayDistance => '반경 ${radiusMeters}m';
}
