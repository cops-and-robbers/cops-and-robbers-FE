// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '경찰과도둑';

  @override
  String get legalDocumentKoreanOnlyNotice => '';

  @override
  String get loadingDefault => '처리 중...';

  @override
  String get permissionLocationFallbackTitle => '위치 권한 안내';

  @override
  String get permissionLocationFallbackMessage => '위치 권한을 허용해주세요';

  @override
  String get dialogUpdateOptionalTitle => '새 버전 안내';

  @override
  String get dialogUpdateOptionalMessage => '더 좋아진 새 버전이 있어요.\n업데이트하시겠어요?';

  @override
  String get dialogUpdateOptionalConfirm => '업데이트';

  @override
  String get dialogUpdateOptionalCancel => '나중에';

  @override
  String get dialogUpdateMandatoryTitle => '업데이트 안내';

  @override
  String get dialogUpdateMandatoryMessage => '새로운 버전이 출시되었어요.\n업데이트하시겠어요?';

  @override
  String get dialogUpdateMandatoryConfirm => '업데이트';

  @override
  String get dialogUpdateMandatoryCancel => '나중에';

  @override
  String chatSystemGameStartTime(int minutes) {
    return '제한 시간은 $minutes분입니다';
  }

  @override
  String get chatSystemGameStartReportTip =>
      '게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다';

  @override
  String get chatSystemPoliceMoveWarning => '경찰이 곧 출동합니다.  도둑은 서둘러 이동하세요!';

  @override
  String chatSystemRemainingRobbers(int count) {
    return '현재 $count명 도주 중!';
  }

  @override
  String get chatSystemFiveMinutesLeft => '게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!';

  @override
  String get errorNetworkTimeout => '서버 연결 시간이 초과되었습니다';

  @override
  String get errorNetworkOffline => '네트워크 연결을 확인하세요';

  @override
  String get errorServerInternal => '서버에 문제가 발생했습니다';

  @override
  String get errorBadRequest => '잘못된 요청입니다';

  @override
  String get errorUnauthorized => '인증에 실패했습니다';

  @override
  String get errorForbidden => '접근 권한이 없습니다';

  @override
  String get errorNotFound => '요청한 리소스를 찾을 수 없습니다';

  @override
  String get errorConflict => '요청이 현재 상태와 충돌합니다';

  @override
  String get buttonConfirm => '확인';

  @override
  String get buttonCancel => '취소';

  @override
  String get dialogReconnectMessage => '연결이 끊어졌어요. 재연결이 필요해요';

  @override
  String get dialogReconnectButtonConnecting => '연결 중...';

  @override
  String get dialogReconnectButtonRetry => '재연결';

  @override
  String get pageForceUpdateTitle => '업데이트 필요';

  @override
  String get pageForceUpdateMessage => '새로운 버전이 출시되었어요\n업데이트 후 이용해 주세요!';

  @override
  String get pageForceUpdateButton => '업데이트';

  @override
  String get pageMaintenanceTitle => '서버 점검 중';

  @override
  String get pageMaintenanceMessage => '더 나은 서비스를 위해 점검 중이에요\n잠시 후 다시 접속해 주세요!';

  @override
  String get buttonGoogleSignIn => 'Google로 계속하기';

  @override
  String get buttonAppleSignIn => 'Apple로 계속하기';

  @override
  String zoneRadiusKm(String km) {
    return '반경 ${km}km';
  }

  @override
  String zoneRadiusMeter(String radiusMeters) {
    return '반경 ${radiusMeters}m';
  }

  @override
  String get zoneRadiusLabel => '반경';

  @override
  String get dialogAgreementRequiredTermsTitle => '필수 약관 미동의';

  @override
  String get errorAuthLoginCancelled => '로그인이 취소되었습니다';

  @override
  String get settingsLanguageLabel => '언어';

  @override
  String get settingsLanguageSubtitle => '앱 표시 언어를 변경할 수 있어요';

  @override
  String get settingsLanguagePageTitle => '언어 선택';

  @override
  String get settingsLanguageOptionSystem => '시스템';

  @override
  String get settingsLanguageOptionKorean => '한국어';

  @override
  String get settingsLanguageOptionEnglish => 'English';

  @override
  String get settingsLanguageOptionJapanese => '日本語';

  @override
  String get asset_loading_joinRoom => '잠입 준비 중...';

  @override
  String get asset_loading_joinRoomJoinOperation => '작전에 합류하는 중...';

  @override
  String get asset_loading_joinRoomEnterSecretPassage => '비밀 통로로 진입 중...';

  @override
  String get asset_loading_joinRoomCheckDisguise => '변장 확인 중...';

  @override
  String get asset_loading_joinRoomCheckDeployment => '작전 투입 인원 확인 중...';

  @override
  String get asset_loading_createRoom => '작전 본부 설치 중...';

  @override
  String get asset_loading_createRoomPrepareHideout => '비밀 아지트 준비 중...';

  @override
  String get asset_loading_createRoomSecureArea => '작전 구역 확보 중...';

  @override
  String get asset_loading_createRoomUnfoldMap => '비밀 지도 펼치는 중...';

  @override
  String get asset_loading_createRoomTuneRadio => '무전기 주파수 맞추는 중...';

  @override
  String get asset_loading_changeTeam => '변장 중...';

  @override
  String get asset_loading_changeTeamChangeCoverIdentity => '위장 신분 변경 중...';

  @override
  String get asset_loading_changeTeamLaunderIdentity => '신분 세탁 중...';

  @override
  String get asset_loading_changeTeamSwitchToDoubleSpy => '이중 스파이 전환 중...';

  @override
  String get asset_loading_changeTeamIssueNewId => '새 신분증 발급 중...';

  @override
  String get asset_loading_startGame => '작전 개시 준비 중...';

  @override
  String get asset_loading_startGamePrepareMoveOut => '출동 준비 중...';

  @override
  String get asset_loading_startGameCountdownStart => '카운트다운 시작...';

  @override
  String get asset_loading_startGameTurnOnRadio => '무전기 켜는 중...';

  @override
  String get asset_loading_startGameDeployAgents => '현장 요원 배치 중...';

  @override
  String get asset_loading_updateArea => '작전 구역 설정 중...';

  @override
  String get asset_loading_updateAreaDesignateZone => '관할 구역 지정 중...';

  @override
  String get asset_loading_updateAreaPlotOnMap => '지도 위에 점 찍는 중...';

  @override
  String get asset_loading_updateAreaAnalyzeSatellite => '위성 사진 분석 중...';

  @override
  String get asset_loading_updateAreaCalculateRange => '작전 범위 계산 중...';

  @override
  String get asset_loading_saveSettings => '작전 지침 수정 중...';

  @override
  String get asset_loading_saveSettingsUpdateRules => '규칙 업데이트 중...';

  @override
  String get asset_loading_saveSettingsApplyNewRules => '새로운 룰 적용 중...';

  @override
  String get asset_loading_saveSettingsChangePasscode => '암호 변경 중...';

  @override
  String get asset_loading_saveSettingsApplyOperationCode => '새 작전 코드 적용 중...';

  @override
  String get asset_loading_loadProfile => '신원 조회 중...';

  @override
  String get asset_loading_loadProfileCheckWantedPoster => '수배서 확인 중...';

  @override
  String get asset_loading_loadProfileInspectId => '신분증 검사 중...';

  @override
  String get asset_loading_loadProfileMatchFingerprints => '지문 대조 중...';

  @override
  String get asset_loading_loadProfileAnalyzeSuspect => '용의자 프로필 분석 중...';

  @override
  String get asset_loading_logout => '철수 중...';

  @override
  String get asset_loading_logoutGoIntoHiding => '잠적 중...';

  @override
  String get asset_loading_logoutEraseTraces => '흔적 지우는 중...';

  @override
  String get asset_loading_logoutDestroyEvidence => '증거 인멸 중...';

  @override
  String get asset_loading_logoutEscapeViaPassage => '비밀 통로로 탈출 중...';

  @override
  String get asset_loading_deleteAccount => '탈퇴 처리 중...';

  @override
  String get asset_loading_deleteAccountObliterateRecords => '기록 말소 중...';

  @override
  String get asset_loading_deleteAccountDeleteIdentity => '신원 삭제 중...';

  @override
  String get asset_loading_reconnect => '다시 현장으로 복귀 중...';

  @override
  String get asset_loading_reconnectRejoinOperation => '작전에 재합류하는 중...';

  @override
  String get asset_loading_reconnectPrepareReturn => '현장 복귀 준비 중...';

  @override
  String get asset_loading_reconnectRestoreRadio => '무전 채널 복구 중...';

  @override
  String get asset_loading_reconnectRescanFrequency => '비밀 주파수 재탐색 중...';

  @override
  String get asset_loading_bugReport => '신고서 작성 중...';

  @override
  String get asset_loading_bugReportSubmitReport => '본부에 보고서 제출 중...';

  @override
  String get asset_loading_bugReportAttachPhotos => '현장 사진 첨부 중...';

  @override
  String get asset_loading_bugReportAssignCaseNumber => '사건 번호 부여 중...';

  @override
  String get asset_loading_bugReportHandToInvestigation => '수사반에 인계 중...';

  @override
  String get asset_loading_easterEggCharacterRumor =>
      '홈 화면 캐릭터를 자꾸 누르면 뭔가 변한다는 소문이...';

  @override
  String get asset_loading_easterEggCharacterTap =>
      '캐릭터를 여러 번 두드리면 새로운 모습이 나타난다던데...?';

  @override
  String get asset_loading_easterEggCharacterSecret =>
      '홈 화면 캐릭터에 숨겨진 비밀이 있다고 한다...';

  @override
  String get asset_loading_easterEggSettingsTap =>
      '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_easterEggVersionTap => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_easterEggVersionSecret =>
      '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_locationpermission_serviceDisabledTitle => '위치 서비스가 꺼져 있습니다';

  @override
  String get asset_locationpermission_serviceDisabledHome =>
      '게임 중 도둑 위치를 경찰 팀에게 공유하고,\n구역 이탈을 감지하기 위해 위치 정보를 사용합니다\n기기 설정에서 위치 서비스를 켜주세요';

  @override
  String get asset_locationpermission_serviceDisabledGame =>
      '게임에 복귀하려면 위치 서비스를 켜주세요\n설정에서 허용 후 앱을 재시작해주세요';

  @override
  String get asset_locationpermission_serviceDisabledWaitingRoom =>
      '게임 참가를 위해 위치 서비스를 켜주세요\n설정에서 허용 후 앱을 재시작해주세요';

  @override
  String get asset_locationpermission_permissionDeniedTitle => '위치 권한이 필요합니다';

  @override
  String get asset_locationpermission_permissionDeniedHome =>
      '게임 중 도둑 위치를 경찰 팀에게 공유하고,\n구역 이탈을 감지하기 위해 위치 정보를 사용합니다\n위치는 게임 참가자에게만 공유되며,\n게임 종료 시 즉시 중단됩니다';

  @override
  String get asset_locationpermission_permissionDeniedGame =>
      '게임에 복귀하려면 위치 권한을 허용해주세요\n설정에서 허용 후 앱을 재시작해주세요';

  @override
  String get asset_locationpermission_permissionDeniedWaitingRoom =>
      '게임 참가를 위해 위치 권한을 허용해주세요\n설정에서 허용 후 앱을 재시작해주세요';

  @override
  String get errorGameRoomCreateUnexpected => '게임 방 생성 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorActiveGameFetchUnexpected =>
      '참여 중인 게임 조회 중 예기치 않은 오류가 발생했습니다';

  @override
  String gameSettingMaxPlayers(String count) {
    return '$count명';
  }

  @override
  String gameSettingRoundMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String gameSettingLocationShareMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String gameSettingPoliceStartDelay(int minutes) {
    return '도둑 도망 후 $minutes분 뒤';
  }

  @override
  String zoneRadiusMeters(String meters) {
    return '반경 ${meters}m';
  }

  @override
  String get errorSettingsSaveFailed => '설정 저장에 실패했습니다';

  @override
  String get pageGameSettingsEditTitle => '설정 수정';

  @override
  String get buttonSaving => '저장 중...';

  @override
  String get buttonSave => '저장';

  @override
  String get errorAreaSaveFailed => '영역 저장에 실패했습니다';

  @override
  String get pageGameSettingsTitle => '게임 설정';

  @override
  String get errorZoneInfoLoadFailed => '구역 정보를 불러올 수 없습니다';

  @override
  String get errorSettingsLoadFailed => '설정 정보를 불러올 수 없습니다';

  @override
  String get zonePlayground => '플레이그라운드';

  @override
  String get zoneJail => '감옥';

  @override
  String get homePageGameButtonsHint => '게임을 만들거나 초대 코드로 참가할 수 있어요';

  @override
  String get dialogSafetyWarningTitle => '주변을 확인하며 이용해 주세요';

  @override
  String get dialogSafetyWarningMessage =>
      '게임 중 화면에만 집중하면 위험할 수 있어요\n도로 및 보행 환경을 확인하며 안전하게 이용해 주세요';

  @override
  String get buttonAcknowledgedSurroundings => '확인했어요!';

  @override
  String get homePageDontShowToday => '오늘은 다시 보지 않기';

  @override
  String get errorAlreadyInGame => '이미 참가 중인 게임이 있습니다';

  @override
  String get errorUnknownGameState => '알 수 없는 게임 상태입니다';

  @override
  String get buttonGoToSettings => '설정으로 이동';

  @override
  String get dialogBatteryGuideTitle => '끊김 없는 게임을 위해';

  @override
  String get homePageBatteryGuideStep1 => '앱 설정 → 배터리 → 제한 없음으로 변경해주세요\n';

  @override
  String get homePageBatteryGuideStep2 => '그래야 화면이 꺼져도 게임이 끊기지 않아요';

  @override
  String get errorJoinFailedCheckCode => '참여에 실패했습니다. 초대 코드를 확인해주세요';

  @override
  String get errorJoinRetry => '참여에 실패했습니다. 다시 시도해주세요';

  @override
  String get dialogJoinRoomTitle => '방 참여하기';

  @override
  String get fieldInviteCodeHint => '참여코드를 입력하세요';

  @override
  String get dialogScanInviteQrTitle => '초대코드 QR을 스캔하세요';

  @override
  String get buttonJoin => '참여하기';

  @override
  String get appBrandName => '경찰과도둑';

  @override
  String get messageComingSoon => '준비중입니다';

  @override
  String get homePageWelcomeMessage => '누가 내 치즈\n훔쳐갔어!!!!🧀';

  @override
  String get homePageWelcomeMessageClassic => '너무 기대 돼\n이번에는 어떤 역할을 할까?';

  @override
  String get buttonCreateRoom => '방 만들기';

  @override
  String get buttonJoinRoom => '방 참여하기';

  @override
  String get sessionCreationStepZoneSubtitle =>
      '게임할 구역을 설정해요.\n먼저 플레이그라운드를 지정하세요';

  @override
  String get sessionCreationStepRulesSubtitle =>
      '게임 규칙을 정해요\n숫자를 탭하면 직접 입력할 수 있어요';

  @override
  String get errorCreateRoomFailed => '게임 방 생성에 실패했습니다. 다시 시도해주세요';

  @override
  String get sessionCreationZoneFirstQuestion => '구역 선택을 먼저 설정할까요?';

  @override
  String get sessionCreationStepParticipantsTitle => '인원을 설정해요';

  @override
  String get sessionCreationStepBasicTitle => '기본 정보를 설정해요';

  @override
  String get sessionCreationStepReviewTitle => '최종 설정을 확인해요';

  @override
  String get sessionCreationStepZoneIntro => '게임에 필요한 구역을 설정해요';

  @override
  String get sessionCreationStepParticipantsHint => '최소 2명부터 게임 진행이 가능해요';

  @override
  String get sessionCreationStepBasicHint => '게임을 진행할 때, 꼭 필요한 정보들이에요';

  @override
  String get sessionCreationStepReviewHint => '방 생성 전 마지막으로 설정을 확인할까요?';

  @override
  String get buttonNext => '다음';

  @override
  String get errorZoneNotConfigured => '구역 정보를 먼저 설정해주세요';

  @override
  String get setupPlaygroundRadiusInputHint => '여기를 누르면 반경을 직접 입력할 수 있어요';

  @override
  String get setupPlaygroundDescription => '게임이 진행될 전체 구역의 크기를 설정해요';

  @override
  String get buttonDone => '완료';

  @override
  String get setupPrisonDescription => '도둑을 잡아둘 감옥의 위치와 크기를 설정해요';

  @override
  String get errorPlaygroundFirst => '플레이그라운드를 먼저 설정해주세요';

  @override
  String get errorJailOutsidePlayground => '감옥이 플레이그라운드 범위를 벗어났어요';

  @override
  String get dummyNicknameBear => '포근포근곰...';

  @override
  String get errorCannotJoinRoom => '방에 참여할 수 없어요';

  @override
  String get errorNotInGame => '해당 게임에 참가하지 않은 사용자입니다';

  @override
  String get waitingRoomTutorialTeamSwitch => '이 버튼을 눌러 다른 팀으로 이동할 수 있어요';

  @override
  String get waitingRoomTutorialInvite => '친구에게 초대 코드를 공유할 수 있어요';

  @override
  String get waitingRoomTutorialSettings => '게임 설정을 확인할 수 있어요';

  @override
  String get waitingRoomTutorialReady => '준비가 되면 눌러주세요';

  @override
  String get dialogInGamePreviewTitle => '인게임 화면 미리 보기';

  @override
  String get dialogTutorialPromptMessage =>
      '게임이 시작되면 어떻게 동작하는지\n한 번 확인하고 시작해볼까요?';

  @override
  String get buttonViewInGamePreview => '보러 가기';

  @override
  String dialogKickConfirmTitle(String nickname) {
    return '$nickname님을 내보낼까요?';
  }

  @override
  String get dialogKickConfirmMessage =>
      '강퇴된 유저는 방에서 즉시 내보내져요\n다시 방에 참가하려면 초대코드를 입력해야 해요';

  @override
  String get buttonKick => '내보내기';

  @override
  String get errorKickFailed => '강퇴 처리 중 오류가 발생했어요';

  @override
  String get dialogKickedFromRoomTitle => '방에서 내보내졌어요';

  @override
  String get dialogKickedFromRoomMessage => '다시 참가하려면 초대코드를 입력해야 해요';

  @override
  String messageMemberKicked(String kickedNickname) {
    return '$kickedNickname님이 내보내졌어요';
  }

  @override
  String get errorTeamChangeFailed => '팀 변경에 실패했어요';

  @override
  String get errorReadyChangeFailed => '준비 상태 변경에 실패했어요';

  @override
  String get errorGameStartFailed => '게임 시작에 실패했어요';

  @override
  String get dialogLeaveRoomTitle => '방을 나가시겠어요?';

  @override
  String get dialogLeaveRoomMessage => '나가면 다시 초대코드를 입력해야 해요';

  @override
  String get buttonLeave => '나가기';

  @override
  String get errorLeaveRoomFailed => '퇴장 처리 중 오류가 발생했습니다';

  @override
  String get dialogInviteCodeCreatedTitle => '초대코드를 생성했어요';

  @override
  String get dialogInviteCodeShareMessage => '친구에게 코드를 공유하고 게임에 참여해 보세요!';

  @override
  String get messageCodeCopied => '코드가 복사되었습니다';

  @override
  String get buttonShare => '공유하기';

  @override
  String get buttonStartGame => '게임 시작';

  @override
  String get buttonReadyDone => '준비 완료';

  @override
  String get buttonReady => '준비';

  @override
  String get pageZonePreviewTitle => '게임 구역';

  @override
  String get zonePreviewSubtitle => '현재 설정된 게임 구역이에요';

  @override
  String get dummyNicknameRaccoon => '오동통 너구리';

  @override
  String get defaultNicknameLabel => '닉네임';

  @override
  String get titleGameRules => '게임 규칙';

  @override
  String get buttonViewInGame => '인게임 보기';

  @override
  String get gameRulesCopGoalPrefix => '경찰은 모든 도둑을 잡아서';

  @override
  String get gameRulesCopGoalSuffix => '체포하면,';

  @override
  String get gameRulesRobberGoalPrefix => '\n도둑은';

  @override
  String get gameRulesRobberGoalCondition => '제한 시간이 끝날 때까지 버티면';

  @override
  String get gameRulesWinSuffix => '승리해요';

  @override
  String get gameRulesLocationShareLine1 => '도둑팀의 위치는';

  @override
  String gameRulesLocationShareLine2(int minutes) {
    return '$minutes분마다';
  }

  @override
  String get gameRulesLocationShareLine3 => '경찰팀에게 공유돼요';

  @override
  String get gameRulesZoneRuleLine1 => '지정된 게임 구역에서 벗어나면 안 돼요';

  @override
  String get gameRulesZoneRuleLine2 => '\n→ 구역 밖으로 나가면 화면이 잠겨요';

  @override
  String get dialogstep0SelectAreaContentTitle => '플레이그라운드';

  @override
  String get dialogstep0SelectAreaContentTitle5bc0 => '감옥';

  @override
  String get fieldstep1ParticipantSettingsContentLabel => '최대 참가자';

  @override
  String get unitPerson => '명';

  @override
  String get fieldstep2GameSettingsContentLabel => '라운드 제한 시간';

  @override
  String get unitMinutes => '분';

  @override
  String get fieldstep2GameSettingsContentLabel5ab2 => '도둑 위치 공유 간격';

  @override
  String get gameSettingNoLocationShareWarning => '도둑의 위치가 공유되지 않아요!';

  @override
  String get fieldstep2GameSettingsContentLabelCe3b => '경찰 출동 시간';

  @override
  String get gameSettingPoliceStartPrefix => '도둑 도망 후';

  @override
  String get gameSettingPoliceStartSuffix => '뒤';

  @override
  String get sectionTitleSettings => '설정';

  @override
  String get labelParticipantCount => '참여 인원';

  @override
  String get fieldRoundTimeLimit => '라운드 제한 시간';

  @override
  String get fieldLocationShareInterval => '위치 공유 간격';

  @override
  String get fieldPoliceDispatchTime => '경찰 출동 시간';

  @override
  String teamSectionCurrentCount(int count) {
    return '현재 $count명';
  }

  @override
  String get sectionTitleZone => '구역';

  @override
  String get errorLogoutGeneric => '로그아웃 중 오류가 발생했습니다';

  @override
  String get errorAuthUserNotFound => '로그인 정보를 가져올 수 없습니다. 다시 시도해주세요';

  @override
  String get errorAuthTokenIssueFailed => '인증 토큰 발급에 실패했습니다. 다시 시도해주세요';

  @override
  String get errorAuthTokenValidationFailed =>
      'Firebase 인증 토큰 검증에 실패했습니다. 다시 로그인해주세요';

  @override
  String get errorAuthInvalidCredential => '잘못된 인증 정보입니다';

  @override
  String get errorAuthAccountDisabled => '비활성화된 계정입니다';

  @override
  String get errorAuthTooManyRequests => '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorAuthSignInMethodUnavailable => '이 로그인 방법은 현재 사용할 수 없습니다';

  @override
  String get errorAuthFirebaseConfig => 'Firebase 설정에 문제가 있습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorAuthFirebaseInternal =>
      'Firebase 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String errorAuthProviderLoginFailed(String provider) {
    return '$provider 로그인에 실패했습니다. 다시 시도해주세요';
  }

  @override
  String get errorAuthLoginFailed => '로그인에 실패했습니다. 다시 시도해주세요';

  @override
  String get linkMarketingConsent => '마케팅 정보 수신';

  @override
  String get agreementPageAgreeButton => '동의하고 시작하기';

  @override
  String get agreementPageTitle => '서비스 이용을 위해\n약관에 동의해주세요';

  @override
  String get agreementPageRequiredNotice => '필수 약관에 모두 동의해야 서비스를 이용하실 수 있어요';

  @override
  String get errorNetworkNotConnected => '아직 네트워크에 연결되지 않았어요';

  @override
  String get errorRequiredAgreementsMissing => '필수 약관에 모두 동의해주세요';

  @override
  String get messageAccountDeleted => '회원탈퇴가 완료되었습니다';

  @override
  String get dialogAge14ConfirmTitle => '만 14세 이상이신가요?';

  @override
  String get dialogAge14ConfirmMessage =>
      '경찰과 도둑은 만 14세 미만 회원가입이 불가능해요.\n해당 정보는 가입 금지 확인 용도로만 사용하고 있어요';

  @override
  String get errorLoginGeneric => '로그인 중 오류가 발생했습니다';

  @override
  String get errorAppleLoginFailed => 'Apple 로그인 중 오류가 발생했습니다';

  @override
  String get errorAgeRestrictionUnder14 => '만 14세 미만은 서비스를 이용할 수 없습니다';

  @override
  String get loginPageTagline => '실시간 GPS 기반 오프라인 추격 레이스';

  @override
  String get loginPageAgreementPrefix => '로그인 시';

  @override
  String get linkPrivacyPolicy => '개인정보 처리방침';

  @override
  String get linkTermsOfService => '이용약관';

  @override
  String get linkLocationTerms => '위치정보 이용약관';

  @override
  String get loginPageAgreementSuffix => '에 동의합니다';

  @override
  String get messageNicknameSaved => '닉네임이 저장되었어요';

  @override
  String get nicknameSetupTitle => '닉네임을 설정해요';

  @override
  String get nicknameSetupSubtitle =>
      '서비스 내에서 계속 사용될 닉네임이에요\n1~10글자로 생성할 수 있어요';

  @override
  String get fieldNicknameHint => '닉네임을 입력하세요';

  @override
  String get buttonCheckNicknameDuplicate => '중복 확인';

  @override
  String get errorNicknameTooShort => '1글자 미만의 닉네임은 사용할 수 없어요';

  @override
  String get errorNicknameDuplicated => '중복된 닉네임이에요. 다른 닉네임을 입력하세요';

  @override
  String get nicknameAvailable => '사용 가능한 닉네임이에요';

  @override
  String get splashReturningToScene => '다시 현장으로 복귀 중...';

  @override
  String get dialogNetworkConnectionFailedTitle => '네트워크 연결 실패';

  @override
  String get dialogSplashOfflineMessage => '인터넷 연결을 확인한 후\n다시 시도해주세요';

  @override
  String get splashPleaseWait => '잠시만 기다려주세요';

  @override
  String get splashCreditTag => 'by 동심지키미';

  @override
  String get splashOfflineTitle => '인터넷 연결이 필요합니다';

  @override
  String get splashOfflineMessage => '연결 상태를 확인한 후\n다시 시도해주세요';

  @override
  String get errorUnknown => '알 수 없는 오류가 발생했습니다';

  @override
  String get errorLogoutFailed => '로그아웃에 실패했습니다';

  @override
  String get agreementAllCheckboxLabel => '전체 동의';

  @override
  String get agreementItemRequiredTag => '[필수]';

  @override
  String get agreementItemOptionalTag => '[선택]';

  @override
  String get gameRobberOnTheRunBanner => '도둑이 도망치는 중이에요!';

  @override
  String get gameOverBannerTitle => '게임 종료!';

  @override
  String get gameOverReasonAllArrested => '도둑이 모두 체포되었습니다!';

  @override
  String get gameOverReasonTimeUp => '제한 시간이 종료되었습니다!';

  @override
  String get gameOverFallbackMessage => '게임이 종료되었습니다.';

  @override
  String get gameTeamCop => '경찰팀';

  @override
  String get gameTeamRobber => '도둑팀';

  @override
  String get gameResultWin => '승리';

  @override
  String get gameResultLose => '패배';

  @override
  String messageGameOverWinner(Object winnerTeamLabel) {
    return '$winnerTeamLabel의 승리입니다!';
  }

  @override
  String get gameRoleCopLabel => '경찰';

  @override
  String get gameRoleRobberLabel => '도둑';

  @override
  String get errorCannotArrestDuringWait => '경찰 대기 시간 중에는 도둑을 체포할 수 없습니다';

  @override
  String get qrScannerWantedRobberTitle => '도둑의 수배 QR을 스캔하세요';

  @override
  String get errorExpiredQr => '만료된 QR입니다. QR 새로고침을 요청하세요';

  @override
  String get errorAlreadyArrested => '이미 체포된 도둑입니다';

  @override
  String get gameArrestOverlayTitle => '체포되었어요!';

  @override
  String get gameArrestOverlayMessage =>
      '체포되어 있는 동안에는 게임 상황을 확인할 수 없어요\n같은 팀에게 구조 요청을 하며 빠르게 탈옥해요!';

  @override
  String get gameArrestOverlayEscapeCompleteButton => '탈옥 완료';

  @override
  String get buttonEscape => '탈옥';

  @override
  String get buttonNo => '아니요';

  @override
  String get labelArrestCount => '체포 횟수';

  @override
  String gameResultArrestCount(int count) {
    return '$count회';
  }

  @override
  String get fieldRemainingRobbers => '남은 도둑';

  @override
  String gameResultRemainingRobberCount(int count) {
    return '$count명';
  }

  @override
  String get fieldGamePlaytime => '게임 진행 시간';

  @override
  String get buttonGoHome => '홈으로';

  @override
  String get buttonPlayAgain => '한 번 더';

  @override
  String gameLocationRevealCountdown(String formatted) {
    return '다음 도둑 위치 공개까지 $formatted';
  }

  @override
  String get dialogArrestConfirmTitle => '해당 플레이어를 체포하셨나요?';

  @override
  String get buttonYes => '네';

  @override
  String get dialogEscapeAttemptMessage => '탈옥을 시도하시겠습니까?';

  @override
  String get gameParticipantOverlayCurrent => '현재';

  @override
  String gameParticipantOverlayCount(int count) {
    return '$count명';
  }

  @override
  String get gameRobberStatusEscaping => '도주 중!';

  @override
  String gamePoliceStartCountdown(String formatted) {
    return '경찰 시작까지 $formatted';
  }

  @override
  String get gameQrDisplayTitle => '수배 QR';

  @override
  String get gameQrDisplayMessage => '경찰에게 QR을 보여주세요';

  @override
  String get buttonClose => '닫기';

  @override
  String get dialogCameraPermissionTitle => '카메라 권한 필요';

  @override
  String get dialogCameraPermissionMessage =>
      'QR코드를 스캔하려면 카메라 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요';

  @override
  String get errorCameraUnavailable => '카메라를 사용할 수 없습니다';

  @override
  String get gameZoneExitBanner => '플레이그라운드를 벗어났어요';

  @override
  String get chatTeamPrefix => '[팀]';

  @override
  String get chatSystemGameTimeLimit30Min => '제한 시간은 30분입니다';

  @override
  String get chatSystemGoodLuckRobber => '도둑 잘 도망쳐 봐요~';

  @override
  String get chatSystemLetsWin => '이겨봅시다!';

  @override
  String get messageMessageCopied => '메시지가 복사되었어요';

  @override
  String get messageUserBlocked => '해당 유저를 차단했어요';

  @override
  String get fieldReportContentLabel => '신고 내용';

  @override
  String get fieldReportReasonHint =>
      '신고 사유를 자세히 작성해 주세요\n(상황 또는 대화 내용을 포함해 주세요)';

  @override
  String get buttonReport => '신고하기';

  @override
  String get messageReportSubmitted => '신고가 접수되었어요';

  @override
  String get errorReportFailed => '신고에 실패했어요';

  @override
  String get dialogReportConfirmTitle => '해당 유저를 신고할까요?';

  @override
  String get chatReportSelectedCategoryLabel => '선택한 신고 사유:';

  @override
  String get chatReportSubmitNotice => '\n신고된 내용은 검토 후 조치할게요';

  @override
  String get buttonCopy => '복사하기';

  @override
  String get buttonBlock => '차단하기';

  @override
  String get chatReportCategoryTitle => '신고 유형 선택';

  @override
  String chatInputBarUnreadAll(String all) {
    return '전체 $all개';
  }

  @override
  String chatInputBarUnreadTeam(String team) {
    return '팀 $team개';
  }

  @override
  String chatInputBarUnreadHint(String body) {
    return '안 읽은 메시지 [$body]';
  }

  @override
  String get chatInputBarConnecting => '연결 중...';

  @override
  String get chatInputBarHint => '채팅을 입력하세요';

  @override
  String get chatMessageListEmpty => '채팅을 시작해보세요';

  @override
  String get buttonGoToLatestMessage => '최신 메시지로 이동';

  @override
  String get chatWeekdayMon => '월';

  @override
  String get chatWeekdayTue => '화';

  @override
  String get chatWeekdayWed => '수';

  @override
  String get chatWeekdayThu => '목';

  @override
  String get chatWeekdayFri => '금';

  @override
  String get chatWeekdaySat => '토';

  @override
  String get chatWeekdaySun => '일';

  @override
  String chatDateSeparator(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year년 $month월 $day일 $weekday요일';
  }

  @override
  String get chatScopeAllTitle => '전체 채팅';

  @override
  String get chatScopeTeamTitle => '팀 채팅';

  @override
  String get chatPreviewTagNotice => '공지';

  @override
  String get chatPreviewTagTeam => '팀';

  @override
  String get chatPreviewTagAll => '전체';

  @override
  String get messageChangesSaved => '변경사항이 저장되었어요';

  @override
  String get errorTemporaryRetry => '일시적인 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String get pageAgreementSettingsTitle => '이용약관 및 정책';

  @override
  String get errorAgreementLoadFailed => '약관 동의 현황을 불러올 수 없습니다';

  @override
  String get buttonRetry => '다시 시도';

  @override
  String get buttonSaveChanges => '변경사항 저장';

  @override
  String get errorLegalDocumentLoadFailed => '문서를 불러올 수 없습니다';

  @override
  String get pageSettingsTitle => '설정';

  @override
  String get settingsSectionAccount => '계정';

  @override
  String get settingsAccountChangeNickname => '닉네임 변경';

  @override
  String get settingsSectionAppPreferences => '앱 설정';

  @override
  String get settingsAppGameNotification => '게임 알림';

  @override
  String get settingsAppGameNotificationDescription =>
      '게임 진행 중 발생하는 이벤트 알림을 설정해요';

  @override
  String get settingsAppGeneralNotification => '알림';

  @override
  String get settingsAppGeneralNotificationHighlight => '게임 중 알림';

  @override
  String get settingsAppGeneralNotificationDetail =>
      '을 포함한 앱에서 보내는 모든 알림을 설정해요';

  @override
  String get settingsAppLocationPermission => '위치 권한 관리';

  @override
  String get settingsAppLocationPermissionDescription =>
      '기기 설정에서 위치 권한을 변경할 수 있어요';

  @override
  String get settingsSectionGuide => '이용 안내';

  @override
  String get settingsGuideBugReport => '버그 제보';

  @override
  String get settingsGuideTutorialRewatch => '튜토리얼 다시 보기';

  @override
  String get settingsGuideTutorialReset => '튜토리얼 초기화';

  @override
  String get settingsGuideAgreements => '이용약관 및 정책';

  @override
  String get settingsSectionEtc => '기타';

  @override
  String get settingsEtcDeleteAccount => '회원 탈퇴';

  @override
  String get settingsAppVersionLabel => '앱 버전';

  @override
  String get settingsSnsPrompt => '더 많은 소식이 궁금하다면 👀';

  @override
  String get errorGameNotificationToggleFailed => '게임 알림 설정을 변경하지 못했어요';

  @override
  String get titleBugReport => '버그 제보';

  @override
  String get fieldBugReportLabel => '버그 내용';

  @override
  String get fieldBugReportHint =>
      '어떤 문제가 발생했나요?\n발생 상황을 자세히 적어주세요(시간, 기기 정보 포함)';

  @override
  String get buttonSubmitReport => '제보하기';

  @override
  String get messageBugReportSubmitted => '버그 제보가 접수되었어요';

  @override
  String get dialogTutorialResetTitle => '튜토리얼 초기화';

  @override
  String get dialogTutorialResetMessage => '모든 화면의 튜토리얼을\n다시 볼 수 있도록 초기화할까요?';

  @override
  String get buttonReset => '초기화';

  @override
  String get messageTutorialReset => '튜토리얼이 초기화되었어요';

  @override
  String get dialogLogoutTitle => '로그아웃';

  @override
  String get dialogLogoutMessage => '정말 로그아웃 하시겠어요?';

  @override
  String get snackbarLogoutFailed => '로그아웃에 실패했습니다';

  @override
  String get snackbarLogoutSuccess => '로그아웃되었습니다';

  @override
  String get dialogDeleteAccountTitle => '회원 탈퇴';

  @override
  String get dialogDeleteAccountMessage =>
      '탈퇴하면 모든 데이터가 삭제되며\n되돌릴 수 없습니다\n\n계속하려면 \"delete\"를 입력하세요';

  @override
  String get fieldDeleteAccountHint => 'delete';

  @override
  String get buttonDeleteAccount => '탈퇴';

  @override
  String get tutorialDummyNicknameCop1 => '경찰1';

  @override
  String get tutorialDummyNicknameRobberKing => '도둑킹';

  @override
  String get tutorialDummyNicknameRobberOrNot => '도둑이게아니게';

  @override
  String get tutorialDummyNicknameCapturedRobber => '잡힌도둑';

  @override
  String get titleTutorialComplete => '튜토리얼 완료!';

  @override
  String get messageTutorialComplete => '핵심 흐름을 익혔어요\n실제 게임에서 활용해보세요';

  @override
  String get buttonFinishTutorial => '튜토리얼 끝내기';

  @override
  String get tutorialInGameMyLocation => '내 위치로 카메라가 이동했어요';

  @override
  String get tutorialMapPreviewLabel => '지도 미리보기';

  @override
  String get tutorialLocationRevealCountdown => '다음 도둑 위치 공개까지 04:30';

  @override
  String get tutorialInGameRulesGuide => '게임 룰 안내가 열려요';

  @override
  String get tutorialQrRobberHint => '내 수배 QR이 화면에 표시돼요. 경찰에게 보여주면 체포';

  @override
  String get tutorialQrCopHint => '카메라가 켜지고 도둑의 QR을 스캔해 체포할 수 있어요';

  @override
  String get tutorialMissionParticipantsButton => '참가자 보기 버튼을 눌러보세요';

  @override
  String get tutorialMissionQrButton => 'QR 버튼을 눌러보세요';

  @override
  String get tutorialMissionMapButton => '지도로 돌아가 보세요';

  @override
  String tutorialMissionProgress(String step) {
    return '미션 $step/3';
  }

  @override
  String get tutorialPerspectiveRobber => '도둑 시점 보는 중';

  @override
  String get tutorialPerspectiveCop => '경찰 시점 보는 중';

  @override
  String get tutorialInGameSelfEscape => '본인이 수감됐다면 카드 탭으로 탈옥을 시도할 수 있어요';

  @override
  String get tutorialInGameQrArrest => '실제 게임에서는 QR 스캔으로 도둑을 체포해요';

  @override
  String get tutorialCurrentLabel => '현재';

  @override
  String tutorialPlayerCount(int count) {
    return '$count명';
  }

  @override
  String get tutorialOnTheRun => '도주 중!';

  @override
  String get tutorialInGameChatExpand => '핸들을 위로 드래그하면 채팅이 펼쳐져요';

  @override
  String get tutorialInGameChatInput => '여기에 메시지를 입력하면 팀/전체 채팅으로 보낼 수 있어요';

  @override
  String get tutorialChatHint => '채팅을 입력하세요';

  @override
  String get tutorialCatalogAreaSubtitle => '플레이그라운드·감옥 설정과 슬라이더 조작';

  @override
  String get tutorialCatalogInviteSubtitle => '초대 코드 입력과 QR 스캔';

  @override
  String get tutorialCatalogWaitingRoomTitle => '대기방';

  @override
  String get tutorialCatalogLobbySubtitle => '팀 변경, 게임 설정, 준비 완료';

  @override
  String get tutorialCatalogInGameTitle => '인게임';

  @override
  String get tutorialCatalogGameSubtitle => '타이머·지도·참가자·채팅·QR';

  @override
  String get pageTutorialCatalogTitle => '튜토리얼';

  @override
  String get tutorialCatalogIntro => '게임을 처음 한다면 한 번씩 보고 시작해보세요';

  @override
  String get tutorialCatalogComingSoon => '준비 중';

  @override
  String get creditMemberHongEuiMin => '홍의민';

  @override
  String get creditMemberParkChanBin => '박찬빈';

  @override
  String get creditMemberLeeChangHee => '이창희';

  @override
  String get creditMemberJeongSangHee => '정상희';

  @override
  String get creditMemberHwangHyeRim => '황혜림';

  @override
  String get creditMemberYoonJiHee => '윤지희';

  @override
  String get creditMemberKimDaim => '김다임';

  @override
  String get creditMemberShinJiHoon => '신지훈';

  @override
  String get creditMemberNamHaeYoon => '남해윤';

  @override
  String get creditMemberSongHyeJung => '송혜정';

  @override
  String get creditMemberLeeJin => '이진';

  @override
  String get creditMemberAhnGeumSeo => '안금서';

  @override
  String get creditMemberSonGeonWoo => '손건우';

  @override
  String get creditMemberShinHyeBin => '신혜빈';

  @override
  String get creditMemberJeongChangWoo => '정창우';

  @override
  String get creditMemberHeoSeokJun => '허석준';

  @override
  String get creditMemberSeoHyunJin => '서현진';

  @override
  String get creditMemberOhDongHyun => '오동현';

  @override
  String get creditMemberChoiSeungHoon => '최승훈';

  @override
  String get creditMemberKimMinWook => '김민욱';

  @override
  String get creditMemberJeongMyeongJun => '정명준';

  @override
  String get creditMemberKangDaeHyun => '강대현';

  @override
  String get creditMemberSimHyuk => '심 혁';

  @override
  String get pageCreditsTitle => '경찰과 도둑을 만든 사람들';

  @override
  String get errorReportGeneric => '신고 처리 중 오류가 발생했습니다';

  @override
  String get reportCategoryBait => '낚시/놀람/도배';

  @override
  String get reportCategoryAbuse => '욕설/비하';

  @override
  String get reportCategoryImpersonation => '사칭/사기';

  @override
  String get reportCategorySpam => '광고/스팸';

  @override
  String get reportCategoryExploit => '부정 행위/버그 악용';

  @override
  String get reportCategoryTeamSabotage => '팀 사기 저하';

  @override
  String get reportCategoryOther => '기타(직접 작성)';

  @override
  String get errorNicknameCheckUnexpected => '닉네임 확인 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorNicknameUpdateUnexpected => '닉네임 변경 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorUserInfoFetch => '사용자 정보 조회 중 오류가 발생했습니다';

  @override
  String get errorDeleteAccountUnexpected => '회원 탈퇴 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorAgreementFetchUnexpected => '약관 동의 상태 조회 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorAgreementSaveUnexpected => '약관 동의 저장 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorGamePushFetchUnexpected =>
      '게임 푸시 알림 동의 조회 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorGamePushUpdateUnexpected =>
      '게임 푸시 알림 동의 업데이트 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorAuthTokenMissing => '인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다';

  @override
  String get errorServerUnreachable => '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorAuthExpired => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get errorNoticesLoadGeneric => '공지사항을 불러오는 중 오류가 발생했습니다';

  @override
  String get messageLoadingNotices => '공지사항을 불러오는 중...';

  @override
  String get errorNoticeLoadFailed => '공지사항을 불러오지 못했어요';

  @override
  String get pageNoticesTitle => '공지사항';

  @override
  String get pageNoticesEmpty => '등록된 공지사항이 없습니다';

  @override
  String get errorAreaLoadFailed => '구역 정보를 불러올 수 없습니다';

  @override
  String get pageNotFoundTitle => '페이지를 찾을 수 없습니다';

  @override
  String get pageNotFoundMessage => '요청하신 페이지가 존재하지 않습니다';

  @override
  String pageNotFoundPath(String path) {
    return '경로: $path';
  }

  @override
  String get buttonLogout => '로그아웃';

  @override
  String get errorBugReportFailed => '버그 제보 처리 중 오류가 발생했습니다';

  @override
  String gameEventStartTime(int minutes) {
    return '제한 시간은 $minutes분입니다.';
  }

  @override
  String get gameEventStartReady => '잠시 후 게임이 시작됩니다.  모든 플레이어는 준비하세요!';

  @override
  String get gameEventStartReportTip =>
      '게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다.';

  @override
  String get gameEventStartGo => '게임 시작!  행운을 빕니다!';

  @override
  String get gameEventPoliceMove => '경찰 출동!  도둑은 도망치세요!';

  @override
  String get gameEventLocationReveal => '현재 도둑의 위치가 공개됩니다!';

  @override
  String gameEventArrestNotice(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname]님이 @icon_robber [$robberNickname]님을 체포했습니다!';
  }

  @override
  String get gameEventEscapeNotice => '도둑이 탈옥했습니다! 지금 바로 체포하세요!';

  @override
  String mapErrorLoadFailed(String mapName) {
    return '$mapName 로드 실패';
  }

  @override
  String get errorGameJoinUnexpected => '게임 입장 중 예기치 않은 오류가 발생했습니다';

  @override
  String get errorAlreadyInAnotherRoom =>
      '이미 참여 중인 방이 있어요. 현재 방에서 나간 후 다시 시도해주세요';

  @override
  String get deeplinkAlreadyInRoom => '이미 참여 중인 방이 있어요';

  @override
  String get errorGameAlreadyStarted => '이미 시작되어 입장할 수 없는 게임이에요';

  @override
  String get errorRoomSwitchFailed => '새 방에 입장하지 못했어요. 이전 방에서는 나온 상태예요';

  @override
  String get deeplinkSwitchRoomTitle => '방을 이동할까요?';

  @override
  String get deeplinkSwitchRoomMessage => '현재 참여 중인 방에서 나가고 새 방에 참가해요';

  @override
  String get deeplinkSwitchRoomConfirm => '나가고 참가';

  @override
  String get errorPendingInviteLoad => '대기 중인 초대 코드를 불러오지 못했어요';

  @override
  String get errorPendingInviteSave => '초대 코드 저장에 실패했어요';

  @override
  String get errorPendingInviteClear => '초대 코드 삭제에 실패했어요';

  @override
  String shareInviteMessage(String inviteCode) {
    return '친구가 경찰과도둑 방에 초대했어요! 초대 코드 $inviteCode';
  }

  @override
  String get errorCodeMissingRequestPart => '요청에 필요한 파트가 누락되었습니다';

  @override
  String get errorCodeInvalidRequestBody => '요청 본문의 형식이 잘못되었습니다';

  @override
  String get errorCodeInvalidQueryParameter => '쿼리 파라미터의 형식이 잘못되었습니다';

  @override
  String get errorCodeQueryParameterTypeMismatch => '요청 파라미터의 타입이 잘못되었습니다';

  @override
  String get errorCodeInvalidInputValue => '입력값이 유효성 검사를 통과하지 못했습니다';

  @override
  String get errorCodeInvalidDestination => '잘못된 연결 경로입니다';

  @override
  String get errorCodeUnsupportedMediaType => '지원하지 않는 형식입니다';

  @override
  String get errorCodeMethodNotAllowed => '허용되지 않은 요청입니다';

  @override
  String get errorCodeEndpointNotFound => '요청 경로를 찾을 수 없습니다';

  @override
  String get errorCodeInvalidSocketSession => '세션 정보를 찾을 수 없습니다. 다시 연결해주세요';

  @override
  String get errorCodeUnauthorizedSubscription => '해당 팀 전용 채널을 구독할 권한이 없습니다';

  @override
  String get errorCodeInternalServerError => '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeFirebaseInitError => '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeFirebaseConfigNotFound =>
      '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeEncryptionFailed => '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeDecryptionFailed => '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeInvalidEncryptionKey => '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeSocialLoginFailed => '소셜 로그인에 실패하였습니다';

  @override
  String get errorCodeAccessTokenExpired => '인증 정보가 만료되었습니다';

  @override
  String get errorCodeRefreshTokenExpired => '로그인이 만료되었습니다. 다시 로그인해주세요';

  @override
  String get errorCodeInvalidToken => '인증 정보가 올바르지 않습니다. 다시 로그인해주세요';

  @override
  String get errorCodeUnauthenticatedRequest => '로그인이 필요합니다';

  @override
  String get errorCodeExpiredFirebaseToken => '인증이 만료되었습니다. 다시 시도해주세요';

  @override
  String get errorCodeInvalidFirebaseToken => '인증에 실패했습니다. 다시 시도해주세요';

  @override
  String get errorCodeUnsupportedSocialType => '지원하지 않는 소셜 로그인 방식입니다';

  @override
  String get errorCodeForbiddenAdminOnly => '관리자 권한이 필요합니다';

  @override
  String get errorCodeNicknameGenerationFailed =>
      '회원가입에 실패했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeFirebaseServerError => '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeUserNotFound => '해당 유저를 찾을 수 없습니다';

  @override
  String get errorCodeDuplicatedNickname => '이미 사용 중인 닉네임입니다. 다른 닉네임을 선택해주세요';

  @override
  String get errorCodeCannotWithdraw => '진행 중인 게임 세션이 있어 탈퇴할 수 없습니다';

  @override
  String get errorCodeRequiredTermsNotAgreed => '필수 약관은 모두 동의해야 합니다';

  @override
  String get errorCodeGameNotFound => '요청하신 게임 정보가 존재하지 않습니다';

  @override
  String get errorCodeGameNotInProgress => '게임이 진행 중인 상태가 아닙니다';

  @override
  String get errorCodeGameNotActive => '대기 중이거나 진행 중인 게임에서만 조회할 수 있습니다';

  @override
  String get errorCodeGameNotWaiting => '대기 중인 게임에서만 설정을 변경할 수 있습니다';

  @override
  String get errorCodeInvalidLocationInterval => '위치 공개 주기는 라운드 시간보다 짧아야 합니다';

  @override
  String get errorCodeInvalidPoliceWaitTime => '경찰 대기 시간은 라운드 시간보다 짧아야 합니다';

  @override
  String get errorCodeInviteCodeGenerationFailed =>
      '초대 코드 생성에 실패했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorCodeInvalidJailRadius =>
      '감옥의 반지름이 플레이그라운드의 반지름보다 크거나 같을 수 없습니다';

  @override
  String get errorCodeJailOutsidePlayground => '감옥은 플레이그라운드 내부에 완전히 포함되어야 합니다';

  @override
  String get errorCodeGameAreaNotFound => '해당 게임 구역을 찾을 수 없습니다';

  @override
  String get errorCodeAlreadyParticipating => '이미 해당 게임에 참가하고 있습니다';

  @override
  String get errorCodeGameAlreadyStarted => '이미 시작된 게임에는 참여할 수 없습니다';

  @override
  String get errorCodeGameFull => '게임에 참가할 수 있는 최대 인원을 초과했습니다';

  @override
  String get errorCodeInvalidInviteCode => '입력하신 초대 코드가 유효하지 않습니다';

  @override
  String get errorCodeParticipantNotFound => '해당 게임에 참가하지 않은 사용자입니다';

  @override
  String get errorCodeNotAParticipant => '해당 게임의 참가자가 아닙니다';

  @override
  String get errorCodeCannotLeaveDuringGame => '게임이 시작된 이후에는 방을 나갈 수 없습니다';

  @override
  String get errorCodeLobbyActionNotAllowed => '게임이 시작된 이후에는 로비 상태를 변경할 수 없습니다';

  @override
  String get errorCodeNotHost => '방장만 할 수 있습니다';

  @override
  String get errorCodeInvalidTeamComposition =>
      '게임을 시작하려면 경찰과 도둑 팀에 각각 최소 1명 이상의 참가자가 필요합니다';

  @override
  String get errorCodeNotAllReady => '모든 참가자가 준비 상태여야 게임을 시작할 수 있습니다';

  @override
  String get errorCodeNotRobberTeam => '도둑 팀만 위치를 전송할 수 있습니다';

  @override
  String get errorCodeHostCannotUnready => '방장은 항상 준비 상태여야 합니다';

  @override
  String get errorCodeParticipantGameMismatch => '경찰과 도둑이 서로 다른 게임에 참여하고 있습니다';

  @override
  String get errorCodeOnlyPoliceCanArrest => '경찰 팀만 도둑을 체포할 수 있습니다';

  @override
  String get errorCodeOnlyRobberCanBeArrested => '도둑 팀만 체포될 수 있습니다';

  @override
  String get errorCodeOnlyRobberCanEscape => '도둑 팀만 탈옥할 수 있습니다';

  @override
  String get errorCodeAlreadyArrested => '이미 수감된 도둑입니다';

  @override
  String get errorCodeNotJailed => '수감된 상태에서만 탈옥할 수 있습니다';

  @override
  String get errorCodePoliceWaitingTime => '경찰은 대기 시간 동안 도둑을 체포할 수 없습니다';

  @override
  String get errorCodeCannotKickYourself => '방장은 자기 자신을 강퇴할 수 없습니다';

  @override
  String get errorCodeNoticeNotFound => '해당 공지사항을 찾을 수 없습니다';

  @override
  String get errorCodeGameResultNotFound => '해당 게임 결과를 찾을 수 없습니다';

  @override
  String get errorCodeEtcReasonRequired => '신고 유형이 기타일 때 사유를 입력해야 합니다';

  @override
  String get errorCodeSelfReport => '본인을 신고할 수 없습니다';

  @override
  String get errorCodeDuplicateReport => '해당 게임에서 이미 신고한 사용자입니다';

  @override
  String get errorCodeReportNotFound => '해당 신고 내역이 존재하지 않습니다';

  @override
  String get errorCodeReportTargetNotFound => '해당 게임에 존재하지 않는 참가자입니다';

  @override
  String get pingFound => '발견';

  @override
  String get pingSuspect => '의심';

  @override
  String get pingCooldownNotice => '잠시 후 다시 시도해주세요';
}
