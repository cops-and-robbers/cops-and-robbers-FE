import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/report_request_model.dart';

part 'report_remote_datasource.g.dart';

/// Report 백엔드 API 클라이언트
///
/// Retrofit 기반으로 신고 API를 호출합니다.
///
/// **엔드포인트**:
/// - `POST /api/report/chat` - 채팅 신고 (JWT 필요)
@RestApi()
abstract class ReportRemoteDataSource {
  factory ReportRemoteDataSource(Dio dio) = _ReportRemoteDataSource;

  /// 채팅 신고
  ///
  /// 201 성공 시 응답 본문 없음
  @POST(ApiEndpoints.reportChat)
  Future<void> reportChat(@Body() ReportRequestModel request);
}
