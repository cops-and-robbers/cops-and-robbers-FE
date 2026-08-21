import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

/// [AppException.messageKey] / 백엔드 [AppException.code] → [AppLocalizations] 메서드 매핑
///
/// 정적 클래스(DioExceptionHandler 등)는 BuildContext를 갖지 않기에 키만 결정한다.
/// UI 레이어(catch 블록, ErrorWidget 등)에서 이 헬퍼로 사용자 노출 메시지를 얻는다.
///
/// **정본 관계**: 백엔드 계약의 정본은 `docs/api-docs.json`(자동 생성)이고,
/// FE가 아는 errorCode의 정본은 아래 [_errorByCodeOrNull] switch다. 수기 요약본을
/// 따로 두면 갱신이 밀려 "문서에 없으니 없는 코드"로 오판하게 되므로 두지 않는다.
/// (api-docs.json은 REST 응답 example에 실린 코드만 담아 STOMP·전역 예외 코드를
///  구조적으로 못 담는다. 그 코드들은 이 switch에만 기록된다.)
/// 문서에 있는 코드가 여기 빠지면 `test/core/i18n/error_message_mapper_test.dart`의
/// 커버리지 테스트가 잡는다.
///
/// 우선순위:
/// 1. 백엔드 errorCode ([shouldUseBackendErrorCode] 조건 충족 시) → [errorByCode]
/// 2. messageKey (네트워크 레벨 / Firebase provider code 등) → [errorByKey]
/// 3. [AppException.message] 폴백
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
extension AppLocalizationsErrorMapping on AppLocalizations {
  /// 예외를 사용자 노출 문자열로 변환 (3단계 우선순위 적용)
  String errorByException(AppException e) {
    // ① docs/api-docs.json 기반 백엔드 errorCode 우선
    if (shouldUseBackendErrorCode(e)) {
      // errorByCode: 매핑 누락 시 내부에서 errorTemporaryRetry 반환
      return errorByCode(e.code!);
    }
    // ② messageKey (네트워크 레벨 / Firebase provider code 등)
    final key = e.messageKey;
    if (key != null && key.isNotEmpty) {
      return errorByKey(key, fallback: e.message);
    }
    // ③ 최종 message 폴백
    return e.message;
  }

  /// 백엔드 errorCode를 직접 사용해야 하는지 판별
  ///
  /// ⚠️ 결합점: DioExceptionHandler가 모든 서버 응답 에러에 messageKey='errorTemporaryRetry'를
  ///    세팅한다는 전제에 의존한다(dio_exception_handler.dart 참조). 한쪽을 바꾸면 이 가드가 깨진다.
  ///
  /// 조건:
  /// - code가 null/empty가 아님
  /// - messageKey가 'errorTemporaryRetry' (서버 발 에러를 DioExceptionHandler가 표준화한 키)
  /// - code 형식이 대문자+언더스코어 식별자 (백엔드 errorCode 포맷)
  ///   — Firebase provider code('invalid-credential' 등)는 소문자+하이픈이므로 자연스럽게 제외됨
  bool shouldUseBackendErrorCode(AppException e) {
    final code = e.code;
    if (code == null || code.isEmpty) return false;
    return e.messageKey == 'errorTemporaryRetry' &&
        RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(code);
  }

  /// 공개 API — 백엔드 errorCode를 사용자 노출 문자열로 변환
  ///
  /// STOMP Notifier 등에서 errorCode를 직접 보유하는 경우 바로 호출 가능.
  /// 매핑 테이블에 없는 코드는 [errorTemporaryRetry] 공통 문구 반환 (non-null 보장).
  String errorByCode(String code) =>
      _errorByCodeOrNull(code) ?? errorTemporaryRetry;

