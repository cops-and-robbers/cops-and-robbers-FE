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
  String get dialogsessionRepositoryImplMessageAddf =>
      'An unexpected error occurred while looking up the game in progress';

  @override
  String session_sessionSettings_L22(String maxPlayers) {
    return '$maxPlayers display';
  }

  @override
  String session_sessionSettings_L27(int roundTimeMinutes) {
    return '$roundTimeMinutes min';
  }

  @override
  String session_sessionSettings_L32(int locationShareMinutes) {
    return '$locationShareMinutes min';
  }

  @override
  String session_sessionSettings_L37(int policeStartDelayMinutes) {
    return '$policeStartDelayMinutes min after Robbers run away';
  }

  @override
  String session_zoneInfo_L25(String km) {
    return 'Radius ${km}km';
  }

  @override
  String session_zoneInfo_L27(String radiusMeters) {
    return 'Radius ${radiusMeters}m';
  }

  @override
  String get session_gameSettingsEditPage_L110 => 'Failed to save settings';

  @override
  String get session_gameSettingsEditPage_L146 => 'Edit settings';

  @override
  String get session_gameSettingsEditPage_L197 => 'Saving...';

  @override
  String get session_gameSettingsEditPage_L197_1 => 'Save';

  @override
  String get session_gameSettingsPage_L140 => 'Failed to save game area';

  @override
  String get session_gameSettingsPage_L190 => 'Game settings';

  @override
  String get session_gameSettingsPage_L210 =>
      'Unable to load game area information';

  @override
  String get session_gameSettingsPage_L228 =>
      'Unable to load settings information';

  @override
  String get session_gameSettingsPage_L270 => 'Playground';

  @override
  String get session_gameSettingsPage_L275 => 'Jail';

  @override
  String get session_homePage_L108 => 'You can create a new game';

  @override
  String get session_homePage_L113 => 'Enter the invite code to join the game';

  @override
  String get dialoghomePageTitle =>
      'Please watch your surroundings while using the app';

  @override
  String get dialoghomePageMessage =>
      'Focusing only on the screen during the game can be dangerous\nPlease check the road and walking environment to stay safe';

  @override
  String get dialoghomePageConfirm => 'I understand!';

  @override
  String get session_homePage_L158 => 'Do not show again today';

  @override
  String get dialoghomePageMessage50b3 =>
      'You are already participating in a game';

  @override
  String get dialoghomePageMessage89ff => 'Unknown game status';

  @override
  String get dialoghomePageConfirm5435 => 'Go to settings';

  @override
  String get dialoghomePageCancel => 'Cancel';

  @override
  String get dialoghomePageTitleEeea => 'For uninterrupted gameplay';

  @override
  String get session_homePage_L332 =>
      'Please change app settings → battery → unrestricted\n';

  @override
  String get session_homePage_L333 =>
      'This prevents the game from disconnecting even when the screen is turned off';

  @override
  String get session_homePage_L432 =>
      'Failed to join. Please check the invite code';

  @override
  String get dialoghomePageMessage8155 => 'Failed to join. Please try again';

  @override
  String get dialoghomePageTitle879f => 'Join waiting room';

  @override
  String get fieldhomePageHint => 'Enter invite code';

  @override
  String get dialoghomePageTitle86c1 => 'Scan the invite code QR';

  @override
  String get dialoghomePageCancel218e => 'Close';

  @override
  String get dialoghomePageConfirm665b => 'Join';

  @override
  String get session_homePage_L601 => 'Cops and Robbers';

  @override
  String get dialoghomePageMessage9e36 => 'In preparation';

  @override
  String get session_homePage_L661 =>
      'I am so excited\nWhat role will I play this time?';

  @override
  String get session_homePage_L677 => 'Create room';

  @override
  String get session_homePage_L684 => 'Join room';

  @override
  String get session_sessionCreationFlowPage_L160 =>
      'Set up the game area\nPlease designate the playground first';

  @override
  String get session_sessionCreationFlowPage_L167 =>
      'Set up the game rules\nTap the number to enter it directly';

  @override
  String get session_sessionCreationFlowPage_L374 =>
      'Failed to create game room. Please try again';

  @override
  String get dialogsessionCreationFlowPageMessage =>
      'You are already participating in a game';

  @override
  String get dialogsessionCreationFlowPageMessage89ff => 'Unknown game status';

  @override
  String get session_sessionCreationFlowPage_L483 =>
      'Shall we set up the game area selection first?';

  @override
  String get session_sessionCreationFlowPage_L484 =>
      'Set up the number of players';

  @override
  String get session_sessionCreationFlowPage_L485 => 'Set up basic information';

  @override
  String get session_sessionCreationFlowPage_L486 => 'Verify final settings';

  @override
  String get session_sessionCreationFlowPage_L491 =>
      'Set up the required game area for the game';

  @override
  String get session_sessionCreationFlowPage_L492 =>
      'A minimum of 2 players is required to play the game';

  @override
  String get session_sessionCreationFlowPage_L493 =>
      'This information is essential for running the game';

  @override
  String get session_sessionCreationFlowPage_L494 =>
      'Shall we check the settings one last time before creating the room?';

  @override
  String get session_sessionCreationFlowPage_L503 => 'Next';

  @override
  String get session_sessionCreationFlowPage_L505 => 'Create room';

  @override
  String get session_sessionCreationFlowPage_L507 => 'Next';

  @override
  String get session_sessionCreationFlowPage_L660 => 'Playground';

  @override
  String get session_sessionCreationFlowPage_L665 => 'Jail';

  @override
  String get session_sessionCreationFlowPage_L676 =>
      'Please set up game area information first';

  @override
  String get session_setupPlaygroundPage_L135 =>
      'Tap here to enter the radius directly';

  @override
  String get session_setupPlaygroundPage_L195 => 'Playground';

  @override
  String get session_setupPlaygroundPage_L212 => 'Playground';

  @override
  String get session_setupPlaygroundPage_L233 =>
      'Set up the size of the total game area where the game will take place';

  @override
  String get session_setupPlaygroundPage_L267 => 'Confirm';

  @override
  String get session_setupPrisonPage_L210 => 'Jail';

  @override
  String get session_setupPrisonPage_L227 => 'Jail';

  @override
  String get session_setupPrisonPage_L248 =>
      'Set up the location and size of the jail to hold the Robbers';

  @override
  String get session_setupPrisonPage_L286 =>
      'Please set up the playground first';

  @override
  String get session_setupPrisonPage_L287 =>
      'The jail is out of the playground range';

  @override
  String get session_setupPrisonPage_L299 => 'Confirm';

  @override
  String get dialogwaitingRoomPageConfirm => 'Go to settings';

  @override
  String get dialogwaitingRoomPageCancel => 'Leave';

  @override
  String get session_waitingRoomPage_L364 => 'Cozy bear...';

  @override
  String get dialogwaitingRoomPageTitle => 'Unable to join the room';

  @override
  String get session_waitingRoomPage_L545 =>
      'This user is not a participant in the corresponding game';

  @override
  String get dialogwaitingRoomPageConfirm3ce8 => 'Confirm';

  @override
  String get session_waitingRoomPage_L631 =>
      'Tap this button to move to another team';

  @override
  String get session_waitingRoomPage_L637 =>
      'You can share the invite code with friends';

  @override
  String get session_waitingRoomPage_L642 => 'You can view the game settings';

  @override
  String get session_waitingRoomPage_L647 => 'Please tap when you are ready';

  @override
  String get dialogwaitingRoomPageTitle1946 => 'In-game screen preview';

  @override
  String get dialogwaitingRoomPageMessage =>
      'Shall we check how it works\nonce the game starts before we begin?';

  @override
  String get dialogwaitingRoomPageConfirmA2d8 => 'Let\'s view';

  @override
  String dialogwaitingRoomPageTitleBc54(String nickname) {
    return 'Remove $nickname?';
  }

  @override
  String get dialogwaitingRoomPageMessageB302 =>
      'Removed users will be kicked out of the room immediately\nThey must enter the invite code to rejoin the room';

  @override
  String get dialogwaitingRoomPageCancelD9de => 'Cancel';

  @override
  String get dialogwaitingRoomPageConfirmC08c => 'Remove';

  @override
  String get dialogwaitingRoomPageMessageE87b =>
      'An error occurred while processing the removal';

  @override
  String get dialogwaitingRoomPageTitle8208 =>
      'You have been removed from the room';

  @override
  String get dialogwaitingRoomPageMessage64a2 =>
      'You must enter the invite code to rejoin';

  @override
  String dialogwaitingRoomPageMessage36a5(String kickedNickname) {
    return '$kickedNickname has been removed';
  }

  @override
  String get session_waitingRoomPage_L1030 => 'Failed to change the team';

  @override
  String get session_waitingRoomPage_L1062 =>
      'Failed to change the readiness status';

  @override
  String get session_waitingRoomPage_L1099 => 'Failed to start the game';

  @override
  String get dialogwaitingRoomPageTitleFfec =>
      'Would you like to leave the room?';

  @override
  String get dialogwaitingRoomPageMessage3930 =>
      'You will need to enter the invite code again to rejoin';

  @override
  String get dialogwaitingRoomPageConfirmC0a3 => 'Leave';

  @override
  String get session_waitingRoomPage_L1130 =>
      'An error occurred while processing your exit';

  @override
  String get dialogwaitingRoomPageTitleA5bb => 'Created an invite code';

  @override
  String get dialogwaitingRoomPageMessage06a6 =>
      'Share the code with your friends and join the game!';

  @override
  String get dialogwaitingRoomPageMessage4785 => 'The code has been copied';

  @override
  String get dialogwaitingRoomPageCancel218e => 'Close';

  @override
  String get dialogwaitingRoomPageConfirm27f8 => 'Share';

  @override
  String get session_waitingRoomPage_L1511 => 'Game start';

  @override
  String get session_waitingRoomPage_L1526 => 'Ready';

  @override
  String get session_waitingRoomPage_L1537 => 'Ready';

  @override
  String get session_zonePreviewPage_L122 => 'Game area';

  @override
  String get session_zonePreviewPage_L145 =>
      'This is the currently configured game area';

  @override
  String get session_waitingRoomParticipantsProvider_L81 => 'Cozy bear...';

  @override
  String get session_waitingRoomParticipantsProvider_L87 => 'Plump raccoon';

  @override
  String get session_waitingRoomParticipantsProvider_L93 => 'Nickname';

  @override
  String get session_waitingRoomParticipantsProvider_L99 => 'Nickname';

  @override
  String get dialoggameRulesContentTitle => 'Game rules';

  @override
  String get dialoggameRulesContentCancel => 'Confirm';

  @override
  String get dialoggameRulesContentConfirm => 'View in-game';

  @override
  String get session_gameRulesContent_L95 =>
      'The Cops win by catching all Robbers and';

  @override
  String get session_gameRulesContent_L96 => 'arresting them,';

  @override
  String get session_gameRulesContent_L97 => '\nand the Robbers win by';

  @override
  String get session_gameRulesContent_L98 =>
      'holding out until the time limit ends';

  @override
  String get session_gameRulesContent_L99 => '';

  @override
  String get session_gameRulesContent_L108 => 'The Robbers\' locations are';

  @override
  String session_gameRulesContent_L109(int minutes) {
    return 'shared with the Cops team every $minutes min';
  }

  @override
  String get session_gameRulesContent_L110 => '';

  @override
  String get session_gameRulesContent_L118 =>
      'You must not leave the designated game area';

  @override
  String get session_gameRulesContent_L119 =>
      '\n→ Screen locks if you leave the zone';

  @override
  String get dialogsessionCodeCardMessage => 'The code has been copied';

  @override
  String get dialogstep0SelectAreaContentTitle => 'Playground';

  @override
  String get dialogstep0SelectAreaContentTitle5bc0 => 'Jail';

  @override
  String get fieldstep1ParticipantSettingsContentLabel => 'Max players';

  @override
  String get session_step1ParticipantSettingsContent_L52 => 'people';

  @override
  String get fieldstep2GameSettingsContentLabel => 'Round time limit';

  @override
  String get session_step2GameSettingsContent_L79 => 'min';

  @override
  String get fieldstep2GameSettingsContentLabel5ab2 =>
      'Robber location reveal interval';

  @override
  String get session_step2GameSettingsContent_L97 => 'min';

  @override
  String get session_step2GameSettingsContent_L104 =>
      'The Robbers\' locations will not be shared!';

  @override
  String get fieldstep2GameSettingsContentLabelCe3b => 'Cop dispatch delay';

  @override
  String get session_step2GameSettingsContent_L115 => 'min';

  @override
  String get session_step2GameSettingsContent_L117 => 'After Robbers run away,';

  @override
  String get session_step2GameSettingsContent_L118 => 'later';

  @override
  String get session_sessionStepLayout_L42 => 'Next';

  @override
  String get dialogsettingListCardTitle => 'Settings';

  @override
  String get fieldsettingListCardLabel => 'Player count';

  @override
  String get fieldsettingListCardLabelEc5e => 'Round time limit';

  @override
  String get fieldsettingListCardLabelA1b3 => 'Location reveal interval';

  @override
  String get fieldsettingListCardLabelCe3b => 'Cop dispatch delay';

  @override
  String get session_teamSection_L116 => 'Cop team';

  @override
  String get session_teamSection_L116_1 => 'Robber team';

  @override
  String session_teamSection_L178(int length) {
    return 'Currently $length people';
  }

  @override
  String get dialogzoneListCardTitle => 'Game area';

  @override
  String get dialogauthRepositoryImplMessage =>
      'An error occurred during sign in';

  @override
  String get dialogauthRepositoryImplMessage993d =>
      'An error occurred during sign out';

  @override
  String get auth_firebaseAuthErrorHandler_L31 =>
      'Unable to retrieve sign in information. Please try again';

  @override
  String get auth_firebaseAuthErrorHandler_L33 =>
      'Failed to issue the authentication token. Please try again';

  @override
  String get auth_firebaseAuthErrorHandler_L35 =>
      'Failed to verify the Firebase authentication token. Please sign in again';

  @override
  String get auth_firebaseAuthErrorHandler_L37 => 'Sign in was cancelled';

  @override
  String get auth_firebaseAuthErrorHandler_L39 =>
      'Please check your network connection';

  @override
  String get auth_firebaseAuthErrorHandler_L41 => 'Invalid credentials';

  @override
  String get auth_firebaseAuthErrorHandler_L43 => 'Account has been disabled';

  @override
  String get auth_firebaseAuthErrorHandler_L45 =>
      'Too many requests. Please try again in a moment';

  @override
  String get auth_firebaseAuthErrorHandler_L47 =>
      'This sign in method is currently unavailable';

  @override
  String get auth_firebaseAuthErrorHandler_L49 =>
      'There is an issue with the Firebase configuration. Please try again in a moment';

  @override
  String get auth_firebaseAuthErrorHandler_L51 =>
      'A Firebase internal error occurred. Please try again in a moment';

  @override
  String auth_firebaseAuthErrorHandler_L55(int provider) {
    return 'Failed to sign in with $provider. Please try again';
  }

  @override
  String get auth_firebaseAuthErrorHandler_L57 =>
      'Sign in failed. Please try again';

  @override
  String get dialogagreementPageTitle => 'Terms of service';

  @override
  String get dialogagreementPageTitleBe29 => 'Privacy policy';

  @override
  String get dialogagreementPageTitle6dcc => 'Location terms of service';

  @override
  String get dialogagreementPageTitle76b8 => 'Receive marketing information';

  @override
  String get auth_agreementPage_L107 => 'Agree and get started';

  @override
  String get auth_agreementPage_L127 =>
      'Please agree to the terms\nto use the service';

  @override
  String get auth_agreementPage_L135 =>
      'You must agree to all required terms to use the service';

  @override
  String get dialogagreementPageMessage => 'Not connected to the network yet';

  @override
  String get dialogagreementPageMessage24a8 =>
      'Please agree to all required terms';

  @override
  String get auth_agreementPage_L184 =>
      'A temporary error occurred. Please try again';

  @override
  String get dialogloginPageTitle => 'Privacy policy';

  @override
  String get dialogloginPageTitle2aa8 => 'Terms of service';

  @override
  String get dialogloginPageTitle6dcc => 'Location terms of service';

  @override
  String get dialogloginPageMessage => 'Account deletion is complete';

  @override
  String get dialogloginPageTitleA40f => 'Are you 14 years of age or older?';

  @override
  String get dialogloginPageMessageBa5d =>
      'Cops and Robbers does not allow signups for users under 14\nThis information is used solely to verify eligibility';

  @override
  String get dialogloginPageConfirm => 'Yes';

  @override
  String get dialogloginPageCancel => 'No';

  @override
  String get dialogloginPageMessageFe9d => 'Sign in was cancelled';

  @override
  String get auth_loginPage_L166 => 'An error occurred during sign in';

  @override
  String get auth_loginPage_L191 => 'An error occurred during Apple sign in';

  @override
  String get auth_loginPage_L260 => 'Users under 14 cannot use the service';

  @override
  String get auth_loginPage_L284 => 'By signing in, you agree to the';

  @override
  String get auth_loginPage_L286 => 'Privacy policy';

  @override
  String get auth_loginPage_L295 => 'Terms of service';

  @override
  String get auth_loginPage_L304 => 'Location terms of service';

  @override
  String get auth_loginPage_L311 => '';

  @override
  String get dialognicknameSetupPageMessage => 'Nickname has been saved';

  @override
  String get auth_nicknameSetupPage_L248 => 'Set up your nickname';

  @override
  String get auth_nicknameSetupPage_L257 =>
      'This nickname will be used throughout the service\nIt can be 1 to 10 characters long';

  @override
  String get auth_nicknameSetupPage_L281 => 'Confirm';

  @override
  String get auth_nicknameSetupPage_L308 => 'Enter nickname';

  @override
  String get auth_nicknameSetupPage_L336 => 'Check duplication';

  @override
  String get auth_nicknameSetupPage_L354 =>
      'Nicknames shorter than 1 character cannot be used';

  @override
  String get auth_nicknameSetupPage_L359 =>
      'This nickname is already taken. Please enter a different nickname';

  @override
  String get auth_nicknameSetupPage_L364 => 'This nickname is available';

  @override
  String get auth_nicknameSetupPage_L369 =>
      'An error occurred. Please try again';

  @override
  String get auth_splashPage_L48 => 'Returning to the field';

  @override
  String get auth_splashPage_L208 => 'Returning to the field';

  @override
  String get dialogsplashPageMessage => 'Not connected to the network yet';

  @override
  String get dialogsplashPageTitle => 'Network connection failed';

  @override
  String get dialogsplashPageMessage665f =>
      'Please check your internet connection\nand try again';

  @override
  String get dialogsplashPageConfirm => 'Retry';

  @override
  String get auth_splashPage_L395 => 'Please wait a moment';

  @override
  String get auth_splashPage_L412 => 'by Dongsim_Jikimi';

  @override
  String get auth_splashPage_L444 => 'Internet connection is required';

  @override
  String get auth_splashPage_L450 =>
      'Please check the connection status\nand try again';

  @override
  String get auth_splashPage_L461 => 'Retry';

  @override
  String get dialogagreementProviderMessage =>
      'A temporary error occurred. Please try again';

  @override
  String auth_authProvider_L129(String message) {
    return 'Reason: $message';
  }

  @override
  String get dialogauthProviderMessage => 'An unknown error occurred';

  @override
  String get dialogauthProviderMessage222f => 'Failed to sign out';

  @override
  String get auth_agreementAllCheckbox_L35 => 'Agree to all';

  @override
  String get auth_agreementItem_L39 => '[Required]';

  @override
  String get auth_agreementItem_L39_1 => '[Optional]';

  @override
  String get dialoggamePageConfirm => 'Go to settings';

  @override
  String get game_gamePage_L379 => 'Robbers are running away!';

  @override
  String get game_gamePage_L1026 => 'Game over!';

  @override
  String get game_gamePage_L1034 => 'All Robbers have been arrested!';

  @override
  String get game_gamePage_L1034_1 => 'The time limit has expired!';

  @override
  String get game_gamePage_L1086 => 'Cop team';

  @override
  String get game_gamePage_L1086_1 => 'Robber team';

  @override
  String get game_gamePage_L1090 => 'Win';

  @override
  String get game_gamePage_L1090_1 => 'Lose';

  @override
  String dialoggamePageMessage(String winnerTeamLabel) {
    return '$winnerTeamLabel wins!';
  }

  @override
  String get dialoggamePageCancel => 'Go to home';

  @override
  String get dialoggamePageConfirm5863 => 'One more time';

  @override
  String get game_gamePage_L1289 => 'Cop';

  @override
  String get game_gamePage_L1290 => 'Robber';

  @override
  String get dialoggamePageMessage5e97 =>
      'Cannot arrest Robbers during the Cops waiting time';

  @override
  String get dialoggamePageTitle => 'Scan the Robber\'s wanted QR code';

  @override
  String get dialoggamePageMessage6487 =>
      'This QR code has expired. Please request a QR refresh';

  @override
  String get dialoggamePageMessage4b5f =>
      'This Robber has already been arrested';

  @override
  String get game_gameEventProvider_L337 =>
      'Unable to retrieve the authentication token. Re-login is required';

  @override
  String get game_gameEventProvider_L452 => 'Failed to request arrest';

  @override
  String get game_gameEventProvider_L492 => 'Failed to request jailbreak';

  @override
  String get game_gameEventProvider_L520 =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get game_gameEventProvider_L702 => 'Cop';

  @override
  String get game_gameEventProvider_L703 => 'Robber';

  @override
  String get game_gameEventProvider_L866 =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get game_gameEventProvider_L937 =>
      'Authentication has expired. Re-login is required';

  @override
  String get game_gameEventProvider_L951 =>
      'Authentication has expired. Re-login is required';

  @override
  String get game_arrestLockOverlay_L71 => 'You have been arrested!';

  @override
  String get game_arrestLockOverlay_L78 =>
      'You cannot check the game status while arrested\nRequest rescue from your teammates and jailbreak quickly!';

  @override
  String get game_arrestLockOverlay_L89 => 'Jailbreak complete';

  @override
  String get dialogarrestLockOverlayTitle => 'Jailbreak';

  @override
  String get dialogarrestLockOverlayMessage => 'Would you like to jailbreak?';

  @override
  String get game_arrestLockOverlay_L102 => 'Jailbreak';

  @override
  String get game_gameActionModal_L63 => 'No';

  @override
  String get game_gameActionModal_L63_1 => 'Cancel';

  @override
  String get game_gameOverResultDialog_L324 => 'Win';

  @override
  String get game_gameOverResultDialog_L324_1 => 'Lose';

  @override
  String get fieldgameOverResultDialogLabel => 'Arrest count';

  @override
  String game_gameOverResultDialog_L345(int totalArrestCount) {
    return '$totalArrestCount times';
  }

  @override
  String get fieldgameOverResultDialogLabelD8df => 'Remaining Robbers';

  @override
  String game_gameOverResultDialog_L351(int remainingRobberCount) {
    return '$remainingRobberCount people';
  }

  @override
  String get fieldgameOverResultDialogLabelAb0c => 'Game playtime';

  @override
  String get game_gameOverResultDialog_L438 => 'Go to home';

  @override
  String get game_gameOverResultDialog_L452 => 'One more time';

  @override
  String game_locationRevealCountdown_L109(String _formatted) {
    return 'Until next Robber location reveal: $_formatted';
  }

  @override
  String get dialogparticipantOverlayMessage =>
      'Cannot arrest Robbers during the Cops waiting time';

  @override
  String get dialogparticipantOverlayTitle => 'Have you arrested this player?';

  @override
  String get game_participantOverlay_L139 => 'Yes';

  @override
  String get dialogparticipantOverlayTitle4167 => 'Jailbreak';

  @override
  String get dialogparticipantOverlayMessage9497 =>
      'Would you like to attempt a jailbreak?';

  @override
  String get game_participantOverlay_L166 => 'Jailbreak';

  @override
  String get game_participantOverlay_L297 => 'Currently';

  @override
  String game_participantOverlay_L299(int count) {
    return '$count people';
  }

  @override
  String get game_participantOverlay_L305 => 'running away!';

  @override
  String game_policeStartCountdown_L79(String _formatted) {
    return 'Until Cops start: $_formatted';
  }

  @override
  String get game_qrDisplayDialog_L62 => 'Wanted QR code';

  @override
  String get game_qrDisplayDialog_L86 => 'Please show the QR code to the Cops';

  @override
  String get game_qrDisplayDialog_L97 => 'Close';

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
  String get game_qrScannerPage_L90 => 'Camera is unavailable';

  @override
  String get game_zoneExitBanner_L66 => 'Left the playground';

  @override
  String get chat_chatProvider_L190 =>
      'Unable to retrieve the authentication token. Re-login is required';

  @override
  String get chat_chatProvider_L254 => 'Me';

  @override
  String get dialogchatProviderMessage => '[Team]';

  @override
  String get chat_chatProvider_L265 => 'Teammate nickname';

  @override
  String get chat_chatProvider_L265_1 => 'Opponent nickname';

  @override
  String get chat_chatProvider_L286 => 'System';

  @override
  String get dialogchatProviderMessageDfca => 'The time limit is 30 minutes';

  @override
  String get chat_chatProvider_L381 => 'System';

  @override
  String get dialogchatProviderMessage2119 =>
      'The game is about to start. All players, please get ready!';

  @override
  String get chat_chatProvider_L388 => 'System';

  @override
  String get dialogchatProviderMessageC357 =>
      'Good luck running away, Robbers~';

  @override
  String get chat_chatProvider_L395 => 'Nickname';

  @override
  String get dialogchatProviderMessageEa9a => 'Let\'s win this!';

  @override
  String get chat_chatProvider_L402 => 'Nickname';

  @override
  String get chat_chatProvider_L564 =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get chat_chatProvider_L655 =>
      'Authentication has expired. Re-login is required';

  @override
  String get chat_chatProvider_L676 =>
      'Authentication has expired. Re-login is required';

  @override
  String get dialogchatContextMenuMessage => 'Message has been copied';

  @override
  String get dialogchatContextMenuMessage2c60 => 'This user has been blocked';

  @override
  String get dialogchatContextMenuTitle => 'Report';

  @override
  String get fieldchatContextMenuLabel => 'Report details';

  @override
  String get fieldchatContextMenuHint =>
      'Please write the reason for the report in detail\n(include the situation or conversation details)';

  @override
  String get chat_chatContextMenu_L140 => 'Report';

  @override
  String get dialogchatContextMenuMessageDf78 => 'Report has been received';

  @override
  String get dialogchatContextMenuMessage9d41 => 'Failed to submit the report';

  @override
  String get dialogchatContextMenuTitle5ccb =>
      'Would you like to report this user?';

  @override
  String get dialogchatContextMenuCancel => 'Cancel';

  @override
  String get dialogchatContextMenuConfirm => 'Report';

  @override
  String get chat_chatContextMenu_L190 => 'Selected reason for report:';

  @override
  String get chat_chatContextMenu_L202 =>
      '\nThe reported content will be reviewed and acted upon';

  @override
  String get fieldchatContextMenuLabelA83e => 'Copy';

  @override
  String get fieldchatContextMenuLabel7812 => 'Report';

  @override
  String get fieldchatContextMenuLabel2f14 => 'Block';

  @override
  String get chat_chatContextMenu_L478 => 'Select report type';

  @override
  String chat_chatInputBar_L98(String all) {
    return 'Total $all';
  }

  @override
  String chat_chatInputBar_L99(String team) {
    return 'Team $team';
  }

  @override
  String chatInputBarUnreadHint(String body) {
    return 'Unread [$body]';
  }

  @override
  String get chat_chatInputBar_L158 => 'Connecting...';

  @override
  String get chat_chatInputBar_L159 => 'Enter chat message';

  @override
  String get chat_chatMessageList_L152 => 'Start chatting';

  @override
  String get fieldchatMessageListLabel => 'Go to the latest message';

  @override
  String get chat_chatMessageList_L276 => 'Mon';

  @override
  String get chat_chatMessageList_L276_1 => 'Tue';

  @override
  String get chat_chatMessageList_L276_2 => 'Wed';

  @override
  String get chat_chatMessageList_L276_3 => 'Thu';

  @override
  String get chat_chatMessageList_L276_4 => 'Fri';

  @override
  String get chat_chatMessageList_L276_5 => 'Sat';

  @override
  String get chat_chatMessageList_L276_6 => 'Sun';

  @override
  String chat_chatMessageList_L278(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year-$month-$day $weekday';
  }

  @override
  String get chat_chatOverlay_L428 => 'Global chat';

  @override
  String get chat_chatOverlay_L428_1 => 'Team chat';

  @override
  String get chat_chatPreviewCard_L116 => 'Notice';

  @override
  String get chat_chatPreviewCard_L120 => 'Team';

  @override
  String get chat_chatPreviewCard_L124 => 'All';

  @override
  String get dialogagreementSettingsPageMessage =>
      'Not connected to the network yet';

  @override
  String get dialogagreementSettingsPageMessageEfc5 =>
      'Changes have been saved';

  @override
  String get settings_agreementSettingsPage_L102 =>
      'A temporary error occurred. Please try again';

  @override
  String get settings_agreementSettingsPage_L142 => 'Terms and policies';

  @override
  String get settings_agreementSettingsPage_L159 =>
      'Unable to load agreement status';

  @override
  String get settings_agreementSettingsPage_L176 => 'Retry';

  @override
  String get dialogagreementSettingsPageTitle => 'Terms of service';

  @override
  String get dialogagreementSettingsPageTitleBe29 => 'Privacy policy';

  @override
  String get dialogagreementSettingsPageTitle6dcc =>
      'Location terms of service';

  @override
  String get dialogagreementSettingsPageTitle76b8 =>
      'Receive marketing information';

  @override
  String get settings_agreementSettingsPage_L261 => 'Save changes';

  @override
  String get settings_legalDocumentPage_L105 => 'Unable to load document';

  @override
  String get settings_settingsPage_L104 => 'Settings';

  @override
  String get settings_settingsPage_L115 => 'Account';

  @override
  String get settings_settingsPage_L117 => 'Change nickname';

  @override
  String get settings_settingsPage_L128 => 'App settings';

  @override
  String get settings_settingsPage_L130 => 'Game notifications';

  @override
  String get settings_settingsPage_L131 =>
      'Configure notifications for events occurring during the game';

  @override
  String get settings_settingsPage_L137 => 'Notification';

  @override
  String get settings_settingsPage_L143 => 'In-game notifications';

  @override
  String get settings_settingsPage_L149 =>
      'Configure all notifications sent by the app including';

  @override
  String get settings_settingsPage_L164 => 'Manage location permissions';

  @override
  String get settings_settingsPage_L165 =>
      'You can change location permissions in device settings';

  @override
  String get settings_settingsPage_L176 => 'Guide';

  @override
  String get settings_settingsPage_L179 => 'Bug report';

  @override
  String get settings_settingsPage_L182 => 'Replay tutorial';

  @override
  String get settings_settingsPage_L186 => 'Reset tutorial';

  @override
  String get settings_settingsPage_L189 => 'Terms and policies';

  @override
  String get settings_settingsPage_L202 => 'Others';

  @override
  String get settings_settingsPage_L204 => 'Sign out';

  @override
  String get settings_settingsPage_L210 => 'Delete account';

  @override
  String get settings_settingsPage_L292 => 'App version';

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
  String get settings_settingsPage_L498 => 'Report';

  @override
  String get dialogsettingsPageMessage1b8e => 'Bug report has been received';

  @override
  String get dialogsettingsPageTitleD4a4 => 'Reset tutorial';

  @override
  String get dialogsettingsPageMessageA4c9 =>
      'Would you like to reset the tutorials\nso you can see them on all screens again?';

  @override
  String get dialogsettingsPageConfirm => 'Reset';

  @override
  String get dialogsettingsPageMessageC8cb => 'Tutorial has been reset';

  @override
  String get dialogsettingsPageTitle9ab1 => 'Sign out';

  @override
  String get dialogsettingsPageMessageE675 =>
      'Are you sure you want to sign out?';

  @override
  String get dialogsettingsPageConfirm9ab1 => 'Sign out';

  @override
  String get settings_settingsPage_L590 => 'Failed to sign out';

  @override
  String get settings_settingsPage_L590_1 => 'Signed out successfully';

  @override
  String get dialogsettingsPageTitle5e0d => 'Delete account';

  @override
  String get settings_settingsPage_L603 =>
      'Deleting your account will erase all data\nand cannot be undone\n\nTo continue, enter \"delete\"';

  @override
  String get fieldsettingsPageHint2960 => 'delete';

  @override
  String get dialogsettingsPageCancel => 'Cancel';

  @override
  String get dialogsettingsPageConfirm9140 => 'Delete';

  @override
  String get settings_settingsPage_L613 => '탈퇴하기';

  @override
  String get tutorial_inGameTutorialPage_L62 => 'Cop1';

  @override
  String get tutorial_inGameTutorialPage_L72 => 'RobberKing';

  @override
  String get tutorial_inGameTutorialPage_L78 => 'RobberOrNot';

  @override
  String get tutorial_inGameTutorialPage_L84 => 'CapturedRobber';

  @override
  String get dialoginGameTutorialPageTitle => 'Tutorial complete!';

  @override
  String get dialoginGameTutorialPageMessage =>
      'You have learned the core gameplay\nTry using it in a real game';

  @override
  String get dialoginGameTutorialPageConfirm => 'Finish tutorial';

  @override
  String get dialoginGameTutorialPageMessage8372 =>
      'Camera has moved to my location';

  @override
  String get tutorial_inGameTutorialPage_L391 => 'Map preview';

  @override
  String get tutorial_inGameTutorialPage_L434 =>
      'Until next Robber location reveal: 04:30';

  @override
  String get dialoginGameTutorialPageMessage9b3f => 'Game rules guide opens';

  @override
  String get tutorial_inGameTutorialPage_L491 =>
      'My wanted QR code is displayed on the screen. Show it to the Cops to get arrested';

  @override
  String get tutorial_inGameTutorialPage_L492 =>
      'Camera turns on and you can scan a Robber\'s QR to arrest them';

  @override
  String get tutorial_inGameTutorialPage_L509 =>
      'Try pressing the view participants button';

  @override
  String get tutorial_inGameTutorialPage_L509_1 => 'Try pressing the QR button';

  @override
  String get tutorial_inGameTutorialPage_L509_2 => 'Try returning to the map';

  @override
  String tutorial_inGameTutorialPage_L525(String _missionStep) {
    return 'Mission $_missionStep/3';
  }

  @override
  String get tutorial_inGameTutorialPage_L608 =>
      'Viewing from Robber\'s perspective';

  @override
  String get tutorial_inGameTutorialPage_L608_1 =>
      'Viewing from Cops\' perspective';

  @override
  String get dialoginGameTutorialPageMessageA1c5 =>
      'If you are jailed, you can attempt a jailbreak by tapping the card';

  @override
  String get dialoginGameTutorialPageMessage9331 =>
      'In the actual game, you arrest Robbers by scanning their QR code';

  @override
  String get tutorial_inGameTutorialPage_L688 => 'Currently';

  @override
  String tutorial_inGameTutorialPage_L690(int count) {
    return '$count people';
  }

  @override
  String get tutorial_inGameTutorialPage_L696 => 'running away!';

  @override
  String get dialoginGameTutorialPageMessage7650 =>
      'Drag the handle up to expand the chat';

  @override
  String get dialoginGameTutorialPageMessageDb39 =>
      'Enter a message here to send it to team/global chat';

  @override
  String get tutorial_inGameTutorialPage_L806 => 'Enter chat message';

  @override
  String get dialogtutorialCatalogPageTitle => 'Create room';

  @override
  String get tutorial_tutorialCatalogPage_L20 =>
      'Playground/jail setup and slider controls';

  @override
  String get dialogtutorialCatalogPageTitle879f => 'Join room';

  @override
  String get tutorial_tutorialCatalogPage_L25 =>
      'Invite code entry and QR scanning';

  @override
  String get dialogtutorialCatalogPageTitle2421 => 'Waiting room';

  @override
  String get tutorial_tutorialCatalogPage_L30 =>
      'Team changes, game settings, and ready status';

  @override
  String get dialogtutorialCatalogPageTitle8700 => 'In-game';

  @override
  String get tutorial_tutorialCatalogPage_L35 =>
      'Timer, map, participants, chat, and QR';

  @override
  String get tutorial_tutorialCatalogPage_L62 => 'Tutorial';

  @override
  String get tutorial_tutorialCatalogPage_L69 =>
      'If it\'s your first time playing, take a look before starting';

  @override
  String get tutorial_tutorialCatalogPage_L200 => 'In preparation';

  @override
  String get credits_creditMember_L78 => 'Hong Eui-min';

  @override
  String get credits_creditMember_L97 => 'Park Chan-bin';

  @override
  String get credits_creditMember_L110 => 'Lee Chang-hee';

  @override
  String get credits_creditMember_L122 => 'Jeong Sang-hee';

  @override
  String get credits_creditMember_L137 => 'Hwang Hye-rim';

  @override
  String get credits_creditMember_L149 => 'Yoon Ji-hee';

  @override
  String get credits_creditMember_L220 => 'Shin Ji-hoon';

  @override
  String get credits_creditMember_L227 => 'Nam Hae-yoon';

  @override
  String get credits_creditMember_L233 => 'Song Hye-jung';

  @override
  String get credits_creditMember_L239 => 'Lee Jin';

  @override
  String get credits_creditMember_L246 => 'Ahn Geum-seo';

  @override
  String get credits_creditMember_L252 => 'Son Geon-woo';

  @override
  String get credits_creditMember_L258 => 'Shin Hye-bin';

  @override
  String get credits_creditMember_L264 => 'Jeong Chang-woo';

  @override
  String get credits_creditMember_L270 => 'Heo Seok-jun';

  @override
  String get credits_creditMember_L276 => 'Seo Hyun-jin';

  @override
  String get credits_creditMember_L282 => 'Oh Dong-hyun';

  @override
  String get credits_creditMember_L288 => 'Choi Seung-hoon';

  @override
  String get credits_creditMember_L294 => 'Kim Min-wook';

  @override
  String get credits_creditMember_L300 => 'Jeong Myeong-jun';

  @override
  String get credits_creditMember_L306 => 'Kang Dae-hyun';

  @override
  String get credits_creditMember_L312 => 'Sim Hyuk';

  @override
  String get credits_creditsPage_L45 => 'Creators of Cops and Robbers';

  @override
  String get dialogreportRepositoryImplMessage =>
      'An error occurred while processing the report';

  @override
  String get report_reportCategories_L7 => 'Trolling/Spamming';

  @override
  String get report_reportCategories_L8 => 'Profanity/Insults';

  @override
  String get report_reportCategories_L9 => 'Impersonation/Scam';

  @override
  String get report_reportCategories_L10 => 'Advertising/Spam';

  @override
  String get report_reportCategories_L11 => 'Cheating/Exploiting bugs';

  @override
  String get report_reportCategories_L12 => 'Sabotage/Griefing';

  @override
  String get report_reportCategories_L13 => 'Others (Write directly)';

  @override
  String get dialoguserRepositoryImplMessage =>
      'An unexpected error occurred while checking nickname';

  @override
  String get dialoguserRepositoryImplMessageAc72 =>
      'An unexpected error occurred while changing nickname';

  @override
  String get dialoguserRepositoryImplMessage243c =>
      'An error occurred while retrieving user profile';

  @override
  String get dialoguserRepositoryImplMessage220e =>
      'An unexpected error occurred while deleting account';

  @override
  String get dialoguserRepositoryImplMessage05b0 =>
      'An unexpected error occurred while retrieving agreement status';

  @override
  String get dialoguserRepositoryImplMessage2357 =>
      'An unexpected error occurred while saving terms agreement';

  @override
  String get dialoguserRepositoryImplMessage3d3a =>
      'An unexpected error occurred while retrieving push notification consent';

  @override
  String get dialoguserRepositoryImplMessage5fe2 =>
      'An unexpected error occurred while updating push notification consent';

  @override
  String get lobby_lobbyProvider_L139 =>
      'Unable to retrieve the authentication token. Re-login is required';

  @override
  String get lobby_lobbyProvider_L187 =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get lobby_lobbyProvider_L319 =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get lobby_lobbyProvider_L381 =>
      'Authentication has expired. Re-login is required';

  @override
  String get lobby_lobbyProvider_L399 =>
      'Authentication has expired. Re-login is required';

  @override
  String get dialognoticeRepositoryImplMessage =>
      'An error occurred while loading notices';

  @override
  String get dialognoticesPageMessage => 'Loading notices...';

  @override
  String get dialognoticesPageMessage4982 => 'Failed to load notices';

  @override
  String get notice_noticesPage_L131 => 'Notices';

  @override
  String get notice_noticesPage_L152 => 'There are no notices registered';

  @override
  String get router_appRouter_L477 => 'Unable to load game area information';

  @override
  String get router_appRouter_L575 => 'Page not found';

  @override
  String get router_appRouter_L586 => 'The requested page does not exist';

  @override
  String router_appRouter_L589(String path) {
    return 'Path: $path';
  }

  @override
  String get router_appRouter_L600 => 'Sign out';

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
  String get gameEventPoliceMoveWarning =>
      'Cops will move soon.  Robbers, hurry and run!';

  @override
  String get gameEventPoliceMove => 'Cops are on the move!  Robbers, run!';

  @override
  String get gameEventLocationReveal => 'Robbers\' locations are now revealed!';

  @override
  String gameEventRemainingRobbers(int count) {
    return '$count robber(s) still on the run!';
  }

  @override
  String gameEventArrestNotice(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname] arrested @icon_robber [$robberNickname]!';
  }

  @override
  String get gameEventEscapeNotice =>
      'A robber has escaped from jail! Arrest them now!';

  @override
  String get gameEventFiveMinutesLeft =>
      '5 minutes left until the game ends. Don\'t miss your last chance!';

  @override
  String mapErrorLoadFailed(String mapName) {
    return 'Failed to load $mapName';
  }
}
