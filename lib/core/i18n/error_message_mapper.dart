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
      case 'ADDRESS_NOT_FOUND':
        return errorCodeAddressNotFound;
      // 역지오코딩 벤더가 둘 다 실패한 경우 — ADDRESS_NOT_FOUND와 달리 같은
      // 핀으로 재시도하면 성공할 수 있는 일시적 장애다.
      case 'ADDRESS_LOOKUP_FAILED':
        return errorCodeAddressLookupFailed;
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
      // 공지 작성·수정은 어드민 콘솔(dongsim-web)만 부른다 — 앱 datasource는
      // GET뿐이라 아래 둘은 노출되지 않는다. 사용자가 할 일도 같아 하나로 묶는다.
      case 'DUPLICATE_TRANSLATION_LANGUAGE':
      case 'MISSING_ORIGINAL_TRANSLATION':
        return errorCodeNoticeTranslationInvalid;
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
      case 'CHAT_MESSAGE_NOT_FOUND':
        return errorCodeChatMessageNotFound;
      // ── 커뮤니티(모집글) 에러 ────────────────────────────────────────
      case 'INVALID_MEETING_DATE':
        return errorCodeInvalidMeetingDate;
      case 'POST_NOT_FOUND':
        return errorCodePostNotFound;
      case 'FORBIDDEN_NOT_AUTHOR':
        return errorCodeForbiddenNotAuthor;
      // ── 커뮤니티(댓글) 에러 ──────────────────────────────────────────
      case 'COMMENT_NOT_FOUND':
        return errorCodeCommentNotFound;
      case 'FORBIDDEN_NOT_COMMENT_AUTHOR':
        return errorCodeForbiddenNotCommentAuthor;
      // 아래 셋은 답글을 달다 부모가 그 사이 사라졌거나 조건이 어긋난 경우다.
      // 서버 사정이 각각 다르지만 사용자가 할 일은 하나 — 목록을 새로 받는 것.
      case 'PARENT_COMMENT_NOT_FOUND':
      case 'PARENT_COMMENT_POST_MISMATCH':
      case 'DELETED_COMMENT_CANNOT_REPLY':
        return errorCodeReplyTargetGone;
      // 답글에 답글은 서버가 막는다(DEC-0034). 화면이 2단만 그리므로 정상
      // 경로로는 오지 않지만, 문서화된 코드라 매핑을 채워 둔다.
      case 'INVALID_COMMENT_DEPTH':
        return errorCodeInvalidCommentDepth;
      // ── 커뮤니티(좋아요·스크랩) 에러 ────────────────────────────────
      // 넷 다 "내 화면의 반응 상태가 서버와 어긋났다"는 같은 말이고, 사용자가
      // 할 일도 없다 — 리포지토리가 409/404를 의도한 최종 상태로 흡수해
      // (누르기 409 = 이미 켜짐, 끄기 404 = 이미 꺼짐) 화면을 서버 쪽으로
      // 맞춘다. 정상 경로로는 노출되지 않지만 문서화된 코드라 매핑은 채운다
      // (PARENT_COMMENT_* 셋을 하나로 묶은 것과 같은 판단).
      case 'ALREADY_LIKED':
      case 'LIKE_NOT_FOUND':
      case 'ALREADY_SCRAPPED':
      case 'SCRAP_NOT_FOUND':
        return errorCodeReactionAlreadyApplied;
      case 'COUNTRY_NOT_SPECIFIED':
        return errorCodeCountryNotSpecified;
      // 앱은 `countryCode`만 보내고 `excludeCountryCodes`는 쓰지 않으므로
      // (datasource 참조) 둘이 충돌할 일이 없다 — DEC-0021 조항 주석 2.
      case 'CONFLICTING_COUNTRY_FILTER':
        return errorCodeConflictingCountryFilter;
      // 앱은 scope=ALL 외의 값을 보내지 않으므로(datasource 참조) SCOPE는
      // 정상 경로로 오지 않는다. sort는 넷 다 서버가 지원해(BE #175) SORT도
      // 정상 경로로는 오지 않는다 — 둘 다 문서화된 코드라 커버리지 테스트가
      // 요구하는 매핑은 채워 둔다.
      case 'UNSUPPORTED_LIST_SCOPE':
        return errorCodeUnsupportedListScope;
      case 'UNSUPPORTED_LIST_SORT':
        return errorCodeUnsupportedListSort;
      // ── 채팅(모임 채팅방) 에러 ───────────────────────────────────────
      // 앱이 아직 채팅 엔드포인트를 부르지 않아 실제 노출되지는 않지만,
      // docs/api-docs.json에 실린 코드라 커버리지 테스트가 매핑을 요구한다.
      // RECRUITMENT_CLOSED는 POST /chat/join 400에서만 나온다(모집글 CRUD가
      // 아니라 채팅 참여 에러) — 여기 둔다.
      case 'RECRUITMENT_CLOSED':
        return errorCodeRecruitmentClosed;
      case 'ALREADY_JOINED':
        return errorCodeAlreadyJoined;
      case 'AUTHOR_CANNOT_LEAVE':
        return errorCodeAuthorCannotLeave;
      case 'CHAT_ROOM_FULL':
        return errorCodeChatRoomFull;
      case 'JOINED_CHAT_ROOM_LIMIT_EXCEEDED':
        return errorCodeJoinedChatRoomLimitExceeded;
      case 'NOT_A_CHAT_MEMBER':
        return errorCodeNotAChatMember;
      // ── 채팅방 강퇴 에러 (방장 전용, DEC-0043) ──────────────────────
      // 강퇴 UI는 아직 없어 노출되지 않지만 문서화된 코드라 매핑은 채운다.
      case 'FORBIDDEN_NOT_CHAT_HOST':
        return errorCodeForbiddenNotChatHost;
      case 'CHAT_MEMBER_NOT_FOUND':
        return errorCodeChatMemberNotFound;
      // 게임 로비의 CANNOT_KICK_YOURSELF와 코드만 다르고 문장이 같다 —
      // 채팅방 방장에게도 그대로 맞는 말이라 문구를 새로 만들지 않는다.
      case 'CANNOT_KICK_SELF':
        return errorCodeCannotKickYourself;
      // ── 채팅방 고정 공지 에러 (방장 전용, DEC-0054) ────────────────────
      // 강퇴의 FORBIDDEN_NOT_CHAT_HOST와 코드가 다르다 — 재사용하면 "참여자를
      // 강퇴할 수 있어요"가 공지 화면에 뜬다.
      case 'FORBIDDEN_NOT_CHAT_PIN_HOST':
        return errorCodeForbiddenNotChatPinHost;
      // 방장이 삭제한 직후 다른 기기에서 수정을 누른 경우다.
      case 'CHAT_PIN_NOT_FOUND':
        return errorCodeChatPinNotFound;
      // ── 채팅 소켓 에러 (STOMP ERROR 프레임, REST 문서에는 없음) ───────────
      // 앱이 빈 메시지·500자를 먼저 막고 messageKey는 UUID(36자)라 정상 경로에선
      // 안 나온다. 연동 가이드(DOC-0037)에 실린 코드라 매핑은 채운다.
      case 'INVALID_MESSAGE_TYPE':
        return errorCodeInvalidMessageType;
      case 'EMPTY_MESSAGE':
        return errorCodeEmptyMessage;
      case 'MESSAGE_TOO_LONG':
        return errorCodeMessageTooLong;
      case 'INVALID_GAME_INVITE':
        return errorCodeInvalidGameInvite;
      case 'INVALID_MESSAGE_KEY':
        return errorCodeInvalidMessageKey;
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
      // 커뮤니티 채팅 공지 (없으면 폴백이 `_guard`의 한국어 하드코딩이라 로케일을
      // 무시한 문구가 그대로 나간다)
      case 'errorCommunityChatNoticeLoadGeneric':
        return errorCommunityChatNoticeLoadGeneric;
      case 'errorCommunityChatNoticeSaveGeneric':
        return errorCommunityChatNoticeSaveGeneric;
      case 'errorCommunityChatNoticeDeleteGeneric':
        return errorCommunityChatNoticeDeleteGeneric;
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
      case 'errorCommunityPushFetchUnexpected':
        return errorCommunityPushFetchUnexpected;
      case 'errorCommunityPushUpdateUnexpected':
        return errorCommunityPushUpdateUnexpected;
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
      case 'errorCommunityCommentsLoadGeneric':
        return errorCommunityCommentsLoadGeneric;
      case 'errorCommunityCommentCreateGeneric':
        return errorCommunityCommentCreateGeneric;
      case 'errorCommunityCommentDeleteGeneric':
        return errorCommunityCommentDeleteGeneric;
      case 'errorCommunityReactionGeneric':
        return errorCommunityReactionGeneric;
      case 'errorCommunityScrapsLoadGeneric':
        return errorCommunityScrapsLoadGeneric;
      case 'errorCommunityNotificationsLoadGeneric':
        return errorCommunityNotificationsLoadGeneric;
      case 'errorCommunityNotificationUnreadCountLoadGeneric':
        return errorCommunityNotificationUnreadCountLoadGeneric;
      case 'errorCommunityNotificationReadGeneric':
        return errorCommunityNotificationReadGeneric;
      case 'errorCommunityPostNotificationUpdateGeneric':
        return errorCommunityPostNotificationUpdateGeneric;
      case 'errorCommunityCommentNotificationUpdateGeneric':
        return errorCommunityCommentNotificationUpdateGeneric;
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
