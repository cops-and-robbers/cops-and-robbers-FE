import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/logout_request_model.dart';
import '../models/token_reissue_request_model.dart';
import '../models/token_reissue_response_model.dart';

part 'auth_remote_datasource.g.dart';

/// Auth 백엔드 API 클라이언트
///
/// Retrofit 기반으로 Auth API를 호출합니다.
///
/// **엔드포인트**:
/// - `POST /api/auth/login` - 소셜 로그인
/// - `POST /api/auth/logout` - 로그아웃
/// - `POST /api/auth/reissue` - 토큰 재발급
@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  /// 소셜 로그인
  ///
  /// Firebase ID Token을 백엔드에 전송하여
  /// JWT Access/Refresh Token을 발급받습니다.
  ///
  /// - 200: 기존 회원 로그인 성공
  /// - 201: 신규 회원 가입 및 로그인 성공
  @POST(ApiEndpoints.login)
  Future<LoginResponseModel> login(@Body() LoginRequestModel request);

  /// 로그아웃
  ///
  /// Refresh Token을 서버에 전송하여 세션을 종료합니다.
  /// 서버에서 Refresh Token 및 디바이스 정보를 삭제합니다.
  ///
  /// - 204: 로그아웃 성공 (응답 본문 없음)
  @POST(ApiEndpoints.logout)
  Future<void> logout(@Body() LogoutRequestModel request);

  /// 토큰 재발급
  ///
  /// 만료된 Access Token을 Refresh Token을 사용하여 재발급합니다.
  ///
  /// - 200: 재발급 성공
  /// - 401: Refresh Token 검증 실패
  @POST(ApiEndpoints.reissue)
  Future<TokenReissueResponseModel> reissue(
    @Body() TokenReissueRequestModel request,
  );
}
