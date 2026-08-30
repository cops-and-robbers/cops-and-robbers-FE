import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/models/page_info_model.dart';
import 'package:cops_and_robbers/features/notice/data/datasources/notice_remote_datasource.dart';
import 'package:cops_and_robbers/features/notice/data/models/notice_response_model.dart';
import 'package:cops_and_robbers/features/notice/data/repositories/notice_repository_impl.dart';
import 'package:cops_and_robbers/features/notice/domain/entities/notice_category.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNoticeRemoteDataSource implements NoticeRemoteDataSource {
  NoticeListResponseModel? responseToReturn;
  Object? errorToThrow;

  /// 마지막 호출에 전달된 `category` 쿼리 값. 호출 전에는 [called]가 false다.
  String? lastCategory;

  /// 마지막 호출에 전달된 `language` 쿼리 값.
  String? lastLanguage;
  bool called = false;

  @override
  Future<NoticeListResponseModel> getNotices({
    required int page,
    required int size,
    required String language,
    String? category,
  }) async {
    called = true;
    lastCategory = category;
    lastLanguage = language;
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/notices'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/notices'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/notices',
    },
  ),
  type: DioExceptionType.badResponse,
);

NoticeListResponseModel _listOf(List<NoticeResponseModel> items) =>
    NoticeListResponseModel(
      content: items,
      page: PageInfoModel(
        size: items.length,
        number: 0,
        totalElements: items.length,
        totalPages: 1,
      ),
    );

void main() {
  group('NoticeRepositoryImpl.getNotices', () {
    test('KST(+09:00) timestamp는 단말 local DateTime으로 정규화되어 반환된다', () async {
      // 백엔드가 v2.7.0부터 "2024-01-01T00:00:00+09:00" 형식으로 보냄.
      // DateTime.parse는 UTC(2023-12-31T15:00:00Z)로 저장하므로
      // .year 직접 호출 시 2023이 되어 표기가 하루 빠지는 버그 방지.
      final raw = NoticeResponseModel.fromJson({
        'id': 1,
        'title': '공지',
        'content': '본문',
        'pinned': false,
        'createdAt': '2024-01-01T00:00:00+09:00',
        'updatedAt': '2024-01-01T00:00:00+09:00',
      });
      final fake = _FakeNoticeRemoteDataSource()
        ..responseToReturn = _listOf([raw]);
      final repo = NoticeRepositoryImpl(fake);

      final result = await repo.getNotices(page: 0, size: 10, language: 'ko');

      final entity = result.items.single;
      // Entity의 createdAt은 local로 변환되어 있어야 한다.
      expect(entity.createdAt.isUtc, false);
      // KST(+09:00) 기준 "2024-01-01" 동일한 절대 시각이어야 한다.
      expect(
        entity.createdAt.isAtSameMomentAs(DateTime.utc(2023, 12, 31, 15, 0, 0)),
        true,
      );
    });

    test('UTC(Z) timestamp도 동일하게 local로 정규화된다', () async {
      // 혹시 백엔드가 Z 형태로 보내더라도 정규화 보장.
      final raw = NoticeResponseModel.fromJson({
        'id': 2,
        'title': 'UTC 공지',
        'content': '본문',
        'pinned': true,
        'createdAt': '2024-06-15T12:00:00Z',
        'updatedAt': '2024-06-15T12:00:00Z',
      });
      final fake = _FakeNoticeRemoteDataSource()
        ..responseToReturn = _listOf([raw]);
      final repo = NoticeRepositoryImpl(fake);

      final result = await repo.getNotices(page: 0, size: 10, language: 'ko');

      final entity = result.items.single;
      expect(entity.createdAt.isUtc, false);
      expect(
        entity.createdAt.isAtSameMomentAs(DateTime.utc(2024, 6, 15, 12, 0, 0)),
        true,
      );
    });

    test('필드는 DTO에서 Entity로 그대로 매핑된다', () async {
      final raw = NoticeResponseModel.fromJson({
        'id': 42,
        'title': '점검 안내',
        'content': '서버 점검합니다',
        'pinned': true,
        'createdAt': '2024-03-21T15:30:00+09:00',
        'updatedAt': '2024-03-21T15:30:00+09:00',
      });
      final fake = _FakeNoticeRemoteDataSource()
        ..responseToReturn = _listOf([raw]);
      final repo = NoticeRepositoryImpl(fake);

      final result = await repo.getNotices(page: 0, size: 10, language: 'ko');

      final entity = result.items.single;
      expect(entity.id, 42);
      expect(entity.title, '점검 안내');
      expect(entity.content, '서버 점검합니다');
      expect(entity.pinned, true);
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeNoticeRemoteDataSource()..errorToThrow = _dioError(500);
      final repo = NoticeRepositoryImpl(fake);

      expect(
        () => repo.getNotices(page: 0, size: 10, language: 'ko'),
        throwsA(isA<AppException>()),
      );
    });

    test('Dio 외 예외는 ServerException으로 wrap된다', () async {
      final fake = _FakeNoticeRemoteDataSource()
        ..errorToThrow = const FormatException('bad json');
      final repo = NoticeRepositoryImpl(fake);

      expect(
        () => repo.getNotices(page: 0, size: 10, language: 'ko'),
        throwsA(isA<ServerException>()),
      );
    });

    // Agents.md 명명 규칙(<subject>_<expected>_when_<condition>)을 따르는 신규 테스트.
    test('forwards_language_query_when_language_given', () async {
      final raw = NoticeResponseModel.fromJson({
        'id': 3,
        'title': 'お知らせ',
        'content': '本文',
        'pinned': false,
        'createdAt': '2024-05-05T09:00:00+09:00',
        'updatedAt': '2024-05-05T09:00:00+09:00',
      });
      final fake = _FakeNoticeRemoteDataSource()
        ..responseToReturn = _listOf([raw]);
      final repo = NoticeRepositoryImpl(fake);

      await repo.getNotices(page: 0, size: 10, language: 'ja');

      expect(fake.lastLanguage, 'ja');
    });

    test('filters_notices_by_selected_category_when_category_given', () async {
      // 서버 계약 고정: enum 값 → 쿼리 문자열. all은 "파라미터 생략"이라 null.
      const expectedQueryValues = <NoticeCategory, String?>{
        NoticeCategory.all: null,
        NoticeCategory.notice: 'NOTICE',
        NoticeCategory.maintenance: 'MAINTENANCE',
        NoticeCategory.event: 'EVENT',
        NoticeCategory.update: 'UPDATE',
      };

      for (final entry in expectedQueryValues.entries) {
        final raw = NoticeResponseModel.fromJson({
          'id': 7,
          'title': '카테고리 공지',
          'content': '본문',
          'pinned': false,
          'createdAt': '2024-05-05T09:00:00+09:00',
          'updatedAt': '2024-05-05T09:00:00+09:00',
        });
        final fake = _FakeNoticeRemoteDataSource()
          ..responseToReturn = _listOf([raw]);
        final repo = NoticeRepositoryImpl(fake);

        final result = await repo.getNotices(
          page: 0,
          size: 10,
          language: 'ko',
          category: entry.key,
        );

        expect(fake.called, true, reason: '${entry.key}');
        expect(fake.lastCategory, entry.value, reason: '${entry.key}');
        // 필터를 걸어도 응답이 정상적으로 Entity로 변환되어야 한다.
        expect(result.items.single.id, 7, reason: '${entry.key}');
      }
    });
  });
}
