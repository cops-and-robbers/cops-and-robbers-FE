import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/models/page_info_model.dart';
import 'package:cops_and_robbers/features/community/data/datasources/community_remote_datasource.dart';
import 'package:cops_and_robbers/features/community/data/models/community_post_model.dart';
import 'package:cops_and_robbers/features/community/data/repositories/community_repository_impl.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대체한다 — 그 안쪽 변환 로직은 전부 실물이다.
class _FakeCommunityRemoteDataSource implements CommunityRemoteDataSource {
  CommunityPostListResponseModel? responseToReturn;
  Object? errorToThrow;

  String? lastScope;
  int? lastPage;
  bool called = false;

  @override
  Future<CommunityPostListResponseModel> getPosts({
    required int page,
    required int size,
    String? scope,
  }) async {
    called = true;
    lastPage = page;
    lastScope = scope;
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
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
  'title': '같이 경찰과 도둑 하실 분!',
  'content': '강남역 근처에서 5명 모집합니다.',
  'meetingAt': '2026-08-10T14:00:00+09:00',
  'location': location ?? {'latitude': 37.4979, 'longitude': 127.0276},
  'maxParticipants': 10,
  'status': status,
  'createdAt': '2026-08-07T12:00:00+09:00',
  ...extra,
};

CommunityPostListResponseModel _listOf(
  List<Map<String, dynamic>> jsons, {
  int number = 0,
  int totalPages = 1,
}) => CommunityPostListResponseModel(
  content: jsons.map(CommunityPostResponseModel.fromJson).toList(),
  page: PageInfoModel(
    size: jsons.length,
    number: number,
    totalElements: jsons.length,
    totalPages: totalPages,
  ),
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

      final result = await repo.getPosts(page: 0, size: 20);

      expect(result.items[0].status, CommunityPostStatus.recruiting);
      expect(result.items[1].status, CommunityPostStatus.completed);
    });

    test('leaves_pending_backend_fields_null_when_absent', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(page: 0, size: 20)).items.single;

      expect(entity.address, isNull);
      expect(entity.currentParticipants, isNull);
      expect(entity.likeCount, isNull);
      expect(entity.bookmarkCount, isNull);
      // 있는 값은 정상 매핑되어야 한다.
      expect(entity.maxParticipants, 10);
      expect(entity.latitude, 37.4979);
      expect(entity.longitude, 127.0276);
    });

    test('carries_pending_backend_fields_into_entity_when_present', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'address': '서울시 광진구 세종대학교',
            },
            extra: {
              'currentParticipants': 2,
              'likeCount': 6,
              'bookmarkCount': 3,
            },
          ),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(page: 0, size: 20)).items.single;

      expect(entity.address, '서울시 광진구 세종대학교');
      expect(entity.currentParticipants, 2);
      expect(entity.likeCount, 6);
      expect(entity.bookmarkCount, 3);
    });

    test('normalizes_kst_timestamps_to_device_local_time', () async {
      // 백엔드가 +09:00을 붙여 보내면 DateTime.parse가 UTC로 저장한다.
      // .month/.day를 그대로 읽으면 표기가 하루 밀린다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(page: 0, size: 20)).items.single;

      expect(entity.meetingAt.isUtc, false);
      expect(
        entity.meetingAt.isAtSameMomentAs(DateTime.utc(2026, 8, 10, 5, 0, 0)),
        true,
      );
    });

    test('omits_scope_query_when_scope_is_all', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(page: 0, size: 20, scope: CommunityScope.all);

      expect(fake.called, true);
      expect(fake.lastScope, isNull);
    });

    test('maps_page_envelope_to_page_entity', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()], number: 2, totalPages: 5);
      final repo = CommunityRepositoryImpl(fake);

      final result = await repo.getPosts(page: 2, size: 20);

      expect(result.currentPage, 2);
      expect(result.totalPages, 5);
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(500);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.getPosts(page: 0, size: 20),
        throwsA(isA<AppException>()),
      );
    });

    test('wraps_unknown_wire_status_into_server_exception', () async {
      // communityPostStatusFromWire의 FormatException이 raw로 새면 안 된다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson(status: 'CANCELLED')]);
      final repo = CommunityRepositoryImpl(fake);

      expect(
        () => repo.getPosts(page: 0, size: 20),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
