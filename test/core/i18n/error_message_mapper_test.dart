import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/i18n/error_message_mapper.dart';

void main() {
  // lookupAppLocalizations은 WidgetsFlutterBinding 없이도 동기적으로 동작한다.
  final l10n = lookupAppLocalizations(const Locale('ko'));

  group('errorByCode', () {
    test('returns_invite_code_message_when_code_is_invalid_invite_code', () {
      expect(
        l10n.errorByCode('INVALID_INVITE_CODE'),
        l10n.errorCodeInvalidInviteCode,
      );
    });

    test('returns_pick_another_spot_when_code_is_address_not_found', () {
      // 그 좌표에 주소·국가가 없어 서버가 글 생성을 거절한 경우다. 공통 폴백
      // "잠시 후 다시 시도"는 틀린 안내다 — 같은 핀으로는 몇 번을 해도 실패한다.
      expect(
        l10n.errorByCode('ADDRESS_NOT_FOUND'),
        l10n.errorCodeAddressNotFound,
      );
    });

    test('returns_common_retry_when_code_is_unmapped', () {
      expect(
        l10n.errorByCode('SOME_FUTURE_UNKNOWN_CODE'),
        l10n.errorTemporaryRetry,
      );
    });
  });

  group('errorByKey', () {
    test('returns_common_retry_message_for_errorTemporaryRetry_key', () {
      expect(l10n.errorByKey('errorTemporaryRetry'), l10n.errorTemporaryRetry);
    });
  });

  group('shouldUseBackendErrorCode', () {
    test('true_for_server_errorcode_with_common_messageKey', () {
      const e = ValidationException(
        message: 'bad request',
        messageKey: 'errorTemporaryRetry',
        code: 'GAME_FULL',
      );
      expect(l10n.shouldUseBackendErrorCode(e), isTrue);
    });

    test('false_for_firebase_provider_code', () {
      // Firebase provider code는 소문자+하이픈 포맷 — 정규식 불일치로 제외됨
      const e = AuthException(
        message: 'invalid credential',
        messageKey: 'errorAuthInvalidCredential',
        code: 'invalid-credential',
      );
      expect(l10n.shouldUseBackendErrorCode(e), isFalse);
    });

    test('false_for_lowercase_code', () {
      const e = NetworkException(
        message: 'timeout',
        messageKey: 'errorNetworkTimeout',
        code: 'timeout',
      );
      // 'timeout'은 소문자이므로 백엔드 errorCode 포맷 정규식 불일치
      expect(l10n.shouldUseBackendErrorCode(e), isFalse);
    });

    test('false_when_code_is_null', () {
      // code 미지정 → null. 정규식 평가 이전 null/empty 가드(54행)에서 false
      const e = NetworkException(
        message: 'timeout',
        messageKey: 'errorNetworkTimeout',
      );
      expect(l10n.shouldUseBackendErrorCode(e), isFalse);
    });
  });

  group('errorByException', () {
    test('uses_errorByCode_when_backend_errorcode', () {
      const e = ValidationException(
        message: 'bad request',
        messageKey: 'errorTemporaryRetry',
        code: 'GAME_FULL',
      );
      expect(l10n.errorByException(e), l10n.errorCodeGameFull);
    });

    test('preserves_messageKey_path_for_firebase_code', () {
      const e = AuthException(
        message: 'invalid credential',
        messageKey: 'errorAuthInvalidCredential',
        code: 'invalid-credential',
      );
      expect(l10n.errorByException(e), l10n.errorAuthInvalidCredential);
    });

    test('uses_messageKey_for_lowercase_code', () {
      const e = NetworkException(
        message: 'timeout',
        messageKey: 'errorNetworkTimeout',
        code: 'timeout',
      );
      expect(l10n.errorByException(e), l10n.errorNetworkTimeout);
    });

    test('uses_messageKey_when_code_is_null', () {
      // code 미지정 → null. backend errorCode 경로 제외, messageKey 경로 사용
      const e = NetworkException(
        message: 'timeout',
        messageKey: 'errorNetworkTimeout',
      );
      expect(l10n.errorByException(e), l10n.errorNetworkTimeout);
    });
  });
}
