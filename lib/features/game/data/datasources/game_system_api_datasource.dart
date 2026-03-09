import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/arrest_request_model.dart';
import '../../data/models/arrest_response_model.dart';
import '../../data/models/game_area_model.dart';

part 'game_system_api_datasource.g.dart';

/// 게임 시스템 REST API 클라이언트
///
/// - `POST /api/games/{gameId}/system/arrest` — 도둑 체포 (경찰만)
/// - `POST /api/games/{gameId}/system/escape` — 탈옥 (수감된 도둑만)
/// - `GET  /api/games/{gameId}/area` — 맵 영역 조회
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
}
