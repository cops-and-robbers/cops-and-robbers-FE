import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/game_result_response_model.dart';

part 'game_result_api_datasource.g.dart';

/// 게임 결과 조회 REST API 클라이언트
///
/// - `GET /api/game-results/{gameResultId}` — 게임 종료 후 결과 조회
@RestApi()
abstract class GameResultApi {
  factory GameResultApi(Dio dio) = _GameResultApi;

  /// 게임 결과 조회
  @GET('/api/game-results/{gameResultId}')
  Future<GameResultResponseModel> getGameResult(
    @Path('gameResultId') int gameResultId,
  );
}