  /// 내부 — 매핑 없으면 null 반환 (errorByCode가 폴백 처리)
  String? _errorByCodeOrNull(String code) {
    switch (code) {
      // ── 요청 검증 에러 ──────────────────────────────────────────────
      case 'MISSING_REQUEST_PART':
        return errorCodeMissingRequestPart;
      case 'INVALID_REQUEST_BODY':
        return errorCodeInvalidRequestBody;
      case 'INVALID_QUERY_PARAMETER':
        return errorCodeInvalidQueryParameter;
      case 'QUERY_PARAMETER_TYPE_MISMATCH':
        return errorCodeQueryParameterTypeMismatch;
      case 'INVALID_INPUT_VALUE':
        return errorCodeInvalidInputValue;
      // 좌표에 주소·국가가 없어 게시글 생성·수정이 거절된 경우(DEC-0022).
      // 공통 폴백 "잠시 후 다시 시도"는 틀린 안내다 — 같은 핀으로는 계속 실패한다.
      // (벤더 장애로 실패하는 ADDRESS_LOOKUP_FAILED는 실제로 일시적이라
      //  공통 폴백이 맞는 안내이므로 매핑하지 않는다.)
      case 'ADDRESS_NOT_FOUND':
        return errorCodeAddressNotFound;
      case 'INVALID_DESTINATION':
        return errorCodeInvalidDestination;
      case 'UNSUPPORTED_MEDIA_TYPE':
        return errorCodeUnsupportedMediaType;
      case 'METHOD_NOT_ALLOWED':
        return errorCodeMethodNotAllowed;
      case 'ENDPOINT_NOT_FOUND':
        return errorCodeEndpointNotFound;
      // ── WebSocket/STOMP 에러 ────────────────────────────────────────
      case 'INVALID_SOCKET_SESSION':
        return errorCodeInvalidSocketSession;
      case 'UNAUTHORIZED_SUBSCRIPTION':
        return errorCodeUnauthorizedSubscription;
      // ── 서버 내부 에러 ──────────────────────────────────────────────
      case 'INTERNAL_SERVER_ERROR':
        return errorCodeInternalServerError;
      case 'FIREBASE_INIT_ERROR':
        return errorCodeFirebaseInitError;
      case 'FIREBASE_CONFIG_NOT_FOUND':
        return errorCodeFirebaseConfigNotFound;
      case 'ENCRYPTION_FAILED':
        return errorCodeEncryptionFailed;
      case 'DECRYPTION_FAILED':
        return errorCodeDecryptionFailed;
      case 'INVALID_ENCRYPTION_KEY':
        return errorCodeInvalidEncryptionKey;
      // ── 인증/보안 에러 ──────────────────────────────────────────────
      case 'SOCIAL_LOGIN_FAILED':
        return errorCodeSocialLoginFailed;
      case 'ACCESS_TOKEN_EXPIRED':
        return errorCodeAccessTokenExpired;
      case 'REFRESH_TOKEN_EXPIRED':
        return errorCodeRefreshTokenExpired;
      case 'INVALID_TOKEN':
        return errorCodeInvalidToken;
      case 'UNAUTHENTICATED_REQUEST':
        return errorCodeUnauthenticatedRequest;
      case 'EXPIRED_FIREBASE_TOKEN':
        return errorCodeExpiredFirebaseToken;
      case 'INVALID_FIREBASE_TOKEN':
        return errorCodeInvalidFirebaseToken;
      case 'UNSUPPORTED_SOCIAL_TYPE':
        return errorCodeUnsupportedSocialType;
      case 'FORBIDDEN_ADMIN_ONLY':
        return errorCodeForbiddenAdminOnly;
      // ── 닉네임/유저 에러 ────────────────────────────────────────────
      case 'NICKNAME_GENERATION_FAILED':
        return errorCodeNicknameGenerationFailed;
      case 'FIREBASE_SERVER_ERROR':
        return errorCodeFirebaseServerError;
      case 'USER_NOT_FOUND':
        return errorCodeUserNotFound;
      case 'DUPLICATED_NICKNAME':
        return errorCodeDuplicatedNickname;
      case 'CANNOT_WITHDRAW':
        return errorCodeCannotWithdraw;
      case 'REQUIRED_TERMS_NOT_AGREED':
        return errorCodeRequiredTermsNotAgreed;
      // ── 게임 설정/상태 에러 ─────────────────────────────────────────
      case 'GAME_NOT_FOUND':
        return errorCodeGameNotFound;
      case 'GAME_NOT_IN_PROGRESS':
        return errorCodeGameNotInProgress;
      case 'GAME_NOT_ACTIVE':
        return errorCodeGameNotActive;
      case 'GAME_NOT_WAITING':
        return errorCodeGameNotWaiting;
      case 'INVALID_LOCATION_INTERVAL':
        return errorCodeInvalidLocationInterval;
      case 'INVALID_POLICE_WAIT_TIME':
        return errorCodeInvalidPoliceWaitTime;
      case 'INVITE_CODE_GENERATION_FAILED':
        return errorCodeInviteCodeGenerationFailed;
      case 'INVALID_JAIL_RADIUS':
        return errorCodeInvalidJailRadius;
      case 'JAIL_OUTSIDE_PLAYGROUND':
        return errorCodeJailOutsidePlayground;
      case 'GAME_AREA_NOT_FOUND':
        return errorCodeGameAreaNotFound;
      // ── 참가자/입장 에러 ─────────────────────────────────────────────
      case 'ALREADY_PARTICIPATING':
        return errorCodeAlreadyParticipating;
      case 'GAME_ALREADY_STARTED':
        return errorCodeGameAlreadyStarted;
      case 'GAME_FULL':
        return errorCodeGameFull;
      case 'INVALID_INVITE_CODE':
        return errorCodeInvalidInviteCode;
      case 'PARTICIPANT_NOT_FOUND':
        return errorCodeParticipantNotFound;
      case 'NOT_A_PARTICIPANT':
        return errorCodeNotAParticipant;
      case 'CANNOT_LEAVE_DURING_GAME':
        return errorCodeCannotLeaveDuringGame;
      // ── 로비 에러 ────────────────────────────────────────────────────
      case 'LOBBY_ACTION_NOT_ALLOWED':
        return errorCodeLobbyActionNotAllowed;
      case 'NOT_HOST':
        return errorCodeNotHost;
      case 'INVALID_TEAM_COMPOSITION':
        return errorCodeInvalidTeamComposition;
      case 'NOT_ALL_READY':
        return errorCodeNotAllReady;
      case 'NOT_ROBBER_TEAM':
        return errorCodeNotRobberTeam;
      case 'HOST_CANNOT_UNREADY':
        return errorCodeHostCannotUnready;
      // ── 게임 플레이 에러 ─────────────────────────────────────────────
      case 'PARTICIPANT_GAME_MISMATCH':
        return errorCodeParticipantGameMismatch;
      case 'ONLY_POLICE_CAN_ARREST':
        return errorCodeOnlyPoliceCanArrest;
      case 'ONLY_ROBBER_CAN_BE_ARRESTED':
        return errorCodeOnlyRobberCanBeArrested;
      case 'ONLY_ROBBER_CAN_ESCAPE':
        return errorCodeOnlyRobberCanEscape;
      case 'ALREADY_ARRESTED':
        return errorCodeAlreadyArrested;
      case 'NOT_JAILED':
        return errorCodeNotJailed;
      case 'POLICE_WAITING_TIME':
        return errorCodePoliceWaitingTime;
      case 'CANNOT_KICK_YOURSELF':
        return errorCodeCannotKickYourself;
      // ── 공지/게임 결과 에러 ──────────────────────────────────────────
      case 'NOTICE_NOT_FOUND':
        return errorCodeNoticeNotFound;
      case 'GAME_RESULT_NOT_FOUND':
        return errorCodeGameResultNotFound;
      // ── 신고 에러 ────────────────────────────────────────────────────
      case 'ETC_REASON_REQUIRED':
        return errorCodeEtcReasonRequired;
      case 'SELF_REPORT':
        return errorCodeSelfReport;
      case 'DUPLICATE_REPORT':
        return errorCodeDuplicateReport;
      case 'REPORT_NOT_FOUND':
        return errorCodeReportNotFound;
      case 'REPORT_TARGET_NOT_FOUND':
        return errorCodeReportTargetNotFound;
      // ── 커뮤니티(모집글) 에러 ────────────────────────────────────────
      case 'INVALID_MEETING_DATE':
        return errorCodeInvalidMeetingDate;
      case 'POST_NOT_FOUND':
        return errorCodePostNotFound;
      case 'FORBIDDEN_NOT_AUTHOR':
        return errorCodeForbiddenNotAuthor;
      case 'COUNTRY_NOT_SPECIFIED':
        return errorCodeCountryNotSpecified;
      // UNSUPPORTED_LIST_SCOPE / UNSUPPORTED_LIST_SORT는 매핑하지 않는다 —
      // 앱은 scope=ALL·sort=LATEST 외의 값을 보내지 않으므로(datasource 참조)
      // 이 코드가 오면 사용자가 아니라 클라이언트 버그다. 공통 폴백으로 충분하다.
      default:
        return null;
    }
  }

