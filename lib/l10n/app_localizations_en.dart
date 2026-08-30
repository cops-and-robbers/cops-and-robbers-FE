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
  String get chatSystemGameStartReportTip =>
      'During the game, you can long-press a chat message to report and block disruptive users';

  @override
  String get chatSystemPoliceMoveWarning =>
      'The Cops will move out shortly. Robbers, hurry up and move!';

  @override
  String chatSystemRemainingRobbers(int count) {
    return 'Currently $count people running away!';
  }

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
  String get errorNotFound => 'The requested information could not be found';

  @override
  String get errorConflict =>
      'We couldn\'t process your request. Please try again in a moment';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonCancel => 'Close';

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
  String get buttonGoogleSignIn => 'Continue with Google';

  @override
  String get buttonAppleSignIn => 'Continue with Apple';

  @override
  String get zoneRadiusLabel => 'Radius';

  @override
  String zoneRadiusValue(String value) {
    return 'Radius $value';
  }

  @override
  String zoneAreaValue(String value) {
    return 'Area $value';
  }

  @override
  String get areaTypeSetByDistance => 'Set by distance';

  @override
  String get areaTypeSetByPin => 'Set by pins';

  @override
  String get setupPlaygroundPinDescription =>
      'Select the whole area where the game will take place';

  @override
  String get setupPrisonPinDescription =>
      'Select the jail area to hold the thieves';

  @override
  String get zoneAreaLabel => 'Area';

  @override
  String get zoneClearAllPins => 'Clear all';

  @override
  String pinMaxCountMessage(int count) {
    return 'You can place up to $count pins';
  }

  @override
  String get pinTooCloseMessage => 'Pins are too close together';

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
  String get asset_loading_sub_joinRoom =>
      'If you close the app now, joining will be canceled. Please wait a moment';

  @override
  String get asset_loading_sub_createRoom =>
      'We\'re setting up the hideout. Please wait a moment';

  @override
  String get asset_loading_sub_changeTeam =>
      'We\'re issuing your new ID. Please wait a moment';

  @override
  String get asset_loading_sub_startGame =>
      'The operation is about to begin. Please don\'t close the app';

  @override
  String get asset_loading_sub_updateArea =>
      'We\'re saving the operation zone. Please wait a moment';

  @override
  String get asset_loading_sub_saveSettings =>
      'We\'re saving your settings. Please wait a moment';

  @override
  String get asset_loading_sub_loadProfile =>
      'We\'re loading your agent profile. Please wait a moment';

  @override
  String get asset_loading_sub_logout =>
      'We\'re pulling you out safely. Please wait a moment';

  @override
  String get asset_loading_sub_deleteAccount =>
      'We\'re erasing your records. Please don\'t close the app';

  @override
  String get asset_loading_sub_bugReport =>
      'We\'re filing your report. Please wait a moment';

  @override
  String get asset_loading_joinRoom => 'Preparing to infiltrate';

  @override
  String get asset_loading_joinRoomJoinOperation => 'Joining the operation';

  @override
  String get asset_loading_joinRoomEnterSecretPassage =>
      'Entering through the secret passage';

  @override
  String get asset_loading_joinRoomCheckDisguise => 'Checking the disguise';

  @override
  String get asset_loading_joinRoomCheckDeployment =>
      'Checking the operation deployment personnel';

  @override
  String get asset_loading_createRoom =>
      'Setting up the operation headquarters';

  @override
  String get asset_loading_createRoomPrepareHideout =>
      'Preparing the secret hideout';

  @override
  String get asset_loading_createRoomSecureArea => 'Securing the game area';

  @override
  String get asset_loading_createRoomUnfoldMap => 'Unfolding the secret map';

  @override
  String get asset_loading_createRoomTuneRadio =>
      'Tuning the walkie-talkie frequency';

  @override
  String get asset_loading_changeTeam => 'Disguising';

  @override
  String get asset_loading_changeTeamChangeCoverIdentity =>
      'Changing the cover identity';

  @override
  String get asset_loading_changeTeamLaunderIdentity =>
      'Laundering the identity';

  @override
  String get asset_loading_changeTeamSwitchToDoubleSpy =>
      'Switching to double spy';

  @override
  String get asset_loading_changeTeamIssueNewId => 'Issuing a new ID';

  @override
  String get asset_loading_startGame => 'Preparing to start the operation';

  @override
  String get asset_loading_startGamePrepareMoveOut => 'Preparing to move out';

  @override
  String get asset_loading_startGameCountdownStart => 'Starting countdown';

  @override
  String get asset_loading_startGameTurnOnRadio =>
      'Turning on the walkie-talkie';

  @override
  String get asset_loading_startGameDeployAgents => 'Deploying field agents';

  @override
  String get asset_loading_updateArea => 'Setting up the game area';

  @override
  String get asset_loading_updateAreaDesignateZone =>
      'Designating the jurisdiction zone';

  @override
  String get asset_loading_updateAreaPlotOnMap => 'Plotting points on the map';

  @override
  String get asset_loading_updateAreaAnalyzeSatellite =>
      'Analyzing satellite imagery';

  @override
  String get asset_loading_updateAreaCalculateRange =>
      'Calculating the operation radius';

  @override
  String get asset_loading_saveSettings => 'Editing operation guidelines';

  @override
  String get asset_loading_saveSettingsUpdateRules => 'Updating the rules';

  @override
  String get asset_loading_saveSettingsApplyNewRules => 'Applying new rules';

  @override
  String get asset_loading_saveSettingsChangePasscode =>
      'Changing the passcode';

  @override
  String get asset_loading_saveSettingsApplyOperationCode =>
      'Applying the new operation code';

  @override
  String get asset_loading_loadProfile => 'Verifying identity';

  @override
  String get asset_loading_loadProfileCheckWantedPoster =>
      'Checking the wanted poster';

  @override
  String get asset_loading_loadProfileInspectId => 'Inspecting the ID';

  @override
  String get asset_loading_loadProfileMatchFingerprints =>
      'Matching fingerprints';

  @override
  String get asset_loading_loadProfileAnalyzeSuspect =>
      'Analyzing the suspect profile';

  @override
  String get asset_loading_logout => 'Withdrawing';

  @override
  String get asset_loading_logoutGoIntoHiding => 'Going into hiding';

  @override
  String get asset_loading_logoutEraseTraces => 'Erasing traces';

  @override
  String get asset_loading_logoutDestroyEvidence => 'Destroying evidence';

  @override
  String get asset_loading_logoutEscapeViaPassage =>
      'Escaping through the secret passage';

  @override
  String get asset_loading_deleteAccount => 'Processing account deletion';

  @override
  String get asset_loading_deleteAccountObliterateRecords =>
      'Obliterating records';

  @override
  String get asset_loading_deleteAccountDeleteIdentity => 'Deleting identity';

  @override
  String get asset_loading_reconnect => 'Returning to the field';

  @override
  String get asset_loading_reconnectRejoinOperation =>
      'Rejoining the operation';

  @override
  String get asset_loading_reconnectPrepareReturn =>
      'Preparing to return to the field';

  @override
  String get asset_loading_reconnectRestoreRadio =>
      'Restoring the radio channel';

  @override
  String get asset_loading_reconnectRescanFrequency =>
      'Rescanning the secret frequency';

  @override
  String get asset_loading_bugReport => 'Writing the report';

  @override
  String get asset_loading_bugReportSubmitReport =>
      'Submitting the report to headquarters';

  @override
  String get asset_loading_bugReportAttachPhotos => 'Attaching field photos';

  @override
  String get asset_loading_bugReportAssignCaseNumber =>
      'Assigning a case number';

  @override
  String get asset_loading_bugReportHandToInvestigation =>
      'Handing over to the investigation team';

  @override
  String get asset_loading_easterEggCharacterRumor =>
      'Rumor has it the home character changes if you keep tapping it...';

  @override
  String get asset_loading_easterEggCharacterTap =>
      'They say a new look appears if you tap the character a bunch of times...?';

  @override
  String get asset_loading_easterEggCharacterSecret =>
      'Word is there\'s a hidden secret in the home character...';

  @override
  String get asset_loading_easterEggSettingsTap =>
      'I heard a secret opens if you keep pressing somewhere in settings';

  @override
  String get asset_loading_easterEggVersionTap =>
      'Something might appear if you keep tapping the app version...?';

  @override
  String get asset_loading_easterEggVersionSecret =>
      'Rumor has it that someone hid a secret in the version number';

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
  String get errorGameRoomCreateUnexpected =>
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
    return '$minutes min after Robbers start';
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
  String get mypageProfileIconLabel => 'Profile icon';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavCommunity => 'Community';

  @override
  String get pageCommunityDetailTitle => 'Post';

  @override
  String get communityDetailJoinChat => 'Join the chat';

  @override
  String get communityDetailShare => 'Share';

  @override
  String get communityChatRoomsEmpty => 'No chat rooms yet';

  @override
  String get communityChatRoomsLoginRequired => 'Log in to see your meetups';

  @override
  String communityChatSystemJoined(String nickname) {
    return '$nickname joined';
  }

  @override
  String communityChatSystemLeft(String nickname) {
    return '$nickname left';
  }

  @override
  String get communityChatPreviewJoined => 'A new member joined';

  @override
  String get communityChatPreviewLeft => 'A member left';

  @override
  String communityChatSystemKicked(String nickname) {
    return '$nickname was removed';
  }

  @override
  String get communityChatPreviewKicked => 'A member was removed';

  @override
  String get communityChatPreviewInvite => 'Game invite';

  @override
  String get communityChatPreviewUnsupported => 'New message';

  @override
  String get communityChatInviteOpened => 'The game has started!';

  @override
  String communityChatInviteTitle(String nickname, String roomTitle) {
    return '$nickname invited you to [$roomTitle]';
  }

  @override
  String communityChatInviteCode(String inviteCode) {
    return 'Invite code $inviteCode';
  }

  @override
  String get communityChatInviteJoin => 'Join game';

  @override
  String get communityChatInputHint => 'Send a message';

  @override
  String get communityChatEnterRoom => 'Enter chat';

  @override
  String communityChatMeetingMembers(String current, int max) {
    return '$current/$max members';
  }

  @override
  String get communityChatViewLocation => 'View location';

  @override
  String communityChatMemberCount(int count) {
    return '$count participants';
  }

  @override
  String get communityChatAuthorBadge => 'Host';

  @override
  String get communityChatViewPost => 'View post';

  @override
  String get communityChatLeave => 'Leave chat';

  @override
  String get communityChatLeaveConfirmTitle => 'Leave this chat?';

  @override
  String get communityChatLeaveConfirmMessage =>
      'You won\'t be able to see this conversation again';

  @override
  String get communityChatMeetingInfoTitle => 'Meeting info';

  @override
  String get communityChatConnectionLost => 'Connection lost';

  @override
  String get communityChatReconnect => 'Reconnect';

  @override
  String get communityChatReconnecting => 'Connecting...';

  @override
  String get communityChatSendFailed => 'Failed · Tap to retry';

  @override
  String get communityChatEvicted => 'You\'re no longer a member of this chat';

  @override
  String get timePeriodAm => 'AM';

  @override
  String get timePeriodPm => 'PM';

  @override
  String communityChatTime(String period, String hour, String minute) {
    return '$hour:$minute $period';
  }

  @override
  String communityChatDateShort(String month, String day) {
    return '$month/$day';
  }

  @override
  String get buttonLogin => 'Log in';

  @override
  String get errorCodeInvalidMessageType => 'This message can\'t be sent';

  @override
  String get errorCodeEmptyMessage => 'Please enter a message';

  @override
  String get errorCodeMessageTooLong => 'Messages can be up to 500 characters';

  @override
  String get errorCodeInvalidGameInvite => 'The invite information is invalid';

  @override
  String get errorCodeInvalidMessageKey =>
      'Couldn\'t send the message. Please try again';

  @override
  String communityDetailCommentCount(int count) {
    return 'Comments $count';
  }

  @override
  String get communityCommentHint => 'Leave a comment';

  @override
  String get communityCommentReplyHint => 'Leave a reply';

  @override
  String get communityCommentReply => 'Reply';

  @override
  String get communityCommentDeleted => 'This comment was deleted';

  @override
  String get communityCommentEmpty => 'Be the first to comment';

  @override
  String get communityCommentJustNow => 'Just now';

  @override
  String communityCommentMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String communityCommentHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get communityDeleteConfirmTitle => 'Delete this post?';

  @override
  String get communityDeleteConfirmMessage => 'This can\'t be undone';

  @override
  String get communityLoginRequiredMessage => 'You need to log in for this';

  @override
  String get communityMenuEdit => 'Edit';

  @override
  String get communityMenuDelete => 'Delete';

  @override
  String get communityMenuMarkCompleted => 'Close recruiting';

  @override
  String get communityMenuMarkRecruiting => 'Reopen recruiting';

  @override
  String get communityMenuLoginRequired => 'Log in to continue';

  @override
  String get communityStatusRecruiting => 'Open';

  @override
  String get communityStatusCompleted => 'Closed';

  @override
  String get communityStatusEnded => 'Ended';

  @override
  String communityHeadcount(int current, int max) {
    return '$current/$max';
  }

  @override
  String communityHeadcountMaxOnly(int max) {
    return 'Max $max';
  }

  @override
  String communityMeetingAt(
    String month,
    String day,
    String weekday,
    String time,
  ) {
    return '$month/$day ($weekday) $time';
  }

  @override
  String get pageCommunityTitle => 'Community';

  @override
  String get pageCommunityEmpty => 'No posts yet';

  @override
  String get pageCommunityScrapTitle => 'Scraps';

  @override
  String get communityScrapEmpty => 'Nothing scrapped yet';

  @override
  String get pageCommunityNotificationTitle => 'Notifications';

  @override
  String get communityNotificationEmpty => 'No notifications yet';

  @override
  String communityNotificationNewComment(String content) {
    return 'New comment: $content';
  }

  @override
  String communityNotificationNewReply(String content) {
    return 'New reply: $content';
  }

  @override
  String get communityScopeAll => 'All';

  @override
  String get communityScopeNearby => 'Nearby';

  @override
  String get communityScopeMine => 'My meetups';

  @override
  String get communitySortLatest => 'Latest';

  @override
  String get communitySortPopular => 'Popular';

  @override
  String get communitySortDistance => 'Nearest';

  @override
  String get communitySortDeadline => 'Closing soon';

  @override
  String get communitySortSheetTitle => 'Sort by';

  @override
  String get communitySortNeedsLocation =>
      'Location access is needed to sort by distance';

  @override
  String get communitySortLocationDenied =>
      'Turn on location access in Settings';

  @override
  String get communitySearchHint => 'Search by title or place';

  @override
  String get communitySearchRecent => 'Recent searches';

  @override
  String get communitySearchClearAll => 'Clear all';

  @override
  String get communitySearchEmpty => 'No results found';

  @override
  String get communitySearchTooShort => 'Enter at least 2 characters';

  @override
  String get communityCreatePost => 'New post';

  @override
  String get communityEditPost => 'Edit post';

  @override
  String get communityBackToList => 'Back to list';

  @override
  String get communityCreateLabelTitle => 'Title';

  @override
  String get communityCreateHintTitle => 'After-work match! Beginners welcome';

  @override
  String get communityCreateLabelContent => 'Details';

  @override
  String get communityCreateHintContent =>
      'Add rules, what to bring, after-party plans';

  @override
  String get communityCreateLabelDate => 'Date';

  @override
  String get communityCreateHintDate => 'Pick a date for the meetup';

  @override
  String communityCreateDateValue(
    String year,
    String month,
    String day,
    String weekday,
    String time,
  ) {
    return '$year.$month.$day ($weekday) $time';
  }

  @override
  String get communityDateSheetTitle => 'Meetup date & time';

  @override
  String get communityDateSheetRowTime => 'Time';

  @override
  String communityDateSheetRowDateValue(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year.$month.$day $weekday';
  }

  @override
  String get communityCreateLabelLocation => 'Location';

  @override
  String get communityCreateHintLocation =>
      'Enter the exact spot, e.g. main gate';

  @override
  String get communityCreateHintAddress =>
      'Filled in when you pick a spot on the map';

  @override
  String get communityCreateHintPickLocation => 'Pick a spot on the map';

  @override
  String get communityLocationCopied => 'Location copied';

  @override
  String get communityLocationPickerTitle => 'Pick a location';

  @override
  String get communityLocationPickerConfirm => 'Use this location';

  @override
  String get communityLocationPickerLoading => 'Checking the address';

  @override
  String get communityLocationPickerHint =>
      'Tap the map to set your meeting spot';

  @override
  String get communityLocationPickerNotFound =>
      'No address here. Please pick another spot';

  @override
  String get communityCreateLoading => 'Posting your recruitment';

  @override
  String get communityCreateLoadingSub =>
      'We\'re publishing your post. Please wait a moment';

  @override
  String get communityEditLoading => 'Updating your recruitment';

  @override
  String get communityEditLoadingSub =>
      'We\'re saving your changes. Please wait a moment';

  @override
  String get communityCreateLabelHeadcount => 'Headcount';

  @override
  String communityHeadcountValue(int count) {
    return '$count';
  }

  @override
  String communityHeadcountQuickAdd(int count) {
    return '+ $count';
  }

  @override
  String get communityHeadcountDecrease => 'Decrease headcount';

  @override
  String get communityHeadcountIncrease => 'Increase headcount';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get bottomNavMyPage => 'My Page';

  @override
  String get comingSoonMessage => 'Coming soon';

  @override
  String get homePageGameButtonsHint =>
      'You can create a game or join with an invite code';

  @override
  String get homeBannerSemanticsLabel => 'Event banner';

  @override
  String get dialogSafetyWarningTitle =>
      'Please watch your surroundings while using the app';

  @override
  String get dialogSafetyWarningMessage =>
      'Focusing only on the screen during the game can be dangerous\nPlease check the road and walking environment to stay safe';

  @override
  String get buttonAcknowledgedSurroundings => 'I understand!';

  @override
  String get homePageDontShowToday => 'Do not show again today';

  @override
  String get errorAlreadyInGame => 'You are already participating in a game';

  @override
  String get errorUnknownGameState => 'Unknown game status';

  @override
  String get buttonGoToSettings => 'Go to settings';

  @override
  String get errorJoinFailedCheckCode =>
      'Failed to join. Please check the invite code';

  @override
  String get errorJoinRetry => 'Failed to join. Please try again';

  @override
  String get dialogJoinRoomTitle => 'Join waiting room';

  @override
  String get fieldInviteCodeHint => 'Enter invite code';

  @override
  String get dialogScanInviteQrTitle => 'Scan the invite code QR';

  @override
  String get buttonJoin => 'Join';

  @override
  String get appBrandName => 'Cops and Robbers';

  @override
  String get messageComingSoon => 'In preparation';

  @override
  String get homePageWelcomeMessage => 'Who stole\nMy cheese!!!!🧀';

  @override
  String get buttonCreateRoom => 'Create game';

  @override
  String get buttonJoinRoom => 'Join game';

  @override
  String get errorCreateRoomFailed =>
      'Failed to create game room. Please try again';

  @override
  String get sessionCreationStepBasicTitle => 'Set up basic information';

  @override
  String get sessionCreationStepReviewTitle => 'Verify final settings';

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
  String get dummyNicknameBear => 'Cozy bear...';

  @override
  String get errorCannotJoinRoom => 'Unable to join the room';

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
  String get dialogTutorialPromptMessage =>
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
  String get titleGameRules => 'Game rules';

  @override
  String get buttonViewInGame => 'View in-game';

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
  String get unitPerson => 'people';

  @override
  String get unitMinutes => 'min';

  @override
  String get gameSettingNoLocationShareWarning =>
      'The Robbers\' locations will not be shared!';

  @override
  String get gameSettingPoliceStartPrefix => 'After Robbers start,';

  @override
  String get gameSettingPoliceStartSuffix => 'later';

  @override
  String get buttonCompleteSetup => 'Done';

  @override
  String warnMaxReached(String max) {
    return 'You can set up to $max';
  }

  @override
  String get warnRoundDurationRange =>
      'Game time must be between 10 and 180 minutes';

  @override
  String get warnShorterThanRoundDuration =>
      'Set this shorter than the game time';

  @override
  String get warnPoliceWaitMin => 'Cop start time must be at least 1 minute';

  @override
  String get dialogQuitCreationTitle => 'Stop creating the room?';

  @override
  String get dialogQuitCreationMessage =>
      'The zone you\'re drawing will be lost';

  @override
  String get buttonKeepCreating => 'Keep creating';

  @override
  String get buttonQuitCreation => 'Stop';

  @override
  String get sectionTitleSettings => 'Settings';

  @override
  String get labelParticipantCount => 'Player count';

  @override
  String get fieldRoundTimeLimit => 'Game time';

  @override
  String get fieldLocationShareInterval => 'Robber location share interval';

  @override
  String get fieldPoliceDispatchTime => 'Cop start time';

  @override
  String teamSectionCurrentCount(int count) {
    return 'Currently $count people';
  }

  @override
  String get sectionTitleZone => 'Game area';

  @override
  String get errorLogoutGeneric => 'An error occurred during sign out';

  @override
  String get errorAuthUserNotFound =>
      'Unable to retrieve sign in information. Please try again';

  @override
  String get errorAuthTokenIssueFailed =>
      'Authentication failed. Please try again';

  @override
  String get errorAuthTokenValidationFailed =>
      'Your login session has expired. Please sign in again';

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
      'A temporary error occurred. Please try again in a moment';

  @override
  String get errorAuthFirebaseInternal =>
      'A temporary error occurred. Please try again in a moment';

  @override
  String errorAuthProviderLoginFailed(String provider) {
    return 'Failed to sign in with $provider. Please try again';
  }

  @override
  String get errorAuthLoginFailed => 'Sign in failed. Please try again';

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
  String get errorNetworkNotConnected => 'Not connected to the network yet';

  @override
  String get errorRequiredAgreementsMissing =>
      'Please agree to all required terms';

  @override
  String get messageAccountDeleted => 'Account deletion is complete';

  @override
  String get dialogAge14ConfirmTitle => 'Are you 14 years of age or older?';

  @override
  String get dialogAge14ConfirmMessage =>
      'Cops and Robbers does not allow signups for users under 14\nThis information is used solely to verify eligibility';

  @override
  String get errorLoginGeneric => 'An error occurred during sign in';

  @override
  String get errorAppleLoginFailed => 'An error occurred during Apple sign in';

  @override
  String get errorAgeRestrictionUnder14 =>
      'Users under 14 cannot use the service';

  @override
  String get loginPageTagline => 'Real-Time GPS Offline Tag Race';

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
  String get messageNicknameSaved => 'Nickname has been saved';

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
  String get dialogNetworkConnectionFailedTitle => 'Network connection failed';

  @override
  String get dialogSplashOfflineMessage =>
      'Please check your internet connection\nand try again';

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
  String get errorUnknown => 'An unknown error occurred';

  @override
  String get errorLogoutFailed => 'Failed to sign out';

  @override
  String get agreementAllCheckboxLabel => 'Agree to all';

  @override
  String get agreementItemRequiredTag => '[Required]';

  @override
  String get agreementItemOptionalTag => '[Optional]';

  @override
  String get gameRobberOnTheRunBanner => 'Robbers are running away!';

  @override
  String get gameOverBannerTitle => 'Game over!';

  @override
  String get gameOverReasonAllArrested => 'All Robbers have been arrested!';

  @override
  String get gameOverReasonTimeUp => 'The time limit has expired!';

  @override
  String get gameOverReasonPoliceForfeited => 'All Cops have left the game!';

  @override
  String get gameOverReasonRobberForfeited => 'All Robbers have left the game!';

  @override
  String get gameOverFallbackMessage => 'The game has ended';

  @override
  String get gameTeamCop => 'Cop team';

  @override
  String get gameTeamRobber => 'Robber team';

  @override
  String get gameResultWin => 'Win';

  @override
  String get gameResultLose => 'Lose';

  @override
  String messageGameOverWinner(Object winnerTeamLabel) {
    return '$winnerTeamLabel wins!';
  }

  @override
  String get gameRoleCopLabel => 'Cop';

  @override
  String get gameRoleRobberLabel => 'Robber';

  @override
  String get errorCannotArrestDuringWait =>
      'Cannot arrest Robbers during the Cops waiting time';

  @override
  String get qrScannerWantedRobberTitle => 'Scan the Robber\'s wanted QR code';

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
  String get buttonEscape => 'Jailbreak';

  @override
  String get buttonNo => 'No';

  @override
  String get labelArrestCount => 'Arrest count';

  @override
  String get fieldRemainingRobbers => 'Remaining Robbers';

  @override
  String get fieldGamePlaytime => 'Game playtime';

  @override
  String get buttonGoHome => 'Go to home';

  @override
  String get buttonPlayAgain => 'One more time';

  @override
  String get labelMyRecord => 'My record';

  @override
  String get labelResult => 'Result';

  @override
  String get messageSaveFailed => 'Failed to save';

  @override
  String get dialogImageActionTitle =>
      'What would you like to do with the image?';

  @override
  String get buttonSaveImage => 'Save image';

  @override
  String get messageImageSaved => 'Image saved';

  @override
  String get messageShareComplete => 'Shared';

  @override
  String get labelNoRoute => 'No movement recorded';

  @override
  String gameLocationRevealCountdown(String formatted) {
    return 'Until next Robber location reveal: $formatted';
  }

  @override
  String get dialogArrestConfirmTitle => 'Have you arrested this player?';

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
  String get dialogCameraPermissionTitle => 'Camera permission required';

  @override
  String get dialogCameraPermissionMessage =>
      'Camera permission is required to scan QR codes\nPlease allow camera permission in settings';

  @override
  String get errorCameraUnavailable => 'Camera is unavailable';

  @override
  String get gameZoneExitBanner => 'Left the playground';

  @override
  String get chatTeamPrefix => '[Team]';

  @override
  String get chatSystemGameTimeLimit30Min => 'The time limit is 30 minutes';

  @override
  String get chatSystemGoodLuckRobber => 'Good luck running away, Robbers~';

  @override
  String get chatSystemLetsWin => 'Let\'s win this!';

  @override
  String get messageMessageCopied => 'Message has been copied';

  @override
  String get messageUserBlocked => 'This user has been blocked';

  @override
  String get fieldReportContentLabel => 'Report details';

  @override
  String get fieldReportReasonHint =>
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
  String get chatReportSelectedCategoryLabel => 'Selected reason for report:';

  @override
  String get chatReportSubmitNotice =>
      '\nThe reported content will be reviewed and acted upon';

  @override
  String get buttonCopy => 'Copy';

  @override
  String get buttonBlock => 'Block';

  @override
  String get reportCategoryLabel => 'Report type';

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
  String get buttonGoToLatestMessage => 'Go to the latest message';

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
  String get settingsAccountMyScraps => 'My scraps';

  @override
  String get settingsSectionAppPreferences => 'App settings';

  @override
  String get settingsAppGameNotification => 'Game notifications';

  @override
  String get settingsAppGameNotificationDescription =>
      'Configure notifications for events occurring during the game';

  @override
  String get settingsAppCommunityNotification => 'Community notifications';

  @override
  String get settingsAppCommunityNotificationDescription =>
      'Get push alerts for comments, replies, and chats. Your inbox keeps them even when this is off';

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
  String get settingsGuideOpenSourceLicenses => 'Open source licenses';

  @override
  String get settingsSectionEtc => 'Others';

  @override
  String get settingsEtcDeleteAccount => 'Delete account';

  @override
  String get settingsAppVersionLabel => 'App version';

  @override
  String get settingsSnsPrompt => 'Curious about more updates? 👀';

  @override
  String get errorGameNotificationToggleFailed =>
      'Failed to change game notification settings';

  @override
  String get errorProfileIconUpdateFailed =>
      'Couldn\'t change your profile icon';

  @override
  String get titleBugReport => 'Bug report';

  @override
  String get fieldBugReportLabel => 'Bug details';

  @override
  String get fieldBugReportHint =>
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
  String get buttonReset => 'Reset';

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
  String get titleTutorialComplete => 'Tutorial complete!';

  @override
  String get messageTutorialComplete =>
      'You have learned the core gameplay\nTry using it in a real game';

  @override
  String get buttonFinishTutorial => 'Finish tutorial';

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
  String get tutorialMissionDropPing =>
      'Try long-pressing the map to drop a pin';

  @override
  String get tutorialPingLongPressHint => 'Long-press anywhere on the map';

  @override
  String tutorialMissionProgress(String step) {
    return 'Mission $step/4';
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
  String get errorReportGeneric =>
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
  String get errorNicknameCheckUnexpected =>
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
  String get errorCommunityPushFetchUnexpected =>
      'An unexpected error occurred while loading community push notification consent';

  @override
  String get errorCommunityPushUpdateUnexpected =>
      'Couldn\'t update community notification settings';

  @override
  String get errorAuthTokenMissing =>
      'We couldn\'t verify your login. Please sign in again';

  @override
  String get errorServerUnreachable =>
      'Unable to connect to the server. Please try again in a moment';

  @override
  String get errorAuthExpired =>
      'Authentication has expired. Re-login is required';

  @override
  String get errorNoticesLoadGeneric =>
      'An error occurred while loading notices';

  @override
  String get errorCommunityPostsLoadGeneric =>
      'Something went wrong while loading posts';

  @override
  String get errorCommunityPostsLoadFailed => 'Couldn\'t load posts';

  @override
  String get errorCommunityPostUpdateGeneric =>
      'Something went wrong while updating the post';

  @override
  String get errorCommunityPostDeleteGeneric =>
      'Something went wrong while deleting the post';

  @override
  String get errorCommunityPostStatusGeneric =>
      'Something went wrong while changing the status';

  @override
  String get errorCommunityPostCreateGeneric =>
      'Something went wrong while posting';

  @override
  String get errorCommunityCommentsLoadGeneric =>
      'Something went wrong while loading comments';

  @override
  String get errorCommunityCommentCreateGeneric =>
      'Something went wrong while posting your comment';

  @override
  String get errorCommunityCommentDeleteGeneric =>
      'Something went wrong while deleting the comment';

  @override
  String get errorCommunityReactionGeneric =>
      'Couldn\'t complete that. Please try again shortly';

  @override
  String get errorCommunityScrapsLoadGeneric =>
      'Couldn\'t load your scraps. Please try again shortly';

  @override
  String get errorCommunityNotificationsLoadGeneric =>
      'Couldn\'t load notifications. Please try again shortly';

  @override
  String get errorCommunityNotificationUnreadCountLoadGeneric =>
      'Couldn\'t load your unread notification count';

  @override
  String get errorCommunityNotificationReadGeneric =>
      'Failed to mark notifications as read';

  @override
  String get errorCommunityAddressLoadGeneric =>
      'Something went wrong while loading the address';

  @override
  String get errorNoticeLoadFailed => 'Failed to load notices';

  @override
  String get pageNoticesTitle => 'Notices';

  @override
  String get pageNoticesEmpty => 'There are no notices registered';

  @override
  String get noticeCategoryAll => 'All';

  @override
  String get noticeCategoryNotice => 'Notice';

  @override
  String get noticeCategoryMaintenance => 'Maintenance';

  @override
  String get noticeCategoryEvent => 'Event';

  @override
  String get noticeCategoryUpdate => 'Update';

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
  String get errorBugReportFailed =>
      'An error occurred while processing the bug report';

  @override
  String gameEventStartTime(int minutes) {
    return 'The time limit is $minutes minutes';
  }

  @override
  String get gameEventStartReady =>
      'The game starts soon.  All players, get ready!';

  @override
  String get gameEventStartReportTip =>
      'Long-press a chat message during the game to report or block players';

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
  String gameEventPlayerLeftNotice(String nickname, String teamLabel) {
    return '[$nickname] ($teamLabel) has left the game';
  }

  @override
  String mapErrorLoadFailed(String mapName) {
    return 'Failed to load $mapName';
  }

  @override
  String get errorGameJoinUnexpected =>
      'An unexpected error occurred while joining the game';

  @override
  String get errorAlreadyInAnotherRoom =>
      'You\'re already in another room. Please leave it first';

  @override
  String get deeplinkAlreadyInRoom => 'You\'re already in a room';

  @override
  String get errorGameAlreadyStarted =>
      'This game has already started, so you can\'t join';

  @override
  String get errorRoomSwitchFailed =>
      'Couldn\'t join the new room. You\'ve already left the previous one';

  @override
  String get deeplinkSwitchRoomTitle => 'Move to this room?';

  @override
  String get deeplinkSwitchRoomMessage =>
      'You\'ll leave your current room and join this new one';

  @override
  String get deeplinkSwitchRoomConfirm => 'Leave and join';

  @override
  String get errorPendingInviteLoad => 'Failed to load the pending invite code';

  @override
  String get errorPendingInviteSave => 'Failed to save the invite code';

  @override
  String get errorPendingInviteClear => 'Failed to clear the invite code';

  @override
  String shareInviteMessage(String inviteCode) {
    return 'You\'ve been invited to a Cops and Robbers room! Code: $inviteCode';
  }

  @override
  String get errorCodeMissingRequestPart =>
      'A required part of the request is missing';

  @override
  String get errorCodeInvalidRequestBody =>
      'The request body format is invalid';

  @override
  String get errorCodeInvalidQueryParameter =>
      'The query parameter format is invalid';

  @override
  String get errorCodeQueryParameterTypeMismatch =>
      'The request parameter type is invalid';

  @override
  String get errorCodeInvalidInputValue =>
      'The value you entered doesn\'t meet the requirements';

  @override
  String get errorCodeAddressNotFound =>
      'No address here. Please pick another spot';

  @override
  String get errorCodeInvalidDestination => 'Invalid connection path';

  @override
  String get errorCodeUnsupportedMediaType => 'Unsupported format';

  @override
  String get errorCodeMethodNotAllowed => 'This request is not allowed';

  @override
  String get errorCodeEndpointNotFound =>
      'The requested path could not be found';

  @override
  String get errorCodeInvalidSocketSession =>
      'Session not found. Please reconnect';

  @override
  String get errorCodeUnauthorizedSubscription =>
      'You don\'t have permission to subscribe to this team\'s channel';

  @override
  String get errorCodeInternalServerError =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeFirebaseInitError =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeFirebaseConfigNotFound =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeEncryptionFailed =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeDecryptionFailed =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeInvalidEncryptionKey =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeSocialLoginFailed => 'Social login failed';

  @override
  String get errorCodeAccessTokenExpired => 'Your session has expired';

  @override
  String get errorCodeRefreshTokenExpired =>
      'Your login has expired. Please sign in again';

  @override
  String get errorCodeInvalidToken =>
      'Invalid credentials. Please sign in again';

  @override
  String get errorCodeUnauthenticatedRequest => 'Please sign in to continue';

  @override
  String get errorCodeExpiredFirebaseToken =>
      'Your session has expired. Please try again';

  @override
  String get errorCodeInvalidFirebaseToken =>
      'Authentication failed. Please try again';

  @override
  String get errorCodeUnsupportedSocialType =>
      'This social login method is not supported';

  @override
  String get errorCodeForbiddenAdminOnly => 'Admin permission is required';

  @override
  String get errorCodeNicknameGenerationFailed =>
      'Sign-up failed. Please try again later';

  @override
  String get errorCodeFirebaseServerError =>
      'A temporary error occurred. Please try again later';

  @override
  String get errorCodeUserNotFound => 'User not found';

  @override
  String get errorCodeDuplicatedNickname =>
      'This nickname is already taken. Please choose another one';

  @override
  String get errorCodeCannotWithdraw =>
      'You can\'t withdraw while a game session is in progress';

  @override
  String get errorCodeRequiredTermsNotAgreed =>
      'You must agree to all required terms';

  @override
  String get errorCodeGameNotFound => 'The requested game does not exist';

  @override
  String get errorCodeGameNotInProgress => 'The game is not in progress';

  @override
  String get errorCodeGameNotActive =>
      'Can only be viewed in a waiting or in-progress game';

  @override
  String get errorCodeGameNotWaiting =>
      'Settings can only be changed while the game is waiting';

  @override
  String get errorCodeInvalidLocationInterval =>
      'Location reveal interval must be shorter than the round time';

  @override
  String get errorCodeInvalidPoliceWaitTime =>
      'Police wait time must be shorter than the round time';

  @override
  String get errorCodeInviteCodeGenerationFailed =>
      'Failed to generate invite code. Please try again later';

  @override
  String get errorCodeInvalidJailRadius =>
      'The jail radius cannot be greater than or equal to the playground radius';

  @override
  String get errorCodeJailOutsidePlayground =>
      'The jail must be completely inside the playground';

  @override
  String get errorCodeGameAreaNotFound => 'Game area not found';

  @override
  String get errorCodeAlreadyParticipating =>
      'You are already participating in this game';

  @override
  String get errorCodeGameAlreadyStarted =>
      'You can\'t join a game that has already started';

  @override
  String get errorCodeGameFull =>
      'The game has reached its maximum number of players';

  @override
  String get errorCodeInvalidInviteCode =>
      'The invite code you entered is invalid';

  @override
  String get errorCodeParticipantNotFound => 'This user is not in this game';

  @override
  String get errorCodeNotAParticipant =>
      'You are not a participant in this game';

  @override
  String get errorCodeCannotLeaveDuringGame =>
      'You can\'t leave the room after the game has started';

  @override
  String get errorCodeLobbyActionNotAllowed =>
      'Lobby changes are not allowed after the game has started';

  @override
  String get errorCodeNotHost => 'Only the host can do this';

  @override
  String get errorCodeInvalidTeamComposition =>
      'To start the game, the police and robber teams each need at least one player';

  @override
  String get errorCodeNotAllReady =>
      'All participants must be ready to start the game';

  @override
  String get errorCodeNotRobberTeam => 'Only the robber team can send location';

  @override
  String get errorCodeHostCannotUnready => 'The host must always be ready';

  @override
  String get errorCodeParticipantGameMismatch =>
      'The police and robber are in different games';

  @override
  String get errorCodeOnlyPoliceCanArrest =>
      'Only the police team can arrest robbers';

  @override
  String get errorCodeOnlyRobberCanBeArrested =>
      'Only the robber team can be arrested';

  @override
  String get errorCodeOnlyRobberCanEscape => 'Only the robber team can escape';

  @override
  String get errorCodeAlreadyArrested => 'This robber is already jailed';

  @override
  String get errorCodeNotJailed => 'You can only escape from jail';

  @override
  String get errorCodePoliceWaitingTime =>
      'Police can\'t arrest robbers during the wait time';

  @override
  String get errorCodeCannotKickYourself => 'The host can\'t kick themselves';

  @override
  String get errorCodeNoticeNotFound => 'Notice not found';

  @override
  String get errorCodeGameResultNotFound => 'Game result not found';

  @override
  String get errorCodeEtcReasonRequired =>
      'A reason is required when the report type is Other';

  @override
  String get errorCodeSelfReport => 'You can\'t report yourself';

  @override
  String get errorCodeDuplicateReport =>
      'You\'ve already reported this user in this game';

  @override
  String get errorCodeReportNotFound => 'The report does not exist';

  @override
  String get errorCodeChatMessageNotFound => 'This message could not be found';

  @override
  String get errorCodeReportTargetNotFound =>
      'This participant does not exist in the game';

  @override
  String get errorCodeInvalidMeetingDate => 'Pick a meeting time in the future';

  @override
  String get errorCodeCommentNotFound => 'This comment was already deleted';

  @override
  String get errorCodeForbiddenNotCommentAuthor =>
      'You can only delete your own comments';

  @override
  String get errorCodeReplyTargetGone =>
      'The comment you\'re replying to is gone. Refresh and try again';

  @override
  String get errorCodeInvalidCommentDepth => 'You can\'t reply to a reply';

  @override
  String get errorCodePostNotFound => 'This post has been deleted';

  @override
  String get errorCodeForbiddenNotAuthor =>
      'Only the host can edit or delete this post';

  @override
  String get errorCodeCountryNotSpecified =>
      'We can\'t identify the country here. Please try from another spot';

  @override
  String get errorCodeAddressLookupFailed =>
      'Couldn\'t look up the address. Please try again later';

  @override
  String get errorCodeRecruitmentClosed =>
      'This recruitment post is already closed';

  @override
  String get errorCodeUnsupportedListScope =>
      'This list scope isn\'t supported';

  @override
  String get errorCodeUnsupportedListSort =>
      'This sort option isn\'t supported';

  @override
  String get errorCodeAlreadyJoined => 'You\'re already in this chat';

  @override
  String get errorCodeAuthorCannotLeave => 'The host can\'t leave this chat';

  @override
  String get errorCodeChatRoomFull => 'This chat is full';

  @override
  String get errorCodeJoinedChatRoomLimitExceeded =>
      'You\'ve joined too many chats. Leave one and try again';

  @override
  String get errorCodeNotAChatMember => 'You\'re not a member of this chat';

  @override
  String get errorCodeReactionAlreadyApplied => 'This is already up to date';

  @override
  String get pingFound => 'Found';

  @override
  String get pingSuspect => 'Suspect';

  @override
  String get pingCooldownNotice => 'Please try again shortly';

  @override
  String get gameLeaveConfirmTitle => 'Leave the game?';

  @override
  String get gameLeaveConfirmMessage => 'You will leave the game in progress';

  @override
  String get gameLeaveFailedMessage =>
      'Couldn\'t leave the game. Please try again';

  @override
  String get gameEventArrestSuccessTitle => 'Suspect Caught';

  @override
  String gameEventArrestSuccessMessage(String nickname) {
    return 'Caught $nickname';
  }

  @override
  String get gameEventArrestSuccessConfirm => 'OK';

  @override
  String get errorEventArrestRequestFailed =>
      'Failed to send arrest request. Please try again';

  @override
  String get gameEventResultTitle => 'Investigation Closed';

  @override
  String get gameEventProgressTitle => 'Catch Progress';

  @override
  String gameEventResultArrestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count staff caught',
      one: '1 staff member caught',
    );
    return '$_temp0';
  }
}
