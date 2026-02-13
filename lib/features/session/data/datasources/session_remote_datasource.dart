import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/create_session_response.dart';
import '../models/game_create_request_model.dart';

part 'session_remote_datasource.g.dart';

/// Session 백엔드 API 클라이언트
///
/// Retrofit 기반으로 Game/Session API를 호출합니다.
///
/// **엔드포인트**:
/// - `POST /api/games` - 게임 방 생성 (JWT 필요)
@RestApi()
abstract class SessionRemoteDataSource {
  factory SessionRemoteDataSource(Dio dio) = _SessionRemoteDataSource;

  /// 게임 방 생성
  ///
  /// 새로운 게임 방을 생성하고 초대 코드를 발급받습니다.
  /// 방을 생성한 사용자는 자동으로 방장이 됩니다.
  ///
  /// - 201: 생성 성공 (gameId, inviteCode, ...)
  /// - 400: 유효성 검증 실패
  /// - 401: 인증 실패
  /// - 409: 이미 활성 게임 참여 중
  @POST(ApiEndpoints.createGame)
  Future<CreateSessionResponse> createGame(
    @Body() GameCreateRequestModel request,
  );
}
