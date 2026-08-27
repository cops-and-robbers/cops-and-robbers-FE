import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/data/datasources/community_remote_datasource.dart';
import 'package:cops_and_robbers/features/community/data/models/community_chat_model.dart';
import 'package:cops_and_robbers/features/community/data/models/community_comment_model.dart';
import 'package:cops_and_robbers/features/community/data/models/community_post_model.dart';
import 'package:cops_and_robbers/features/community/data/repositories/community_repository_impl.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대체한다 — 그 안쪽 변환 로직은 전부 실물이다.
class _FakeCommunityRemoteDataSource implements CommunityRemoteDataSource {
  CommunityPostListResponseModel? responseToReturn;
  Object? errorToThrow;

  String? lastScope;
  String? lastCursor;
  String? lastCountryCode;
  double? lastLatitude;
  double? lastLongitude;
  bool called = false;

  String? lastSort;
  String? lastKeyword;
  double? lastListLatitude;
  double? lastListLongitude;

  @override
  Future<CommunityPostListResponseModel> getPosts({
    String? cursor,
    required int size,
    String? scope,
    required String countryCode,
    String? sort,
    String? keyword,
    double? latitude,
    double? longitude,
  }) async {
    called = true;
    lastCursor = cursor;
    lastScope = scope;
    lastCountryCode = countryCode;
    lastSort = sort;
    lastKeyword = keyword;
    lastListLatitude = latitude;
    lastListLongitude = longitude;
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }

  // ── 국가 조회 ──
  CommunityCountryResponseModel? countryToReturn;

  @override
  Future<CommunityCountryResponseModel> getCountry({
    required double latitude,
    required double longitude,
  }) async {
    lastLatitude = latitude;
    lastLongitude = longitude;
    if (errorToThrow != null) throw errorToThrow!;
    return countryToReturn!;
  }

  // ── 주소 조회 ──
  CommunityAddressResponseModel? addressToReturn;

