import 'package:cops_and_robbers/core/utils/iso_timestamp_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsoTimestampParser', () {
    test('returns_utc_assumed_datetime_when_timezone_suffix_missing', () {
      // 이슈 #339 회귀 방지: timezone 누락 시 단말 local로 해석되면
      // 백엔드 UTC와 9시간 오프셋이 발생함.
      final result = IsoTimestampParser.parse('2026-05-11T14:53:38');

      expect(
        result?.toUtc(),
        DateTime.utc(2026, 5, 11, 14, 53, 38),
        reason: 'timezone suffix가 없으면 UTC로 가정해야 함',
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
      // Dart DateTime은 microsecond(6자리)까지만 지원.
      final result = IsoTimestampParser.parse('2026-05-11T14:53:38.731399999Z');

      expect(result?.toUtc().microsecond, 731399);
    });

    test('returns_same_instant_for_naive_and_z_suffixed_inputs', () {
      // 백엔드의 timezone 누락 응답과 명시적 UTC 응답이 같은 시각으로 해석되어야 함.
      final naive = IsoTimestampParser.parse('2026-05-11T14:53:38');
      final withZ = IsoTimestampParser.parse('2026-05-11T14:53:38Z');

      expect(naive, withZ);
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
