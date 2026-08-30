import '../entities/notice_category.dart';
import '../entities/notice_entity.dart';

/// 공지사항 도메인 Repository 인터페이스
///
/// 데이터 출처(REST API, 캐시 등) 구체에 의존하지 않는다.
abstract class NoticeRepository {
  /// 공지사항 목록을 페이지 단위로 조회한다.
  ///
  /// [page]는 0-based, [size]는 페이지당 개수.
  /// [language]는 ISO 639-1 언어 코드(ko·en·ja). 번역이 없는 공지는 한국어로 온다.
  /// [category]가 `NoticeCategory.all`이면 필터 없이 전체를 조회한다.
  /// 실패 시 `AppException` 계열 예외를 던진다.
  Future<NoticePageEntity> getNotices({
    required int page,
    required int size,
    required String language,
    NoticeCategory category = NoticeCategory.all,
  });
}