  /// 키로부터 직접 메시지 조회 (예외 객체 없이도 사용 가능)
  ///
  /// 새 ARB 키가 추가되면 본 switch에도 케이스 추가 필요.
  /// (자동화 가능하지만 일단 명시적 매핑으로 시작 — 컴파일 타임 안전성 우선)
  String errorByKey(String key, {String? fallback}) {
    switch (key) {
      // 공통 에러 (서버 응답 에러의 DioExceptionHandler 표준 키)
      case 'errorTemporaryRetry':
        return errorTemporaryRetry;
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
      // Firebase 인증 에러 (firebase_auth_error_handler.dart)
      case 'errorAuthUserNotFound':
        return errorAuthUserNotFound;
      case 'errorAuthTokenIssueFailed':
        return errorAuthTokenIssueFailed;
      case 'errorAuthTokenValidationFailed':
        return errorAuthTokenValidationFailed;
      case 'errorAuthInvalidCredential':
        return errorAuthInvalidCredential;
      case 'errorAuthAccountDisabled':
        return errorAuthAccountDisabled;
      case 'errorAuthTooManyRequests':
        return errorAuthTooManyRequests;
      case 'errorAuthSignInMethodUnavailable':
        return errorAuthSignInMethodUnavailable;
      case 'errorAuthFirebaseConfig':
        return errorAuthFirebaseConfig;
      case 'errorAuthFirebaseInternal':
        return errorAuthFirebaseInternal;
      case 'errorAuthLoginFailed':
        return errorAuthLoginFailed;
      // errorAuthProviderLoginFailed는 placeholder 필요 — 호출부에서 직접 호출
      // 서버 연결
      case 'errorServerUnreachable':
        return errorServerUnreachable;
      // 게임 영역
      case 'errorAreaLoadFailed':
        return errorAreaLoadFailed;
      // ── 기능별 예기치 못한 실패 ─────────────────────────────────────
      // 각 Notifier/Repository가 catch에서 messageKey로 세팅하는 키들.
      // 누락 시 errorByException의 fallback(=하드코딩 한국어 message)으로 떨어져
      // en/ja 로케일 사용자에게 한국어가 노출되므로, 로케일 메시지로 매핑한다.
      case 'errorLoginGeneric':
        return errorLoginGeneric;
      case 'errorLogoutGeneric':
        return errorLogoutGeneric;
      case 'errorLogoutFailed':
        return errorLogoutFailed;
      case 'errorUserInfoFetch':
        return errorUserInfoFetch;
      case 'errorNicknameCheckUnexpected':
        return errorNicknameCheckUnexpected;
      case 'errorNicknameUpdateUnexpected':
        return errorNicknameUpdateUnexpected;
      case 'errorDeleteAccountUnexpected':
        return errorDeleteAccountUnexpected;
      case 'errorAgreementFetchUnexpected':
        return errorAgreementFetchUnexpected;
      case 'errorAgreementSaveUnexpected':
        return errorAgreementSaveUnexpected;
      case 'errorGameRoomCreateUnexpected':
        return errorGameRoomCreateUnexpected;
      case 'errorGameJoinUnexpected':
        return errorGameJoinUnexpected;
      case 'errorActiveGameFetchUnexpected':
        return errorActiveGameFetchUnexpected;
      case 'errorGamePushFetchUnexpected':
        return errorGamePushFetchUnexpected;
      case 'errorGamePushUpdateUnexpected':
        return errorGamePushUpdateUnexpected;
      case 'errorPendingInviteSave':
        return errorPendingInviteSave;
      case 'errorPendingInviteLoad':
        return errorPendingInviteLoad;
      case 'errorPendingInviteClear':
        return errorPendingInviteClear;
      case 'errorNoticesLoadGeneric':
        return errorNoticesLoadGeneric;
      case 'errorCommunityPostsLoadGeneric':
        return errorCommunityPostsLoadGeneric;
      case 'errorCommunityAddressLoadGeneric':
        return errorCommunityAddressLoadGeneric;
      case 'errorCommunityPostCreateGeneric':
        return errorCommunityPostCreateGeneric;
      case 'errorCommunityPostUpdateGeneric':
        return errorCommunityPostUpdateGeneric;
      case 'errorCommunityPostDeleteGeneric':
        return errorCommunityPostDeleteGeneric;
      case 'errorCommunityPostStatusGeneric':
        return errorCommunityPostStatusGeneric;
      case 'errorReportGeneric':
        return errorReportGeneric;
      case 'errorBugReportFailed':
        return errorBugReportFailed;
      case 'errorUnknown':
        return errorUnknown;
      default:
        return fallback ?? key;
    }
  }
}
