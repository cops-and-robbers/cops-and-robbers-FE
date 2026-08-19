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

  /// 모집 게시글 목록 조회 (커서 페이지네이션)
  ///
  /// 응답: `{ content: CommunityPostResponse[], cursor: CursorInfo }`
  ///
  /// 서버가 허용하는 파라미터는 `cursor`·`size`·`scope`·`sort` 넷뿐이고 그 외에는
  /// 400을 준다. Retrofit은 여기 선언된 것만 보내며, null인 값은 생성된
  /// `removeWhere`가 빼므로 "첫 요청 = 커서 없음", "전체 = scope 생략"이 그대로
  /// 표현된다. `sort`는 기본값 `LATEST`만 동작해 보내지 않는다.
  ///
  /// 주의: `scope`는 `ALL` 외 값이 아직 400이다. 확정 실패를 왕복시키지 않도록
  /// Notifier가 전체 외 범위로는 호출하지 않는다.
  @GET(ApiEndpoints.communityPosts)
  Future<CommunityPostListResponseModel> getPosts({
    @Query('cursor') String? cursor,
    @Query('size') required int size,
    @Query('scope') String? scope,
  });
}
