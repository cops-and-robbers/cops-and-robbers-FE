import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/community_post_model.dart';

part 'community_remote_datasource.g.dart';

/// Community 백엔드 API 클라이언트 (Retrofit)
///
/// `AuthInterceptor`가 JWT를 자동 주입하므로 헤더 수동 처리 불필요.
@RestApi()
abstract class CommunityRemoteDataSource {
  factory CommunityRemoteDataSource(Dio dio) = _CommunityRemoteDataSource;

  /// 모집 게시글 목록 조회
  ///
  /// 응답: `{ content: CommunityPostResponse[], page: PageInfo }`
  /// [scope]가 null이면 생성된 `removeWhere`가 파라미터를 빼므로 전체 조회된다.
  ///
  /// 주의: 백엔드는 아직 `scope`를 모른다. Spring은 모르는 쿼리 파라미터를
  /// 조용히 무시하므로, 지원 전까지 Notifier가 전체 외 범위로는 호출하지 않는다.
  @GET(ApiEndpoints.communityPosts)
  Future<CommunityPostListResponseModel> getPosts({
    @Query('page') required int page,
    @Query('size') required int size,
    @Query('scope') String? scope,
  });
}
