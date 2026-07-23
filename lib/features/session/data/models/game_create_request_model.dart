import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../game/data/models/game_area_model.dart';

part 'game_create_request_model.freezed.dart';
part 'game_create_request_model.g.dart';

/// 게임 방 생성 API 요청 DTO
///
/// `POST /api/games` 요청 본문
///
/// API 스펙에 맞춰 중첩 구조로 구성됩니다:
/// - `area`: 영역 설정 (areaType + circle/polygon)
/// - `settings`: 게임 규칙 설정
///
/// **요청 예시 (원형)**:
/// ```json
/// {
///   "area": {
///     "areaType": "CIRCLE",
///     "circle": {
///       "playgroundCenter": { "latitude": 37.5665, "longitude": 126.978 },
///       "playgroundRadiusInMeters": 1000,
///       "jailCenter": { "latitude": 37.5665, "longitude": 126.978 },
///       "jailRadiusInMeters": 100
///     }
///   },
///   "settings": {
///     "roundDurationMinutes": 30,
///     "locationRevealIntervalMinutes": 5,
///     "policeWaitMinutes": 3,
///     "maxParticipants": 10
///   }
/// }
/// ```
@freezed
class GameCreateRequestModel with _$GameCreateRequestModel {
  const factory GameCreateRequestModel({
    /// 영역 설정 (areaType + circle/polygon)
    required GameAreaRequestModel area,

    /// 게임 규칙 설정
    required GameSettingsRequestModel settings,
  }) = _GameCreateRequestModel;

  factory GameCreateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameCreateRequestModelFromJson(json);
}

/// 영역 설정 요청 DTO (v2.13.0 areaType 중첩 구조)
///
/// areaType에 해당하는 객체 하나만 채워 전송한다. null 필드는 직렬화에서 제외.
@freezed
class GameAreaRequestModel with _$GameAreaRequestModel {
  const factory GameAreaRequestModel({
    required GameAreaType areaType,
    @JsonKey(includeIfNull: false) CircleAreaRequestModel? circle,
    @JsonKey(includeIfNull: false) PolygonAreaRequestModel? polygon,
  }) = _GameAreaRequestModel;

  factory GameAreaRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameAreaRequestModelFromJson(json);
}

/// 원형 구역 요청 DTO
@freezed
class CircleAreaRequestModel with _$CircleAreaRequestModel {
  const factory CircleAreaRequestModel({
    /// 플레이그라운드 중심 좌표
    required CoordinatesRequestModel playgroundCenter,

    /// 플레이그라운드 반경 (미터, 최소 10m, 정수)
    required int playgroundRadiusInMeters,

    /// 감옥 중심 좌표
    required CoordinatesRequestModel jailCenter,

    /// 감옥 반경 (미터, 최소 5m, 정수)
    required int jailRadiusInMeters,
  }) = _CircleAreaRequestModel;

  factory CircleAreaRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CircleAreaRequestModelFromJson(json);
}

/// 다각형 구역 요청 DTO (꼭짓점은 경계 순서로 정렬된 상태로 전송)
@freezed
class PolygonAreaRequestModel with _$PolygonAreaRequestModel {
  const factory PolygonAreaRequestModel({
    /// 플레이그라운드 꼭짓점 좌표 목록
    required List<CoordinatesRequestModel> playgroundPolygon,

    /// 감옥 꼭짓점 좌표 목록
    required List<CoordinatesRequestModel> jailPolygon,
  }) = _PolygonAreaRequestModel;

  factory PolygonAreaRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PolygonAreaRequestModelFromJson(json);
}

/// 좌표 요청 DTO
///
/// 위도(latitude)와 경도(longitude)를 포함합니다.
@freezed
class CoordinatesRequestModel with _$CoordinatesRequestModel {
  const factory CoordinatesRequestModel({
    /// 위도
    required double latitude,

    /// 경도
    required double longitude,
  }) = _CoordinatesRequestModel;

  factory CoordinatesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesRequestModelFromJson(json);
}

/// 게임 규칙 설정 요청 DTO
///
/// 라운드 시간, 위치 공개 주기, 경찰 대기 시간, 최대 참여 인원을 포함합니다.
@freezed
class GameSettingsRequestModel with _$GameSettingsRequestModel {
  const factory GameSettingsRequestModel({
    /// 라운드 시간 (10~180분)
    required int roundDurationMinutes,

    /// 위치 공개 주기 (최소 1분)
    required int locationRevealIntervalMinutes,

    /// 경찰 대기 시간 (최소 0분)
    required int policeWaitMinutes,

    /// 최대 참여 인원 (2~50명)
    required int maxParticipants,
  }) = _GameSettingsRequestModel;

  factory GameSettingsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsRequestModelFromJson(json);
}
