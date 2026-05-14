import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/notice_repository.dart';
import '../datasources/notice_remote_datasource.dart';

/// `NoticeRepository` 구현체
///
/// DataSource 호출 → DTO를 도메인 Entity로 변환.
/// `DioException`은 `DioExceptionHandler`로 일괄 변환.
class NoticeRepositoryImpl implements NoticeRepository {
  final NoticeRemoteDataSource _dataSource;

  NoticeRepositoryImpl(this._dataSource);

  @override
  Future<NoticePageEntity> getNotices({
    required int page,
    required int size,
  }) async {
    try {
      final res = await _dataSource.getNotices(page: page, size: size);
      return NoticePageEntity(
        items: res.content
            .map(
              (m) => NoticeEntity(
                id: m.id,
                title: m.title,
                content: m.content,
                pinned: m.pinned,
                // 백엔드가 timezone suffix(+09:00)를 포함해 직렬화하므로
                // json_serializable이 UTC DateTime으로 파싱한다. UI는 단말 local
                // 기준 날짜 표기를 기대하므로 Entity 경계에서 local로 정규화한다.
                createdAt: m.createdAt.toLocal(),
              ),
            )
            .toList(),
        currentPage: res.page.number,
        totalPages: res.page.totalPages,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      // Dio 외 예외(JSON 파싱 실패 등) → AppException으로 통일.
      // UI는 `error is AppException`을 가정하므로 raw 예외가 새어나가지 않게 차단.
      throw ServerException(
        message: '공지사항을 불러오는 중 오류가 발생했습니다',
        originalException: e,
      );
    }
  }
}
