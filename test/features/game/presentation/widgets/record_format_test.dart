import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/record_format.dart';

void main() {
  group('formatDistance', () {
    test('shows_meters_below_1km', () {
      expect(formatDistance(0), '0 m');
      expect(formatDistance(540), '540 m');
      expect(formatDistance(999.4), '999 m');
    });

    test('shows_km_with_two_decimals_at_or_above_1km', () {
      expect(formatDistance(1000), '1.00 km');
      expect(formatDistance(2543), '2.54 km');
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
