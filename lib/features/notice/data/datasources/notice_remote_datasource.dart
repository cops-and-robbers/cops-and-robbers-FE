import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/notice_response_model.dart';

part 'notice_remote_datasource.g.dart';

/// Notice 백엔드 API 클라이언트 (Retrofit)
///
/// `AuthInterceptor`가 JWT를 자동 주입하므로 헤더 수동 처리 불필요.
@RestApi()
abstract class NoticeRemoteDataSource {
  factory NoticeRemoteDataSource(Dio dio) = _NoticeRemoteDataSource;

  /// 공지사항 목록 조회
  ///
  /// 응답: `{ content: NoticeResponse[], page: PageInfo }`
  /// 정렬: 고정 공지(pinned=true) 우선, 이후 최신순 (백엔드 처리)
  /// [category]가 null이면 생성된 `removeWhere`가 파라미터를 빼므로 전체 조회된다.
  @GET(ApiEndpoints.getNotices)
  Future<NoticeListResponseModel> getNotices({
    @Query('page') required int page,
    @Query('size') required int size,
    @Query('category') String? category,
  });
}
