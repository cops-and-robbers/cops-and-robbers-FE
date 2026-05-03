import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/bug_report_request_model.dart';

part 'bug_remote_datasource.g.dart';

/// Bug 백엔드 API 클라이언트
///
/// Retrofit 기반으로 버그 제보 API를 호출합니다.
/// JWT는 `AuthInterceptor`가 자동 주입합니다.
///
/// **엔드포인트**:
/// - `POST /api/bugs` - 버그 제보 (JWT 필요, 응답 본문 없음)
@RestApi()
abstract class BugRemoteDataSource {
  factory BugRemoteDataSource(Dio dio) = _BugRemoteDataSource;

  /// 버그 제보
  ///
  /// 201 성공 시 응답 본문 없음.
  @POST(ApiEndpoints.reportBug)
  Future<void> reportBug(@Body() BugReportRequestModel request);
}
