import 'package:cops_and_robbers/features/community/presentation/community_notification_time_format.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ko'));
  final now = DateTime(2026, 8, 30, 12, 0);

  group('formatNotificationTime', () {
    test('returns_just_now_when_under_a_minute', () {
      expect(
        formatNotificationTime(
          l10n,
          now.subtract(const Duration(seconds: 30)),
          now,
        ),
        '방금',
      );
    });

    test('returns_minutes_ago_when_under_an_hour', () {
      expect(
        formatNotificationTime(
          l10n,
          now.subtract(const Duration(minutes: 3)),
          now,
        ),
        '3분 전',
      );
    });

    test('returns_hours_ago_when_under_a_day', () {
      expect(
        formatNotificationTime(
          l10n,
          now.subtract(const Duration(hours: 5)),
          now,
        ),
        '5시간 전',
      );
    });

    test('returns_zero_padded_month_day_when_a_day_or_older', () {
      // 시안(`8/09`)대로 일은 두 자리다.
      expect(
        formatNotificationTime(l10n, DateTime(2026, 8, 9, 23), now),
        '8/09',
      );
    });
  });
}
