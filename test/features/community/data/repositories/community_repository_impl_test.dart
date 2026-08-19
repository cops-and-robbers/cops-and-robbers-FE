import 'package:cops_and_robbers/core/errors/app_exception.dart';
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
  String? lastCursor;
  bool called = false;

  @override
  Future<CommunityPostListResponseModel> getPosts({
    String? cursor,
    required int size,
    String? scope,
  }) async {
    called = true;
    lastCursor = cursor;
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
  'writerNickname': '무서운경찰관',
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
  String? nextCursor,
  bool hasNext = false,
}) => CommunityPostListResponseModel(
  content: jsons.map(CommunityPostResponseModel.fromJson).toList(),
  cursor: CursorInfoModel(nextCursor: nextCursor, hasNext: hasNext),
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

      final result = await repo.getPosts(size: 20);

      expect(result.items[0].status, CommunityPostStatus.recruiting);
      expect(result.items[1].status, CommunityPostStatus.completed);
    });

    test('prefers_building_name_for_location_label', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'address': '서울 광진구 군자동 98',
              'roadAddress': '서울특별시 광진구 능동로 209',
              'buildingName': '세종대학교',
            },
          ),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(size: 20)).items.single;

      expect(entity.locationLabel, '세종대학교');
    });

    test('falls_back_to_road_address_when_building_name_is_missing', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'address': '서울 광진구 군자동 98',
              'roadAddress': '서울특별시 광진구 능동로 209',
            },
          ),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(size: 20)).items.single;

      expect(entity.locationLabel, '서울특별시 광진구 능동로 209');
    });

    test('falls_back_to_lot_address_when_road_address_is_missing', () async {
      // 도로명이 없는 지역 — 지번만 내려온다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([
          _postJson(
            location: {
              'latitude': 37.4979,
              'longitude': 127.0276,
              'address': '서울 광진구 군자동 98',
            },
          ),
        ]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(size: 20)).items.single;

      expect(entity.locationLabel, '서울 광진구 군자동 98');
    });

    test('leaves_location_label_null_when_geocoding_failed', () async {
      // 셋 다 null이면 카드가 위치 행을 숨긴다 — 좌표는 사용자에게 무의미하다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(size: 20)).items.single;

      expect(entity.locationLabel, isNull);
      // 좌표는 상세 지도용으로 그대로 살아 있어야 한다.
      expect(entity.latitude, 37.4979);
      expect(entity.longitude, 127.0276);
    });

    test('leaves_pending_backend_fields_null_when_absent', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(size: 20)).items.single;

      expect(entity.currentParticipants, isNull);
      expect(entity.likeCount, isNull);
      expect(entity.bookmarkCount, isNull);
      expect(entity.maxParticipants, 10);
    });

    test('normalizes_kst_timestamps_to_device_local_time', () async {
      // 백엔드가 +09:00을 붙여 보내면 DateTime.parse가 UTC로 저장한다.
      // .month/.day를 그대로 읽으면 표기가 하루 밀린다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      final entity = (await repo.getPosts(size: 20)).items.single;

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

      await repo.getPosts(size: 20);

      expect(fake.called, true);
      expect(fake.lastCursor, isNull);
    });

    test('forwards_cursor_verbatim_when_loading_next_page', () async {
      // 커서 문자열은 서버 내부 형식이다 — 열어보거나 가공하지 않는다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(cursor: 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg', size: 20);

      expect(fake.lastCursor, 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg');
    });

    test('omits_scope_query_when_scope_is_all', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson()]);
      final repo = CommunityRepositoryImpl(fake);

      await repo.getPosts(size: 20, scope: CommunityScope.all);

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

      final result = await repo.getPosts(size: 20);

      expect(result.nextCursor, 'MjAyNi0wOC0xNVQxMjozMDo0NXw0Mg');
      expect(result.hasNext, true);
    });

    test('wraps_dio_error_into_app_exception', () async {
      final fake = _FakeCommunityRemoteDataSource()
        ..errorToThrow = _dioError(500);
      final repo = CommunityRepositoryImpl(fake);

      expect(() => repo.getPosts(size: 20), throwsA(isA<AppException>()));
    });

    test('wraps_unknown_wire_status_into_server_exception', () async {
      // communityPostStatusFromWire의 FormatException이 raw로 새면 안 된다.
      final fake = _FakeCommunityRemoteDataSource()
        ..responseToReturn = _listOf([_postJson(status: 'CANCELLED')]);
      final repo = CommunityRepositoryImpl(fake);

      expect(() => repo.getPosts(size: 20), throwsA(isA<ServerException>()));
    });
  });
}
