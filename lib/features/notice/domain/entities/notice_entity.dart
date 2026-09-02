import 'package:freezed_annotation/freezed_annotation.dart';

part 'notice_entity.freezed.dart';

/// 공지사항 도메인 엔티티
///
/// UI가 직접 보는 형태. DTO에서 사용하지 않는 필드(`updatedAt`)는 제외.
/// JSON 직렬화 미지원(외부 의존성 없음).
@freezed
class NoticeEntity with _$NoticeEntity {
  const factory NoticeEntity({
    required int id,
    required String title,
    required String content,

    /// 상단 고정 여부. true면 백엔드가 정렬 시 우선 노출하며,
    /// UI에서는 제목 앞에 아이콘을 표시한다.
    required bool pinned,
    required DateTime createdAt,

    /// 요청한 언어의 번역이 없어 서버가 다른 언어로 대체했는지 여부.
    /// 언어 코드 두 개를 도메인까지 끌지 않고 판정 결과만 넘긴다.
    @Default(false) bool isTranslationFallback,
  }) = _NoticeEntity;
}

/// 페이지네이션이 적용된 공지사항 페이지 엔티티
///
/// `NoticesNotifier`의 상태(`AsyncValue<NoticePageEntity>`)로 사용된다.
/// `currentPage`는 0-based.
@freezed
class NoticePageEntity with _$NoticePageEntity {
  const factory NoticePageEntity({
    required List<NoticeEntity> items,
    required int currentPage,
    required int totalPages,
  }) = _NoticePageEntity;
}
