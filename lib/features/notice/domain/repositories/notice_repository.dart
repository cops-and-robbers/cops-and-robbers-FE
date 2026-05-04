import '../entities/notice_entity.dart';

/// 공지사항 도메인 Repository 인터페이스
///
/// 데이터 출처(REST API, 캐시 등) 구체에 의존하지 않는다.
abstract class NoticeRepository {
  /// 공지사항 목록을 페이지 단위로 조회한다.
  ///
  /// [page]는 0-based, [size]는 페이지당 개수.
  /// 실패 시 `AppException` 계열 예외를 던진다.
  Future<NoticePageEntity> getNotices({
    required int page,
    required int size,
  });
}
