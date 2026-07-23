import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/area_shape.dart';

part 'game_area_model.freezed.dart';
part 'game_area_model.g.dart';

/// 구역 타입 — 서버 와이어 문자열은 이 enum 정의에만 존재한다
enum GameAreaType {
  @JsonValue('CIRCLE')
  circle,
  @JsonValue('POLYGON')
  polygon,
}

/// 위도/경도 좌표 DTO
@freezed
class LatLngModel with _$LatLngModel {
  const factory LatLngModel({
    required double latitude,
    required double longitude,
  }) = _LatLngModel;

  factory LatLngModel.fromJson(Map<String, dynamic> json) =>
      _$LatLngModelFromJson(json);
}

/// 원형 구역 DTO (areaType == CIRCLE 전용)
@freezed
class CircleAreaModel with _$CircleAreaModel {
  const factory CircleAreaModel({
    required LatLngModel playgroundCenter,
    required double playgroundRadiusInMeters,
    required LatLngModel jailCenter,
    required double jailRadiusInMeters,
  }) = _CircleAreaModel;

  factory CircleAreaModel.fromJson(Map<String, dynamic> json) =>
      _$CircleAreaModelFromJson(json);
}

/// 다각형 구역 DTO (areaType == POLYGON 전용)
@freezed
class PolygonAreaModel with _$PolygonAreaModel {
  const factory PolygonAreaModel({
    required List<LatLngModel> playgroundPolygon,
    required List<LatLngModel> jailPolygon,
  }) = _PolygonAreaModel;

  factory PolygonAreaModel.fromJson(Map<String, dynamic> json) =>
      _$PolygonAreaModelFromJson(json);
}

/// 게임 맵 영역 DTO
///
/// `GET /api/games/{gameId}/area` 응답 (v2.13.0 areaType 중첩 구조).
/// areaType에 해당하는 객체(circle/polygon) 하나만 채워진다.
@freezed
class GameAreaModel with _$GameAreaModel {
  const factory GameAreaModel({
    required GameAreaType areaType,
    CircleAreaModel? circle,
    PolygonAreaModel? polygon,
  }) = _GameAreaModel;

  factory GameAreaModel.fromJson(Map<String, dynamic> json) =>
      _$GameAreaModelFromJson(json);
}

/// DTO → 도메인 엔티티 매퍼 — 스키마 의존이 이 함수 하나에 격리된다
extension GameAreaModelMapper on GameAreaModel {
  GameAreaEntity toEntity() {
    switch (areaType) {
      case GameAreaType.circle:
        final c = circle;
        if (c == null) {
          // areaType과 데이터 객체 불일치 — 서버 응답 계약 위반
          throw const ServerException(
            message: '게임 구역 응답 형식이 올바르지 않습니다 (CIRCLE 데이터 누락)',
          );
        }
        return GameAreaEntity(
          playground: AreaShape.circle(
            center: GeoPoint(
              latitude: c.playgroundCenter.latitude,
              longitude: c.playgroundCenter.longitude,
            ),
            radiusInMeters: c.playgroundRadiusInMeters,
          ),
          jail: AreaShape.circle(
            center: GeoPoint(
              latitude: c.jailCenter.latitude,
              longitude: c.jailCenter.longitude,
            ),
            radiusInMeters: c.jailRadiusInMeters,
          ),
        );
      case GameAreaType.polygon:
        final p = polygon;
        if (p == null ||
            p.playgroundPolygon.length < 3 ||
            p.jailPolygon.length < 3) {
          // 꼭짓점 3개 미만은 다각형이 아님 — 판정·렌더링 모두 무의미
          throw const ServerException(
            message: '게임 구역 응답 형식이 올바르지 않습니다 (POLYGON 데이터 불량)',
          );
        }
        return GameAreaEntity(
          playground: AreaShape.polygon(
            points: [
              for (final v in p.playgroundPolygon)
                GeoPoint(latitude: v.latitude, longitude: v.longitude),
            ],
          ),
          jail: AreaShape.polygon(
            points: [
              for (final v in p.jailPolygon)
                GeoPoint(latitude: v.latitude, longitude: v.longitude),
            ],
          ),
        );
    }
  }
}
