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
  /// 응답: `{ content: CommunityPostResponse[], cursor: CursorInfo }`
  ///
  /// 서버가 허용하는 파라미터는 여덟(`cursor·size·scope·countryCode·sort·
  /// keyword·latitude·longitude`)뿐이고 그 외에는 400(`INVALID_QUERY_PARAMETER`)을
  /// 준다. Retrofit은 여기 선언된 것만 보내며, null인 값은 생성된 `removeWhere`가
  /// 빼므로 "첫 요청 = 커서 없음", "전체 = scope 생략"이 그대로 표현된다.
  ///
  /// [countryCode]는 필수다 — 목록은 DB만 보고 국가로 나뉜다(DEC-0021). 국가는
  /// [getCountry]로 먼저 구한다. 빈 문자열을 보내면 400(`COUNTRY_NOT_SPECIFIED`).
  ///
  /// [sort]는 `LATEST`·`DEADLINE`·`DISTANCE`만 동작하고 `POPULAR`는 400이다.
  /// [latitude]·[longitude]는 `sort=DISTANCE`일 때만 필수이며, 다른 정렬에서
  /// 보내면 400이다 — Repository가 그 분기를 진다.
  /// [keyword]는 공백을 제외하고 2자 이상이어야 하며 미만이면 400이다.
  ///
  /// 커서에는 국가·정렬·검색어가 봉인돼 있어, 셋 중 하나라도 직전 요청과 다르면
  /// 커서를 재사용할 수 없다(400).
  ///
  /// 주의: `scope`는 `ALL` 외 값이 아직 400이다. 확정 실패를 왕복시키지 않도록
  /// Notifier가 전체 외 범위로는 호출하지 않는다.
  @GET(ApiEndpoints.communityPosts)
  Future<CommunityPostListResponseModel> getPosts({
    @Query('cursor') String? cursor,
    @Query('size') required int size,
    @Query('scope') String? scope,
    @Query('countryCode') required String countryCode,
    @Query('sort') String? sort,
    @Query('keyword') String? keyword,
    @Query('latitude') double? latitude,
    @Query('longitude') double? longitude,
  });

  /// 좌표 국가 조회 (저장하지 않음, 로그인 불필요)
  ///
  /// 목록을 부르기 전에 국가를 한 번 정하는 용도다. 주소를 만들지 않아 벤더 호출이
  /// 1회고, 그래서 목록 자체는 외부 벤더와 완전히 분리된다(DEC-0021).
  ///
  /// 국가를 특정할 수 없는 좌표는 400(`COUNTRY_NOT_SPECIFIED`), 벤더가 둘 다
  /// 응답하지 않으면 500(`ADDRESS_LOOKUP_FAILED`).
  @GET('${ApiEndpoints.communityPosts}/country')
  Future<CommunityCountryResponseModel> getCountry({
    @Query('latitude') required double latitude,
    @Query('longitude') required double longitude,
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
  /// 400(`INVALID_MEETING_DATE`), 주소를 못 찾는 좌표면 400(`ADDRESS_NOT_FOUND`),
  /// 역지오코딩이 두 벤더 모두 실패하면 500(`ADDRESS_LOOKUP_FAILED`)이고 글은
  /// 만들어지지 않는다 — 국가 코드가 비면 어느 목록에도 안 걸리기 때문(DEC-0022).
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
  /// 좌표가 바뀌어 재변환할 때 역지오코딩이 실패하면 생성과 같은 경로로 거절된다
  /// (500 `ADDRESS_LOOKUP_FAILED`, DEC-0022).
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
