import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/record_format.dart';

void main() {
  group('formatDistanceParts', () {
    test('returns_rounded_meters_with_m_unit_when_under_1km', () {
      expect(formatDistanceParts(0), (value: '0', unit: 'm'));
      expect(formatDistanceParts(540), (value: '540', unit: 'm'));
      expect(formatDistanceParts(999.4), (value: '999', unit: 'm'));
    });

    test('returns_two_decimal_kilometers_when_1km_or_more', () {
      expect(formatDistanceParts(1000), (value: '1.00', unit: 'Km'));
      expect(formatDistanceParts(2543), (value: '2.54', unit: 'Km'));
    });
  });

  group('formatRecordDate', () {
    test('formats_locale_independent_numeric_datetime', () {
      expect(
        formatRecordDate(DateTime(2026, 6, 19, 19, 28)),
        '2026.06.19 19:28',
      );
      expect(formatRecordDate(DateTime(2026, 1, 5, 9, 3)), '2026.01.05 09:03');
    });
  });
}
