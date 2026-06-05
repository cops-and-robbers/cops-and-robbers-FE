import 'package:freezed_annotation/freezed_annotation.dart';

part 'ping.freezed.dart';

/// 핑 종류
///
/// 코드 토큰 = 아이콘 파일명 토큰 (found / suspect)
enum PingType { found, suspect }

/// 맵 핑 엔티티 (순수 Dart — google_maps의 LatLng 의존 없음)
///
/// 좌표는 double로 보관하고, LatLng 변환은 presentation 경계에서 수행한다.
@freezed
class Ping with _$Ping {
  const factory Ping({
    /// 로컬 임시 id (마커/타이머 식별용, 'ping_<counter>').
    /// 서버 핑 API 도입 시 서버가 부여하는 id로 대체된다.
    required String id,
    required PingType type,
    required double latitude,
    required double longitude,
    required DateTime createdAt,
  }) = _Ping;
}
