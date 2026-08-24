import 'package:cops_and_robbers/features/community/presentation/community_chat_time_format.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('formatChatTime', () {
    test('formats_afternoon_as_pm_twelve_hour', () {
      expect(formatChatTime(l10n, DateTime(2026, 8, 24, 17, 34)), '오후 5:34');
    });
    test('formats_midnight_as_am_twelve', () {
      expect(formatChatTime(l10n, DateTime(2026, 8, 24, 0, 5)), '오전 12:05');
    });
    test('formats_noon_as_pm_twelve', () {
      expect(formatChatTime(l10n, DateTime(2026, 8, 24, 12, 0)), '오후 12:00');
    });
  });

  group('formatChatListTime', () {
    final now = DateTime(2026, 8, 24, 20, 0);
    test('uses_time_when_same_day', () {
      expect(
        formatChatListTime(l10n, DateTime(2026, 8, 24, 8, 31), now),
        '오전 8:31',
      );
    });
    test('uses_month_day_when_other_day', () {
      expect(
        formatChatListTime(l10n, DateTime(2026, 8, 2, 15, 24), now),
        '8/2',
      );
    });
  });
}
