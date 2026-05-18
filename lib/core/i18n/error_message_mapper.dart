import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// [AppException.messageKey] → [AppLocalizations] 메서드 매핑
///
/// 정적 클래스(DioExceptionHandler 등)는 BuildContext를 갖지 않기에 키만 결정한다.
/// UI 레이어(catch 블록, ErrorWidget 등)에서 이 헬퍼로 사용자 노출 메시지를 얻는다.
///
/// 사용 예:
/// ```dart
/// try {
///   await repo.foo();
/// } on AppException catch (e) {
///   final l10n = AppLocalizations.of(context);
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(l10n.errorByException(e))),
///   );
/// }
/// ```
///
/// 알 수 없는 키 / 키 없음 → [AppException.message] 폴백 (레거시 코드 호환).
extension AppLocalizationsErrorMapping on AppLocalizations {
  /// 예외의 messageKey를 사용자 노출 문자열로 변환
  String errorByException(AppException e) {
    final key = e.messageKey;
    if (key == null || key.isEmpty) return e.message;
    return errorByKey(key, fallback: e.message);
  }

  /// 키로부터 직접 메시지 조회 (예외 객체 없이도 사용 가능)
  ///
  /// 새 ARB 키가 추가되면 본 switch에도 케이스 추가 필요.
  /// (자동화 가능하지만 일단 명시적 매핑으로 시작 — 컴파일 타임 안전성 우선)
  String errorByKey(String key, {String? fallback}) {
    switch (key) {
      // 네트워크/API 에러 (dio_exception_handler.dart)
      case 'errorNetworkTimeout':
        return errorNetworkTimeout;
      case 'errorNetworkOffline':
        return errorNetworkOffline;
      case 'errorServerInternal':
        return errorServerInternal;
      case 'errorBadRequest':
        return errorBadRequest;
      case 'errorUnauthorized':
        return errorUnauthorized;
      case 'errorForbidden':
        return errorForbidden;
      case 'errorNotFound':
        return errorNotFound;
      case 'errorConflict':
        return errorConflict;
      // 인증 에러
      case 'errorAuthLoginCancelled':
        return errorAuthLoginCancelled;
      case 'errorAuthTokenMissing':
        return errorAuthTokenMissing;
      case 'errorAuthExpired':
        return errorAuthExpired;
      // 서버 연결
      case 'errorServerUnreachable':
        return errorServerUnreachable;
      // 게임 영역
      case 'errorAreaLoadFailed':
        return errorAreaLoadFailed;
      default:
        return fallback ?? key;
    }
  }
}