  @override
  Future<CommunityAddressResponseModel> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    lastLatitude = latitude;
    lastLongitude = longitude;
    if (errorToThrow != null) throw errorToThrow!;
    return addressToReturn!;
  }

  // ── 단건 계열 ──
  // 목록 테스트와 같은 페이크를 공유한다. 응답·예외는 위 두 필드를 재사용하지
  // 않고 각각 따로 둔다 — 목록 응답 타입과 다르기 때문이다.
  CommunityPostResponseModel? postToReturn;
  CommunityPostWriteRequestModel? lastUpdateBody;
  CommunityPostWriteRequestModel? lastCreateBody;
  CommunityPostStatusRequestModel? lastStatusBody;
  int? lastPostId;

  @override
  Future<CommunityPostResponseModel> createPost(
    CommunityPostWriteRequestModel body,
  ) async {
    lastCreateBody = body;
    if (errorToThrow != null) throw errorToThrow!;
    return postToReturn!;
  }

  @override
  Future<CommunityPostResponseModel> getPost(int postId) async {
    lastPostId = postId;
    if (errorToThrow != null) throw errorToThrow!;
    return postToReturn!;
  }

  @override
  Future<CommunityPostResponseModel> updatePost(
    int postId,
    CommunityPostWriteRequestModel body,
  ) async {
    lastPostId = postId;
    lastUpdateBody = body;
    if (errorToThrow != null) throw errorToThrow!;
    return postToReturn!;
  }

  @override
  Future<void> deletePost(int postId) async {
    lastPostId = postId;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<CommunityPostResponseModel> updateStatus(
    int postId,
    CommunityPostStatusRequestModel body,
  ) async {
    lastPostId = postId;
    lastStatusBody = body;
    if (errorToThrow != null) throw errorToThrow!;
    return postToReturn!;
  }

  // 댓글은 CommunityCommentRepository가 다룬다 — 게시글 테스트가 이쪽을 건드리면
  // 조용히 통과하는 대신 그 자리에서 드러나야 한다.
  @override
  Future<CommunityCommentListResponseModel> getComments(
    int postId, {
    int? cursor,
    int? size,
  }) => throw UnimplementedError('이 테스트는 댓글 조회를 쓰지 않는다');

  @override
  Future<CommunityCommentResponseModel> createComment(
    int postId,
    CommunityCommentCreateRequestModel body,
  ) => throw UnimplementedError('이 테스트는 댓글 작성을 쓰지 않는다');

  @override
  Future<void> deleteComment(int commentId) =>
      throw UnimplementedError('이 테스트는 댓글 삭제를 쓰지 않는다');

  @override
  Future<void> likePost(int postId) =>
      throw UnimplementedError('이 테스트는 좋아요를 쓰지 않는다');

  @override
  Future<void> unlikePost(int postId) =>
      throw UnimplementedError('이 테스트는 좋아요 취소를 쓰지 않는다');

  @override
  Future<void> scrapPost(int postId) =>
      throw UnimplementedError('이 테스트는 스크랩을 쓰지 않는다');

  @override
  Future<void> unscrapPost(int postId) =>
      throw UnimplementedError('이 테스트는 스크랩 취소를 쓰지 않는다');

  @override
  Future<CommunityChatRoomListResponseModel> getChatRooms() =>
      throw UnimplementedError('이 테스트는 채팅방 목록을 쓰지 않는다');

  @override
  Future<void> joinChat(int postId) =>
      throw UnimplementedError('이 테스트는 채팅방 참여를 쓰지 않는다');

  @override
  Future<void> leaveChat(int postId) =>
      throw UnimplementedError('이 테스트는 채팅방 나가기를 쓰지 않는다');

  @override
  Future<CommunityChatHistoryResponseModel> getChatMessages(
    int postId, {
    int? cursor,
    int? size,
  }) => throw UnimplementedError('이 테스트는 대화 내역 조회를 쓰지 않는다');

  @override
  Future<CommunityChatMemberListResponseModel> getChatMembers(int postId) =>
      throw UnimplementedError('이 테스트는 채팅방 멤버 조회를 쓰지 않는다');

  // ── 내 스크랩 목록 ──
  CommunityScrapListResponseModel? scrapsToReturn;
  int? lastScrapsCursor;
  int? lastScrapsSize;

  @override
  Future<CommunityScrapListResponseModel> getScraps({
    int? cursor,
    int? size,
  }) async {
    lastScrapsCursor = cursor;
    lastScrapsSize = size;
    if (errorToThrow != null) throw errorToThrow!;
    return scrapsToReturn!;
  }
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/community-posts'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/community-posts'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/community-posts',
    },
  ),
  type: DioExceptionType.badResponse,
);

Map<String, dynamic> _postJson({
  int id = 1,
  String status = 'RECRUITING',
  Map<String, dynamic>? location,
  Map<String, dynamic> extra = const {},
}) => {
  'id': id,
  'writerId': 7,
  'writerNickname': '무서운경찰관',
  'title': '같이 경찰과 도둑 하실 분!',
  'content': '강남역 근처에서 5명 모집합니다.',
  'meetingAt': '2026-08-10T14:00:00+09:00',
  'location': location ?? {'latitude': 37.4979, 'longitude': 127.0276},
  'maxParticipants': 10,
  'status': status,
  'createdAt': '2026-08-07T12:00:00+09:00',
  'likeCount': 0,
  'scrapCount': 0,
  'liked': false,
  'scrapped': false,
  ...extra,
};

CommunityPostListResponseModel _listOf(
  List<Map<String, dynamic>> jsons, {
  String? nextCursor,
  bool hasNext = false,
}) => CommunityPostListResponseModel(
  content: jsons.map(CommunityPostResponseModel.fromJson).toList(),
  cursor: CursorInfoModel(nextCursor: nextCursor, hasNext: hasNext),
);

// 스크랩 목록 봉투는 피드와 달리 평평한 정수 커서다 — cursor 객체로 감싸지 않는다.
CommunityScrapListResponseModel _scrapListOf(
  List<Map<String, dynamic>> jsons, {
  int? nextCursor,
  bool hasNext = false,
}) => CommunityScrapListResponseModel(
  content: jsons.map(CommunityPostResponseModel.fromJson).toList(),
  hasNext: hasNext,
  nextCursor: nextCursor,
);

