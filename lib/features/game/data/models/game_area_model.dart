import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_area_model.freezed.dart';
part 'game_area_model.g.dart';

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

/// 도둑 마지막 공개 위치 DTO
///
/// `GET /api/games/{gameId}/robbers/location` 응답 항목.
/// 재연결 후 누락된 LOCATION_REVEAL 이벤트 복구에 사용합니다.
@freezed
class RobberLocationModel with _$RobberLocationModel {
  const factory RobberLocationModel({
    required int participantId,
    required String nickname,
    required double latitude,
    required double longitude,
  }) = _RobberLocationModel;

  factory RobberLocationModel.fromJson(Map<String, dynamic> json) =>
      _$RobberLocationModelFromJson(json);
}

/// 게임 맵 영역 DTO
///
/// `GET /api/games/{gameId}/area` 응답.
/// 플레이그라운드와 감옥 영역 중심 좌표 및 반경을 제공합니다.
@freezed
class GameAreaModel with _$GameAreaModel {
  const factory GameAreaModel({
    required LatLngModel playgroundCenter,
    required double playgroundRadiusInMeters,
    required LatLngModel jailCenter,
    required double jailRadiusInMeters,
  }) = _GameAreaModel;

  factory GameAreaModel.fromJson(Map<String, dynamic> json) =>
      _$GameAreaModelFromJson(json);
}
