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

  /// 모집 게시글 목록 조회 (커서 페이지네이션, 국가별 분리)
  ///
  /// 응답: `{ content: CommunityPostResponse[], cursor: CursorInfo, countryCode }`
  ///
  /// 서버가 허용하는 파라미터는 여기 선언된 일곱뿐이고 그 외에는
  /// 400(`INVALID_QUERY_PARAMETER`)을 준다. Retrofit은 여기 선언된 것만 보내며,
  /// null인 값은 생성된 `removeWhere`가 빼므로 "첫 요청 = 커서 없음",
  /// "전체 = scope 생략"이 그대로 표현된다. `sort`는 기본값 `LATEST`만 동작해
  /// 선언하지 않는다.
  ///
  /// [countryCode] 또는 [latitude]·[longitude] 중 하나는 반드시 있어야 한다 —
  /// 둘 다 없으면 400(`COUNTRY_NOT_SPECIFIED`). 좌표로 보내면 서버가 국가를
  /// 판별해 응답 `countryCode`에 실어 주므로, 다음 페이지부터는 그 값만 보낸다.
  ///
  /// 주의: `scope`는 `ALL` 외 값이 아직 400이다. 확정 실패를 왕복시키지 않도록
  /// Notifier가 전체 외 범위로는 호출하지 않는다.
  @GET(ApiEndpoints.communityPosts)
  Future<CommunityPostListResponseModel> getPosts({
    @Query('cursor') String? cursor,
    @Query('size') required int size,
    @Query('scope') String? scope,
    @Query('countryCode') String? countryCode,
    @Query('latitude') double? latitude,
    @Query('longitude') double? longitude,
  });

  /// 좌표 주소 조회 (저장하지 않음)
  ///
  /// 작성 화면에서 핀을 찍은 직후 위치를 확인시키는 용도다. 주소가 없는 좌표는
  /// 400(`ADDRESS_NOT_FOUND`), 조회 자체가 실패하면 500(`ADDRESS_LOOKUP_FAILED`).
  @GET('${ApiEndpoints.communityPosts}/address')
  Future<CommunityAddressResponseModel> getAddress({
    @Query('latitude') required double latitude,
    @Query('longitude') required double longitude,
  });

  /// 게시글 생성
  ///
  /// 201로 생성된 글 전체를 돌려준다. 로그인 필요(401). 모임 시각이 과거면
  /// 400(`INVALID_MEETING_DATE`), 주소를 못 찾는 좌표면 400(`ADDRESS_NOT_FOUND`).
  @POST(ApiEndpoints.communityPosts)
  Future<CommunityPostResponseModel> createPost(
    @Body() CommunityPostWriteRequestModel body,
  );

  /// 게시글 단건 조회
  ///
  /// 비로그인도 열람 가능하다 (DEC-0014) — `AuthInterceptor`가 토큰을 못 붙여도
  /// 200이 온다. 없는 글이면 404(`POST_NOT_FOUND`).
  @GET('${ApiEndpoints.communityPosts}/{postId}')
  Future<CommunityPostResponseModel> getPost(@Path('postId') int postId);

  /// 게시글 수정 (전체 교체)
  ///
  /// 작성자 본인만 가능하다 — 아니면 403(`FORBIDDEN_NOT_AUTHOR`).
  @PUT('${ApiEndpoints.communityPosts}/{postId}')
  Future<CommunityPostResponseModel> updatePost(
    @Path('postId') int postId,
    @Body() CommunityPostWriteRequestModel body,
  );

  /// 게시글 삭제
  ///
  /// 204 No Content라 본문이 없다. 작성자 본인만 가능하다(403).
  @DELETE('${ApiEndpoints.communityPosts}/{postId}')
  Future<void> deletePost(@Path('postId') int postId);

  /// 모집 상태 변경 (모집중 ↔ 마감)
  ///
  /// 수정된 게시글 전체를 돌려주므로 응답을 그대로 화면 갱신에 쓴다.
  /// 작성자 본인만 가능하다(403).
  @PATCH('${ApiEndpoints.communityPosts}/{postId}/status')
  Future<CommunityPostResponseModel> updateStatus(
    @Path('postId') int postId,
    @Body() CommunityPostStatusRequestModel body,
  );
}
