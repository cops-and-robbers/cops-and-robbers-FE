import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/game_result_response_model.dart';
import '../models/my_game_record_response_model.dart';

part 'game_result_api_datasource.g.dart';

/// 게임 결과 조회 REST API 클라이언트
///
/// - `GET /api/game-results/{gameResultId}` — 게임 종료 후 결과 조회
/// - `GET /api/game-results/{gameResultId}/me` — 내 개인 기록 조회
@RestApi()
abstract class GameResultApi {
  factory GameResultApi(Dio dio) = _GameResultApi;

  /// 게임 결과 조회
  @GET('/api/game-results/{gameResultId}')
  Future<GameResultResponseModel> getGameResult(
    @Path('gameResultId') int gameResultId,
  );

  /// 내 개인 기록 조회 — 토큰의 사용자 기준이라 participantId를 받지 않는다.
  @GET('/api/game-results/{gameResultId}/me')
  Future<MyGameRecordResponseModel> getMyGameRecord(
    @Path('gameResultId') int gameResultId,
  );
}
