import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/constants/report_categories.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_request_model.dart';

/// Report Repository 구현체
///
/// [ReportRemoteDataSource]를 통해 신고 API를 호출합니다.
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _dataSource;

  ReportRepositoryImpl(this._dataSource);

  @override
  Future<void> reportChat({
    required int gameId,
    required int reportedParticipantId,
    required String messageContent,
    required ReportCategory category,
    String? etcReason,
  }) async {
    try {
      final request = ReportRequestModel(
        gameId: gameId,
        reportedParticipantId: reportedParticipantId,
        messageContent: messageContent,
        reportType: category.apiType,
        etcReason: category == ReportCategory.other ? etcReason : null,
      );
      await _dataSource.reportChat(request);
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '신고 처리 중 오류가 발생했습니다.',
        messageKey: 'errorReportGeneric',
        originalException: e,
      );
    }
  }

  @override
  Future<void> reportCommunityPost({
    required int postId,
    required ReportCategory category,
    String? etcReason,
  }) async {
    try {
      await _dataSource.reportCommunityPost(
        CommunityPostReportRequestModel(
          postId: postId,
          reportType: category.apiType,
          // 서버는 ETC일 때만 사유를 받는다. 유형을 바꾸기 전에 쓰다 만 문구가
          // 남아 있어도 그대로 딸려 가지 않게 여기서 끊는다.
          etcReason: category == ReportCategory.other ? etcReason : null,
        ),
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '신고 처리 중 오류가 발생했습니다.',
        messageKey: 'errorReportGeneric',
        originalException: e,
      );
    }
  }
}
