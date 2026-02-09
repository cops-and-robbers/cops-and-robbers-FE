import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/nickname_check_response_model.dart';
import '../models/nickname_update_request_model.dart';

part 'user_remote_datasource.g.dart';

/// User 백엔드 API 클라이언트
///
/// Retrofit 기반으로 User API를 호출합니다.
///
/// **엔드포인트**:
/// - `GET /api/user/check-nickname` - 닉네임 중복 확인 (인증 불필요)
/// - `PATCH /api/user/me/nickname` - 닉네임 변경 (JWT 필요)
@RestApi()
abstract class UserRemoteDataSource {
  factory UserRemoteDataSource(Dio dio) = _UserRemoteDataSource;

  /// 닉네임 중복 확인
  ///
  /// 닉네임의 사용 가능 여부를 확인합니다.
  /// 인증 토큰이 필요하지 않습니다.
  ///
  /// - 200: 확인 결과 (isAvailable, message)
  /// - 400: 파라미터 누락
  @GET(ApiEndpoints.checkNickname)
  Future<NicknameCheckResponseModel> checkNickname(
    @Query('nickname') String nickname,
  );

  /// 닉네임 변경
  ///
  /// 현재 로그인한 사용자의 닉네임을 변경합니다.
  ///
  /// - 204: 변경 성공 (응답 본문 없음)
  /// - 400: 유효성 검사 실패
  /// - 409: 닉네임 중복
  @PATCH(ApiEndpoints.updateNickname)
  Future<void> updateNickname(@Body() NicknameUpdateRequestModel request);
}