void main() {
  group('CommunityRepositoryImpl.getPosts', () {
    test('maps_wire_status_to_domain_enum', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(id: 1, status: 'RECRUITING'),
          _postJson(id: 2, status: 'COMPLETED'),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(size: 20, countryCode: 'KR');

      expect(result.items[0].status, CommunityPostStatus.recruiting);
      expect(result.items[1].status, CommunityPostStatus.completed);
    });

    test('joins_region_and_place_name_for_location_label', () async {
      // 서버 지역과 작성자 장소명을 병기한다 (DEC-0015) — 접어서 하나만 쓰지 않는다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'region': '서울특별시 광진구 군자동',
              'placeName': '세종대학교 정문',
            },
          ),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(
        size: 20,
        countryCode: 'KR',
      )).items.single;

      expect(entity.locationLabel, '서울특별시 광진구 군자동 · 세종대학교 정문');
    });

    test('keeps_place_name_alone_when_geocoding_failed', () async {
      // 역지오코딩이 실패해도 작성자가 입력한 장소명은 살아 있다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'placeName': '세종대학교 정문',
            },
          ),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(
        size: 20,
        countryCode: 'KR',
      )).items.single;

      expect(entity.locationLabel, '세종대학교 정문');
    });

    test('leaves_location_label_null_when_both_parts_are_missing', () async {
      // 둘 다 없으면 카드가 위치 행을 숨긴다 — 좌표는 사용자에게 무의미하다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(
        size: 20,
        countryCode: 'KR',
      )).items.single;

      expect(entity.locationLabel, isNull);
      // 좌표는 상세 지도용으로 그대로 살아 있어야 한다.
      expect(entity.latitude, 37.4979);
      expect(entity.longitude, 127.0276);
    });

    test('forwards_country_code_when_listing', () async {
      // 목록은 국가별로 나뉘고 countryCode만 받는다 — 좌표를 보내면 400이다 (DEC-0021).
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(size: 20, countryCode: 'JP');

      expect(fake.lastCountryCode, 'JP');
    });

    test('leaves_pending_backend_fields_null_when_absent', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(
        size: 20,
        countryCode: 'KR',
      )).items.single;

      expect(entity.currentParticipants, isNull);
      expect(entity.maxParticipants, 10);
    });

    test('normalizes_kst_timestamps_to_device_local_time', () async {
      // 백엔드가 +09:00을 붙여 보내면 DateTime.parse가 UTC로 저장한다.
      // .month/.day를 그대로 읽으면 표기가 하루 밀린다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(
        size: 20,
        countryCode: 'KR',
      )).items.single;

      expect(entity.meetingAt.isUtc, false);
      expect(
        entity.meetingAt.isAtSameMomentAs(DateTime.utc(2026, 8, 10, 5, 0, 0)),
        true,
      );
    });

    test('omits_cursor_query_on_first_request', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(size: 20, countryCode: 'KR');

      expect(fake.called, true);
      expect(fake.lastCursor, isNull);
    });

    test('forwards_cursor_verbatim_when_loading_next_page', () async {
      // 커서 문자열은 서버 내부 형식이다 — 열어보거나 가공하지 않는다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(
        cursor: 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg',
        size: 20,
        countryCode: 'KR',
      );

      expect(fake.lastCursor, 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg');
    });

    test('omits_scope_query_when_scope_is_all', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(
        size: 20,
        scope: CommunityScope.all,
        countryCode: 'KR',
      );

      expect(fake.called, true);
      expect(fake.lastScope, isNull);
    });

    test('maps_cursor_envelope_to_page_entity', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf(
          [_postJson()],
          nextCursor: 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg',
          hasNext: true,
        );
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(size: 20, countryCode: 'KR');

      expect(result.nextCursor, 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg');
      expect(result.hasNext, true);
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(500);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.getPosts(size: 20, countryCode: 'KR'),
        throwsA(isA<AppException>()),
      );
    });

    test('falls_back_to_ended_when_wire_status_is_unknown', () async {
      // 알 수 없는 상태 하나가 목록 한 장을 통째로 날리지 않아야 한다. '종료'로
      // 보수적으로 잡아야 참여 표시와 상태 변경이 둘 다 막힌다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson(status: 'CANCELLED')]);
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(size: 20, countryCode: 'KR');

      expect(result.items.single.status, CommunityPostStatus.ended);
    });

    test('maps_ended_status_when_server_marks_meeting_as_past', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson(status: 'ENDED')]);
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(size: 20, countryCode: 'KR');

      expect(result.items.single.status, CommunityPostStatus.ended);
    });

    test('sends_coordinates_only_when_sort_is_distance', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(
        size: 20,
        countryCode: 'KR',
        sort: CommunitySortOption.distance,
        latitude: 37.4979,
        longitude: 127.0276,
      );

      expect(fake.lastSort, 'DISTANCE');
      expect(fake.lastListLatitude, 37.4979);
      expect(fake.lastListLongitude, 127.0276);
    });

    test('omits_coordinates_when_sort_is_not_distance', () async {
      // 거리순이 아닌데 좌표를 실으면 서버가 400을 준다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(
        size: 20,
        countryCode: 'KR',
        sort: CommunitySortOption.deadline,
        latitude: 37.4979,
        longitude: 127.0276,
      );

      expect(fake.lastSort, 'DEADLINE');
      expect(fake.lastListLatitude, isNull);
      expect(fake.lastListLongitude, isNull);
    });

    test('sends_keyword_when_search_term_is_given', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(size: 20, countryCode: 'KR', keyword: '서울');

      expect(fake.lastKeyword, '서울');
      // 기본 정렬이 실제로 서버 계약값 LATEST로 나가는지 — sort를 생략하는
      // 케이스라 여기서 함께 확인한다.
      expect(fake.lastSort, 'LATEST');
    });
  });

  group('CommunityRepositoryImpl.getPost', () {
    test('maps_response_to_entity_when_post_exists', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..postToReturn = CommunityPostResponseModel.fromJson(
          _postJson(
            id: 42,
            status: 'COMPLETED',
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'region': '서울특별시 광진구 군자동',
              'placeName': '세종대학교 정문',
            },
            // 넷 다 비대칭 값으로 둔다 — 0/0/false/false 조합이면 필드가
            // 뒤바뀌어도(liked↔scrapped, likeCount↔scrapCount) 조용히 통과한다.
            extra: {
              'likeCount': 6,
              'scrapCount': 3,
              'liked': true,
              'scrapped': false,
            },
          ),
        );
      final repo = CommunityRepositoryImpl(fake);

      final post = await repo.getPost(42);

      expect(post.id, 42);
      expect(post.status, CommunityPostStatus.completed);
      expect(post.locationLabel, '서울특별시 광진구 군자동 · 세종대학교 정문');
      expect(post.likeCount, 6);
      expect(post.isLiked, isTrue);
      expect(post.scrapCount, 3);
      expect(post.isScrapped, isFalse);
      expect(fake.lastPostId, 42);
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(404);
      final repo = CommunityRepositoryImpl(fake);

      expect(() => repo.getPost(1), throwsA(isA<AppException>()));
    });
  });

  group('CommunityRepositoryImpl.updatePost', () {
    /// 로컬 DateTime을 그대로 직렬화하면 timezone suffix가 빠져 서버가 자기
    /// 로컬 시각으로 읽는다 — 모임 시각이 통째로 밀리는 버그라 값으로 못 박는다.
    test('sends_meeting_time_as_utc_iso_when_local_time_given', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..postToReturn = CommunityPostResponseModel.fromJson(_postJson());
      final repo = CommunityRepositoryImpl(fake);

      // KST 18:00 == UTC 09:00
      await repo.updatePost(
        postId: 7,
        title: '수정 제목',
        content: '수정 본문',
        meetingAt: DateTime.utc(2026, 9, 10, 9).toLocal(),
        latitude: 37.4979,
        longitude: 127.0276,
        placeName: '세종대학교 정문',
        maxParticipants: 8,
      );

      expect(
        fake.lastUpdateBody!.toJson()['meetingAt'],
        '2026-09-10T09:00:00.000Z',
      );
    });

    test('sends_place_name_with_coordinates_in_location', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..postToReturn = CommunityPostResponseModel.fromJson(_postJson());
      final repo = CommunityRepositoryImpl(fake);

      await repo.updatePost(
        postId: 7,
        title: '수정 제목',
        content: '수정 본문',
        meetingAt: DateTime.utc(2026, 9, 10, 9),
        latitude: 37.4979,
        longitude: 127.0276,
        placeName: '세종대학교 정문',
        maxParticipants: 8,
      );

      // region·countryCode는 서버가 채우는 값이라 실리면 안 되고, placeName은
      // 작성자 입력이라 반드시 실려야 한다 (빠지면 400).
      expect(fake.lastUpdateBody!.toJson()['location'], {
        'latitude': 37.4979,
        'longitude': 127.0276,
        'placeName': '세종대학교 정문',
      });
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(403);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.updatePost(
          postId: 7,
          title: 't',
          content: 'c',
          meetingAt: DateTime.utc(2026, 9, 10),
          latitude: 0,
          longitude: 0,
          placeName: 'p',
          maxParticipants: 2,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('CommunityRepositoryImpl.createPost', () {
    test('sends_full_write_body_when_post_submitted', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..postToReturn = CommunityPostResponseModel.fromJson(_postJson(id: 99));
      final repo = CommunityRepositoryImpl(fake);

      final created = await repo.createPost(
        title: '같이 하실 분',
        content: '어린이대공원에서 봐요',
        meetingAt: DateTime.utc(2026, 9, 10, 9),
        latitude: 37.5502,
        longitude: 127.0736,
        placeName: '어린이대공원 정문',
        maxParticipants: 6,
      );

      final body = fake.lastCreateBody!.toJson();
      expect(body['title'], '같이 하실 분');
      expect(body['maxParticipants'], 6);
      expect(body['meetingAt'], '2026-09-10T09:00:00.000Z');
      expect(body['location'], {
        'latitude': 37.5502,
        'longitude': 127.0736,
        'placeName': '어린이대공원 정문',
      });
      // 생성된 글을 그대로 돌려주므로 호출자가 화면 전환에 바로 쓴다.
      expect(created.id, 99);
    });

    test('wraps_dio_error_into_app_exception', () async {
      // 과거 모임 시각(INVALID_MEETING_DATE)·주소 없는 좌표(ADDRESS_NOT_FOUND)가
      // 둘 다 400으로 온다.
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(400);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.createPost(
          title: 't',
          content: 'c',
          meetingAt: DateTime.utc(2020, 1, 1),
          latitude: 0,
          longitude: 0,
          placeName: 'p',
          maxParticipants: 2,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('CommunityRepositoryImpl.getAddress', () {
    test('maps_address_response_to_entity_when_pin_dropped', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..addressToReturn = CommunityAddressResponseModel.fromJson({
          'region': '서울특별시 광진구 화양동',
          'address': '서울특별시 광진구 화양동 1-20',
          'countryCode': 'KR',
        });
      final repo = CommunityRepositoryImpl(fake);

      final address = await repo.getAddress(
        latitude: 37.5502,
        longitude: 127.0736,
      );

      expect(address.region, '서울특별시 광진구 화양동');
      expect(address.address, '서울특별시 광진구 화양동 1-20');
      expect(address.countryCode, 'KR');
      expect(fake.lastLatitude, 37.5502);
      expect(fake.lastLongitude, 127.0736);
    });

    test('wraps_dio_error_into_app_exception', () async {
      // 주소 없는 좌표는 400(ADDRESS_NOT_FOUND) — 화면이 "다른 곳을 골라주세요"로
      // 안내할 수 있게 AppException으로 통일한다.
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(400);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.getAddress(latitude: 0, longitude: 0),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('CommunityRepositoryImpl.getCountryCode', () {
    test('returns_server_country_code_when_position_given', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..countryToReturn = const CommunityCountryResponseModel(
          countryCode: 'JP',
        );
      final repo = CommunityRepositoryImpl(fake);

      final code = await repo.getCountryCode(
        latitude: 35.6895,
        longitude: 139.6917,
      );

      expect(code, 'JP');
      expect(fake.lastLatitude, 35.6895);
      expect(fake.lastLongitude, 139.6917);
    });

    test('returns_null_when_server_omits_country_code', () async {
      // 기기 로케일로 물러서는 판단은 호출자 몫이다 — 여기서 'KR' 같은 값으로
      // 메우면 호출자가 "서버가 모른다"를 구분하지 못한다.
      final fake = _FakeCommunityRemoteDataSource()
        ..countryToReturn = const CommunityCountryResponseModel();
      final repo = CommunityRepositoryImpl(fake);

      expect(await repo.getCountryCode(latitude: 0, longitude: 0), isNull);
    });

    test('wraps_dio_error_into_app_exception', () async {
      // 국가를 못 정하는 좌표 400(COUNTRY_NOT_SPECIFIED)·벤더 장애 500
      // (ADDRESS_LOOKUP_FAILED) 모두 AppException — 호출자는 종류를 가리지 않고
      // 기기 로케일로 물러선다.
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(500);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.getCountryCode(latitude: 0, longitude: 0),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('CommunityRepositoryImpl.deletePost', () {
    test('completes_when_server_returns_no_content', () async {
      final fake = _FakeCommunityRemoteDataSource();
      final repo = CommunityRepositoryImpl(fake);

      await repo.deletePost(7);

      expect(fake.lastPostId, 7);
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(403);
      final repo = CommunityRepositoryImpl(fake);

      expect(() => repo.deletePost(7), throwsA(isA<AppException>()));
    });
  });

  group('CommunityRepositoryImpl.updateStatus', () {
    test('sends_wire_string_when_domain_status_given', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..postToReturn = CommunityPostResponseModel.fromJson(
          _postJson(status: 'COMPLETED'),
        );
      final repo = CommunityRepositoryImpl(fake);

      final post = await repo.updateStatus(
        postId: 7,
        status: CommunityPostStatus.completed,
      );

      expect(fake.lastStatusBody!.status, 'COMPLETED');
      // 변경된 글을 돌려주므로 호출자가 화면 갱신에 바로 쓴다.
      expect(post.status, CommunityPostStatus.completed);
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(403);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.updateStatus(
          postId: 7,
          status: CommunityPostStatus.recruiting,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('CommunityRepositoryImpl.getScraps', () {
    test('maps_scrap_page_with_integer_cursor', () async {
      // 커서가 정수 그대로 넘어와야 한다 — 문자열로 바꿔 들고 있으면 다음
      // 요청에서 다시 파싱해야 하고, 실패 지점이 하나 늘어난다.
      final fake = _FakeCommunityRemoteDataSource()
        ..scrapsToReturn = _scrapListOf(
          [
            _postJson(extra: {'scrapped': true}),
          ],
          nextCursor: 12,
          hasNext: true,
        );
      final repository = CommunityRepositoryImpl(fake);

      final page = await repository.getScraps(cursor: null, size: 20);

      expect(page.items.single.isScrapped, isTrue);
      expect(page.nextCursor, 12);
      expect(page.hasNext, isTrue);
    });

    test('maps_null_cursor_and_no_next_page_on_last_page', () async {
      // 위 테스트와 반대 극단 — hasNext/nextCursor가 뒤집혀도 위 테스트만으론
      // 못 잡는다. 둘을 같이 둬야 상수 반환 같은 얕은 구현이 드러난다.
      final fake = _FakeCommunityRemoteDataSource()
        ..scrapsToReturn = _scrapListOf([_postJson()], hasNext: false);
      final repository = CommunityRepositoryImpl(fake);

      final page = await repository.getScraps(cursor: 12, size: 20);

      expect(page.items.single.isScrapped, isFalse);
      expect(page.nextCursor, isNull);
      expect(page.hasNext, isFalse);
    });

    test('forwards_cursor_and_size_to_datasource_verbatim', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..scrapsToReturn = _scrapListOf([]);
      final repository = CommunityRepositoryImpl(fake);

      await repository.getScraps(cursor: 12, size: 7);

      expect(fake.lastScrapsCursor, 12);
      expect(fake.lastScrapsSize, 7);
    });

    test('wraps_dio_error_into_app_exception', () async {
      // 비로그인 401을 포함해 데이터소스 예외는 전부 AppException으로 통일된다.
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(401);
      final repository = CommunityRepositoryImpl(fake);

      expect(
        () => repository.getScraps(cursor: null, size: 20),
        throwsA(isA<AppException>()),
      );
    });
  });
}
