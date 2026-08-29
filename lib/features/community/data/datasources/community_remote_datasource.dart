import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/community_chat_model.dart';
import '../models/community_comment_model.dart';
import '../models/community_notification_model.dart';
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

  /// 댓글 목록 조회 (커서 페이지네이션, 비로그인 가능)
  ///
  /// 1depth 댓글만 페이징되고 답글은 각 댓글의 `replies`에 전부 담겨 온다.
  /// [cursor]는 이전 응답의 `nextCursor`(댓글 id)이며 첫 페이지는 생략한다.
  /// [size]는 1~50, 생략하면 20이다.
  @GET('${ApiEndpoints.communityPosts}/{postId}/comments')
  Future<CommunityCommentListResponseModel> getComments(
    @Path('postId') int postId, {
    @Query('cursor') int? cursor,
    @Query('size') int? size,
  });

  /// 댓글·답글 작성
  ///
  /// 201로 생성된 댓글 한 건을 돌려준다 — 목록을 다시 부르지 않고 끼워 넣는다.
  @POST('${ApiEndpoints.communityPosts}/{postId}/comments')
  Future<CommunityCommentResponseModel> createComment(
    @Path('postId') int postId,
    @Body() CommunityCommentCreateRequestModel body,
  );

  /// 댓글 삭제
  ///
  /// 204 No Content라 본문이 없다. 작성자 본인만 가능하다(403).
  /// 답글이 남아 있으면 서버가 자리만 남기고 마스킹하며, 마지막 답글이 지워지면
  /// 껍데기 부모까지 함께 정리한다(DEC-0034) — 결과를 앱이 계산할 수 없어
  /// 호출 뒤에는 목록을 다시 받는다.
  @DELETE('${ApiEndpoints.communityPosts}/comments/{commentId}')
  Future<void> deleteComment(@Path('commentId') int commentId);

  /// 게시글 좋아요 (응답 본문 없음)
  ///
  /// 이미 눌러 둔 글이면 409 `ALREADY_LIKED`. Repository가 그것을 성공으로
  /// 삼킨다 — 사용자가 원한 최종 상태가 이미 그것이기 때문이다.
  @POST('${ApiEndpoints.communityPosts}/{postId}/likes')
  Future<void> likePost(@Path('postId') int postId);

  /// 게시글 좋아요 취소. 누른 적이 없으면 404 `LIKE_NOT_FOUND`.
  @DELETE('${ApiEndpoints.communityPosts}/{postId}/likes')
  Future<void> unlikePost(@Path('postId') int postId);

  /// 게시글 스크랩. 이미 스크랩한 글이면 409 `ALREADY_SCRAPPED`.
  @POST('${ApiEndpoints.communityPosts}/{postId}/scraps')
  Future<void> scrapPost(@Path('postId') int postId);

  /// 게시글 스크랩 취소. 스크랩한 적이 없으면 404 `SCRAP_NOT_FOUND`.
  @DELETE('${ApiEndpoints.communityPosts}/{postId}/scraps')
  Future<void> unscrapPost(@Path('postId') int postId);

  /// 내 채팅방 목록 조회
  ///
  /// 참여 방 수에 상한(100)이 있어 페이징하지 않는다. 마지막 대화가 최근인
  /// 순서이며 대화가 없는 방은 맨 뒤다 — 정렬은 서버가 한다.
  ///
  /// 경로에 `{postId}`가 없다. `/{postId}/chat/...`과 형태가 달라 보이지만
  /// 유저 단위 리소스라 그렇다(`/scraps`와 같은 자리).
  @GET('${ApiEndpoints.communityPosts}/chat/rooms')
  Future<CommunityChatRoomListResponseModel> getChatRooms();

  /// 채팅방 참여
  ///
  /// 201 Created, 본문 없음. 이미 멤버면 409(`ALREADY_JOINED`)인데 화면 입장에는
  /// 영향이 없어 Repository가 성공으로 삼킨다 — 서버가 `chatJoined`를 주지 않아
  /// (BE #173) 앱이 참여 여부를 미리 알 수 없기 때문이다.
  ///
  /// 그 밖: 모집 마감·종료 400(`RECRUITMENT_CLOSED`), 정원 초과
  /// 400(`CHAT_ROOM_FULL`), 참여 방 100개 초과
  /// 400(`JOINED_CHAT_ROOM_LIMIT_EXCEEDED`).
  @POST('${ApiEndpoints.communityPosts}/{postId}/chat/join')
  Future<void> joinChat(@Path('postId') int postId);

  /// 채팅방 나가기
  ///
  /// 204 No Content. 작성자는 나갈 수 없다(400 `AUTHOR_CANNOT_LEAVE`) — 화면이
  /// 버튼 자체를 숨기지만 서버가 최종 판정이다.
  ///
  /// 성공한 뒤에야 소켓 구독을 끊는다. 서버는 **구독 시점에만** 자격을 보므로
  /// 끊지 않으면 나간 방 메시지가 계속 들어온다(DEC-0026 계약 03).
  @DELETE('${ApiEndpoints.communityPosts}/{postId}/chat/leave')
  Future<void> leaveChat(@Path('postId') int postId);

  /// 대화 내역 조회 (커서 페이지네이션)
  ///
  /// 최신순이다. [cursor]는 이전 응답의 `nextCursor`(메시지 id)이며 생략하면
  /// 가장 최근부터, [size]는 1~50이고 생략하면 20이다. `hasNext`가 true일 때만
  /// `nextCursor`가 실려 온다.
  ///
  /// 방 멤버만 부를 수 있다(403 `NOT_A_CHAT_MEMBER`) — 다른 기기에서 나갔거나
  /// 작성자가 게시글을 지운 뒤에는 이 코드가 온다.
  @GET('${ApiEndpoints.communityPosts}/{postId}/chat/messages')
  Future<CommunityChatHistoryResponseModel> getChatMessages(
    @Path('postId') int postId, {
    @Query('cursor') int? cursor,
    @Query('size') int? size,
  });

  /// 내 스크랩 목록 조회 (커서 페이지네이션, 로그인 필수)
  ///
  /// 스크랩한 순서(최신순) 고정이라 정렬·검색 파라미터가 없다. 커서는 스크랩 id
  /// 정수이고, 목록 커서(opaque 문자열)와 형식이 다르다. 비로그인은 401이다.
  @GET('${ApiEndpoints.communityPosts}/scraps')
  Future<CommunityScrapListResponseModel> getScraps({
    @Query('cursor') int? cursor,
    @Query('size') int? size,
  });

  /// 알림함 목록 조회 (커서 페이지네이션, 로그인 필수)
  ///
  /// 내 글에 달린 댓글·답글 알림을 최신순으로 준다. 최근 60일 이내 것만
  /// 내려간다(DEC-0047). 커서는 스크랩 목록과 같은 정수 형태다. 조회만으로는
  /// 읽음 처리되지 않는다(DEC-0038) — [readNotifications]를 따로 불러야 한다.
  @GET('${ApiEndpoints.communityPosts}/notifications')
  Future<CommunityNotificationListResponseModel> getNotifications({
    @Query('cursor') int? cursor,
    @Query('size') int? size,
  });

  /// 안 읽은 알림 개수 조회 (종 아이콘 배지용)
  ///
  /// 최근 60일 이내 알림 중 읽음 커서보다 나중에 생긴 것만 센다(DEC-0047).
  @GET('${ApiEndpoints.communityPosts}/notifications/unread-count')
  Future<CommunityNotificationUnreadCountResponseModel>
  getUnreadNotificationCount();

  /// 알림 읽음 처리 — 읽음 커서를 현재 시각으로 옮긴다
  ///
  /// 알림마다 저장된 값이 아니라 유저당 커서 하나라 개별 읽음 처리는
  /// 불가능하다(DEC-0038). 응답 본문 없음(204).
  @POST('${ApiEndpoints.communityPosts}/notifications/read')
  Future<void> readNotifications();

  /// 채팅방 멤버 목록 조회
  ///
  /// 사이드바의 참가자 목록과 방장 판정에 쓴다. 방 멤버만 부를 수 있다
  /// (403 `NOT_A_CHAT_MEMBER`). 페이징 없음 — 방 정원이 상한이다.
  ///
  /// 닉네임은 대화 내역과 같은 규칙이다(조회 시점 현재 값, 탈퇴자만 `"알수없음"`).
  @GET('${ApiEndpoints.communityPosts}/{postId}/chat/members')
  Future<CommunityChatMemberListResponseModel> getChatMembers(
    @Path('postId') int postId,
  );
}
