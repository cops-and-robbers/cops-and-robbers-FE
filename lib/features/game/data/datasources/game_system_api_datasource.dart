import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/arrest_request_model.dart';
import '../../data/models/arrest_response_model.dart';
import '../../data/models/game_area_model.dart';
import '../../data/models/game_state_model.dart';
export '../../data/models/game_area_model.dart' show RobberLocationModel;
export '../../data/models/game_state_model.dart'
    show GameStateModel, ParticipantInfoModel, RobberLocationInfoModel;

part 'game_system_api_datasource.g.dart';

/// 게임 시스템 REST API 클라이언트
///
/// - `POST /api/games/{gameId}/system/arrest` — 도둑 체포 (경찰만)
/// - `POST /api/games/{gameId}/system/escape` — 탈옥 (수감된 도둑만)
/// - `GET  /api/games/{gameId}/area` — 맵 영역 조회
/// - `GET  /api/games/{gameId}/state` — 게임 상태 조회 (소켓 재연결 시 복원용)
@RestApi()
abstract class GameSystemApi {
  factory GameSystemApi(Dio dio) = _GameSystemApi;

  /// 도둑 체포
  @POST('/api/games/{gameId}/system/arrest')
  Future<ArrestResponseModel> arrest(
    @Path('gameId') int gameId,
    @Body() ArrestRequestModel body,
  );

  /// 탈옥
  @POST('/api/games/{gameId}/system/escape')
  Future<void> escape(@Path('gameId') int gameId);

  /// 맵 영역 조회
  @GET('/api/games/{gameId}/area')
  Future<GameAreaModel> getArea(@Path('gameId') int gameId);

  /// 게임 상태 조회
  ///
  /// 소켓 재연결 시 게임 화면 복원에 사용합니다.
  /// - `robberLocations`: 마지막 공개 주기의 생존 도둑 위치 (경찰 대기 중 또는 첫 공개 전이면 빈 배열)
  /// - `participants`: 전체 참여자 팀·상태 목록
  @GET('/api/games/{gameId}/state')
  Future<GameStateModel> getGameState(@Path('gameId') int gameId);

  /// 가장 최근 공개된 도둑 위치 목록 조회
  ///
  /// @deprecated v2.6.0부터 deprecated. [getGameState]의 `robberLocations` 필드를 사용하세요.
  /// 재연결 후 누락된 LOCATION_REVEAL 이벤트를 보완하기 위해 호출.
  /// 아직 위치 공개 전이면 빈 배열 반환.
  @GET('/api/games/{gameId}/robbers/location')
  Future<List<RobberLocationModel>> getRobberLastLocations(
    @Path('gameId') int gameId,
  );
}
