import '../../domain/entities/notice_category.dart';

/// 공지사항 카테고리의 서버 와이어 문자열은 이 매핑에만 존재한다.
///
/// `@JsonValue`를 쓰지 않는 이유: 그 어노테이션은 json_serializable이
/// `fromJson`/`toJson`을 만들 때만 읽히고 결과가 `.g.dart`의 private
/// `_$...EnumMap`에 들어간다. 이 값은 JSON 본문이 아니라 쿼리스트링으로
/// 나가므로 Retrofit의 `@Query`가 그 맵에 닿지 못한다.
extension NoticeCategoryQuery on NoticeCategory {
  /// `GET /api/notices`의 `category` 쿼리 값.
  ///
  /// `null`이면 Retrofit이 생성한 `removeWhere((k, v) => v == null)`가
  /// 파라미터 자체를 제외하므로, "전체 = 파라미터 생략"이라는 백엔드 계약이
  /// 그대로 표현된다.
  String? get queryValue => switch (this) {
    NoticeCategory.all => null,
    NoticeCategory.notice => 'NOTICE',
    NoticeCategory.maintenance => 'MAINTENANCE',
    NoticeCategory.event => 'EVENT',
    NoticeCategory.update => 'UPDATE',
  };
}
