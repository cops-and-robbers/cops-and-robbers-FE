import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/report/data/datasources/report_remote_datasource.dart';
import 'package:cops_and_robbers/features/report/data/models/report_request_model.dart';
import 'package:cops_and_robbers/features/report/data/repositories/report_repository_impl.dart';
import 'package:cops_and_robbers/features/report/domain/constants/report_categories.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository는 진짜 코드가 돈다.
class _FakeReportRemoteDataSource implements ReportRemoteDataSource {
  CommunityChatReportRequestModel? lastRequest;
  Object? errorToThrow;

  @override
  Future<void> reportCommunityChat(
    CommunityChatReportRequestModel request,
  ) async {
    lastRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/report/community-chat'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/report/community-chat'),
    statusCode: statusCode,
    data: {
      'errorCode': 'CHAT_MESSAGE_NOT_FOUND',
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/report/community-chat',
    },
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  group('ReportRepositoryImpl.reportCommunityChat', () {
    test('신고 대상 메시지 번호와 유형을 본문에 담아 보낸다', () async {
      // 대상은 서버가 발급한 메시지 id다 — 앱이 만든 messageKey를 보내면
      // 서버가 못 찾는다(404 CHAT_MESSAGE_NOT_FOUND).
      final fake = _FakeReportRemoteDataSource();
      final repo = ReportRepositoryImpl(fake);

      await repo.reportCommunityChat(
        chatMessageId: 1234,
        category: ReportCategory.abuse,
      );

      expect(fake.lastRequest?.chatMessageId, 1234);
      expect(fake.lastRequest?.reportType, 'VERBAL_ABUSE');
    });

    test('기타가 아닌 유형에는 기타 사유를 싣지 않는다', () async {
      final fake = _FakeReportRemoteDataSource();
      final repo = ReportRepositoryImpl(fake);

      await repo.reportCommunityChat(
        chatMessageId: 1234,
        category: ReportCategory.spam,
        etcReason: '쓰다 만 사유',
      );

      expect(fake.lastRequest?.etcReason, isNull);
    });

    test('기타 유형이면 사유를 그대로 싣는다', () async {
      final fake = _FakeReportRemoteDataSource();
      final repo = ReportRepositoryImpl(fake);

      await repo.reportCommunityChat(
        chatMessageId: 1234,
        category: ReportCategory.other,
        etcReason: '단체로 욕설을 해요',
      );

      expect(fake.lastRequest?.reportType, 'ETC');
      expect(fake.lastRequest?.etcReason, '단체로 욕설을 해요');
    });

    test('DioException은 AppException으로 변환된다', () async {
      final fake = _FakeReportRemoteDataSource()..errorToThrow = _dioError(404);
      final repo = ReportRepositoryImpl(fake);

      expect(
        () => repo.reportCommunityChat(
          chatMessageId: 1234,
          category: ReportCategory.spam,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
