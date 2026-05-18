import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/repositories/bug_repository.dart';
import '../datasources/bug_remote_datasource.dart';
import '../models/bug_report_request_model.dart';

/// Bug Repository 구현체
///
/// [BugRemoteDataSource]를 통해 버그 제보 API를 호출합니다.
class BugRepositoryImpl implements BugRepository {
  final BugRemoteDataSource _dataSource;

  BugRepositoryImpl(this._dataSource);

  @override
  Future<void> reportBug({required String content}) async {
    try {
      await _dataSource.reportBug(BugReportRequestModel(content: content));
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: '버그 제보 처리 중 오류가 발생했습니다.',
        messageKey: 'errorBugReportFailed',
        originalException: e,
      );
    }
  }
}
