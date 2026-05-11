/// 서버 응답의 ISO-8601 타임스탬프를 안전하게 [DateTime]으로 파싱한다.
///
/// 처리 정책:
/// - **nanosecond 절단**: Dart [DateTime]은 microsecond(소수점 6자리)까지만
///   지원하므로 7자리 이상은 6자리로 자른다.
///   (예: `"...:38.731399999"` → `"...:38.731399"`)
/// - **timezone 누락 시 UTC 가정**: ISO 문자열 끝에 `Z` 또는 `±HH:MM` suffix가
///   없으면 백엔드가 UTC 의도로 보냈다고 보고 `Z`를 강제 부여한다.
///   Dart 기본 동작은 단말 local timezone으로 해석하므로, 백엔드 UTC와
///   단말 KST 사이에 9시간 오프셋이 발생하는 버그를 방지하기 위함이다.
///   (이슈 #339 — `GET /api/games/{id}` 응답의 `gameStartTime`이 timezone
///   suffix 없이 내려와 재접속 시 경찰 대기 시간이 약 530분으로 표시되던 문제)
/// - **반환은 local로 변환**: `DateTime.now()` 같은 local 기준값과 비교할 때
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
    final withTz = _timezoneRegex.hasMatch(trimmed) ? trimmed : '${trimmed}Z';
    return DateTime.tryParse(withTz)?.toLocal();
  }
}
