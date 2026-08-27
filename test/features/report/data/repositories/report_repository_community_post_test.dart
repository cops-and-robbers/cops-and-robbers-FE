import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/report/data/datasources/report_remote_datasource.dart';
import 'package:cops_and_robbers/features/report/data/models/report_request_model.dart';
import 'package:cops_and_robbers/features/report/data/repositories/report_repository_impl.dart';
import 'package:cops_and_robbers/features/report/domain/constants/report_categories.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository는 진짜 코드가 돈다.
class _FakeReportRemoteDataSource implements ReportRemoteDataSource {
  CommunityPostReportRequestModel? lastRequest;
  Object? errorToThrow;

  @override
  Future<void> reportCommunityPost(
    CommunityPostReportRequestModel request,
  ) async {
    lastRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/report/community-post'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/report/community-post'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/report/community-post',
    },
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  group('ReportRepositoryImpl.reportCommunityPost', () {
    test('신고 대상 글 번호와 유형을 본문에 담아 보낸다', () async {
      final fake = _FakeReportRemoteDataSource();
      final repo = ReportRepositoryImpl(fake);

      await repo.reportCommunityPost(
        postId: 42,
        category: ReportCategory.spam,
      );

      expect(fake.lastRequest?.postId, 42);
      expect(fake.lastRequest?.reportType, 'SPAM');
    });

    // 기타 사유는 유형이 ETC일 때만 서버가 받는다. 다른 유형에 실어 보내면
    // 사용자가 앞서 쓰다 만 문구가 엉뚱한 신고에 딸려 간다.
    test('기타가 아닌 유형에는 기타 사유를 싣지 않는다', () async {
      final fake = _FakeReportRemoteDataSource();
      final repo = ReportRepositoryImpl(fake);

      await repo.reportCommunityPost(
        postId: 42,
        category: ReportCategory.abuse,
        etcReason: '쓰다 만 사유',
      );

      expect(fake.lastRequest?.etcReason, isNull);
    });

    test('기타 유형이면 사유를 그대로 싣는다', () async {
      final fake = _FakeReportRemoteDataSource();
      final repo = ReportRepositoryImpl(fake);

      await repo.reportCommunityPost(
        postId: 42,
        category: ReportCategory.other,
        etcReason: '모임 장소가 위험해요',
      );

      expect(fake.lastRequest?.reportType, 'ETC');
      expect(fake.lastRequest?.etcReason, '모임 장소가 위험해요');
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeReportRemoteDataSource()..errorToThrow = _dioError(409);
      final repo = ReportRepositoryImpl(fake);

      expect(
        () => repo.reportCommunityPost(
          postId: 42,
          category: ReportCategory.spam,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
