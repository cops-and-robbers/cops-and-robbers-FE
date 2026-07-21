import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/core/services/loading_message_service.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// 로딩 화면 서브카피(안심 문구) 제공 검증.
///
/// 제목은 세계관 랜덤 문구지만, 서브카피는 "앱을 끄지 마세요" 류의 안심 문구라
/// 카테고리당 하나로 고정된다. reconnect는 별도 UI(reconnect_modal)를 쓰므로 없다.
void main() {
  final ko = lookupAppLocalizations(const Locale('ko'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('LoadingMessageService.subtitleFor', () {
    test('returns_reassurance_copy_for_join_room_in_korean', () {
      expect(
        LoadingMessageService.subtitleFor(ko, LoadingCategory.joinRoom),
        '지금 앱을 끄면 합류가 취소돼요. 잠시만 기다려주세요',
      );
    });

    test('returns_localized_copy_when_locale_is_english', () {
      expect(
        LoadingMessageService.subtitleFor(en, LoadingCategory.joinRoom),
        "If you close the app now, joining will be canceled. Please wait a moment",
      );
    });

    test('returns_null_for_reconnect_category', () {
      expect(
        LoadingMessageService.subtitleFor(ko, LoadingCategory.reconnect),
        isNull,
      );
    });

    test('returns_non_empty_copy_for_every_category_except_reconnect', () {
      for (final category in LoadingCategory.values) {
        if (category == LoadingCategory.reconnect) continue;
        final subtitle = LoadingMessageService.subtitleFor(ko, category);
        expect(subtitle, isNotNull, reason: '$category 서브카피 누락');
        expect(subtitle, isNotEmpty, reason: '$category 서브카피 빈 문자열');
      }
    });

    test('subtitle_does_not_end_with_period', () {
      for (final category in LoadingCategory.values) {
        final subtitle = LoadingMessageService.subtitleFor(ko, category);
        if (subtitle == null) continue;
        expect(
          subtitle.endsWith('.'),
          isFalse,
          reason: '$category — 사용자 노출 문구 끝 마침표 금지',
        );
      }
    });
  });
}
