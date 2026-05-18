// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cops and Robbers';

  @override
  String get legalDocumentKoreanOnlyNotice =>
      'This document is provided in Korean only. The Korean version is the legally binding text';

  @override
  String get loadingDefault => 'Processing...';

  @override
  String get permissionLocationFallbackTitle => 'Location permission guide';

  @override
  String get permissionLocationFallbackMessage =>
      'Please allow location permission';

  @override
  String get dialogUpdateOptionalTitle => 'New version notice';

  @override
  String get dialogUpdateOptionalMessage =>
      'An improved new version is available\nWould you like to update?';

  @override
  String get dialogUpdateOptionalConfirm => 'Update';

  @override
  String get dialogUpdateOptionalCancel => 'Later';

  @override
  String get dialogUpdateMandatoryTitle => 'Update notice';

  @override
  String get dialogUpdateMandatoryMessage =>
      'A new version has been released\nWould you like to update?';

  @override
  String get dialogUpdateMandatoryConfirm => 'Update';

  @override
  String get dialogUpdateMandatoryCancel => 'Later';

  @override
  String chatSystemGameStartTime(int minutes) {
    return 'The time limit is $minutes minutes';
  }

  @override
  String get chatSystemGameStartReady =>
      'The game will start shortly. All players, please get ready!';

  @override
  String get chatSystemGameStartReportTip =>
      'During the game, you can long-press a chat message to report and block disruptive users';

  @override
  String get chatSystemGameStartGo => 'Game start! Good luck!';

  @override
  String get chatSystemPoliceMoveWarning =>
      'The Cops will move out shortly. Robbers, hurry up and move!';

  @override
  String get chatSystemPoliceMove => 'Cops moving out! Robbers, run away!';

  @override
  String get chatSystemLocationReveal =>
      'The Robbers\' current locations are being revealed!';

  @override
  String chatSystemRemainingRobbers(int count) {
    return 'Currently $count people running away!';
  }

  @override
  String chatSystemArrest(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname] arrested @icon_robber [$robberNickname]!';
  }

  @override
  String get chatSystemEscapeNotice =>
      'A Robber has jailbroken! Arrest them right now!';

  @override
  String get chatSystemFiveMinutesLeft =>
      '5 minutes left until game over. Don\'t miss your last chance!';

  @override
  String get errorNetworkTimeout => 'Server connection timed out';

  @override
  String get errorNetworkOffline => 'Please check your network connection';

  @override
  String get errorServerInternal => 'An error occurred on the server';

  @override
  String get errorBadRequest => 'Invalid request';

  @override
  String get errorUnauthorized => 'Authentication failed';

  @override
  String get errorForbidden => 'Access denied';

  @override
  String get errorNotFound => 'The requested resource could not be found';

  @override
  String get errorConflict => 'The request conflicts with the current state';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get dialogReconnectMessage =>
      'Connection lost. Reconnection is required';

  @override
  String get dialogReconnectButtonConnecting => 'Connecting...';

  @override
  String get dialogReconnectButtonRetry => 'Reconnect';

  @override
  String get pageForceUpdateTitle => 'Update required';

  @override
  String get pageForceUpdateMessage =>
      'A new version has been released\nPlease update before using the app!';

  @override
  String get pageForceUpdateButton => 'Update';

  @override
  String get pageMaintenanceTitle => 'Under maintenance';

  @override
  String get pageMaintenanceMessage =>
      'We are performing maintenance to provide better service\nPlease reconnect in a moment!';

  @override
  String get buttonGoogleSignIn => 'Get started with Google';

  @override
  String get buttonAppleSignIn => 'Get started with Apple';

  @override
  String zoneRadiusKm(String km) {
    return 'Radius ${km}km';
  }

  @override
  String zoneRadiusMeter(String radiusMeters) {
    return 'Radius ${radiusMeters}m';
  }

  @override
  String get zoneRadiusLabel => 'Radius';

  @override
  String get dialogAgreementRequiredTermsTitle => 'Required terms not agreed';

  @override
  String get errorAuthLoginCancelled => 'Sign in was cancelled';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Change the app display language';

  @override
  String get settingsLanguagePageTitle => 'Select language';

  @override
  String get settingsLanguageOptionSystem => 'System';

  @override
  String get settingsLanguageOptionKorean => '한국어';

  @override
  String get settingsLanguageOptionEnglish => 'English';

  @override
  String get settingsLanguageOptionJapanese => '日本語';

  @override
  String get asset_loading_joinRoom => 'Preparing to infiltrate';

  @override
  String get asset_loading_joinRoom477c => 'Joining the operation';

  @override
  String get asset_loading_joinRoom24a9 =>
      'Entering through the secret passage';

  @override
  String get asset_loading_joinRoomCb98 => 'Checking the disguise';

  @override
  String get asset_loading_joinRoomF964 =>
      'Checking the operation deployment personnel';

  @override
  String get asset_loading_joinRoomB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_joinRoomAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_joinRoom25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_createRoom =>
      'Setting up the operation headquarters';

  @override
  String get asset_loading_createRoomF1fe => 'Preparing the secret hideout';

  @override
  String get asset_loading_createRoom01f8 => 'Securing the game area';

  @override
  String get asset_loading_createRoom5076 => 'Unfolding the secret map';

  @override
  String get asset_loading_createRoomDd9e =>
      'Tuning the walkie-talkie frequency';

  @override
  String get asset_loading_createRoomB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_createRoomAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_createRoom25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_changeTeam => 'Disguising';

  @override
  String get asset_loading_changeTeam681d => 'Changing the cover identity';

  @override
  String get asset_loading_changeTeam1106 => 'Laundering the identity';

  @override
  String get asset_loading_changeTeam4d7a => 'Switching to double spy';

  @override
  String get asset_loading_changeTeam4cdc => 'Issuing a new ID';

  @override
  String get asset_loading_changeTeamB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_changeTeamAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_changeTeam25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_startGame => 'Preparing to start the operation';

  @override
  String get asset_loading_startGameA35d => 'Preparing to move out';

  @override
  String get asset_loading_startGame64c3 => 'Starting countdown';

  @override
  String get asset_loading_startGame7a2f => 'Turning on the walkie-talkie';

  @override
  String get asset_loading_startGame1b41 => 'Deploying field agents';

  @override
  String get asset_loading_startGameB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_startGameAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_startGame25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_updateArea => 'Setting up the game area';

  @override
  String get asset_loading_updateArea8c32 =>
      'Designating the jurisdiction zone';

  @override
  String get asset_loading_updateArea0183 => 'Plotting points on the map';

  @override
  String get asset_loading_updateArea2433 => 'Analyzing satellite imagery';

  @override
  String get asset_loading_updateAreaDc8b => 'Calculating the operation radius';

  @override
  String get asset_loading_updateAreaB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_updateAreaAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_updateArea25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_saveSettings => 'Editing operation guidelines';

  @override
  String get asset_loading_saveSettingsFb58 => 'Updating the rules';

  @override
  String get asset_loading_saveSettings65dc => 'Applying new rules';

  @override
  String get asset_loading_saveSettings5e80 => 'Changing the passcode';

  @override
  String get asset_loading_saveSettings128d =>
      'Applying the new operation code';

  @override
  String get asset_loading_saveSettingsB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_saveSettingsAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_saveSettings25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_loadProfile => 'Verifying identity';

  @override
  String get asset_loading_loadProfile27ee => 'Checking the wanted poster';

  @override
  String get asset_loading_loadProfile6dac => 'Inspecting the ID';

  @override
  String get asset_loading_loadProfile23c6 => 'Matching fingerprints';

  @override
  String get asset_loading_loadProfile221d => 'Analyzing the suspect profile';

  @override
  String get asset_loading_loadProfileB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_loadProfileAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_loadProfile25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_logout => 'Withdrawing';

  @override
  String get asset_loading_logout3031 => 'Going into hiding';

  @override
  String get asset_loading_logoutCe40 => 'Erasing traces';

  @override
  String get asset_loading_logout0ba9 => 'Destroying evidence';

  @override
  String get asset_loading_logoutFc0d => 'Escaping through the secret passage';

  @override
  String get asset_loading_logoutB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_logoutAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_logout25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_deleteAccount => 'Processing account deletion';

  @override
  String get asset_loading_deleteAccountC5fd => 'Obliterating records';

  @override
  String get asset_loading_deleteAccount517f => 'Deleting identity';

  @override
  String get asset_loading_reconnect => 'Returning to the field';

  @override
  String get asset_loading_reconnectBa5f => 'Rejoining the operation';

  @override
  String get asset_loading_reconnect098b => 'Preparing to return to the field';

  @override
  String get asset_loading_reconnect429b => 'Restoring the radio channel';

  @override
  String get asset_loading_reconnect6b88 => 'Rescanning the secret frequency';

  @override
  String get asset_loading_reconnectB36a =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_reconnectAaf8 =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_reconnect25aa =>
      'Rumor has it that someone hid a secret in the version number';

  @override
  String get asset_loading_bugReport => 'Writing the report';

  @override
  String get asset_loading_bugReportDd4b =>
      'Submitting the report to headquarters';

  @override
  String get asset_loading_bugReport5d70 => 'Attaching field photos';

  @override
  String get asset_loading_bugReport3c49 => 'Assigning a case number';

  @override
  String get asset_loading_bugReport83ca =>
      'Handing over to the investigation team';

  @override
  String get asset_locationpermission_serviceDisabledTitle =>
      'Location services are turned off';

  @override
  String get asset_locationpermission_serviceDisabledHome =>
      'Location information is used to share the Robber\'s location with the Cops team during the game and to detect if anyone leaves the area\nPlease turn on location services in your device settings';

  @override
  String get asset_locationpermission_serviceDisabledGame =>
      'Please turn on location services to return to the game\nAllow permission in settings and restart the app';

  @override
  String get asset_locationpermission_serviceDisabledWaitingRoom =>
      'Please turn on location services to join the game\nAllow permission in settings and restart the app';

  @override
  String get asset_locationpermission_permissionDeniedTitle =>
      'Location permission is required';

  @override
  String get asset_locationpermission_permissionDeniedHome =>
      'Location information is used to share the Robber\'s location with the Cops team during the game and to detect if anyone leaves the area\nLocation is shared only with game participants and will stop immediately when the game ends';

  @override
  String get asset_locationpermission_permissionDeniedGame =>
      'Please allow location permission to return to the game\nAllow permission in settings and restart the app';

  @override
  String get asset_locationpermission_permissionDeniedWaitingRoom =>
      'Please allow location permission to join the game\nAllow permission in settings and restart the app';

  @override
  String get dialogsessionRepositoryImplMessage =>
      'An unexpected error occurred while creating the waiting room';

  @override
  String get errorActiveGameFetchUnexpected =>
      'An unexpected error occurred while looking up the game in progress';

  @override
  String gameSettingMaxPlayers(String count) {
    return '$count players';
  }

  @override
  String gameSettingRoundMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String gameSettingLocationShareMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String gameSettingPoliceStartDelay(int minutes) {
    return '$minutes min after Robbers run away';
  }

  @override
  String zoneRadiusMeters(String meters) {
    return 'Radius ${meters}m';
  }

  @override
  String get errorSettingsSaveFailed => 'Failed to save settings';

  @override
  String get pageGameSettingsEditTitle => 'Edit settings';

  @override
  String get buttonSaving => 'Saving...';

  @override
  String get buttonSave => 'Save';

  @override
  String get errorAreaSaveFailed => 'Failed to save game area';

  @override
  String get pageGameSettingsTitle => 'Game settings';

  @override
  String get errorZoneInfoLoadFailed => 'Unable to load game area information';

  @override
  String get errorSettingsLoadFailed => 'Unable to load settings information';

  @override
  String get zonePlayground => 'Playground';

  @override
  String get zoneJail => 'Jail';

  @override
  String get homePageCreateGameHint => 'You can create a new game';

  @override
  String get homePageJoinGameHint => 'Enter the invite code to join the game';

  @override
  String get dialoghomePageTitle =>
      'Please watch your surroundings while using the app';

  @override
  String get dialoghomePageMessage =>
      'Focusing only on the screen during the game can be dangerous\nPlease check the road and walking environment to stay safe';

  @override
  String get dialoghomePageConfirm => 'I understand!';

  @override
  String get homePageDontShowToday => 'Do not show again today';

  @override
  String get errorAlreadyInGame => 'You are already participating in a game';

  @override
  String get errorUnknownGameState => 'Unknown game status';

  @override
  String get buttonGoToSettings => 'Go to settings';

  @override
  String get dialoghomePageCancel => 'Cancel';

  @override
  String get dialogBatteryGuideTitle => 'For uninterrupted gameplay';

  @override
  String get homePageBatteryGuideStep1 =>
      'Please change app settings → battery → unrestricted\n';

  @override
  String get homePageBatteryGuideStep2 =>
      'This prevents the game from disconnecting even when the screen is turned off';

  @override
  String get errorJoinFailedCheckCode =>
      'Failed to join. Please check the invite code';

  @override
  String get errorJoinRetry => 'Failed to join. Please try again';

  @override
  String get dialogJoinRoomTitle => 'Join waiting room';

  @override
  String get fieldhomePageHint => 'Enter invite code';

  @override
  String get dialogScanInviteQrTitle => 'Scan the invite code QR';

  @override
  String get buttonJoin => 'Join';

  @override
  String get appBrandName => 'Cops and Robbers';

  @override
  String get messageComingSoon => 'In preparation';

  @override
  String get homePageWelcomeMessage =>
      'I am so excited\nWhat role will I play this time?';

  @override
  String get buttonCreateRoom => 'Create room';

  @override
  String get buttonJoinRoom => 'Join room';

  @override
  String get sessionCreationStepZoneSubtitle =>
      'Set up the game area\nPlease designate the playground first';

  @override
  String get sessionCreationStepRulesSubtitle =>
      'Set up the game rules\nTap the number to enter it directly';

  @override
  String get errorCreateRoomFailed =>
      'Failed to create game room. Please try again';

  @override
  String get dialogsessionCreationFlowPageMessage =>
      'You are already participating in a game';

  @override
  String get sessionCreationZoneFirstQuestion =>
      'Shall we set up the game area selection first?';

  @override
  String get sessionCreationStepParticipantsTitle =>
      'Set up the number of players';

  @override
  String get sessionCreationStepBasicTitle => 'Set up basic information';

  @override
  String get sessionCreationStepReviewTitle => 'Verify final settings';

  @override
  String get sessionCreationStepZoneIntro =>
      'Set up the required game area for the game';

  @override
  String get sessionCreationStepParticipantsHint =>
      'A minimum of 2 players is required to play the game';

  @override
  String get sessionCreationStepBasicHint =>
      'This information is essential for running the game';

  @override
  String get sessionCreationStepReviewHint =>
      'Shall we check the settings one last time before creating the room?';

  @override
  String get buttonNext => 'Next';

  @override
  String get errorZoneNotConfigured =>
      'Please set up game area information first';

  @override
  String get setupPlaygroundRadiusInputHint =>
      'Tap here to enter the radius directly';

  @override
  String get setupPlaygroundDescription =>
      'Set up the size of the total game area where the game will take place';

  @override
  String get buttonDone => 'Confirm';

  @override
  String get setupPrisonDescription =>
      'Set up the location and size of the jail to hold the Robbers';

  @override
  String get errorPlaygroundFirst => 'Please set up the playground first';

  @override
  String get errorJailOutsidePlayground =>
      'The jail is out of the playground range';

  @override
  String get dialogwaitingRoomPageConfirm => 'Go to settings';

  @override
  String get dialogwaitingRoomPageCancel => 'Leave';

  @override
  String get dummyNicknameBear => 'Cozy bear...';

  @override
  String get dialogwaitingRoomPageTitle => 'Unable to join the room';

  @override
  String get errorNotInGame =>
      'This user is not a participant in the corresponding game';

  @override
  String get waitingRoomTutorialTeamSwitch =>
      'Tap this button to move to another team';

  @override
  String get waitingRoomTutorialInvite =>
      'You can share the invite code with friends';

  @override
  String get waitingRoomTutorialSettings => 'You can view the game settings';

  @override
  String get waitingRoomTutorialReady => 'Please tap when you are ready';

  @override
  String get dialogInGamePreviewTitle => 'In-game screen preview';

  @override
  String get dialogwaitingRoomPageMessage =>
      'Shall we check how it works\nonce the game starts before we begin?';

  @override
  String get buttonViewInGamePreview => 'Let\'s view';

  @override
  String dialogKickConfirmTitle(String nickname) {
    return 'Remove $nickname?';
  }

  @override
  String get dialogKickConfirmMessage =>
      'Removed users will be kicked out of the room immediately\nThey must enter the invite code to rejoin the room';

  @override
  String get buttonKick => 'Remove';

  @override
  String get errorKickFailed =>
      'An error occurred while processing the removal';

  @override
  String get dialogKickedFromRoomTitle => 'You have been removed from the room';

  @override
  String get dialogKickedFromRoomMessage =>
      'You must enter the invite code to rejoin';

  @override
  String messageMemberKicked(String kickedNickname) {
    return '$kickedNickname has been removed';
  }

  @override
  String get errorTeamChangeFailed => 'Failed to change the team';

  @override
  String get errorReadyChangeFailed => 'Failed to change the readiness status';

  @override
  String get errorGameStartFailed => 'Failed to start the game';

  @override
  String get dialogLeaveRoomTitle => 'Would you like to leave the room?';

  @override
  String get dialogLeaveRoomMessage =>
      'You will need to enter the invite code again to rejoin';

  @override
  String get buttonLeave => 'Leave';

  @override
  String get errorLeaveRoomFailed =>
      'An error occurred while processing your exit';

  @override
  String get dialogInviteCodeCreatedTitle => 'Created an invite code';

  @override
  String get dialogInviteCodeShareMessage =>
      'Share the code with your friends and join the game!';

  @override
  String get messageCodeCopied => 'The code has been copied';

  @override
  String get buttonShare => 'Share';

  @override
  String get buttonStartGame => 'Game start';

  @override
  String get buttonReadyDone => 'Ready';

  @override
  String get buttonReady => 'Ready';

  @override
  String get pageZonePreviewTitle => 'Game area';

  @override
  String get zonePreviewSubtitle =>
      'This is the currently configured game area';

  @override
  String get dummyNicknameRaccoon => 'Plump raccoon';

  @override
  String get defaultNicknameLabel => 'Nickname';

  @override
  String get dialoggameRulesContentTitle => 'Game rules';

  @override
  String get dialoggameRulesContentCancel => 'Confirm';

  @override
  String get dialoggameRulesContentConfirm => 'View in-game';

  @override
  String get gameRulesCopGoalPrefix =>
      'The Cops win by catching all Robbers and';

  @override
  String get gameRulesCopGoalSuffix => 'arresting them,';

  @override
  String get gameRulesRobberGoalPrefix => '\nand the Robbers win by';

  @override
  String get gameRulesRobberGoalCondition =>
      'holding out until the time limit ends';

  @override
  String get gameRulesWinSuffix => '';

  @override
  String get gameRulesLocationShareLine1 => 'The Robbers\' locations are';

  @override
  String gameRulesLocationShareLine2(int minutes) {
    return 'shared with the Cops team every $minutes min';
  }

  @override
  String get gameRulesLocationShareLine3 => '';

  @override
  String get gameRulesZoneRuleLine1 =>
      'You must not leave the designated game area';

  @override
  String get gameRulesZoneRuleLine2 => '\n→ Screen locks if you leave the zone';

  @override
  String get dialogsessionCodeCardMessage => 'The code has been copied';

  @override
  String get dialogstep0SelectAreaContentTitle => 'Playground';

  @override
  String get dialogstep0SelectAreaContentTitle5bc0 => 'Jail';

  @override
  String get fieldstep1ParticipantSettingsContentLabel => 'Max players';

  @override
  String get unitPerson => 'people';

  @override
  String get fieldstep2GameSettingsContentLabel => 'Round time limit';

  @override
  String get unitMinutes => 'min';

  @override
  String get fieldstep2GameSettingsContentLabel5ab2 =>
      'Robber location reveal interval';

  @override
  String get gameSettingNoLocationShareWarning =>
      'The Robbers\' locations will not be shared!';

  @override
  String get fieldstep2GameSettingsContentLabelCe3b => 'Cop dispatch delay';

  @override
  String get gameSettingPoliceStartPrefix => 'After Robbers run away,';

  @override
  String get gameSettingPoliceStartSuffix => 'later';

  @override
  String get dialogsettingListCardTitle => 'Settings';

  @override
  String get fieldsettingListCardLabel => 'Player count';

  @override
  String get fieldRoundTimeLimit => 'Round time limit';

  @override
  String get fieldLocationShareInterval => 'Location reveal interval';

  @override
  String get fieldPoliceDispatchTime => 'Cop dispatch delay';

  @override
  String teamSectionCurrentCount(int count) {
    return 'Currently $count people';
  }

  @override
  String get dialogzoneListCardTitle => 'Game area';

  @override
  String get dialogauthRepositoryImplMessage =>
      'An error occurred during sign in';

  @override
  String get errorLogoutGeneric => 'An error occurred during sign out';

  @override
  String get errorAuthUserNotFound =>
      'Unable to retrieve sign in information. Please try again';

  @override
  String get errorAuthTokenIssueFailed =>
      'Failed to issue the authentication token. Please try again';

  @override
  String get errorAuthTokenValidationFailed =>
      'Failed to verify the Firebase authentication token. Please sign in again';

  @override
  String get errorAuthInvalidCredential => 'Invalid credentials';

  @override
  String get errorAuthAccountDisabled => 'Account has been disabled';

  @override
  String get errorAuthTooManyRequests =>
      'Too many requests. Please try again in a moment';

  @override
  String get errorAuthSignInMethodUnavailable =>
      'This sign in method is currently unavailable';

  @override
  String get errorAuthFirebaseConfig =>
      'There is an issue with the Firebase configuration. Please try again in a moment';

  @override
  String get errorAuthFirebaseInternal =>
      'A Firebase internal error occurred. Please try again in a moment';

  @override
  String errorAuthProviderLoginFailed(String provider) {
    return 'Failed to sign in with $provider. Please try again';
  }

  @override
  String get errorAuthLoginFailed => 'Sign in failed. Please try again';

  @override
  String get dialogagreementPageTitle => 'Terms of service';

  @override
  String get linkMarketingConsent => 'Receive marketing information';

  @override
  String get agreementPageAgreeButton => 'Agree and get started';

  @override
  String get agreementPageTitle =>
      'Please agree to the terms\nto use the service';

  @override
  String get agreementPageRequiredNotice =>
      'You must agree to all required terms to use the service';

  @override
  String get dialogagreementPageMessage => 'Not connected to the network yet';

  @override
  String get errorRequiredAgreementsMissing =>
      'Please agree to all required terms';

  @override
  String get dialogloginPageTitle => 'Privacy policy';

  @override
  String get dialogloginPageMessage => 'Account deletion is complete';

  @override
  String get dialogAge14ConfirmTitle => 'Are you 14 years of age or older?';

  @override
  String get dialogAge14ConfirmMessage =>
      'Cops and Robbers does not allow signups for users under 14\nThis information is used solely to verify eligibility';

  @override
  String get dialogloginPageConfirm => 'Yes';

  @override
  String get dialogloginPageCancel => 'No';

  @override
  String get errorLoginGeneric => 'An error occurred during sign in';

  @override
  String get errorAppleLoginFailed => 'An error occurred during Apple sign in';

  @override
  String get errorAgeRestrictionUnder14 =>
      'Users under 14 cannot use the service';

  @override
  String get loginPageAgreementPrefix => 'By signing in, you agree to the';

  @override
  String get linkPrivacyPolicy => 'Privacy policy';

  @override
  String get linkTermsOfService => 'Terms of service';

  @override
  String get linkLocationTerms => 'Location terms of service';

  @override
  String get loginPageAgreementSuffix => '';

  @override
  String get dialognicknameSetupPageMessage => 'Nickname has been saved';

  @override
  String get nicknameSetupTitle => 'Set up your nickname';

  @override
  String get nicknameSetupSubtitle =>
      'This nickname will be used throughout the service\nIt can be 1 to 10 characters long';

  @override
  String get fieldNicknameHint => 'Enter nickname';

  @override
  String get buttonCheckNicknameDuplicate => 'Check duplication';

  @override
  String get errorNicknameTooShort =>
      'Nicknames shorter than 1 character cannot be used';

  @override
  String get errorNicknameDuplicated =>
      'This nickname is already taken. Please enter a different nickname';

  @override
  String get nicknameAvailable => 'This nickname is available';

  @override
  String get splashReturningToScene => 'Returning to the field';

  @override
  String get dialogsplashPageMessage => 'Not connected to the network yet';

  @override
  String get dialogsplashPageTitle => 'Network connection failed';

  @override
  String get dialogSplashOfflineMessage =>
      'Please check your internet connection\nand try again';

  @override
  String get dialogsplashPageConfirm => 'Retry';

  @override
  String get splashPleaseWait => 'Please wait a moment';

  @override
  String get splashCreditTag => 'by Innocare';

  @override
  String get splashOfflineTitle => 'Internet connection is required';

  @override
  String get splashOfflineMessage =>
      'Please check the connection status\nand try again';

  @override
  String get dialogagreementProviderMessage =>
      'A temporary error occurred. Please try again';

  @override
  String get dialogauthProviderMessage => 'An unknown error occurred';

  @override
  String get errorLogoutFailed => 'Failed to sign out';

  @override
  String get agreementAllCheckboxLabel => 'Agree to all';

  @override
  String get agreementItemRequiredTag => '[Required]';

  @override
  String get agreementItemOptionalTag => '[Optional]';

  @override
  String get dialoggamePageConfirm => 'Go to settings';

  @override
  String get gameRobberOnTheRunBanner => 'Robbers are running away!';

  @override
  String get gameOverBannerTitle => 'Game over!';

  @override
  String get gameOverReasonAllArrested => 'All Robbers have been arrested!';

  @override
  String get gameOverReasonTimeUp => 'The time limit has expired!';

  @override
  String get gameTeamCop => 'Cop team';

  @override
  String get gameTeamRobber => 'Robber team';

  @override
  String get gameResultWin => 'Win';

  @override
  String get gameResultLose => 'Lose';

  @override
  String dialoggamePageMessage(String winnerTeamLabel) {
    return '$winnerTeamLabel wins!';
  }

  @override
  String get dialoggamePageCancel => 'Go to home';

  @override
  String get gameRoleCopLabel => 'Cop';

  @override
  String get gameRoleRobberLabel => 'Robber';

  @override
  String get errorCannotArrestDuringWait =>
      'Cannot arrest Robbers during the Cops waiting time';

  @override
  String get dialoggamePageTitle => 'Scan the Robber\'s wanted QR code';

  @override
  String get errorExpiredQr =>
      'This QR code has expired. Please request a QR refresh';

  @override
  String get errorAlreadyArrested => 'This Robber has already been arrested';

  @override
  String get gameArrestOverlayTitle => 'You have been arrested!';

  @override
  String get gameArrestOverlayMessage =>
      'You cannot check the game status while arrested\nRequest rescue from your teammates and jailbreak quickly!';

  @override
  String get gameArrestOverlayEscapeCompleteButton => 'Jailbreak complete';

  @override
  String get dialogarrestLockOverlayTitle => 'Jailbreak';

  @override
  String get dialogarrestLockOverlayMessage => 'Would you like to jailbreak?';

  @override
  String get buttonEscape => 'Jailbreak';

  @override
  String get buttonNo => 'No';

  @override
  String get fieldgameOverResultDialogLabel => 'Arrest count';

  @override
  String gameResultArrestCount(int count) {
    return '$count times';
  }

  @override
  String get fieldRemainingRobbers => 'Remaining Robbers';

  @override
  String gameResultRemainingRobberCount(int count) {
    return '$count people';
  }

  @override
  String get fieldGamePlaytime => 'Game playtime';

  @override
  String get buttonGoHome => 'Go to home';

  @override
  String get buttonPlayAgain => 'One more time';

  @override
  String gameLocationRevealCountdown(String formatted) {
    return 'Until next Robber location reveal: $formatted';
  }

  @override
  String get dialogparticipantOverlayMessage =>
      'Cannot arrest Robbers during the Cops waiting time';

  @override
  String get dialogparticipantOverlayTitle => 'Have you arrested this player?';

  @override
  String get buttonYes => 'Yes';

  @override
  String get dialogEscapeAttemptMessage =>
      'Would you like to attempt a jailbreak?';

  @override
  String get gameParticipantOverlayCurrent => 'Currently';

  @override
  String gameParticipantOverlayCount(int count) {
    return '$count people';
  }

  @override
  String get gameRobberStatusEscaping => 'running away!';

  @override
  String gamePoliceStartCountdown(String formatted) {
    return 'Until Cops start: $formatted';
  }

  @override
  String get gameQrDisplayTitle => 'Wanted QR code';

  @override
  String get gameQrDisplayMessage => 'Please show the QR code to the Cops';

  @override
  String get buttonClose => 'Close';

  @override
  String get dialogqrScannerPageTitle => 'Camera permission required';

  @override
  String get dialogqrScannerPageMessage =>
      'Camera permission is required to scan QR codes\nPlease allow camera permission in settings';

  @override
  String get dialogqrScannerPageConfirm => 'Go to settings';

  @override
  String get dialogqrScannerPageCancel => 'Close';

  @override
  String get errorCameraUnavailable => 'Camera is unavailable';

  @override
  String get gameZoneExitBanner => 'Left the playground';

  @override
  String get dialogchatProviderMessage => '[Team]';

  @override
  String get chatSystemGameTimeLimit30Min => 'The time limit is 30 minutes';

  @override
  String get chatSystemGoodLuckRobber => 'Good luck running away, Robbers~';

  @override
  String get chatSystemLetsWin => 'Let\'s win this!';

  @override
  String get dialogchatContextMenuMessage => 'Message has been copied';

  @override
  String get messageUserBlocked => 'This user has been blocked';

  @override
  String get dialogchatContextMenuTitle => 'Report';

  @override
  String get fieldchatContextMenuLabel => 'Report details';

  @override
  String get fieldchatContextMenuHint =>
      'Please write the reason for the report in detail\n(include the situation or conversation details)';

  @override
  String get buttonReport => 'Report';

  @override
  String get messageReportSubmitted => 'Report has been received';

  @override
  String get errorReportFailed => 'Failed to submit the report';

  @override
  String get dialogReportConfirmTitle => 'Would you like to report this user?';

  @override
  String get dialogchatContextMenuCancel => 'Cancel';

  @override
  String get dialogchatContextMenuConfirm => 'Report';

  @override
  String get chatReportSelectedCategoryLabel => 'Selected reason for report:';

  @override
  String get chatReportSubmitNotice =>
      '\nThe reported content will be reviewed and acted upon';

  @override
  String get buttonCopy => 'Copy';

  @override
  String get buttonBlock => 'Block';

  @override
  String get chatReportCategoryTitle => 'Select report type';

  @override
  String chatInputBarUnreadAll(String all) {
    return 'Total $all';
  }

  @override
  String chatInputBarUnreadTeam(String team) {
    return 'Team $team';
  }

  @override
  String chatInputBarUnreadHint(String body) {
    return 'Unread [$body]';
  }

  @override
  String get chatInputBarConnecting => 'Connecting...';

  @override
  String get chatInputBarHint => 'Enter chat message';

  @override
  String get chatMessageListEmpty => 'Start chatting';

  @override
  String get fieldchatMessageListLabel => 'Go to the latest message';

  @override
  String get chatWeekdayMon => 'Mon';

  @override
  String get chatWeekdayTue => 'Tue';

  @override
  String get chatWeekdayWed => 'Wed';

  @override
  String get chatWeekdayThu => 'Thu';

  @override
  String get chatWeekdayFri => 'Fri';

  @override
  String get chatWeekdaySat => 'Sat';

  @override
  String get chatWeekdaySun => 'Sun';

  @override
  String chatDateSeparator(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year-$month-$day $weekday';
  }

  @override
  String get chatScopeAllTitle => 'Global chat';

  @override
  String get chatScopeTeamTitle => 'Team chat';

  @override
  String get chatPreviewTagNotice => 'Notice';

  @override
  String get chatPreviewTagTeam => 'Team';

  @override
  String get chatPreviewTagAll => 'All';

  @override
  String get dialogagreementSettingsPageMessage =>
      'Not connected to the network yet';

  @override
  String get messageChangesSaved => 'Changes have been saved';

  @override
  String get errorTemporaryRetry =>
      'A temporary error occurred. Please try again';

  @override
  String get pageAgreementSettingsTitle => 'Terms and policies';

  @override
  String get errorAgreementLoadFailed => 'Unable to load agreement status';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get dialogagreementSettingsPageTitle => 'Terms of service';

  @override
  String get buttonSaveChanges => 'Save changes';

  @override
  String get errorLegalDocumentLoadFailed => 'Unable to load document';

  @override
  String get pageSettingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsAccountChangeNickname => 'Change nickname';

  @override
  String get settingsSectionAppPreferences => 'App settings';

  @override
  String get settingsAppGameNotification => 'Game notifications';

  @override
  String get settingsAppGameNotificationDescription =>
      'Configure notifications for events occurring during the game';

  @override
  String get settingsAppGeneralNotification => 'Notification';

  @override
  String get settingsAppGeneralNotificationHighlight => 'In-game notifications';

  @override
  String get settingsAppGeneralNotificationDetail =>
      'Configure all notifications sent by the app including';

  @override
  String get settingsAppLocationPermission => 'Manage location permissions';

  @override
  String get settingsAppLocationPermissionDescription =>
      'You can change location permissions in device settings';

  @override
  String get settingsSectionGuide => 'Guide';

  @override
  String get settingsGuideBugReport => 'Bug report';

  @override
  String get settingsGuideTutorialRewatch => 'Replay tutorial';

  @override
  String get settingsGuideTutorialReset => 'Reset tutorial';

  @override
  String get settingsGuideAgreements => 'Terms and policies';

  @override
  String get settingsSectionEtc => 'Others';

  @override
  String get settingsEtcDeleteAccount => 'Delete account';

  @override
  String get settingsAppVersionLabel => 'App version';

  @override
  String get dialogsettingsPageMessage =>
      'Failed to change game notification settings';

  @override
  String get dialogsettingsPageTitle => 'Bug report';

  @override
  String get fieldsettingsPageLabel => 'Bug details';

  @override
  String get fieldsettingsPageHint =>
      'What kind of problem occurred?\nPlease write down the details of the situation (including time and device info)';

  @override
  String get buttonSubmitReport => 'Report';

  @override
  String get messageBugReportSubmitted => 'Bug report has been received';

  @override
  String get dialogTutorialResetTitle => 'Reset tutorial';

  @override
  String get dialogTutorialResetMessage =>
      'Would you like to reset the tutorials\nso you can see them on all screens again?';

  @override
  String get dialogsettingsPageConfirm => 'Reset';

  @override
  String get messageTutorialReset => 'Tutorial has been reset';

  @override
  String get dialogLogoutTitle => 'Sign out';

  @override
  String get dialogLogoutMessage => 'Are you sure you want to sign out?';

  @override
  String get snackbarLogoutFailed => 'Failed to sign out';

  @override
  String get snackbarLogoutSuccess => 'Signed out successfully';

  @override
  String get dialogDeleteAccountTitle => 'Delete account';

  @override
  String get dialogDeleteAccountMessage =>
      'Deleting your account will erase all data\nand cannot be undone\n\nTo continue, enter \"delete\"';

  @override
  String get fieldDeleteAccountHint => 'delete';

  @override
  String get dialogsettingsPageCancel => 'Cancel';

  @override
  String get buttonDeleteAccount => 'Delete';

  @override
  String get tutorialDummyNicknameCop1 => 'Cop1';

  @override
  String get tutorialDummyNicknameRobberKing => 'RobberKing';

  @override
  String get tutorialDummyNicknameRobberOrNot => 'RobberOrNot';

  @override
  String get tutorialDummyNicknameCapturedRobber => 'CapturedRobber';

  @override
  String get dialoginGameTutorialPageTitle => 'Tutorial complete!';

  @override
  String get dialoginGameTutorialPageMessage =>
      'You have learned the core gameplay\nTry using it in a real game';

  @override
  String get dialoginGameTutorialPageConfirm => 'Finish tutorial';

  @override
  String get tutorialInGameMyLocation => 'Camera has moved to my location';

  @override
  String get tutorialMapPreviewLabel => 'Map preview';

  @override
  String get tutorialLocationRevealCountdown =>
      'Until next Robber location reveal: 04:30';

  @override
  String get tutorialInGameRulesGuide => 'Game rules guide opens';

  @override
  String get tutorialQrRobberHint =>
      'My wanted QR code is displayed on the screen. Show it to the Cops to get arrested';

  @override
  String get tutorialQrCopHint =>
      'Camera turns on and you can scan a Robber\'s QR to arrest them';

  @override
  String get tutorialMissionParticipantsButton =>
      'Try pressing the view participants button';

  @override
  String get tutorialMissionQrButton => 'Try pressing the QR button';

  @override
  String get tutorialMissionMapButton => 'Try returning to the map';

  @override
  String tutorialMissionProgress(String step) {
    return 'Mission $step/3';
  }

  @override
  String get tutorialPerspectiveRobber => 'Viewing from Robber\'s perspective';

  @override
  String get tutorialPerspectiveCop => 'Viewing from Cops\' perspective';

  @override
  String get tutorialInGameSelfEscape =>
      'If you are jailed, you can attempt a jailbreak by tapping the card';

  @override
  String get tutorialInGameQrArrest =>
      'In the actual game, you arrest Robbers by scanning their QR code';

  @override
  String get tutorialCurrentLabel => 'Currently';

  @override
  String tutorialPlayerCount(int count) {
    return '$count people';
  }

  @override
  String get tutorialOnTheRun => 'running away!';

  @override
  String get tutorialInGameChatExpand =>
      'Drag the handle up to expand the chat';

  @override
  String get tutorialInGameChatInput =>
      'Enter a message here to send it to team/global chat';

  @override
  String get tutorialChatHint => 'Enter chat message';

  @override
  String get dialogtutorialCatalogPageTitle => 'Create room';

  @override
  String get tutorialCatalogAreaSubtitle =>
      'Playground/jail setup and slider controls';

  @override
  String get tutorialCatalogInviteSubtitle =>
      'Invite code entry and QR scanning';

  @override
  String get tutorialCatalogWaitingRoomTitle => 'Waiting room';

  @override
  String get tutorialCatalogLobbySubtitle =>
      'Team changes, game settings, and ready status';

  @override
  String get tutorialCatalogInGameTitle => 'In-game';

  @override
  String get tutorialCatalogGameSubtitle =>
      'Timer, map, participants, chat, and QR';

  @override
  String get pageTutorialCatalogTitle => 'Tutorial';

  @override
  String get tutorialCatalogIntro =>
      'If it\'s your first time playing, take a look before starting';

  @override
  String get tutorialCatalogComingSoon => 'In preparation';

  @override
  String get creditMemberHongEuiMin => 'Hong Eui-min';

  @override
  String get creditMemberParkChanBin => 'Park Chan-bin';

  @override
  String get creditMemberLeeChangHee => 'Lee Chang-hee';

  @override
  String get creditMemberJeongSangHee => 'Jeong Sang-hee';

  @override
  String get creditMemberHwangHyeRim => 'Hwang Hye-rim';

  @override
  String get creditMemberYoonJiHee => 'Yoon Ji-hee';

  @override
  String get creditMemberKimDaim => 'Kim Da-im';

  @override
  String get creditMemberShinJiHoon => 'Shin Ji-hoon';

  @override
  String get creditMemberNamHaeYoon => 'Nam Hae-yoon';

  @override
  String get creditMemberSongHyeJung => 'Song Hye-jung';

  @override
  String get creditMemberLeeJin => 'Lee Jin';

  @override
  String get creditMemberAhnGeumSeo => 'Ahn Geum-seo';

  @override
  String get creditMemberSonGeonWoo => 'Son Geon-woo';

  @override
  String get creditMemberShinHyeBin => 'Shin Hye-bin';

  @override
  String get creditMemberJeongChangWoo => 'Jeong Chang-woo';

  @override
  String get creditMemberHeoSeokJun => 'Heo Seok-jun';

  @override
  String get creditMemberSeoHyunJin => 'Seo Hyun-jin';

  @override
  String get creditMemberOhDongHyun => 'Oh Dong-hyun';

  @override
  String get creditMemberChoiSeungHoon => 'Choi Seung-hoon';

  @override
  String get creditMemberKimMinWook => 'Kim Min-wook';

  @override
  String get creditMemberJeongMyeongJun => 'Jeong Myeong-jun';

  @override
  String get creditMemberKangDaeHyun => 'Kang Dae-hyun';

  @override
  String get creditMemberSimHyuk => 'Sim Hyuk';

  @override
  String get pageCreditsTitle => 'Creators of Cops and Robbers';

  @override
  String get dialogreportRepositoryImplMessage =>
      'An error occurred while processing the report';

  @override
  String get reportCategoryBait => 'Trolling/Spamming';

  @override
  String get reportCategoryAbuse => 'Profanity/Insults';

  @override
  String get reportCategoryImpersonation => 'Impersonation/Scam';

  @override
  String get reportCategorySpam => 'Advertising/Spam';

  @override
  String get reportCategoryExploit => 'Cheating/Exploiting bugs';

  @override
  String get reportCategoryTeamSabotage => 'Sabotage/Griefing';

  @override
  String get reportCategoryOther => 'Others (Write directly)';

  @override
  String get dialoguserRepositoryImplMessage =>
      'An unexpected error occurred while checking nickname';

  @override
  String get errorNicknameUpdateUnexpected =>
      'An unexpected error occurred while changing nickname';

  @override
  String get errorUserInfoFetch =>
      'An error occurred while retrieving user profile';

  @override
  String get errorDeleteAccountUnexpected =>
      'An unexpected error occurred while deleting account';

  @override
  String get errorAgreementFetchUnexpected =>
      'An unexpected error occurred while retrieving agreement status';

  @override
  String get errorAgreementSaveUnexpected =>
      'An unexpected error occurred while saving terms agreement';

  @override
  String get errorGamePushFetchUnexpected =>
      'An unexpected error occurred while retrieving push notification consent';

  @override
  String get errorGamePushUpdateUnexpected =>
      'An unexpected error occurred while updating push notification consent';

  @override
  String get errorAuthTokenMissing =>
      'Unable to retrieve the authentication token. Re-login is required';

  @override
  String get errorServerUnreachable =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get errorAuthExpired =>
      'Authentication has expired. Re-login is required';

  @override
  String get dialognoticeRepositoryImplMessage =>
      'An error occurred while loading notices';

  @override
  String get dialognoticesPageMessage => 'Loading notices...';

  @override
  String get errorNoticeLoadFailed => 'Failed to load notices';

  @override
  String get pageNoticesTitle => 'Notices';

  @override
  String get pageNoticesEmpty => 'There are no notices registered';

  @override
  String get errorAreaLoadFailed => 'Unable to load game area information';

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage => 'The requested page does not exist';

  @override
  String pageNotFoundPath(String path) {
    return 'Path: $path';
  }

  @override
  String get buttonLogout => 'Sign out';

  @override
  String get dialogbugRepositoryImplMessage =>
      'An error occurred while processing the bug report';

  @override
  String get dialogmainTitle => 'Cops and Robbers';

  @override
  String gameEventStartTime(int minutes) {
    return 'The time limit is $minutes minutes.';
  }

  @override
  String get gameEventStartReady =>
      'The game starts soon.  All players, get ready!';

  @override
  String get gameEventStartReportTip =>
      'Long-press a chat message during the game to report or block players.';

  @override
  String get gameEventStartGo => 'Game start!  Good luck!';

  @override
  String get gameEventPoliceMove => 'Cops are on the move!  Robbers, run!';

  @override
  String get gameEventLocationReveal => 'Robbers\' locations are now revealed!';

  @override
  String gameEventArrestNotice(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname] arrested @icon_robber [$robberNickname]!';
  }

  @override
  String get gameEventEscapeNotice =>
      'A robber has escaped from jail! Arrest them now!';

  @override
  String mapErrorLoadFailed(String mapName) {
    return 'Failed to load $mapName';
  }
}
