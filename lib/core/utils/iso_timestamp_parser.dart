/// 서버 응답의 ISO-8601 타임스탬프를 안전하게 [DateTime]으로 파싱한다.
///
/// 처리 정책:
/// - **nanosecond 절단**: Dart [DateTime]은 microsecond(소수점 6자리)까지만
///   지원하므로 7자리 이상은 6자리로 자른다.
///   (예: `"...:38.731399999"` → `"...:38.731399"`)
/// - **timezone 누락 시 KST(Asia/Seoul) 가정**: 백엔드 `ClockConfig`가
///   `Clock.system(ZoneId.of("Asia/Seoul"))`로 설정되어 `LocalDateTime`을
///   timezone suffix 없이 직렬화하므로, 누락된 입력은 `+09:00`을 강제 부여해
///   KST로 해석한다. 단말 timezone에 의존하지 않고 일관된 시각 계산을 보장한다.
///   (이슈 #339 — Android 에뮬레이터처럼 단말 timezone이 KST가 아닌 환경에서
///   재접속 시 경찰 대기 시간이 약 530분으로 표시되던 문제)
/// - **단말 local로 변환**: `DateTime.now()` 같은 local 기준값과 비교할 때
///   사람이 읽는 시각 표현이 의도대로 동작하도록 `.toLocal()`을 적용한다.
///
/// 빈 문자열·`null`·파싱 실패 시 `null` 반환.
class IsoTimestampParser {
  IsoTimestampParser._();

  static final _nanoTrimRegex = RegExp(r'(\.\d{1,6})\d*');
  static final _timezoneRegex = RegExp(r'(Z|[+-]\d{2}:?\d{2})$');

  /// ISO-8601 문자열을 단말 local [DateTime]으로 파싱한다.
  static DateTime? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final trimmed = raw.replaceFirstMapped(_nanoTrimRegex, (m) => m.group(1)!);
    final withTz = _timezoneRegex.hasMatch(trimmed)
        ? trimmed
        : '$trimmed+09:00';
    return DateTime.tryParse(withTz)?.toLocal();
  }
}
