import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_create_request_model.freezed.dart';
part 'game_create_request_model.g.dart';

/// 게임 방 생성 API 요청 DTO
///
/// `POST /api/games` 요청 본문
///
/// API 스펙에 맞춰 중첩 구조로 구성됩니다:
/// - `area`: 영역 설정 (플레이그라운드, 감옥)
/// - `settings`: 게임 규칙 설정
///
/// **요청 예시**:
/// ```json
/// {
///   "area": {
///     "playgroundCenter": { "latitude": 37.5665, "longitude": 126.978 },
///     "playgroundRadiusInMeters": 1000,
///     "jailCenter": { "latitude": 37.5665, "longitude": 126.978 },
///     "jailRadiusInMeters": 100
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
    /// 영역 설정 (플레이그라운드, 감옥)
    required AreaRequestModel area,

    /// 게임 규칙 설정
    required GameSettingsRequestModel settings,
  }) = _GameCreateRequestModel;

  factory GameCreateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameCreateRequestModelFromJson(json);
}

/// 영역 설정 요청 DTO
///
/// 플레이그라운드와 감옥의 중심 좌표 및 반경을 포함합니다.
@freezed
class AreaRequestModel with _$AreaRequestModel {
  const factory AreaRequestModel({
    /// 플레이그라운드 중심 좌표
    required CoordinatesRequestModel playgroundCenter,

    /// 플레이그라운드 반경 (미터, 최소 10m, 정수)
    required int playgroundRadiusInMeters,

    /// 감옥 중심 좌표
    required CoordinatesRequestModel jailCenter,

    /// 감옥 반경 (미터, 최소 5m, 정수)
    required int jailRadiusInMeters,
  }) = _AreaRequestModel;

  factory AreaRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AreaRequestModelFromJson(json);
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

    /// 위치 공개 주기 (최소 5분)
    required int locationRevealIntervalMinutes,

    /// 경찰 대기 시간 (최소 0분)
    required int policeWaitMinutes,

    /// 최대 참여 인원 (2~50명)
    required int maxParticipants,
  }) = _GameSettingsRequestModel;

  factory GameSettingsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsRequestModelFromJson(json);
}
