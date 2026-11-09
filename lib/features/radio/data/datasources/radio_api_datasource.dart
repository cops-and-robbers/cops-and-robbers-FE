import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/radio_token_model.dart';

part 'radio_api_datasource.g.dart';

/// 무전 REST API 클라이언트
///
/// - `POST /api/games/{gameId}/radio/token` — 경찰 본인의 무전 접속 토큰 (본문 없음).
///   받을 때마다 서버가 자격을 다시 검증하고 사용 시간을 기록한다.
@RestApi()
abstract class RadioApi {
  factory RadioApi(Dio dio) = _RadioApi;

  @POST('/api/games/{gameId}/radio/token')
  Future<RadioTokenModel> issueToken(@Path('gameId') int gameId);
}
