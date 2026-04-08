import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../../chat/domain/constants/report_categories.dart';
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
        originalException: e,
      );
    }
  }
}
