import 'package:cops_and_robbers/core/utils/iso_timestamp_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsoTimestampParser', () {
    test('returns_kst_assumed_datetime_when_timezone_suffix_missing', () {
      // 이슈 #339 회귀 방지: 백엔드 ClockConfig가 Asia/Seoul 기준이므로
      // timezone suffix가 누락된 응답은 KST 의도로 해석해야 함.
      // (단말 timezone이 KST가 아닌 환경에서 9시간 오프셋 방지)
      final result = IsoTimestampParser.parse('2026-05-11T14:53:38');

      expect(
        result?.toUtc(),
        DateTime.utc(2026, 5, 11, 5, 53, 38),
        reason:
            'timezone suffix가 없으면 KST로 가정 → '
            'KST 14:53:38 = UTC 05:53:38',
      );
    });

    test('preserves_offset_when_explicit_timezone_provided', () {
      // KST 23:53:38 = UTC 14:53:38
      final result = IsoTimestampParser.parse('2026-05-11T23:53:38+09:00');

      expect(result?.toUtc(), DateTime.utc(2026, 5, 11, 14, 53, 38));
    });

    test('parses_as_utc_when_z_suffix_present', () {
      final result = IsoTimestampParser.parse('2026-05-11T14:53:38Z');

      expect(result?.toUtc(), DateTime.utc(2026, 5, 11, 14, 53, 38));
    });

    test('truncates_subsecond_to_microsecond_precision', () {
      // 나노초(9자리) .731399999 → 마이크로초(6자리) .731399 로 절단.
      // Dart의 millisecond/microsecond getter는 각각 0~999 자리값이므로
      // .731399초 = 731(ms) + 399(µs) 로 검증한다 (.microsecond 단독은 0~999 범위).
      final result = IsoTimestampParser.parse('2026-05-11T14:53:38.731399999Z');

      expect(result?.toUtc().millisecond, 731);
      expect(result?.toUtc().microsecond, 399);
    });

    test('returns_same_instant_for_naive_and_kst_suffixed_inputs', () {
      // 백엔드의 timezone 누락 응답(KST 의도)과 명시적 KST 응답이
      // 같은 시각으로 해석되어야 함.
      final naive = IsoTimestampParser.parse('2026-05-11T14:53:38');
      final withKst = IsoTimestampParser.parse('2026-05-11T14:53:38+09:00');

      expect(naive, withKst);
    });

    test('returns_null_when_input_is_null', () {
      expect(IsoTimestampParser.parse(null), isNull);
    });

    test('returns_null_when_input_is_empty', () {
      expect(IsoTimestampParser.parse(''), isNull);
    });

    test('returns_null_when_input_is_invalid_format', () {
      expect(IsoTimestampParser.parse('not-a-date'), isNull);
    });
  });
}
