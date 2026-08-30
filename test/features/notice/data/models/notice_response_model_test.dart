import 'package:cops_and_robbers/features/notice/data/models/notice_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// `NoticeResponse`의 언어 쌍(`language`·`requestedLanguage`) 매핑 검증.
///
/// 검증 대상 행동:
/// - 두 필드가 실제로 앱 모델까지 들어온다 (미매핑이면 freezed가 조용히 버린다)
/// - 키가 없는 응답에서도 파싱이 깨지지 않고 "대체 아님"으로 떨어진다
/// - 대체 판정은 두 값의 비교 하나뿐이다
Map<String, dynamic> _json({String? language, String? requestedLanguage}) => {
  'id': 1,
  'title': '공지 제목',
  'content': '공지 본문',
  'pinned': false,
  'createdAt': '2026-08-30T12:00:00+09:00',
  'updatedAt': '2026-08-30T12:00:00+09:00',
  if (language != null) 'language': language,
  if (requestedLanguage != null) 'requestedLanguage': requestedLanguage,
};

void main() {
  group('NoticeResponseModel 언어 쌍', () {
    test('parses_language_pair_when_response_carries_them', () {
      final model = NoticeResponseModel.fromJson(
        _json(language: 'ko', requestedLanguage: 'ja'),
      );

      expect(model.language, 'ko');
      expect(model.requestedLanguage, 'ja');
    });

    test('keeps_language_pair_null_when_keys_are_absent', () {
      final model = NoticeResponseModel.fromJson(_json());

      expect(model.language, isNull);
      expect(model.requestedLanguage, isNull);
    });

    test('is_fallback_when_served_language_differs_from_requested', () {
      // 서버 대체 순서(요청 → 원문 → 아무 번역)가 일어난 경우.
      // 두 값이 갈린다 == 요청한 언어의 번역이 아직 없다.
      final model = NoticeResponseModel.fromJson(
        _json(language: 'ko', requestedLanguage: 'ja'),
      );

      expect(model.isTranslationFallback, true);
    });

    test('is_not_fallback_when_requested_language_was_served', () {
      final model = NoticeResponseModel.fromJson(
        _json(language: 'ja', requestedLanguage: 'ja'),
      );

      expect(model.isTranslationFallback, false);
    });

    test('is_not_fallback_when_language_pair_is_absent', () {
      // api-docs가 두 필드를 required로 두지 않았다. 값이 없으면 대체 여부를
      // 알 수 없으므로, 안내를 띄우지 않는 쪽(false)으로 떨어져야 한다.
      final model = NoticeResponseModel.fromJson(_json());

      expect(model.isTranslationFallback, false);
    });

    test('is_not_fallback_when_only_one_side_is_present', () {
      final servedOnly = NoticeResponseModel.fromJson(_json(language: 'ko'));
      final requestedOnly = NoticeResponseModel.fromJson(
        _json(requestedLanguage: 'ja'),
      );

      expect(servedOnly.isTranslationFallback, false);
      expect(requestedOnly.isTranslationFallback, false);
    });
  });
}
