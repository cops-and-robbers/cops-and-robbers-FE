import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// 앱 이름 (MaterialApp.title) — i18n 스모크 테스트용 첫 키
  ///
  /// In ko, this message translates to:
  /// **'경찰과도둑'**
  String get appTitle;

  /// 법적 문서 페이지 상단 고지문 — 한국어 원본만 제공함을 비-ko 로케일에 안내 (ko는 빈 문자열 → 미표시)
  ///
  /// In ko, this message translates to:
  /// **''**
  String get legalDocumentKoreanOnlyNotice;

  /// No description provided for @loadingDefault.
  ///
  /// In ko, this message translates to:
  /// **'처리 중...'**
  String get loadingDefault;

  /// No description provided for @permissionLocationFallbackTitle.
  ///
  /// In ko, this message translates to:
  /// **'위치 권한 안내'**
  String get permissionLocationFallbackTitle;

  /// No description provided for @permissionLocationFallbackMessage.
  ///
  /// In ko, this message translates to:
  /// **'위치 권한을 허용해주세요'**
  String get permissionLocationFallbackMessage;

  /// No description provided for @dialogUpdateOptionalTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 버전 안내'**
  String get dialogUpdateOptionalTitle;

  /// No description provided for @dialogUpdateOptionalMessage.
  ///
  /// In ko, this message translates to:
  /// **'더 좋아진 새 버전이 있어요\n업데이트할까요?'**
  String get dialogUpdateOptionalMessage;

  /// No description provided for @dialogUpdateOptionalConfirm.
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get dialogUpdateOptionalConfirm;

  /// No description provided for @dialogUpdateOptionalCancel.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get dialogUpdateOptionalCancel;

  /// No description provided for @dialogUpdateMandatoryTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 안내'**
  String get dialogUpdateMandatoryTitle;

  /// No description provided for @dialogUpdateMandatoryMessage.
  ///
  /// In ko, this message translates to:
  /// **'새로운 버전이 나왔어요\n업데이트할까요?'**
  String get dialogUpdateMandatoryMessage;

  /// No description provided for @dialogUpdateMandatoryConfirm.
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get dialogUpdateMandatoryConfirm;

  /// No description provided for @dialogUpdateMandatoryCancel.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get dialogUpdateMandatoryCancel;

  /// No description provided for @chatSystemGameStartTime.
  ///
  /// In ko, this message translates to:
  /// **'제한 시간은 {minutes}분이에요'**
  String chatSystemGameStartTime(int minutes);

  /// No description provided for @chatSystemGameStartReportTip.
  ///
  /// In ko, this message translates to:
  /// **'게임 중 채팅을 길게 누르면 불편한 유저를 신고하고 차단할 수 있어요'**
  String get chatSystemGameStartReportTip;

  /// No description provided for @chatSystemPoliceMoveWarning.
  ///
  /// In ko, this message translates to:
  /// **'경찰이 곧 출동해요.  도둑은 서둘러 이동하세요!'**
  String get chatSystemPoliceMoveWarning;

  /// No description provided for @chatSystemRemainingRobbers.
  ///
  /// In ko, this message translates to:
  /// **'현재 {count}명 도주 중!'**
  String chatSystemRemainingRobbers(int count);

  /// No description provided for @chatSystemFiveMinutesLeft.
  ///
  /// In ko, this message translates to:
  /// **'게임 종료까지 5분 남았어요. 마지막 기회를 놓치지 마세요!'**
  String get chatSystemFiveMinutesLeft;

  /// No description provided for @errorNetworkTimeout.
  ///
  /// In ko, this message translates to:
  /// **'서버 연결이 너무 오래 걸려요'**
  String get errorNetworkTimeout;

  /// No description provided for @errorNetworkOffline.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인하세요'**
  String get errorNetworkOffline;

  /// No description provided for @errorServerInternal.
  ///
  /// In ko, this message translates to:
  /// **'서버에 문제가 생겼어요'**
  String get errorServerInternal;

  /// No description provided for @errorBadRequest.
  ///
  /// In ko, this message translates to:
  /// **'잘못된 요청이에요'**
  String get errorBadRequest;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했어요'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In ko, this message translates to:
  /// **'접근 권한이 없어요'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In ko, this message translates to:
  /// **'요청한 정보를 찾을 수 없어요'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In ko, this message translates to:
  /// **'요청을 처리할 수 없어요. 잠시 후 다시 시도해주세요'**
  String get errorConflict;

  /// No description provided for @buttonConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get buttonConfirm;

  /// No description provided for @buttonCancel.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get buttonCancel;

  /// No description provided for @dialogReconnectMessage.
  ///
  /// In ko, this message translates to:
  /// **'연결이 끊어졌어요. 재연결이 필요해요'**
  String get dialogReconnectMessage;

  /// No description provided for @dialogReconnectButtonConnecting.
  ///
  /// In ko, this message translates to:
  /// **'연결 중...'**
  String get dialogReconnectButtonConnecting;

  /// No description provided for @dialogReconnectButtonRetry.
  ///
  /// In ko, this message translates to:
  /// **'재연결'**
  String get dialogReconnectButtonRetry;

  /// No description provided for @pageForceUpdateTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 필요'**
  String get pageForceUpdateTitle;

  /// No description provided for @pageForceUpdateMessage.
  ///
  /// In ko, this message translates to:
  /// **'새로운 버전이 출시되었어요\n업데이트 후 이용해 주세요!'**
  String get pageForceUpdateMessage;

  /// No description provided for @pageForceUpdateButton.
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get pageForceUpdateButton;

  /// No description provided for @pageMaintenanceTitle.
  ///
  /// In ko, this message translates to:
  /// **'서버 점검 중'**
  String get pageMaintenanceTitle;

  /// No description provided for @pageMaintenanceMessage.
  ///
  /// In ko, this message translates to:
  /// **'더 나은 서비스를 위해 점검 중이에요\n잠시 후 다시 접속해 주세요!'**
  String get pageMaintenanceMessage;

  /// No description provided for @buttonGoogleSignIn.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get buttonGoogleSignIn;

  /// No description provided for @buttonAppleSignIn.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 계속하기'**
  String get buttonAppleSignIn;

  /// No description provided for @zoneRadiusLabel.
  ///
  /// In ko, this message translates to:
  /// **'반경'**
  String get zoneRadiusLabel;

  /// 구역 크기 — 원형 반경. 값+단위는 formatRadiusValue가 생성한다
  ///
  /// In ko, this message translates to:
  /// **'반경 {value}'**
  String zoneRadiusValue(String value);

  /// 구역 크기 — 폴리곤 면적. 값+단위는 formatAreaValue가 생성한다
  ///
  /// In ko, this message translates to:
  /// **'면적 {value}'**
  String zoneAreaValue(String value);

  /// No description provided for @areaTypeSetByDistance.
  ///
  /// In ko, this message translates to:
  /// **'거리로 설정'**
  String get areaTypeSetByDistance;

  /// No description provided for @areaTypeSetByPin.
  ///
  /// In ko, this message translates to:
  /// **'핀으로 설정'**
  String get areaTypeSetByPin;

  /// No description provided for @setupPlaygroundPinDescription.
  ///
  /// In ko, this message translates to:
  /// **'게임이 진행될 전체 구역을 선택해요'**
  String get setupPlaygroundPinDescription;

  /// No description provided for @setupPrisonPinDescription.
  ///
  /// In ko, this message translates to:
  /// **'도둑을 잡아둘 감옥 구역을 선택해요'**
  String get setupPrisonPinDescription;

  /// No description provided for @zoneAreaLabel.
  ///
  /// In ko, this message translates to:
  /// **'면적'**
  String get zoneAreaLabel;

  /// No description provided for @zoneClearAllPins.
  ///
  /// In ko, this message translates to:
  /// **'전체 해제'**
  String get zoneClearAllPins;

  /// No description provided for @pinMaxCountMessage.
  ///
  /// In ko, this message translates to:
  /// **'핀은 최대 {count}개까지 찍을 수 있어요'**
  String pinMaxCountMessage(int count);

  /// No description provided for @pinTooCloseMessage.
  ///
  /// In ko, this message translates to:
  /// **'핀이 너무 가까워요'**
  String get pinTooCloseMessage;

  /// No description provided for @dialogAgreementRequiredTermsTitle.
  ///
  /// In ko, this message translates to:
  /// **'필수 약관 미동의'**
  String get dialogAgreementRequiredTermsTitle;

  /// No description provided for @errorAuthLoginCancelled.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 취소됐어요'**
  String get errorAuthLoginCancelled;

  /// 설정 화면의 언어 설정 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguageLabel;

  /// 언어 메뉴 부제 (서브타이틀)
  ///
  /// In ko, this message translates to:
  /// **'앱 표시 언어를 변경할 수 있어요'**
  String get settingsLanguageSubtitle;

  /// 언어 설정 페이지 AppBar 제목
  ///
  /// In ko, this message translates to:
  /// **'언어 선택'**
  String get settingsLanguagePageTitle;

  /// 언어 옵션: 단말 시스템 로캘 추종
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get settingsLanguageOptionSystem;

  /// 언어 옵션: 한국어 — 모든 로캘에서 자국어 표기 유지
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get settingsLanguageOptionKorean;

  /// 언어 옵션: 영어 — 모든 로캘에서 자국어 표기 유지
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get settingsLanguageOptionEnglish;

  /// 언어 옵션: 일본어 — 모든 로캘에서 자국어 표기 유지
  ///
  /// In ko, this message translates to:
  /// **'日本語'**
  String get settingsLanguageOptionJapanese;

  /// No description provided for @asset_loading_sub_joinRoom.
  ///
  /// In ko, this message translates to:
  /// **'지금 앱을 끄면 합류가 취소돼요. 잠시만 기다려주세요'**
  String get asset_loading_sub_joinRoom;

  /// No description provided for @asset_loading_sub_createRoom.
  ///
  /// In ko, this message translates to:
  /// **'작전 본부를 세우는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_createRoom;

  /// No description provided for @asset_loading_sub_changeTeam.
  ///
  /// In ko, this message translates to:
  /// **'새 신분증을 발급하는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_changeTeam;

  /// No description provided for @asset_loading_sub_startGame.
  ///
  /// In ko, this message translates to:
  /// **'곧 작전이 시작돼요. 앱을 끄지 말아주세요'**
  String get asset_loading_sub_startGame;

  /// No description provided for @asset_loading_sub_updateArea.
  ///
  /// In ko, this message translates to:
  /// **'작전 구역을 저장하는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_updateArea;

  /// No description provided for @asset_loading_sub_saveSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정을 저장하는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_saveSettings;

  /// No description provided for @asset_loading_sub_loadProfile.
  ///
  /// In ko, this message translates to:
  /// **'요원 정보를 불러오는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_loadProfile;

  /// No description provided for @asset_loading_sub_logout.
  ///
  /// In ko, this message translates to:
  /// **'안전하게 철수하는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_logout;

  /// No description provided for @asset_loading_sub_deleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'기록을 지우는 중이에요. 앱을 끄지 말아주세요'**
  String get asset_loading_sub_deleteAccount;

  /// No description provided for @asset_loading_sub_bugReport.
  ///
  /// In ko, this message translates to:
  /// **'제보를 접수하는 중이에요. 잠시만 기다려주세요'**
  String get asset_loading_sub_bugReport;

  /// No description provided for @asset_loading_joinRoom.
  ///
  /// In ko, this message translates to:
  /// **'잠입 준비 중...'**
  String get asset_loading_joinRoom;

  /// No description provided for @asset_loading_joinRoomJoinOperation.
  ///
  /// In ko, this message translates to:
  /// **'작전에 합류하는 중...'**
  String get asset_loading_joinRoomJoinOperation;

  /// No description provided for @asset_loading_joinRoomEnterSecretPassage.
  ///
  /// In ko, this message translates to:
  /// **'비밀 통로로 진입 중...'**
  String get asset_loading_joinRoomEnterSecretPassage;

  /// No description provided for @asset_loading_joinRoomCheckDisguise.
  ///
  /// In ko, this message translates to:
  /// **'변장 확인 중...'**
  String get asset_loading_joinRoomCheckDisguise;

  /// No description provided for @asset_loading_joinRoomCheckDeployment.
  ///
  /// In ko, this message translates to:
  /// **'작전 투입 인원 확인 중...'**
  String get asset_loading_joinRoomCheckDeployment;

  /// No description provided for @asset_loading_createRoom.
  ///
  /// In ko, this message translates to:
  /// **'작전 본부 설치 중...'**
  String get asset_loading_createRoom;

  /// No description provided for @asset_loading_createRoomPrepareHideout.
  ///
  /// In ko, this message translates to:
  /// **'비밀 아지트 준비 중...'**
  String get asset_loading_createRoomPrepareHideout;

  /// No description provided for @asset_loading_createRoomSecureArea.
  ///
  /// In ko, this message translates to:
  /// **'작전 구역 확보 중...'**
  String get asset_loading_createRoomSecureArea;

  /// No description provided for @asset_loading_createRoomUnfoldMap.
  ///
  /// In ko, this message translates to:
  /// **'비밀 지도 펼치는 중...'**
  String get asset_loading_createRoomUnfoldMap;

  /// No description provided for @asset_loading_createRoomTuneRadio.
  ///
  /// In ko, this message translates to:
  /// **'무전기 주파수 맞추는 중...'**
  String get asset_loading_createRoomTuneRadio;

  /// No description provided for @asset_loading_changeTeam.
  ///
  /// In ko, this message translates to:
  /// **'변장 중...'**
  String get asset_loading_changeTeam;

  /// No description provided for @asset_loading_changeTeamChangeCoverIdentity.
  ///
  /// In ko, this message translates to:
  /// **'위장 신분 변경 중...'**
  String get asset_loading_changeTeamChangeCoverIdentity;

  /// No description provided for @asset_loading_changeTeamLaunderIdentity.
  ///
  /// In ko, this message translates to:
  /// **'신분 세탁 중...'**
  String get asset_loading_changeTeamLaunderIdentity;

  /// No description provided for @asset_loading_changeTeamSwitchToDoubleSpy.
  ///
  /// In ko, this message translates to:
  /// **'이중 스파이 전환 중...'**
  String get asset_loading_changeTeamSwitchToDoubleSpy;

  /// No description provided for @asset_loading_changeTeamIssueNewId.
  ///
  /// In ko, this message translates to:
  /// **'새 신분증 발급 중...'**
  String get asset_loading_changeTeamIssueNewId;

  /// No description provided for @asset_loading_startGame.
  ///
  /// In ko, this message translates to:
  /// **'작전 개시 준비 중...'**
  String get asset_loading_startGame;

  /// No description provided for @asset_loading_startGamePrepareMoveOut.
  ///
  /// In ko, this message translates to:
  /// **'출동 준비 중...'**
  String get asset_loading_startGamePrepareMoveOut;

  /// No description provided for @asset_loading_startGameCountdownStart.
  ///
  /// In ko, this message translates to:
  /// **'카운트다운 시작...'**
  String get asset_loading_startGameCountdownStart;

  /// No description provided for @asset_loading_startGameTurnOnRadio.
  ///
  /// In ko, this message translates to:
  /// **'무전기 켜는 중...'**
  String get asset_loading_startGameTurnOnRadio;

  /// No description provided for @asset_loading_startGameDeployAgents.
  ///
  /// In ko, this message translates to:
  /// **'현장 요원 배치 중...'**
  String get asset_loading_startGameDeployAgents;

  /// No description provided for @asset_loading_updateArea.
  ///
  /// In ko, this message translates to:
  /// **'작전 구역 설정 중...'**
  String get asset_loading_updateArea;

  /// No description provided for @asset_loading_updateAreaDesignateZone.
  ///
  /// In ko, this message translates to:
  /// **'관할 구역 지정 중...'**
  String get asset_loading_updateAreaDesignateZone;

  /// No description provided for @asset_loading_updateAreaPlotOnMap.
  ///
  /// In ko, this message translates to:
  /// **'지도 위에 점 찍는 중...'**
  String get asset_loading_updateAreaPlotOnMap;

  /// No description provided for @asset_loading_updateAreaAnalyzeSatellite.
  ///
  /// In ko, this message translates to:
  /// **'위성 사진 분석 중...'**
  String get asset_loading_updateAreaAnalyzeSatellite;

  /// No description provided for @asset_loading_updateAreaCalculateRange.
  ///
  /// In ko, this message translates to:
  /// **'작전 범위 계산 중...'**
  String get asset_loading_updateAreaCalculateRange;

  /// No description provided for @asset_loading_saveSettings.
  ///
  /// In ko, this message translates to:
  /// **'작전 지침 수정 중...'**
  String get asset_loading_saveSettings;

  /// No description provided for @asset_loading_saveSettingsUpdateRules.
  ///
  /// In ko, this message translates to:
  /// **'규칙 업데이트 중...'**
  String get asset_loading_saveSettingsUpdateRules;

  /// No description provided for @asset_loading_saveSettingsApplyNewRules.
  ///
  /// In ko, this message translates to:
  /// **'새로운 룰 적용 중...'**
  String get asset_loading_saveSettingsApplyNewRules;

  /// No description provided for @asset_loading_saveSettingsChangePasscode.
  ///
  /// In ko, this message translates to:
  /// **'암호 변경 중...'**
  String get asset_loading_saveSettingsChangePasscode;

  /// No description provided for @asset_loading_saveSettingsApplyOperationCode.
  ///
  /// In ko, this message translates to:
  /// **'새 작전 코드 적용 중...'**
  String get asset_loading_saveSettingsApplyOperationCode;

  /// No description provided for @asset_loading_loadProfile.
  ///
  /// In ko, this message translates to:
  /// **'신원 조회 중...'**
  String get asset_loading_loadProfile;

  /// No description provided for @asset_loading_loadProfileCheckWantedPoster.
  ///
  /// In ko, this message translates to:
  /// **'수배서 확인 중...'**
  String get asset_loading_loadProfileCheckWantedPoster;

  /// No description provided for @asset_loading_loadProfileInspectId.
  ///
  /// In ko, this message translates to:
  /// **'신분증 검사 중...'**
  String get asset_loading_loadProfileInspectId;

  /// No description provided for @asset_loading_loadProfileMatchFingerprints.
  ///
  /// In ko, this message translates to:
  /// **'지문 대조 중...'**
  String get asset_loading_loadProfileMatchFingerprints;

  /// No description provided for @asset_loading_loadProfileAnalyzeSuspect.
  ///
  /// In ko, this message translates to:
  /// **'용의자 프로필 분석 중...'**
  String get asset_loading_loadProfileAnalyzeSuspect;

  /// No description provided for @asset_loading_logout.
  ///
  /// In ko, this message translates to:
  /// **'철수 중...'**
  String get asset_loading_logout;

  /// No description provided for @asset_loading_logoutGoIntoHiding.
  ///
  /// In ko, this message translates to:
  /// **'잠적 중...'**
  String get asset_loading_logoutGoIntoHiding;

  /// No description provided for @asset_loading_logoutEraseTraces.
  ///
  /// In ko, this message translates to:
  /// **'흔적 지우는 중...'**
  String get asset_loading_logoutEraseTraces;

  /// No description provided for @asset_loading_logoutDestroyEvidence.
  ///
  /// In ko, this message translates to:
  /// **'증거 인멸 중...'**
  String get asset_loading_logoutDestroyEvidence;

  /// No description provided for @asset_loading_logoutEscapeViaPassage.
  ///
  /// In ko, this message translates to:
  /// **'비밀 통로로 탈출 중...'**
  String get asset_loading_logoutEscapeViaPassage;

  /// No description provided for @asset_loading_deleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'탈퇴 처리 중...'**
  String get asset_loading_deleteAccount;

  /// No description provided for @asset_loading_deleteAccountObliterateRecords.
  ///
  /// In ko, this message translates to:
  /// **'기록 말소 중...'**
  String get asset_loading_deleteAccountObliterateRecords;

  /// No description provided for @asset_loading_deleteAccountDeleteIdentity.
  ///
  /// In ko, this message translates to:
  /// **'신원 삭제 중...'**
  String get asset_loading_deleteAccountDeleteIdentity;

  /// No description provided for @asset_loading_reconnect.
  ///
  /// In ko, this message translates to:
  /// **'다시 현장으로 복귀 중...'**
  String get asset_loading_reconnect;

  /// No description provided for @asset_loading_reconnectRejoinOperation.
  ///
  /// In ko, this message translates to:
  /// **'작전에 재합류하는 중...'**
  String get asset_loading_reconnectRejoinOperation;

  /// No description provided for @asset_loading_reconnectPrepareReturn.
  ///
  /// In ko, this message translates to:
  /// **'현장 복귀 준비 중...'**
  String get asset_loading_reconnectPrepareReturn;

  /// No description provided for @asset_loading_reconnectRestoreRadio.
  ///
  /// In ko, this message translates to:
  /// **'무전 채널 복구 중...'**
  String get asset_loading_reconnectRestoreRadio;

  /// No description provided for @asset_loading_reconnectRescanFrequency.
  ///
  /// In ko, this message translates to:
  /// **'비밀 주파수 재탐색 중...'**
  String get asset_loading_reconnectRescanFrequency;

  /// No description provided for @asset_loading_bugReport.
  ///
  /// In ko, this message translates to:
  /// **'신고서 작성 중...'**
  String get asset_loading_bugReport;

  /// No description provided for @asset_loading_bugReportSubmitReport.
  ///
  /// In ko, this message translates to:
  /// **'본부에 보고서 제출 중...'**
  String get asset_loading_bugReportSubmitReport;

  /// No description provided for @asset_loading_bugReportAttachPhotos.
  ///
  /// In ko, this message translates to:
  /// **'현장 사진 첨부 중...'**
  String get asset_loading_bugReportAttachPhotos;

  /// No description provided for @asset_loading_bugReportAssignCaseNumber.
  ///
  /// In ko, this message translates to:
  /// **'사건 번호 부여 중...'**
  String get asset_loading_bugReportAssignCaseNumber;

  /// No description provided for @asset_loading_bugReportHandToInvestigation.
  ///
  /// In ko, this message translates to:
  /// **'수사반에 인계 중...'**
  String get asset_loading_bugReportHandToInvestigation;

  /// 로딩 화면 이스터에그 힌트 — 홈 화면 캐릭터 변경 (9개 카테고리 공용)
  ///
  /// In ko, this message translates to:
  /// **'홈 화면 캐릭터를 자꾸 누르면 뭔가 변한다는 소문이...'**
  String get asset_loading_easterEggCharacterRumor;

  /// 로딩 화면 이스터에그 힌트 — 홈 화면 캐릭터 변경 (9개 카테고리 공용)
  ///
  /// In ko, this message translates to:
  /// **'캐릭터를 여러 번 두드리면 새로운 모습이 나타난다던데...?'**
  String get asset_loading_easterEggCharacterTap;

  /// 로딩 화면 이스터에그 힌트 — 홈 화면 캐릭터 변경 (9개 카테고리 공용)
  ///
  /// In ko, this message translates to:
  /// **'홈 화면 캐릭터에 숨겨진 비밀이 있다고 한다...'**
  String get asset_loading_easterEggCharacterSecret;

  /// 로딩 화면 이스터에그 힌트 — 설정 화면 숨김 진입 (9개 카테고리 공용)
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_easterEggSettingsTap;

  /// 로딩 화면 이스터에그 힌트 — 앱 버전 탭 (9개 카테고리 공용)
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_easterEggVersionTap;

  /// 로딩 화면 이스터에그 힌트 — 버전 번호 비밀 (9개 카테고리 공용)
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_easterEggVersionSecret;

  /// No description provided for @asset_locationpermission_serviceDisabledTitle.
  ///
  /// In ko, this message translates to:
  /// **'위치 서비스가 꺼져 있어요'**
  String get asset_locationpermission_serviceDisabledTitle;

  /// No description provided for @asset_locationpermission_serviceDisabledHome.
  ///
  /// In ko, this message translates to:
  /// **'게임 중 도둑 위치를 경찰 팀에게 공유하고,\n구역 이탈을 감지하기 위해 위치 정보를 사용해요\n기기 설정에서 위치 서비스를 켜주세요'**
  String get asset_locationpermission_serviceDisabledHome;

  /// No description provided for @asset_locationpermission_serviceDisabledGame.
  ///
  /// In ko, this message translates to:
  /// **'게임에 복귀하려면 위치 서비스를 켜주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_serviceDisabledGame;

  /// No description provided for @asset_locationpermission_serviceDisabledWaitingRoom.
  ///
  /// In ko, this message translates to:
  /// **'게임 참가를 위해 위치 서비스를 켜주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_serviceDisabledWaitingRoom;

  /// No description provided for @asset_locationpermission_permissionDeniedTitle.
  ///
  /// In ko, this message translates to:
  /// **'위치 권한이 필요해요'**
  String get asset_locationpermission_permissionDeniedTitle;

  /// No description provided for @asset_locationpermission_permissionDeniedHome.
  ///
  /// In ko, this message translates to:
  /// **'게임 중 도둑 위치를 경찰 팀에게 공유하고,\n구역 이탈을 감지하기 위해 위치 정보를 사용해요\n위치는 게임 참가자에게만 공유되며,\n게임 종료 시 즉시 중단돼요'**
  String get asset_locationpermission_permissionDeniedHome;

  /// No description provided for @asset_locationpermission_permissionDeniedGame.
  ///
  /// In ko, this message translates to:
  /// **'게임에 복귀하려면 위치 권한을 허용해주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_permissionDeniedGame;

  /// No description provided for @asset_locationpermission_permissionDeniedWaitingRoom.
  ///
  /// In ko, this message translates to:
  /// **'게임 참가를 위해 위치 권한을 허용해주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_permissionDeniedWaitingRoom;

  /// 게임 방 생성 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'게임 방 생성 중 예기치 않은 오류가 생겼어요'**
  String get errorGameRoomCreateUnexpected;

  /// 참여 중인 게임 조회 실패 시 표시되는 예외 메시지
  ///
  /// In ko, this message translates to:
  /// **'참여 중인 게임 조회 중 예기치 않은 오류가 생겼어요'**
  String get errorActiveGameFetchUnexpected;

  /// 게임 설정 — 최대 참가 인원수 표기 (단위: 명)
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String gameSettingMaxPlayers(String count);

  /// 게임 설정 — 라운드 시간 표기 (단위: 분)
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String gameSettingRoundMinutes(int minutes);

  /// 게임 설정 — 위치 공유 주기 표기 (단위: 분)
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String gameSettingLocationShareMinutes(int minutes);

  /// 게임 설정 — 경찰 출동 시작 지연 시간 표기
  ///
  /// In ko, this message translates to:
  /// **'도둑 도망 후 {minutes}분 뒤'**
  String gameSettingPoliceStartDelay(int minutes);

  /// 게임 설정 저장 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'설정 저장에 실패했어요'**
  String get errorSettingsSaveFailed;

  /// 게임 설정 수정 페이지 타이틀
  ///
  /// In ko, this message translates to:
  /// **'설정 수정'**
  String get pageGameSettingsEditTitle;

  /// 저장 진행 중 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'저장 중...'**
  String get buttonSaving;

  /// 공통 — 저장 버튼
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get buttonSave;

  /// 게임 구역 저장 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'영역 저장에 실패했어요'**
  String get errorAreaSaveFailed;

  /// 게임 설정 페이지 타이틀
  ///
  /// In ko, this message translates to:
  /// **'게임 설정'**
  String get pageGameSettingsTitle;

  /// 구역 정보 로드 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'구역 정보를 불러오지 못했어요'**
  String get errorZoneInfoLoadFailed;

  /// 게임 설정 로드 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'설정 정보를 불러오지 못했어요'**
  String get errorSettingsLoadFailed;

  /// 공통 — 플레이그라운드 라벨
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get zonePlayground;

  /// 공통 — 감옥 라벨
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get zoneJail;

  /// 마이페이지 — 프로필 아이콘 선택 섹션 헤더
  ///
  /// In ko, this message translates to:
  /// **'프로필 아이콘'**
  String get mypageProfileIconLabel;

  /// 바텀 네비게이션 — 홈 탭 라벨
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get bottomNavHome;

  /// 바텀 네비게이션 — 커뮤니티 탭 라벨
  ///
  /// In ko, this message translates to:
  /// **'커뮤니티'**
  String get bottomNavCommunity;

  /// 모집글 상세 화면 앱바 제목
  ///
  /// In ko, this message translates to:
  /// **'모집글'**
  String get pageCommunityDetailTitle;

  /// 모집글 상세 — 모임 채팅방에 들어가는 버튼
  ///
  /// In ko, this message translates to:
  /// **'채팅 참여하기'**
  String get communityDetailJoinChat;

  /// 모집글 상세 — 공유 액션 라벨
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get communityDetailShare;

  /// 모집글 상세 — 댓글 섹션 제목 (답글 포함 개수)
  ///
  /// In ko, this message translates to:
  /// **'댓글 {count}'**
  String communityDetailCommentCount(int count);

  /// 댓글 입력창 placeholder
  ///
  /// In ko, this message translates to:
  /// **'댓글을 남겨보세요'**
  String get communityCommentHint;

  /// 답글 입력창 placeholder
  ///
  /// In ko, this message translates to:
  /// **'답글을 남겨보세요'**
  String get communityCommentReplyHint;

  /// 댓글 아래 답글 작성 버튼
  ///
  /// In ko, this message translates to:
  /// **'답글 달기'**
  String get communityCommentReply;

  /// 댓글이 하나도 없을 때 표시
  ///
  /// In ko, this message translates to:
  /// **'첫 댓글을 남겨보세요'**
  String get communityCommentEmpty;

  /// 댓글 작성 시각 — 1분 미만
  ///
  /// In ko, this message translates to:
  /// **'방금'**
  String get communityCommentJustNow;

  /// 댓글 작성 시각 — 1시간 미만
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 전'**
  String communityCommentMinutesAgo(int minutes);

  /// 댓글 작성 시각 — 하루 미만
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 전'**
  String communityCommentHoursAgo(int hours);

  /// 모집글 삭제 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'모집글을 삭제할까요'**
  String get communityDeleteConfirmTitle;

  /// 모집글 삭제 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'삭제하면 되돌릴 수 없어요'**
  String get communityDeleteConfirmMessage;

  /// 비로그인 사용자가 쓰기 동작을 시도했을 때 안내
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요한 기능이에요'**
  String get communityLoginRequiredMessage;

  /// 모집글 더보기 메뉴 — 내 글 수정
  ///
  /// In ko, this message translates to:
  /// **'수정하기'**
  String get communityMenuEdit;

  /// 모집글 더보기 메뉴 — 내 글 삭제
  ///
  /// In ko, this message translates to:
  /// **'삭제하기'**
  String get communityMenuDelete;

  /// 모집글 더보기 메뉴 — 모집중인 글을 마감으로 바꾸기
  ///
  /// In ko, this message translates to:
  /// **'마감하기'**
  String get communityMenuMarkCompleted;

  /// 모집글 더보기 메뉴 — 마감된 글을 모집중으로 되돌리기
  ///
  /// In ko, this message translates to:
  /// **'다시 모집하기'**
  String get communityMenuMarkRecruiting;

  /// 모집글 더보기 메뉴 — 비로그인 사용자에게 보이는 로그인 유도
  ///
  /// In ko, this message translates to:
  /// **'로그인하고 이용하기'**
  String get communityMenuLoginRequired;

  /// 커뮤니티 카드 — 모집 중인 게시글 배지
  ///
  /// In ko, this message translates to:
  /// **'모집중'**
  String get communityStatusRecruiting;

  /// 커뮤니티 카드 — 모집이 끝난 게시글 배지
  ///
  /// In ko, this message translates to:
  /// **'마감'**
  String get communityStatusCompleted;

  /// 커뮤니티 카드 — 모임 날짜가 지나 끝난 게시글 배지
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get communityStatusEnded;

  /// 커뮤니티 카드 — 현재 참여 인원 / 정원
  ///
  /// In ko, this message translates to:
  /// **'{current}/{max}명'**
  String communityHeadcount(int current, int max);

  /// 커뮤니티 카드 — 현재 인원을 백엔드가 아직 주지 않을 때 정원만 표시
  ///
  /// In ko, this message translates to:
  /// **'정원 {max}명'**
  String communityHeadcountMaxOnly(int max);

  /// 커뮤니티 카드 — 모임 일시 표기
  ///
  /// In ko, this message translates to:
  /// **'{month}/{day} ({weekday}) {time}'**
  String communityMeetingAt(
    String month,
    String day,
    String weekday,
    String time,
  );

  /// 커뮤니티 탭 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'커뮤니티'**
  String get pageCommunityTitle;

  /// 커뮤니티 목록이 비어 있을 때 표시되는 안내
  ///
  /// In ko, this message translates to:
  /// **'등록된 모집글이 없어요'**
  String get pageCommunityEmpty;

  /// 커뮤니티 범위 필터 — 전체 글
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get communityScopeAll;

  /// 커뮤니티 범위 필터 — 내 주변 글
  ///
  /// In ko, this message translates to:
  /// **'우리 동네'**
  String get communityScopeNearby;

  /// 커뮤니티 범위 필터 — 내가 참여하는 모임
  ///
  /// In ko, this message translates to:
  /// **'내 모임'**
  String get communityScopeMine;

  /// 커뮤니티 목록 정렬 — 최신순
  ///
  /// In ko, this message translates to:
  /// **'최신순'**
  String get communitySortLatest;

  /// 커뮤니티 목록 정렬 — 인기순
  ///
  /// In ko, this message translates to:
  /// **'인기순'**
  String get communitySortPopular;

  /// 커뮤니티 목록 정렬 — 거리순 (현재 위치 기준)
  ///
  /// In ko, this message translates to:
  /// **'거리순'**
  String get communitySortDistance;

  /// 커뮤니티 목록 정렬 — 마감 임박순
  ///
  /// In ko, this message translates to:
  /// **'마감 임박순'**
  String get communitySortDeadline;

  /// 정렬 선택 바텀시트 접근성 라벨
  ///
  /// In ko, this message translates to:
  /// **'정렬 기준'**
  String get communitySortSheetTitle;

  /// 커뮤니티 정렬 — 거리순 선택 시 위치 권한을 거부했을 때
  ///
  /// In ko, this message translates to:
  /// **'위치 권한이 있어야 거리순으로 볼 수 있어요'**
  String get communitySortNeedsLocation;

  /// 커뮤니티 정렬 — 위치 권한이 영구 거부돼 다시 물을 수 없을 때
  ///
  /// In ko, this message translates to:
  /// **'설정에서 위치 권한을 켜주세요'**
  String get communitySortLocationDenied;

  /// 커뮤니티 목록 하단 모집글 작성 버튼 (작성 화면 제목 겸용)
  ///
  /// In ko, this message translates to:
  /// **'모집글 작성'**
  String get communityCreatePost;

  /// 모집글 수정 화면 제목 (작성 화면을 수정 모드로 열었을 때)
  ///
  /// In ko, this message translates to:
  /// **'모집글 수정'**
  String get communityEditPost;

  /// 사라진 모집글 상세에서 목록으로 나가는 버튼 — 재시도가 무의미한 경우라 '다시 시도' 대신 쓴다
  ///
  /// In ko, this message translates to:
  /// **'목록으로 돌아가기'**
  String get communityBackToList;

  /// 모집글 작성 — 제목 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get communityCreateLabelTitle;

  /// 모집글 작성 — 제목 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'퇴근하고 한 판! 초보 환영'**
  String get communityCreateHintTitle;

  /// 모집글 작성 — 설명 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get communityCreateLabelContent;

  /// 모집글 작성 — 설명 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'규칙, 준비물, 뒤풀이 여부 등을 적어주세요'**
  String get communityCreateHintContent;

  /// 모집글 작성 — 날짜 섹션 라벨 (날짜 선택 바텀시트 제목 겸용)
  ///
  /// In ko, this message translates to:
  /// **'날짜'**
  String get communityCreateLabelDate;

  /// 모집글 작성 — 날짜 미선택 상태 힌트
  ///
  /// In ko, this message translates to:
  /// **'모임 날짜를 골라주세요'**
  String get communityCreateHintDate;

  /// 모집글 작성 — 선택된 모임 일시 표기 (26.08.29 (목) 14:30)
  ///
  /// In ko, this message translates to:
  /// **'{year}.{month}.{day} ({weekday}) {time}'**
  String communityCreateDateValue(
    String year,
    String month,
    String day,
    String weekday,
    String time,
  );

  /// 날짜 선택 바텀시트 제목
  ///
  /// In ko, this message translates to:
  /// **'모임 날짜 및 시간'**
  String get communityDateSheetTitle;

  /// 날짜 선택 바텀시트 — 시간 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get communityDateSheetRowTime;

  /// 날짜 선택 바텀시트 — 날짜 행의 값 (26.08.29 목)
  ///
  /// In ko, this message translates to:
  /// **'{year}.{month}.{day} {weekday}'**
  String communityDateSheetRowDateValue(
    String year,
    String month,
    String day,
    String weekday,
  );

  /// 모집글 작성 — 장소 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'장소'**
  String get communityCreateLabelLocation;

  /// 모집글 작성 — 만나는 곳(placeName) 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'상세주소를 입력해주세요 ex) 어린이대공원 정문'**
  String get communityCreateHintLocation;

  /// 모집글 작성 - 기본 주소 칸(읽기 전용)의 빈 상태 힌트. 값은 GET /api/community-posts/address가 채우며 지도로만 바뀐다
  ///
  /// In ko, this message translates to:
  /// **'지도에서 위치를 고르면 채워져요'**
  String get communityCreateHintAddress;

  /// 모집글 작성 — 좌표를 아직 안 고른 상태의 지도 카드 안내
  ///
  /// In ko, this message translates to:
  /// **'지도에서 위치를 골라주세요'**
  String get communityCreateHintPickLocation;

  /// 모집글 상세 — 장소 텍스트를 탭해 클립보드에 담았을 때의 안내
  ///
  /// In ko, this message translates to:
  /// **'장소를 복사했어요'**
  String get communityLocationCopied;

  /// 장소 선택 지도 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'장소 선택'**
  String get communityLocationPickerTitle;

  /// 장소 선택 지도 화면 — 현재 핀 위치를 확정하는 버튼
  ///
  /// In ko, this message translates to:
  /// **'이 위치로 선택'**
  String get communityLocationPickerConfirm;

  /// 장소 선택 지도 화면 — 좌표 주소를 조회하는 동안의 안내
  ///
  /// In ko, this message translates to:
  /// **'주소를 확인하는 중이에요'**
  String get communityLocationPickerLoading;

  /// 장소 선택 지도 화면 — 표시할 주소가 없을 때의 안내
  ///
  /// In ko, this message translates to:
  /// **'지도를 눌러 만날 곳을 정해요'**
  String get communityLocationPickerHint;

  /// 장소 선택 지도 화면 — 좌표 주소 조회가 실패했을 때의 안내
  ///
  /// In ko, this message translates to:
  /// **'주소를 찾을 수 없는 곳이에요. 다른 곳을 골라주세요'**
  String get communityLocationPickerNotFound;

  /// 모집글 등록 API 대기 중 로딩 화면 제목 (AppLoading.showMessage)
  ///
  /// In ko, this message translates to:
  /// **'모집글 올리는 중...'**
  String get communityCreateLoading;

  /// No description provided for @communityCreateLoadingSub.
  ///
  /// In ko, this message translates to:
  /// **'모집글을 등록하는 중이에요. 잠시만 기다려주세요'**
  String get communityCreateLoadingSub;

  /// 모집글 수정 API 대기 중 로딩 화면 제목 (AppLoading.showMessage)
  ///
  /// In ko, this message translates to:
  /// **'모집글 고치는 중...'**
  String get communityEditLoading;

  /// No description provided for @communityEditLoadingSub.
  ///
  /// In ko, this message translates to:
  /// **'모집글을 수정하는 중이에요. 잠시만 기다려주세요'**
  String get communityEditLoadingSub;

  /// 모집글 작성 — 모집 인원 섹션 라벨 (인원 선택 바텀시트 제목 겸용)
  ///
  /// In ko, this message translates to:
  /// **'모집 인원'**
  String get communityCreateLabelHeadcount;

  /// 모집글 작성 — 선택된 모집 인원
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String communityHeadcountValue(int count);

  /// 인원 선택 바텀시트 — 인원을 한 번에 더하는 칩
  ///
  /// In ko, this message translates to:
  /// **'+ {count}명'**
  String communityHeadcountQuickAdd(int count);

  /// 모집글 작성 — 인원 감소 버튼 접근성 라벨
  ///
  /// In ko, this message translates to:
  /// **'인원 줄이기'**
  String get communityHeadcountDecrease;

  /// 모집글 작성 — 인원 증가 버튼 접근성 라벨
  ///
  /// In ko, this message translates to:
  /// **'인원 늘리기'**
  String get communityHeadcountIncrease;

  /// 요일 단축 라벨 — 월요일
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get weekdayMon;

  /// 요일 단축 라벨 — 화요일
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get weekdayTue;

  /// 요일 단축 라벨 — 수요일
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get weekdayWed;

  /// 요일 단축 라벨 — 목요일
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get weekdayThu;

  /// 요일 단축 라벨 — 금요일
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get weekdayFri;

  /// 요일 단축 라벨 — 토요일
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get weekdaySat;

  /// 요일 단축 라벨 — 일요일
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get weekdaySun;

  /// 바텀 네비게이션 — 마이페이지 탭 라벨
  ///
  /// In ko, this message translates to:
  /// **'마이페이지'**
  String get bottomNavMyPage;

  /// 아직 구현되지 않은 탭(커뮤니티·마이페이지)의 안내 문구
  ///
  /// In ko, this message translates to:
  /// **'준비 중이에요'**
  String get comingSoonMessage;

  /// 홈 페이지 — 방 만들기/참여하기 버튼 통합 안내
  ///
  /// In ko, this message translates to:
  /// **'게임을 만들거나 초대 코드로 참가할 수 있어요'**
  String get homePageGameButtonsHint;

  /// 홈 페이지 — 원격 이미지 배너 접근성 라벨
  ///
  /// In ko, this message translates to:
  /// **'이벤트 배너'**
  String get homeBannerSemanticsLabel;

  /// 홈 진입 시 표시되는 주변 안전 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'주변을 확인하며 이용해 주세요'**
  String get dialogSafetyWarningTitle;

  /// 홈 진입 시 표시되는 주변 안전 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'게임 중 화면에만 집중하면 위험할 수 있어요\n도로 및 보행 환경을 확인하며 안전하게 이용해 주세요'**
  String get dialogSafetyWarningMessage;

  /// 주변 안전 확인 다이얼로그의 동의 버튼 ('확인했어요!')
  ///
  /// In ko, this message translates to:
  /// **'확인했어요!'**
  String get buttonAcknowledgedSurroundings;

  /// 홈 페이지 — 안내 다이얼로그 오늘 숨김 옵션
  ///
  /// In ko, this message translates to:
  /// **'오늘은 다시 보지 않기'**
  String get homePageDontShowToday;

  /// 이미 다른 게임에 참가 중일 때 안내
  ///
  /// In ko, this message translates to:
  /// **'이미 참가 중인 게임이 있어요'**
  String get errorAlreadyInGame;

  /// 게임 상태를 식별할 수 없을 때 표시
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 게임 상태예요'**
  String get errorUnknownGameState;

  /// 기기 설정 화면으로 이동하는 버튼
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get buttonGoToSettings;

  /// 방 참여 실패 — 초대 코드 확인 안내
  ///
  /// In ko, this message translates to:
  /// **'참여에 실패했어요. 초대 코드를 확인해주세요'**
  String get errorJoinFailedCheckCode;

  /// 방 참여 실패 — 일반 재시도 안내
  ///
  /// In ko, this message translates to:
  /// **'참여에 실패했어요. 다시 시도해주세요'**
  String get errorJoinRetry;

  /// 방 참여 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'방 참여하기'**
  String get dialogJoinRoomTitle;

  /// 초대 코드 입력 필드 placeholder
  ///
  /// In ko, this message translates to:
  /// **'참여코드를 입력하세요'**
  String get fieldInviteCodeHint;

  /// 초대코드 QR 스캔 안내 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'초대코드 QR을 스캔하세요'**
  String get dialogScanInviteQrTitle;

  /// 방 참여 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'참여하기'**
  String get buttonJoin;

  /// 앱 브랜드명 — ko: 한글 '경찰과도둑', en: 영문 'Cops and Robbers', ja: 일본 현지명 'ケイドロ'
  ///
  /// In ko, this message translates to:
  /// **'경찰과도둑'**
  String get appBrandName;

  /// 미구현 기능 안내 메시지
  ///
  /// In ko, this message translates to:
  /// **'준비 중이에요'**
  String get messageComingSoon;

  /// 홈 페이지 — 메인 환영 메시지
  ///
  /// In ko, this message translates to:
  /// **'누가 내 치즈\n훔쳐갔어!!!!🧀'**
  String get homePageWelcomeMessage;

  /// 공통 — 게임 생성 버튼
  ///
  /// In ko, this message translates to:
  /// **'게임 생성하기'**
  String get buttonCreateRoom;

  /// 공통 — 게임 참여 버튼
  ///
  /// In ko, this message translates to:
  /// **'게임 참여하기'**
  String get buttonJoinRoom;

  /// 방 생성 — 구역 설정 단계 안내
  ///
  /// In ko, this message translates to:
  /// **'게임할 구역을 설정해요.\n먼저 플레이그라운드를 지정하세요'**
  String get sessionCreationStepZoneSubtitle;

  /// 방 생성 — 규칙 설정 단계 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙을 정해요\n숫자를 탭하면 직접 입력할 수 있어요'**
  String get sessionCreationStepRulesSubtitle;

  /// 방 생성 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 방 생성에 실패했어요. 다시 시도해주세요'**
  String get errorCreateRoomFailed;

  /// 방 생성 — 구역 미설정 시 안내
  ///
  /// In ko, this message translates to:
  /// **'구역 선택을 먼저 설정할까요?'**
  String get sessionCreationZoneFirstQuestion;

  /// 방 생성 — 인원 설정 단계 타이틀
  ///
  /// In ko, this message translates to:
  /// **'인원을 설정해요'**
  String get sessionCreationStepParticipantsTitle;

  /// 방 생성 — 기본 정보 설정 단계 타이틀
  ///
  /// In ko, this message translates to:
  /// **'기본 정보를 설정해요'**
  String get sessionCreationStepBasicTitle;

  /// 방 생성 — 최종 설정 확인 단계 타이틀
  ///
  /// In ko, this message translates to:
  /// **'최종 설정을 확인해요'**
  String get sessionCreationStepReviewTitle;

  /// 방 생성 — 구역 설정 단계 보조 설명
  ///
  /// In ko, this message translates to:
  /// **'게임에 필요한 구역을 설정해요'**
  String get sessionCreationStepZoneIntro;

  /// 방 생성 — 인원 설정 단계 보조 설명
  ///
  /// In ko, this message translates to:
  /// **'최소 2명부터 게임 진행이 가능해요'**
  String get sessionCreationStepParticipantsHint;

  /// 방 생성 — 기본 정보 단계 보조 설명
  ///
  /// In ko, this message translates to:
  /// **'게임을 진행할 때, 꼭 필요한 정보들이에요'**
  String get sessionCreationStepBasicHint;

  /// 방 생성 — 리뷰 단계 보조 설명
  ///
  /// In ko, this message translates to:
  /// **'방 생성 전 마지막으로 설정을 확인할까요?'**
  String get sessionCreationStepReviewHint;

  /// 공통 — 다음 단계 버튼
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get buttonNext;

  /// 구역 미설정 상태에서 다음 단계 진입 시 안내
  ///
  /// In ko, this message translates to:
  /// **'구역 정보를 먼저 설정해주세요'**
  String get errorZoneNotConfigured;

  /// 플레이그라운드 설정 — 반경 입력 안내
  ///
  /// In ko, this message translates to:
  /// **'여기를 누르면 반경을 직접 입력할 수 있어요'**
  String get setupPlaygroundRadiusInputHint;

  /// 플레이그라운드 설정 — 화면 안내문
  ///
  /// In ko, this message translates to:
  /// **'게임이 진행될 전체 구역의 크기를 설정해요'**
  String get setupPlaygroundDescription;

  /// 공통 — 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get buttonDone;

  /// 감옥 설정 — 화면 안내문
  ///
  /// In ko, this message translates to:
  /// **'도둑을 잡아둘 감옥의 위치와 크기를 설정해요'**
  String get setupPrisonDescription;

  /// 감옥 설정 시 플레이그라운드 미설정 안내
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드를 먼저 설정해주세요'**
  String get errorPlaygroundFirst;

  /// 감옥 설정 시 플레이그라운드 범위 이탈 안내
  ///
  /// In ko, this message translates to:
  /// **'감옥이 플레이그라운드 범위를 벗어났어요'**
  String get errorJailOutsidePlayground;

  /// 더미 닉네임 — 곰 (튜토리얼/스켈레톤용)
  ///
  /// In ko, this message translates to:
  /// **'포근포근곰...'**
  String get dummyNicknameBear;

  /// 방 참여 불가 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'방에 참여할 수 없어요'**
  String get errorCannotJoinRoom;

  /// 권한 없음 — 해당 게임 참가자가 아닐 때 안내
  ///
  /// In ko, this message translates to:
  /// **'해당 게임에 참가하지 않은 사용자예요'**
  String get errorNotInGame;

  /// 대기실 튜토리얼 — 팀 변경 버튼 안내
  ///
  /// In ko, this message translates to:
  /// **'이 버튼을 눌러 다른 팀으로 이동할 수 있어요'**
  String get waitingRoomTutorialTeamSwitch;

  /// 대기실 튜토리얼 — 초대 코드 공유 안내
  ///
  /// In ko, this message translates to:
  /// **'친구에게 초대 코드를 공유할 수 있어요'**
  String get waitingRoomTutorialInvite;

  /// 대기실 튜토리얼 — 설정 확인 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 설정을 확인할 수 있어요'**
  String get waitingRoomTutorialSettings;

  /// 대기실 튜토리얼 — 준비 버튼 안내
  ///
  /// In ko, this message translates to:
  /// **'준비가 되면 눌러주세요'**
  String get waitingRoomTutorialReady;

  /// 인게임 미리보기 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'인게임 화면 미리 보기'**
  String get dialogInGamePreviewTitle;

  /// 대기실에서 튜토리얼 진행을 권유하는 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'게임이 시작되면 어떻게 동작하는지\n한 번 확인하고 시작해볼까요?'**
  String get dialogTutorialPromptMessage;

  /// 인게임 튜토리얼 미리보기로 이동 버튼
  ///
  /// In ko, this message translates to:
  /// **'보러 가기'**
  String get buttonViewInGamePreview;

  /// 강퇴 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'{nickname}님을 내보낼까요?'**
  String dialogKickConfirmTitle(String nickname);

  /// 강퇴 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'강퇴된 유저는 방에서 즉시 내보내져요\n다시 방에 참가하려면 초대코드를 입력해야 해요'**
  String get dialogKickConfirmMessage;

  /// 참가자 강퇴 확정 버튼
  ///
  /// In ko, this message translates to:
  /// **'내보내기'**
  String get buttonKick;

  /// 참가자 강퇴 실패 시 표시되는 에러 메시지
  ///
  /// In ko, this message translates to:
  /// **'강퇴 처리 중 오류가 생겼어요'**
  String get errorKickFailed;

  /// 강퇴 알림 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'방에서 내보내졌어요'**
  String get dialogKickedFromRoomTitle;

  /// 강퇴 알림 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'다시 참가하려면 초대코드를 입력해야 해요'**
  String get dialogKickedFromRoomMessage;

  /// 강퇴된 멤버 알림 (placeholder: 강퇴된 닉네임)
  ///
  /// In ko, this message translates to:
  /// **'{kickedNickname}님이 내보내졌어요'**
  String messageMemberKicked(String kickedNickname);

  /// 대기실 — 팀 변경 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'팀 변경에 실패했어요'**
  String get errorTeamChangeFailed;

  /// 대기실 — 준비 상태 변경 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'준비 상태 변경에 실패했어요'**
  String get errorReadyChangeFailed;

  /// 대기실 — 게임 시작 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 시작에 실패했어요'**
  String get errorGameStartFailed;

  /// 대기실 퇴장 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'방을 나갈까요?'**
  String get dialogLeaveRoomTitle;

  /// 대기실 퇴장 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'나가면 다시 초대코드를 입력해야 해요'**
  String get dialogLeaveRoomMessage;

  /// 대기실 퇴장 확정 버튼
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get buttonLeave;

  /// 대기실 — 퇴장 처리 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'퇴장 처리 중 오류가 생겼어요'**
  String get errorLeaveRoomFailed;

  /// 초대코드 생성 완료 알림 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'초대코드를 생성했어요'**
  String get dialogInviteCodeCreatedTitle;

  /// 초대코드 공유 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'친구에게 코드를 공유하고 게임에 참여해 보세요!'**
  String get dialogInviteCodeShareMessage;

  /// 초대코드 클립보드 복사 완료 안내
  ///
  /// In ko, this message translates to:
  /// **'코드를 복사했어요'**
  String get messageCodeCopied;

  /// 공유 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'공유하기'**
  String get buttonShare;

  /// 공통 — 게임 시작 버튼
  ///
  /// In ko, this message translates to:
  /// **'게임 시작'**
  String get buttonStartGame;

  /// 대기실 — 준비 완료 버튼
  ///
  /// In ko, this message translates to:
  /// **'준비 완료'**
  String get buttonReadyDone;

  /// 대기실 — 준비 버튼
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get buttonReady;

  /// 구역 미리보기 페이지 타이틀
  ///
  /// In ko, this message translates to:
  /// **'게임 구역'**
  String get pageZonePreviewTitle;

  /// 구역 미리보기 — 본문 안내
  ///
  /// In ko, this message translates to:
  /// **'현재 설정된 게임 구역이에요'**
  String get zonePreviewSubtitle;

  /// 더미 닉네임 — 너구리 (튜토리얼/스켈레톤용)
  ///
  /// In ko, this message translates to:
  /// **'오동통 너구리'**
  String get dummyNicknameRaccoon;

  /// 닉네임 누락 시 기본 표시 라벨
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get defaultNicknameLabel;

  /// 게임 규칙 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙'**
  String get titleGameRules;

  /// 게임 규칙 다이얼로그의 '인게임 보기' 버튼
  ///
  /// In ko, this message translates to:
  /// **'인게임 보기'**
  String get buttonViewInGame;

  /// 게임 규칙 — 경찰 승리 조건 도입부
  ///
  /// In ko, this message translates to:
  /// **'경찰은 모든 도둑을 잡아서'**
  String get gameRulesCopGoalPrefix;

  /// 게임 규칙 — 경찰 승리 조건 강조부
  ///
  /// In ko, this message translates to:
  /// **'체포하면,'**
  String get gameRulesCopGoalSuffix;

  /// 게임 규칙 — 도둑 승리 조건 도입부 (개행 포함)
  ///
  /// In ko, this message translates to:
  /// **'\n도둑은'**
  String get gameRulesRobberGoalPrefix;

  /// 게임 규칙 — 도둑 승리 조건 본문
  ///
  /// In ko, this message translates to:
  /// **'제한 시간이 끝날 때까지 버티면'**
  String get gameRulesRobberGoalCondition;

  /// 게임 규칙 — 승리 조건 종결부
  ///
  /// In ko, this message translates to:
  /// **'승리해요'**
  String get gameRulesWinSuffix;

  /// 게임 규칙 — 위치 공유 1줄 (한국어 어순 1행)
  ///
  /// In ko, this message translates to:
  /// **'도둑팀의 위치는'**
  String get gameRulesLocationShareLine1;

  /// 게임 규칙 — 위치 공유 2줄 (주기 강조)
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분마다'**
  String gameRulesLocationShareLine2(int minutes);

  /// 게임 규칙 — 위치 공유 3줄 (한국어 어순 종결)
  ///
  /// In ko, this message translates to:
  /// **'경찰팀에게 공유돼요'**
  String get gameRulesLocationShareLine3;

  /// 게임 규칙 — 구역 이탈 금지 1줄
  ///
  /// In ko, this message translates to:
  /// **'지정된 게임 구역에서 벗어나면 안 돼요'**
  String get gameRulesZoneRuleLine1;

  /// 게임 규칙 — 구역 이탈 금지 2줄 (개행 + 화살표 포함)
  ///
  /// In ko, this message translates to:
  /// **'\n→ 구역 밖으로 나가면 화면이 잠겨요'**
  String get gameRulesZoneRuleLine2;

  /// No description provided for @dialogstep0SelectAreaContentTitle.
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get dialogstep0SelectAreaContentTitle;

  /// No description provided for @dialogstep0SelectAreaContentTitle5bc0.
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get dialogstep0SelectAreaContentTitle5bc0;

  /// No description provided for @fieldstep1ParticipantSettingsContentLabel.
  ///
  /// In ko, this message translates to:
  /// **'최대 참가자'**
  String get fieldstep1ParticipantSettingsContentLabel;

  /// 공통 — 인원수 단위 (명)
  ///
  /// In ko, this message translates to:
  /// **'명'**
  String get unitPerson;

  /// No description provided for @fieldstep2GameSettingsContentLabel.
  ///
  /// In ko, this message translates to:
  /// **'라운드 제한 시간'**
  String get fieldstep2GameSettingsContentLabel;

  /// 공통 — 시간 단위 (분)
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get unitMinutes;

  /// No description provided for @fieldstep2GameSettingsContentLabel5ab2.
  ///
  /// In ko, this message translates to:
  /// **'도둑 위치 공유 간격'**
  String get fieldstep2GameSettingsContentLabel5ab2;

  /// 게임 설정 — 위치 공유 비활성 경고
  ///
  /// In ko, this message translates to:
  /// **'도둑의 위치가 공유되지 않아요!'**
  String get gameSettingNoLocationShareWarning;

  /// No description provided for @fieldstep2GameSettingsContentLabelCe3b.
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동 시간'**
  String get fieldstep2GameSettingsContentLabelCe3b;

  /// 게임 설정 — 경찰 출동 시간 prefix
  ///
  /// In ko, this message translates to:
  /// **'도둑 도망 후'**
  String get gameSettingPoliceStartPrefix;

  /// 게임 설정 — 경찰 출동 시간 suffix
  ///
  /// In ko, this message translates to:
  /// **'뒤'**
  String get gameSettingPoliceStartSuffix;

  /// 대기실 설정 카드 섹션 타이틀
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get sectionTitleSettings;

  /// 대기실 설정 카드의 참여 인원 라벨
  ///
  /// In ko, this message translates to:
  /// **'참여 인원'**
  String get labelParticipantCount;

  /// 게임 설정 — 라운드 제한 시간 라벨
  ///
  /// In ko, this message translates to:
  /// **'라운드 제한 시간'**
  String get fieldRoundTimeLimit;

  /// 게임 설정 — 위치 공유 간격 라벨
  ///
  /// In ko, this message translates to:
  /// **'위치 공유 간격'**
  String get fieldLocationShareInterval;

  /// 게임 설정 — 경찰 출동 시간 라벨
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동 시간'**
  String get fieldPoliceDispatchTime;

  /// 팀 섹션 — 현재 인원수 표기
  ///
  /// In ko, this message translates to:
  /// **'현재 {count}명'**
  String teamSectionCurrentCount(int count);

  /// 대기실 구역 카드 섹션 타이틀
  ///
  /// In ko, this message translates to:
  /// **'구역'**
  String get sectionTitleZone;

  /// 로그아웃 처리 중 일반 오류 안내
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 중 오류가 생겼어요'**
  String get errorLogoutGeneric;

  /// Firebase 인증 — 사용자 정보 조회 실패
  ///
  /// In ko, this message translates to:
  /// **'로그인 정보를 가져올 수 없어요. 다시 시도해주세요'**
  String get errorAuthUserNotFound;

  /// Firebase 인증 — 토큰 발급 실패
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했어요. 다시 시도해주세요'**
  String get errorAuthTokenIssueFailed;

  /// Firebase 인증 — 토큰 검증 실패
  ///
  /// In ko, this message translates to:
  /// **'로그인 정보가 만료됐어요. 다시 로그인해주세요'**
  String get errorAuthTokenValidationFailed;

  /// Firebase 인증 — 잘못된 인증 정보
  ///
  /// In ko, this message translates to:
  /// **'잘못된 인증 정보예요'**
  String get errorAuthInvalidCredential;

  /// Firebase 인증 — 비활성화된 계정
  ///
  /// In ko, this message translates to:
  /// **'비활성화된 계정이에요'**
  String get errorAuthAccountDisabled;

  /// Firebase 인증 — 요청 과다 (rate limit)
  ///
  /// In ko, this message translates to:
  /// **'요청이 너무 많아요. 잠시 후 다시 시도해주세요'**
  String get errorAuthTooManyRequests;

  /// Firebase 인증 — 비활성화된 로그인 방법
  ///
  /// In ko, this message translates to:
  /// **'이 로그인 방법은 현재 사용할 수 없어요'**
  String get errorAuthSignInMethodUnavailable;

  /// Firebase 인증 — 설정 오류 (API 키 등)
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorAuthFirebaseConfig;

  /// Firebase 인증 — 내부 오류
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorAuthFirebaseInternal;

  /// Firebase 인증 — 특정 provider 로그인 실패 (Google/Apple 등)
  ///
  /// In ko, this message translates to:
  /// **'{provider} 로그인에 실패했어요. 다시 시도해주세요'**
  String errorAuthProviderLoginFailed(String provider);

  /// Firebase 인증 — 일반 로그인 실패 (provider 미지정)
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했어요. 다시 시도해주세요'**
  String get errorAuthLoginFailed;

  /// 마케팅 정보 수신 동의 링크 라벨
  ///
  /// In ko, this message translates to:
  /// **'마케팅 정보 수신'**
  String get linkMarketingConsent;

  /// 약관 동의 페이지 — 동의 후 시작 버튼
  ///
  /// In ko, this message translates to:
  /// **'동의하고 시작하기'**
  String get agreementPageAgreeButton;

  /// 약관 동의 페이지 — 본문 타이틀
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용을 위해\n약관에 동의해주세요'**
  String get agreementPageTitle;

  /// 약관 동의 페이지 — 필수 약관 안내
  ///
  /// In ko, this message translates to:
  /// **'필수 약관에 모두 동의해야 서비스를 이용하실 수 있어요'**
  String get agreementPageRequiredNotice;

  /// 네트워크 미연결 시 표시되는 안내 (약관 동의/스플래시 등 공용)
  ///
  /// In ko, this message translates to:
  /// **'아직 네트워크에 연결되지 않았어요'**
  String get errorNetworkNotConnected;

  /// 필수 약관 미동의 안내
  ///
  /// In ko, this message translates to:
  /// **'필수 약관에 모두 동의해주세요'**
  String get errorRequiredAgreementsMissing;

  /// 회원 탈퇴 완료 토스트
  ///
  /// In ko, this message translates to:
  /// **'회원탈퇴를 완료했어요'**
  String get messageAccountDeleted;

  /// 만 14세 이상 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'만 14세 이상이신가요?'**
  String get dialogAge14ConfirmTitle;

  /// 만 14세 이상 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'경찰과 도둑은 만 14세 미만 회원가입이 불가능해요.\n해당 정보는 가입 금지 확인 용도로만 사용하고 있어요'**
  String get dialogAge14ConfirmMessage;

  /// 로그인 처리 중 발생한 일반 오류
  ///
  /// In ko, this message translates to:
  /// **'로그인 중 오류가 생겼어요'**
  String get errorLoginGeneric;

  /// Apple 로그인 전용 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'Apple 로그인 중 오류가 생겼어요'**
  String get errorAppleLoginFailed;

  /// 만 14세 미만 가입 차단 안내
  ///
  /// In ko, this message translates to:
  /// **'만 14세 미만은 서비스를 이용할 수 없어요'**
  String get errorAgeRestrictionUnder14;

  /// 로그인 페이지 로고 아래 표시되는 앱 한 줄 소개 카피
  ///
  /// In ko, this message translates to:
  /// **'실시간 GPS 기반 오프라인 추격 레이스'**
  String get loginPageTagline;

  /// 로그인 페이지 약관 안내 접두사 (예: '로그인 시 ~ 에 동의합니다')
  ///
  /// In ko, this message translates to:
  /// **'로그인 시'**
  String get loginPageAgreementPrefix;

  /// 공통 — 개인정보 처리방침 링크 텍스트
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get linkPrivacyPolicy;

  /// 공통 — 이용약관 링크 텍스트
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get linkTermsOfService;

  /// 공통 — 위치정보 이용약관 링크 텍스트
  ///
  /// In ko, this message translates to:
  /// **'위치정보 이용약관'**
  String get linkLocationTerms;

  /// 로그인 페이지 약관 안내 접미사
  ///
  /// In ko, this message translates to:
  /// **'에 동의해요'**
  String get loginPageAgreementSuffix;

  /// 닉네임 저장 완료 토스트
  ///
  /// In ko, this message translates to:
  /// **'닉네임이 저장되었어요'**
  String get messageNicknameSaved;

  /// 닉네임 설정 페이지 — 메인 타이틀
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 설정해요'**
  String get nicknameSetupTitle;

  /// 닉네임 설정 페이지 — 보조 안내문
  ///
  /// In ko, this message translates to:
  /// **'서비스 내에서 계속 사용될 닉네임이에요\n1~10글자로 생성할 수 있어요'**
  String get nicknameSetupSubtitle;

  /// 공통 — 닉네임 입력 필드 placeholder
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 입력하세요'**
  String get fieldNicknameHint;

  /// 닉네임 중복 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'중복 확인'**
  String get buttonCheckNicknameDuplicate;

  /// 닉네임 검증 — 글자 수 부족
  ///
  /// In ko, this message translates to:
  /// **'1글자 미만의 닉네임은 사용할 수 없어요'**
  String get errorNicknameTooShort;

  /// 닉네임 검증 — 이미 사용 중
  ///
  /// In ko, this message translates to:
  /// **'중복된 닉네임이에요. 다른 닉네임을 입력하세요'**
  String get errorNicknameDuplicated;

  /// 닉네임 검증 — 사용 가능
  ///
  /// In ko, this message translates to:
  /// **'사용 가능한 닉네임이에요'**
  String get nicknameAvailable;

  /// 스플래시 — 자동 로그인 진행 안내
  ///
  /// In ko, this message translates to:
  /// **'다시 현장으로 복귀 중...'**
  String get splashReturningToScene;

  /// 네트워크 연결 실패 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결 실패'**
  String get dialogNetworkConnectionFailedTitle;

  /// 스플래시 — 오프라인 다이얼로그 본문 (스플래시 화면 본문 splashOfflineMessage와 별개)
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결을 확인한 후\n다시 시도해주세요'**
  String get dialogSplashOfflineMessage;

  /// 스플래시 — 대기 안내
  ///
  /// In ko, this message translates to:
  /// **'잠시만 기다려주세요'**
  String get splashPleaseWait;

  /// 스플래시 — 제작 크레딧 태그라인
  ///
  /// In ko, this message translates to:
  /// **'by 동심지키미'**
  String get splashCreditTag;

  /// 스플래시 — 오프라인 상태 타이틀
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결이 필요해요'**
  String get splashOfflineTitle;

  /// 스플래시 — 오프라인 상태 본문
  ///
  /// In ko, this message translates to:
  /// **'연결 상태를 확인한 후\n다시 시도해주세요'**
  String get splashOfflineMessage;

  /// 원인을 특정할 수 없는 일반 오류 메시지 (auth fallback 등)
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 생겼어요'**
  String get errorUnknown;

  /// 로그아웃 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'로그아웃에 실패했어요'**
  String get errorLogoutFailed;

  /// 약관 — 전체 동의 체크박스 라벨
  ///
  /// In ko, this message translates to:
  /// **'전체 동의'**
  String get agreementAllCheckboxLabel;

  /// 약관 항목 — 필수 태그
  ///
  /// In ko, this message translates to:
  /// **'[필수]'**
  String get agreementItemRequiredTag;

  /// 약관 항목 — 선택 태그
  ///
  /// In ko, this message translates to:
  /// **'[선택]'**
  String get agreementItemOptionalTag;

  /// 게임 시작 후 도둑 도주 시작 알림 배너
  ///
  /// In ko, this message translates to:
  /// **'도둑이 도망치는 중이에요!'**
  String get gameRobberOnTheRunBanner;

  /// 게임 종료 시 화면 상단에 표시되는 배너 타이틀
  ///
  /// In ko, this message translates to:
  /// **'게임 종료!'**
  String get gameOverBannerTitle;

  /// 게임 종료 사유 — 도둑 전원 체포로 종료
  ///
  /// In ko, this message translates to:
  /// **'도둑이 모두 체포됐어요!'**
  String get gameOverReasonAllArrested;

  /// 게임 종료 사유 — 제한 시간 만료
  ///
  /// In ko, this message translates to:
  /// **'제한 시간이 끝났어요!'**
  String get gameOverReasonTimeUp;

  /// 게임 종료 사유 — 경찰 전원 퇴장(몰수)으로 도둑 승리
  ///
  /// In ko, this message translates to:
  /// **'경찰이 모두 퇴장했어요!'**
  String get gameOverReasonPoliceForfeited;

  /// 게임 종료 사유 — 도둑 전원 퇴장(몰수)으로 경찰 승리
  ///
  /// In ko, this message translates to:
  /// **'도둑이 모두 퇴장했어요!'**
  String get gameOverReasonRobberForfeited;

  /// GAME_OVER 소켓 이벤트 유실 등으로 승패/통계 정보를 복구할 수 없을 때 표시하는 중립 종료 메시지
  ///
  /// In ko, this message translates to:
  /// **'게임이 끝났어요'**
  String get gameOverFallbackMessage;

  /// 경찰 팀 라벨 (팀명)
  ///
  /// In ko, this message translates to:
  /// **'경찰팀'**
  String get gameTeamCop;

  /// 도둑 팀 라벨 (팀명)
  ///
  /// In ko, this message translates to:
  /// **'도둑팀'**
  String get gameTeamRobber;

  /// 게임 결과 — 승리
  ///
  /// In ko, this message translates to:
  /// **'승리'**
  String get gameResultWin;

  /// 게임 결과 — 패배
  ///
  /// In ko, this message translates to:
  /// **'패배'**
  String get gameResultLose;

  /// 게임 종료 다이얼로그 메시지 — 승리팀 안내
  ///
  /// In ko, this message translates to:
  /// **'{winnerTeamLabel}의 승리예요!'**
  String messageGameOverWinner(Object winnerTeamLabel);

  /// 경찰 역할 단일 라벨 (닉네임 누락 시 fallback 포함)
  ///
  /// In ko, this message translates to:
  /// **'경찰'**
  String get gameRoleCopLabel;

  /// 도둑 역할 단일 라벨 (닉네임 누락 시 fallback 포함)
  ///
  /// In ko, this message translates to:
  /// **'도둑'**
  String get gameRoleRobberLabel;

  /// 체포 실패 — 경찰 대기 시간 중
  ///
  /// In ko, this message translates to:
  /// **'경찰 대기 시간 중에는 도둑을 체포할 수 없어요'**
  String get errorCannotArrestDuringWait;

  /// 도둑 수배 QR 스캐너 페이지 타이틀
  ///
  /// In ko, this message translates to:
  /// **'도둑의 수배 QR을 스캔하세요'**
  String get qrScannerWantedRobberTitle;

  /// QR 스캔 실패 — QR 만료
  ///
  /// In ko, this message translates to:
  /// **'만료된 QR이에요. QR 새로고침을 요청하세요'**
  String get errorExpiredQr;

  /// 체포 실패 — 이미 체포된 도둑
  ///
  /// In ko, this message translates to:
  /// **'이미 체포된 도둑이에요'**
  String get errorAlreadyArrested;

  /// 체포된 도둑에게 표시되는 잠금 오버레이 타이틀
  ///
  /// In ko, this message translates to:
  /// **'체포되었어요!'**
  String get gameArrestOverlayTitle;

  /// 체포 잠금 오버레이 안내 본문
  ///
  /// In ko, this message translates to:
  /// **'체포되어 있는 동안에는 게임 상황을 확인할 수 없어요\n같은 팀에게 구조 요청을 하며 빠르게 탈옥해요!'**
  String get gameArrestOverlayMessage;

  /// 체포 잠금 오버레이에서 탈옥을 확정하는 버튼
  ///
  /// In ko, this message translates to:
  /// **'탈옥 완료'**
  String get gameArrestOverlayEscapeCompleteButton;

  /// 공통 — 탈옥 액션 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'탈옥'**
  String get buttonEscape;

  /// 공통 — 부정 응답 버튼
  ///
  /// In ko, this message translates to:
  /// **'아니요'**
  String get buttonNo;

  /// 게임 종료 결과 다이얼로그의 체포 횟수 라벨
  ///
  /// In ko, this message translates to:
  /// **'체포 횟수'**
  String get labelArrestCount;

  /// 게임 종료 결과 — 남은 도둑 라벨
  ///
  /// In ko, this message translates to:
  /// **'남은 도둑'**
  String get fieldRemainingRobbers;

  /// 게임 종료 결과 — 게임 진행 시간 라벨
  ///
  /// In ko, this message translates to:
  /// **'게임 진행 시간'**
  String get fieldGamePlaytime;

  /// 공통 — 홈 화면으로 이동 버튼
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get buttonGoHome;

  /// 공통 — 다시 플레이 버튼
  ///
  /// In ko, this message translates to:
  /// **'한 번 더'**
  String get buttonPlayAgain;

  /// 내 기록 다이얼로그 — 제목
  ///
  /// In ko, this message translates to:
  /// **'내 기록'**
  String get labelMyRecord;

  /// 내 기록 — 승패 결과 라벨
  ///
  /// In ko, this message translates to:
  /// **'결과'**
  String get labelResult;

  /// 내 기록 — 저장 실패 스낵바
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했어요'**
  String get messageSaveFailed;

  /// 게임 종료 결과 이미지 저장/공유 선택 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'이미지를 어떻게 할까요?'**
  String get dialogImageActionTitle;

  /// 게임 종료 결과 이미지 저장 버튼
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get buttonSaveImage;

  /// 게임 종료 결과 이미지 저장 완료 스낵바
  ///
  /// In ko, this message translates to:
  /// **'이미지를 저장했어요'**
  String get messageImageSaved;

  /// 내 기록 — 공유 완료 스낵바
  ///
  /// In ko, this message translates to:
  /// **'공유했어요'**
  String get messageShareComplete;

  /// 내 기록 — 경로가 없을 때 표시
  ///
  /// In ko, this message translates to:
  /// **'이동 기록 없음'**
  String get labelNoRoute;

  /// 다음 도둑 위치 공개까지 남은 시간 카운트다운 (mm:ss 포함)
  ///
  /// In ko, this message translates to:
  /// **'다음 도둑 위치 공개까지 {formatted}'**
  String gameLocationRevealCountdown(String formatted);

  /// 참가자 체포 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'해당 플레이어를 체포하셨나요?'**
  String get dialogArrestConfirmTitle;

  /// 공통 — 긍정 응답 버튼
  ///
  /// In ko, this message translates to:
  /// **'네'**
  String get buttonYes;

  /// 탈옥 시도 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'탈옥할까요?'**
  String get dialogEscapeAttemptMessage;

  /// 참가자 오버레이 — 현재 인원 라벨
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get gameParticipantOverlayCurrent;

  /// 참가자 오버레이 — 인원 수 표기 (단위: 명)
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String gameParticipantOverlayCount(int count);

  /// 도둑 상태 — 도주 중 표기
  ///
  /// In ko, this message translates to:
  /// **'도주 중!'**
  String get gameRobberStatusEscaping;

  /// 경찰 출동 시작까지 남은 시간 카운트다운 (mm:ss 포함)
  ///
  /// In ko, this message translates to:
  /// **'경찰 시작까지 {formatted}'**
  String gamePoliceStartCountdown(String formatted);

  /// 도둑 수배 QR 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'수배 QR'**
  String get gameQrDisplayTitle;

  /// 도둑 수배 QR 다이얼로그 안내 본문
  ///
  /// In ko, this message translates to:
  /// **'경찰에게 QR을 보여주세요'**
  String get gameQrDisplayMessage;

  /// 공통 — 닫기 버튼
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get buttonClose;

  /// 카메라 권한 요청 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'카메라 권한 필요'**
  String get dialogCameraPermissionTitle;

  /// 카메라 권한 요청 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'QR코드를 스캔하려면 카메라 권한이 필요해요\n설정에서 카메라 권한을 허용해주세요'**
  String get dialogCameraPermissionMessage;

  /// QR 스캐너 — 카메라 초기화 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'카메라를 사용할 수 없어요'**
  String get errorCameraUnavailable;

  /// 플레이 영역 이탈 시 표시되는 배너
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드를 벗어났어요'**
  String get gameZoneExitBanner;

  /// 팀 채팅 메시지 prefix 라벨 (예: [팀])
  ///
  /// In ko, this message translates to:
  /// **'[팀]'**
  String get chatTeamPrefix;

  /// 더미 채팅 시스템 메시지 — 제한 시간 안내 (30분 고정)
  ///
  /// In ko, this message translates to:
  /// **'제한 시간은 30분이에요'**
  String get chatSystemGameTimeLimit30Min;

  /// 더미 채팅 메시지 — 경찰의 도둑 응원 메시지
  ///
  /// In ko, this message translates to:
  /// **'도둑 잘 도망쳐 봐요~'**
  String get chatSystemGoodLuckRobber;

  /// 더미 채팅 메시지 — 팀 응원 메시지
  ///
  /// In ko, this message translates to:
  /// **'이겨봅시다!'**
  String get chatSystemLetsWin;

  /// 채팅 메시지 복사 완료 토스트
  ///
  /// In ko, this message translates to:
  /// **'메시지가 복사되었어요'**
  String get messageMessageCopied;

  /// 사용자 차단 완료 안내
  ///
  /// In ko, this message translates to:
  /// **'해당 유저를 차단했어요'**
  String get messageUserBlocked;

  /// 신고 사유 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'신고 내용'**
  String get fieldReportContentLabel;

  /// 신고 사유 입력 필드 placeholder
  ///
  /// In ko, this message translates to:
  /// **'신고 사유를 자세히 작성해 주세요\n(상황 또는 대화 내용을 포함해 주세요)'**
  String get fieldReportReasonHint;

  /// 신고 공통 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'신고하기'**
  String get buttonReport;

  /// 신고 제출 완료 안내 메시지
  ///
  /// In ko, this message translates to:
  /// **'신고가 접수되었어요'**
  String get messageReportSubmitted;

  /// 신고 제출 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'신고에 실패했어요'**
  String get errorReportFailed;

  /// 신고 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'해당 유저를 신고할까요?'**
  String get dialogReportConfirmTitle;

  /// 신고 폼 — 선택한 카테고리 라벨 (뒤에 카테고리 이름 이어붙음)
  ///
  /// In ko, this message translates to:
  /// **'선택한 신고 사유:'**
  String get chatReportSelectedCategoryLabel;

  /// 신고 폼 — 제출 시 검토 안내 (선두 줄바꿈은 위 라벨과 줄 분리 의도)
  ///
  /// In ko, this message translates to:
  /// **'\n신고된 내용은 검토 후 조치할게요'**
  String get chatReportSubmitNotice;

  /// 텍스트 복사 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'복사하기'**
  String get buttonCopy;

  /// 사용자 차단 액션 버튼
  ///
  /// In ko, this message translates to:
  /// **'차단하기'**
  String get buttonBlock;

  /// 신고 폼 — 카테고리 선택 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'신고 유형 선택'**
  String get chatReportCategoryTitle;

  /// 미읽음 힌트 부분 — 전체 채팅 미읽음 수
  ///
  /// In ko, this message translates to:
  /// **'전체 {all}개'**
  String chatInputBarUnreadAll(String all);

  /// 미읽음 힌트 부분 — 팀 채팅 미읽음 수
  ///
  /// In ko, this message translates to:
  /// **'팀 {team}개'**
  String chatInputBarUnreadTeam(String team);

  /// 채팅 입력바 위 미읽음 힌트 wrapper — body에는 '전체 N개 · 팀 N개' 같은 부분 라벨이 들어감
  ///
  /// In ko, this message translates to:
  /// **'안 읽은 메시지 [{body}]'**
  String chatInputBarUnreadHint(String body);

  /// 채팅 입력바 — STOMP 연결 중 placeholder
  ///
  /// In ko, this message translates to:
  /// **'연결 중...'**
  String get chatInputBarConnecting;

  /// 채팅 입력바 — 메시지 입력 placeholder
  ///
  /// In ko, this message translates to:
  /// **'채팅을 입력하세요'**
  String get chatInputBarHint;

  /// 채팅 메시지 리스트 — 메시지 0건 빈 상태 안내
  ///
  /// In ko, this message translates to:
  /// **'채팅을 시작해보세요'**
  String get chatMessageListEmpty;

  /// 채팅 화면에서 최신 메시지로 스크롤 이동하는 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'최신 메시지로 이동'**
  String get buttonGoToLatestMessage;

  /// 채팅 날짜 구분선 — 월요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get chatWeekdayMon;

  /// 채팅 날짜 구분선 — 화요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get chatWeekdayTue;

  /// 채팅 날짜 구분선 — 수요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get chatWeekdayWed;

  /// 채팅 날짜 구분선 — 목요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get chatWeekdayThu;

  /// 채팅 날짜 구분선 — 금요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get chatWeekdayFri;

  /// 채팅 날짜 구분선 — 토요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get chatWeekdaySat;

  /// 채팅 날짜 구분선 — 일요일 단축 라벨
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get chatWeekdaySun;

  /// 채팅 날짜 구분선 — 날짜+요일 라벨 (요일은 chatWeekday* 키 값이 들어감)
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일 {weekday}요일'**
  String chatDateSeparator(
    String year,
    String month,
    String day,
    String weekday,
  );

  /// 채팅 오버레이 — 전체 채팅 탭 제목
  ///
  /// In ko, this message translates to:
  /// **'전체 채팅'**
  String get chatScopeAllTitle;

  /// 채팅 오버레이 — 팀 채팅 탭 제목
  ///
  /// In ko, this message translates to:
  /// **'팀 채팅'**
  String get chatScopeTeamTitle;

  /// 채팅 프리뷰 카드 — 시스템 공지 태그
  ///
  /// In ko, this message translates to:
  /// **'공지'**
  String get chatPreviewTagNotice;

  /// 채팅 프리뷰 카드 — 팀 채팅 태그
  ///
  /// In ko, this message translates to:
  /// **'팀'**
  String get chatPreviewTagTeam;

  /// 채팅 프리뷰 카드 — 전체 채팅 태그
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get chatPreviewTagAll;

  /// 설정 변경사항 저장 완료 안내 메시지
  ///
  /// In ko, this message translates to:
  /// **'변경사항이 저장되었어요'**
  String get messageChangesSaved;

  /// 일시적 오류 발생 시 재시도 유도 공통 메시지
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 다시 시도해주세요'**
  String get errorTemporaryRetry;

  /// 이용약관/정책 설정 페이지 타이틀
  ///
  /// In ko, this message translates to:
  /// **'이용약관 및 정책'**
  String get pageAgreementSettingsTitle;

  /// 약관 동의 정보 조회 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'약관 동의 현황을 불러오지 못했어요'**
  String get errorAgreementLoadFailed;

  /// 재시도 공통 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get buttonRetry;

  /// 변경사항 저장 공통 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'변경사항 저장'**
  String get buttonSaveChanges;

  /// 법적 문서(약관/정책) 로드 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'문서를 불러오지 못했어요'**
  String get errorLegalDocumentLoadFailed;

  /// 설정 페이지 AppBar 타이틀
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get pageSettingsTitle;

  /// 설정 — 계정 섹션 헤더
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get settingsSectionAccount;

  /// 설정 — 닉네임 변경 메뉴
  ///
  /// In ko, this message translates to:
  /// **'닉네임 변경'**
  String get settingsAccountChangeNickname;

  /// 설정 — 앱 설정 섹션 헤더
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get settingsSectionAppPreferences;

  /// 설정 — 게임 알림 토글 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'게임 알림'**
  String get settingsAppGameNotification;

  /// 설정 — 게임 알림 토글 메뉴 부제
  ///
  /// In ko, this message translates to:
  /// **'게임 진행 중 발생하는 이벤트 알림을 설정해요'**
  String get settingsAppGameNotificationDescription;

  /// 설정 — 시스템 알림 설정 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get settingsAppGeneralNotification;

  /// 설정 — 시스템 알림 설정 부제의 강조 토큰 (스타일 분리 위해 별도 키)
  ///
  /// In ko, this message translates to:
  /// **'게임 중 알림'**
  String get settingsAppGeneralNotificationHighlight;

  /// 설정 — 시스템 알림 설정 부제의 나머지 토큰 (Highlight 뒤에 이어붙임)
  ///
  /// In ko, this message translates to:
  /// **'을 포함한 앱에서 보내는 모든 알림을 설정해요'**
  String get settingsAppGeneralNotificationDetail;

  /// 설정 — 위치 권한 관리 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'위치 권한 관리'**
  String get settingsAppLocationPermission;

  /// 설정 — 위치 권한 관리 메뉴 부제
  ///
  /// In ko, this message translates to:
  /// **'기기 설정에서 위치 권한을 변경할 수 있어요'**
  String get settingsAppLocationPermissionDescription;

  /// 설정 — 이용 안내 섹션 헤더
  ///
  /// In ko, this message translates to:
  /// **'이용 안내'**
  String get settingsSectionGuide;

  /// 설정 — 버그 제보 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'버그 제보'**
  String get settingsGuideBugReport;

  /// 설정 — 튜토리얼 다시 보기 메뉴
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 다시 보기'**
  String get settingsGuideTutorialRewatch;

  /// 설정 — 튜토리얼 초기화 메뉴
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 초기화'**
  String get settingsGuideTutorialReset;

  /// 설정 — 이용약관 및 정책 메뉴 (페이지 진입)
  ///
  /// In ko, this message translates to:
  /// **'이용약관 및 정책'**
  String get settingsGuideAgreements;

  /// 설정 — 기타 섹션 헤더 (로그아웃/탈퇴 등)
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get settingsSectionEtc;

  /// 설정 — 회원 탈퇴 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴'**
  String get settingsEtcDeleteAccount;

  /// 설정 — 앱 버전 표시 메뉴 라벨
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get settingsAppVersionLabel;

  /// 설정 — 공식 SNS 채널 아이콘 행 상단 안내 문구
  ///
  /// In ko, this message translates to:
  /// **'더 많은 소식이 궁금하다면 👀'**
  String get settingsSnsPrompt;

  /// 게임 알림 설정 변경 실패 메시지
  ///
  /// In ko, this message translates to:
  /// **'게임 알림 설정을 변경하지 못했어요'**
  String get errorGameNotificationToggleFailed;

  /// 버그 제보 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'버그 제보'**
  String get titleBugReport;

  /// 버그 제보 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'버그 내용'**
  String get fieldBugReportLabel;

  /// 버그 제보 입력 필드 placeholder
  ///
  /// In ko, this message translates to:
  /// **'어떤 문제가 발생했나요?\n발생 상황을 자세히 적어주세요(시간, 기기 정보 포함)'**
  String get fieldBugReportHint;

  /// 버그 제보 다이얼로그 — 제출 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'제보하기'**
  String get buttonSubmitReport;

  /// 버그 제보 접수 완료 안내
  ///
  /// In ko, this message translates to:
  /// **'버그 제보가 접수되었어요'**
  String get messageBugReportSubmitted;

  /// 튜토리얼 초기화 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 초기화'**
  String get dialogTutorialResetTitle;

  /// 튜토리얼 초기화 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'모든 화면의 튜토리얼을\n다시 볼 수 있도록 초기화할까요?'**
  String get dialogTutorialResetMessage;

  /// 초기화 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get buttonReset;

  /// 튜토리얼 초기화 완료 안내 메시지
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼이 초기화되었어요'**
  String get messageTutorialReset;

  /// 로그아웃 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get dialogLogoutTitle;

  /// 로그아웃 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃할까요?'**
  String get dialogLogoutMessage;

  /// 로그아웃 실패 스낵바 메시지
  ///
  /// In ko, this message translates to:
  /// **'로그아웃에 실패했어요'**
  String get snackbarLogoutFailed;

  /// 로그아웃 성공 스낵바 메시지
  ///
  /// In ko, this message translates to:
  /// **'로그아웃했어요'**
  String get snackbarLogoutSuccess;

  /// 회원 탈퇴 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴'**
  String get dialogDeleteAccountTitle;

  /// 회원 탈퇴 확인 다이얼로그 본문 — 비가역성 경고 + 확인 키워드 입력 요구
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하면 모든 데이터가 사라지고\n되돌릴 수 없어요\n\n계속하려면 \"delete\"를 입력하세요'**
  String get dialogDeleteAccountMessage;

  /// 회원 탈퇴 확인 입력 필드 placeholder (사용자가 직접 입력해야 하는 키워드)
  ///
  /// In ko, this message translates to:
  /// **'delete'**
  String get fieldDeleteAccountHint;

  /// 회원 탈퇴 확정 버튼
  ///
  /// In ko, this message translates to:
  /// **'탈퇴'**
  String get buttonDeleteAccount;

  /// 튜토리얼용 더미 캐릭터 닉네임 — 한국어는 원본, 비-ko는 영문 표기
  ///
  /// In ko, this message translates to:
  /// **'경찰1'**
  String get tutorialDummyNicknameCop1;

  /// 튜토리얼용 더미 캐릭터 닉네임 — 한국어는 원본, 비-ko는 영문 표기
  ///
  /// In ko, this message translates to:
  /// **'도둑킹'**
  String get tutorialDummyNicknameRobberKing;

  /// 튜토리얼용 더미 캐릭터 닉네임 — 한국어는 원본, 비-ko는 영문 표기
  ///
  /// In ko, this message translates to:
  /// **'도둑이게아니게'**
  String get tutorialDummyNicknameRobberOrNot;

  /// 튜토리얼용 더미 캐릭터 닉네임 — 한국어는 원본, 비-ko는 영문 표기
  ///
  /// In ko, this message translates to:
  /// **'잡힌도둑'**
  String get tutorialDummyNicknameCapturedRobber;

  /// 튜토리얼 완료 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 완료!'**
  String get titleTutorialComplete;

  /// 튜토리얼 완료 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'핵심 흐름을 익혔어요\n실제 게임에서 활용해보세요'**
  String get messageTutorialComplete;

  /// 튜토리얼 완료 다이얼로그의 종료 버튼
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 끝내기'**
  String get buttonFinishTutorial;

  /// 튜토리얼 — 내 위치 버튼 동작 안내
  ///
  /// In ko, this message translates to:
  /// **'내 위치로 카메라가 이동했어요'**
  String get tutorialInGameMyLocation;

  /// 튜토리얼 — 인게임 지도 미리보기 상단 라벨
  ///
  /// In ko, this message translates to:
  /// **'지도 미리보기'**
  String get tutorialMapPreviewLabel;

  /// 튜토리얼 — 도둑 위치 공개 카운트다운 (시연용 고정값)
  ///
  /// In ko, this message translates to:
  /// **'다음 도둑 위치 공개까지 04:30'**
  String get tutorialLocationRevealCountdown;

  /// 튜토리얼 — 게임 룰 버튼 동작 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 룰 안내가 열려요'**
  String get tutorialInGameRulesGuide;

  /// 튜토리얼 — 도둑 시점 QR 안내 (수배 QR 표시)
  ///
  /// In ko, this message translates to:
  /// **'내 수배 QR이 화면에 표시돼요. 경찰에게 보여주면 체포'**
  String get tutorialQrRobberHint;

  /// 튜토리얼 — 경찰 시점 QR 안내 (스캐너 사용)
  ///
  /// In ko, this message translates to:
  /// **'카메라가 켜지고 도둑의 QR을 스캔해 체포할 수 있어요'**
  String get tutorialQrCopHint;

  /// 튜토리얼 미션 — 참가자 버튼 탭 안내 (총 4 중 하나)
  ///
  /// In ko, this message translates to:
  /// **'참가자 보기 버튼을 눌러보세요'**
  String get tutorialMissionParticipantsButton;

  /// 튜토리얼 미션 — QR 버튼 탭 안내 (총 4 중 하나)
  ///
  /// In ko, this message translates to:
  /// **'QR 버튼을 눌러보세요'**
  String get tutorialMissionQrButton;

  /// 튜토리얼 미션 3/4 — 지도로 복귀 안내
  ///
  /// In ko, this message translates to:
  /// **'지도로 돌아가 보세요'**
  String get tutorialMissionMapButton;

  /// 튜토리얼 미션 4/4 — 지도 롱프레스로 핀 찍기 안내
  ///
  /// In ko, this message translates to:
  /// **'지도를 길게 눌러 핀을 찍어보세요'**
  String get tutorialMissionDropPing;

  /// 튜토리얼 — 지도 롱프레스 핀 찍기 힌트 인디케이터
  ///
  /// In ko, this message translates to:
  /// **'맵 아무 곳이나 길게 눌러보세요'**
  String get tutorialPingLongPressHint;

  /// 튜토리얼 진행도 라벨 (현재 미션 / 총 4)
  ///
  /// In ko, this message translates to:
  /// **'미션 {step}/4'**
  String tutorialMissionProgress(String step);

  /// 튜토리얼 — 도둑 시점 시연 상태 표시
  ///
  /// In ko, this message translates to:
  /// **'도둑 시점 보는 중'**
  String get tutorialPerspectiveRobber;

  /// 튜토리얼 — 경찰 시점 시연 상태 표시
  ///
  /// In ko, this message translates to:
  /// **'경찰 시점 보는 중'**
  String get tutorialPerspectiveCop;

  /// 튜토리얼 — 본인 수감 시 카드 탭으로 탈옥 시도 안내
  ///
  /// In ko, this message translates to:
  /// **'본인이 수감됐다면 카드 탭으로 탈옥을 시도할 수 있어요'**
  String get tutorialInGameSelfEscape;

  /// 튜토리얼 — 실제 게임 QR 체포 방식 안내
  ///
  /// In ko, this message translates to:
  /// **'실제 게임에서는 QR 스캔으로 도둑을 체포해요'**
  String get tutorialInGameQrArrest;

  /// 튜토리얼 — '현재' 라벨 (현재 도주 중인 도둑 수 앞 텍스트)
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get tutorialCurrentLabel;

  /// 튜토리얼 — 인원수 표시 (예: 3명)
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String tutorialPlayerCount(int count);

  /// 튜토리얼 — 도주 중 강조 텍스트
  ///
  /// In ko, this message translates to:
  /// **'도주 중!'**
  String get tutorialOnTheRun;

  /// 튜토리얼 — 채팅 시트 확장 제스처 안내
  ///
  /// In ko, this message translates to:
  /// **'핸들을 위로 드래그하면 채팅이 펼쳐져요'**
  String get tutorialInGameChatExpand;

  /// 튜토리얼 — 채팅 입력 영역 사용법 안내
  ///
  /// In ko, this message translates to:
  /// **'여기에 메시지를 입력하면 팀/전체 채팅으로 보낼 수 있어요'**
  String get tutorialInGameChatInput;

  /// 튜토리얼 — 채팅 입력바 placeholder (인게임 chat과 동일 문구지만 컨텍스트 분리)
  ///
  /// In ko, this message translates to:
  /// **'채팅을 입력하세요'**
  String get tutorialChatHint;

  /// 튜토리얼 카탈로그 — 방 만들기 단계 부제
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드·감옥 설정과 슬라이더 조작'**
  String get tutorialCatalogAreaSubtitle;

  /// 튜토리얼 카탈로그 — 방 참여하기 단계 부제
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 입력과 QR 스캔'**
  String get tutorialCatalogInviteSubtitle;

  /// 튜토리얼 카탈로그 — 대기방 단계 제목
  ///
  /// In ko, this message translates to:
  /// **'대기방'**
  String get tutorialCatalogWaitingRoomTitle;

  /// 튜토리얼 카탈로그 — 대기방 단계 부제
  ///
  /// In ko, this message translates to:
  /// **'팀 변경, 게임 설정, 준비 완료'**
  String get tutorialCatalogLobbySubtitle;

  /// 튜토리얼 카탈로그 — 인게임 단계 제목
  ///
  /// In ko, this message translates to:
  /// **'인게임'**
  String get tutorialCatalogInGameTitle;

  /// 튜토리얼 카탈로그 — 인게임 단계 부제
  ///
  /// In ko, this message translates to:
  /// **'타이머·지도·참가자·채팅·QR'**
  String get tutorialCatalogGameSubtitle;

  /// 튜토리얼 카탈로그 페이지 타이틀
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼'**
  String get pageTutorialCatalogTitle;

  /// 튜토리얼 카탈로그 페이지 인트로 안내
  ///
  /// In ko, this message translates to:
  /// **'게임을 처음 한다면 한 번씩 보고 시작해보세요'**
  String get tutorialCatalogIntro;

  /// 튜토리얼 카탈로그 — 미구현 단계의 '준비 중' 라벨
  ///
  /// In ko, this message translates to:
  /// **'준비 중'**
  String get tutorialCatalogComingSoon;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Hong Eui-min)
  ///
  /// In ko, this message translates to:
  /// **'홍의민'**
  String get creditMemberHongEuiMin;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Park Chan-bin)
  ///
  /// In ko, this message translates to:
  /// **'박찬빈'**
  String get creditMemberParkChanBin;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Lee Chang-hee)
  ///
  /// In ko, this message translates to:
  /// **'이창희'**
  String get creditMemberLeeChangHee;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Jeong Sang-hee)
  ///
  /// In ko, this message translates to:
  /// **'정상희'**
  String get creditMemberJeongSangHee;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Hwang Hye-rim)
  ///
  /// In ko, this message translates to:
  /// **'황혜림'**
  String get creditMemberHwangHyeRim;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Yoon Ji-hee)
  ///
  /// In ko, this message translates to:
  /// **'윤지희'**
  String get creditMemberYoonJiHee;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Kim Da-im)
  ///
  /// In ko, this message translates to:
  /// **'김다임'**
  String get creditMemberKimDaim;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Shin Ji-hoon)
  ///
  /// In ko, this message translates to:
  /// **'신지훈'**
  String get creditMemberShinJiHoon;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Nam Hae-yoon)
  ///
  /// In ko, this message translates to:
  /// **'남해윤'**
  String get creditMemberNamHaeYoon;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Song Hye-jung)
  ///
  /// In ko, this message translates to:
  /// **'송혜정'**
  String get creditMemberSongHyeJung;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Lee Jin)
  ///
  /// In ko, this message translates to:
  /// **'이진'**
  String get creditMemberLeeJin;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Ahn Geum-seo)
  ///
  /// In ko, this message translates to:
  /// **'안금서'**
  String get creditMemberAhnGeumSeo;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Son Geon-woo)
  ///
  /// In ko, this message translates to:
  /// **'손건우'**
  String get creditMemberSonGeonWoo;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Shin Hye-bin)
  ///
  /// In ko, this message translates to:
  /// **'신혜빈'**
  String get creditMemberShinHyeBin;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Jeong Chang-woo)
  ///
  /// In ko, this message translates to:
  /// **'정창우'**
  String get creditMemberJeongChangWoo;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Heo Seok-jun)
  ///
  /// In ko, this message translates to:
  /// **'허석준'**
  String get creditMemberHeoSeokJun;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Seo Hyun-jin)
  ///
  /// In ko, this message translates to:
  /// **'서현진'**
  String get creditMemberSeoHyunJin;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Oh Dong-hyun)
  ///
  /// In ko, this message translates to:
  /// **'오동현'**
  String get creditMemberOhDongHyun;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Choi Seung-hoon)
  ///
  /// In ko, this message translates to:
  /// **'최승훈'**
  String get creditMemberChoiSeungHoon;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Kim Min-wook)
  ///
  /// In ko, this message translates to:
  /// **'김민욱'**
  String get creditMemberKimMinWook;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Jeong Myeong-jun)
  ///
  /// In ko, this message translates to:
  /// **'정명준'**
  String get creditMemberJeongMyeongJun;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Kang Dae-hyun)
  ///
  /// In ko, this message translates to:
  /// **'강대현'**
  String get creditMemberKangDaeHyun;

  /// 크레딧 멤버 표시명 — 한국어는 원본, 비-ko 로케일은 영문 표기 (Sim Hyuk)
  ///
  /// In ko, this message translates to:
  /// **'심 혁'**
  String get creditMemberSimHyuk;

  /// 크레딧 페이지 상단 헤더 — 제작진 소개
  ///
  /// In ko, this message translates to:
  /// **'경찰과 도둑을 만든 사람들'**
  String get pageCreditsTitle;

  /// 신고 처리 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'신고 처리 중 오류가 생겼어요'**
  String get errorReportGeneric;

  /// 신고 카테고리 — 낚시/놀람/도배 (ReportCategory.bait)
  ///
  /// In ko, this message translates to:
  /// **'낚시/놀람/도배'**
  String get reportCategoryBait;

  /// 신고 카테고리 — 욕설/비하 (ReportCategory.abuse)
  ///
  /// In ko, this message translates to:
  /// **'욕설/비하'**
  String get reportCategoryAbuse;

  /// 신고 카테고리 — 사칭/사기 (ReportCategory.impersonation)
  ///
  /// In ko, this message translates to:
  /// **'사칭/사기'**
  String get reportCategoryImpersonation;

  /// 신고 카테고리 — 광고/스팸 (ReportCategory.spam)
  ///
  /// In ko, this message translates to:
  /// **'광고/스팸'**
  String get reportCategorySpam;

  /// 신고 카테고리 — 부정 행위/버그 악용 (ReportCategory.exploit)
  ///
  /// In ko, this message translates to:
  /// **'부정 행위/버그 악용'**
  String get reportCategoryExploit;

  /// 신고 카테고리 — 팀 사기 저하 (ReportCategory.teamSabotage)
  ///
  /// In ko, this message translates to:
  /// **'팀 사기 저하'**
  String get reportCategoryTeamSabotage;

  /// 신고 카테고리 — 기타 (ReportCategory.other, 직접 입력)
  ///
  /// In ko, this message translates to:
  /// **'기타(직접 작성)'**
  String get reportCategoryOther;

  /// 닉네임 중복 확인 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'닉네임 확인 중 예기치 않은 오류가 생겼어요'**
  String get errorNicknameCheckUnexpected;

  /// 닉네임 변경 실패 시 표시되는 예외 메시지
  ///
  /// In ko, this message translates to:
  /// **'닉네임 변경 중 예기치 않은 오류가 생겼어요'**
  String get errorNicknameUpdateUnexpected;

  /// 사용자 정보 조회 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'사용자 정보 조회 중 오류가 생겼어요'**
  String get errorUserInfoFetch;

  /// 회원 탈퇴 처리 중 예기치 않은 오류 안내
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴 중 예기치 않은 오류가 생겼어요'**
  String get errorDeleteAccountUnexpected;

  /// 약관 동의 상태 조회 중 예기치 않은 오류 안내
  ///
  /// In ko, this message translates to:
  /// **'약관 동의 상태 조회 중 예기치 않은 오류가 생겼어요'**
  String get errorAgreementFetchUnexpected;

  /// 약관 동의 저장 중 예기치 않은 오류 안내
  ///
  /// In ko, this message translates to:
  /// **'약관 동의 저장 중 예기치 않은 오류가 생겼어요'**
  String get errorAgreementSaveUnexpected;

  /// 게임 푸시 알림 동의 조회 중 예기치 않은 오류 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 푸시 알림 동의 조회 중 예기치 않은 오류가 생겼어요'**
  String get errorGamePushFetchUnexpected;

  /// 게임 푸시 알림 동의 업데이트 중 예기치 않은 오류 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 푸시 알림 동의 업데이트 중 예기치 않은 오류가 생겼어요'**
  String get errorGamePushUpdateUnexpected;

  /// 인증 토큰 조회 실패 — secure storage에 토큰이 없거나 만료된 토큰 정리 후
  ///
  /// In ko, this message translates to:
  /// **'로그인 정보를 확인할 수 없어요. 다시 로그인해주세요'**
  String get errorAuthTokenMissing;

  /// 서버 연결 실패 — STOMP/REST 모두 실패 시 재시도 권장 안내
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없어요. 잠시 후 다시 시도해주세요'**
  String get errorServerUnreachable;

  /// 인증 토큰 만료 — 재로그인 유도
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료됐어요. 재로그인이 필요해요'**
  String get errorAuthExpired;

  /// 공지사항 로딩 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 불러오는 중 오류가 생겼어요'**
  String get errorNoticesLoadGeneric;

  /// 커뮤니티 모집글 로딩 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'모집글을 불러오는 중 오류가 생겼어요'**
  String get errorCommunityPostsLoadGeneric;

  /// 커뮤니티 목록 조회 실패 시 화면에 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'모집글을 불러오지 못했어요'**
  String get errorCommunityPostsLoadFailed;

  /// 커뮤니티 모집글 수정 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'모집글을 수정하는 중 오류가 생겼어요'**
  String get errorCommunityPostUpdateGeneric;

  /// 커뮤니티 모집글 삭제 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'모집글을 삭제하는 중 오류가 생겼어요'**
  String get errorCommunityPostDeleteGeneric;

  /// 커뮤니티 모집 상태 변경 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'모집 상태를 바꾸는 중 오류가 생겼어요'**
  String get errorCommunityPostStatusGeneric;

  /// 커뮤니티 모집글 등록 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'모집글을 등록하는 중 오류가 생겼어요'**
  String get errorCommunityPostCreateGeneric;

  /// 모집글 작성 중 좌표 주소 조회에 실패했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'주소를 불러오는 중 오류가 생겼어요'**
  String get errorCommunityAddressLoadGeneric;

  /// 공지사항 로딩 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 불러오지 못했어요'**
  String get errorNoticeLoadFailed;

  /// 공지사항 페이지 AppBar 제목
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get pageNoticesTitle;

  /// 공지사항 페이지 — 공지가 0건일 때 표시하는 빈 상태 메시지
  ///
  /// In ko, this message translates to:
  /// **'등록된 공지사항이 없어요'**
  String get pageNoticesEmpty;

  /// 공지사항 카테고리 필터 칩 — 전체(필터 없음)
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get noticeCategoryAll;

  /// 공지사항 카테고리 필터 칩 — 일반 공지(백엔드 기본 카테고리)
  ///
  /// In ko, this message translates to:
  /// **'공지'**
  String get noticeCategoryNotice;

  /// 공지사항 카테고리 필터 칩 — 서버 점검
  ///
  /// In ko, this message translates to:
  /// **'점검'**
  String get noticeCategoryMaintenance;

  /// 공지사항 카테고리 필터 칩 — 이벤트
  ///
  /// In ko, this message translates to:
  /// **'이벤트'**
  String get noticeCategoryEvent;

  /// 공지사항 카테고리 필터 칩 — 앱 업데이트
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get noticeCategoryUpdate;

  /// 게임 진입 시 area(구역) 정보 로드 실패 안내
  ///
  /// In ko, this message translates to:
  /// **'구역 정보를 불러오지 못했어요'**
  String get errorAreaLoadFailed;

  /// 404 페이지 AppBar 제목
  ///
  /// In ko, this message translates to:
  /// **'페이지를 찾을 수 없어요'**
  String get pageNotFoundTitle;

  /// 404 페이지 본문 — 잘못된 경로 진입 시 안내
  ///
  /// In ko, this message translates to:
  /// **'요청하신 페이지가 없어요'**
  String get pageNotFoundMessage;

  /// 404 페이지 — 시도한 경로 표시 (디버깅 도움)
  ///
  /// In ko, this message translates to:
  /// **'경로: {path}'**
  String pageNotFoundPath(String path);

  /// 로그아웃 공통 버튼 라벨
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get buttonLogout;

  /// 버그 제보 처리 중 예외가 발생했을 때 표시되는 메시지
  ///
  /// In ko, this message translates to:
  /// **'버그 제보 처리 중 오류가 생겼어요'**
  String get errorBugReportFailed;

  /// START 1단계 — 제한 시간 안내
  ///
  /// In ko, this message translates to:
  /// **'제한 시간은 {minutes}분이에요'**
  String gameEventStartTime(int minutes);

  /// START 2단계 — 게임 시작 예고
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 게임이 시작돼요.  모든 플레이어는 준비하세요!'**
  String get gameEventStartReady;

  /// START 3단계 — 신고/차단 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 중 채팅을 길게 누르면 불편한 유저를 신고하고 차단할 수 있어요'**
  String get gameEventStartReportTip;

  /// START 4단계 — 게임 시작 확정
  ///
  /// In ko, this message translates to:
  /// **'게임 시작!  행운을 빌어요!'**
  String get gameEventStartGo;

  /// 경찰 출동 확정
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동!  도둑은 도망치세요!'**
  String get gameEventPoliceMove;

  /// 도둑 위치 공개 안내
  ///
  /// In ko, this message translates to:
  /// **'현재 도둑의 위치가 공개돼요!'**
  String get gameEventLocationReveal;

  /// 체포 공지 — @icon_police/@icon_robber 마커는 채팅 버블에서 SVG로 치환
  ///
  /// In ko, this message translates to:
  /// **'@icon_police [{policeNickname}]님이 @icon_robber [{robberNickname}]님을 체포했어요!'**
  String gameEventArrestNotice(String policeNickname, String robberNickname);

  /// 탈옥 공지
  ///
  /// In ko, this message translates to:
  /// **'도둑이 탈옥했어요! 지금 바로 체포하세요!'**
  String get gameEventEscapeNotice;

  /// 인게임 중도 퇴장 공지 배너 — 닉네임과 팀 라벨 표시
  ///
  /// In ko, this message translates to:
  /// **'[{nickname}]({teamLabel}) 님이 게임에서 나갔어요'**
  String gameEventPlayerLeftNotice(String nickname, String teamLabel);

  /// 지도 로드 실패 시 표시 메시지
  ///
  /// In ko, this message translates to:
  /// **'{mapName} 로드 실패'**
  String mapErrorLoadFailed(String mapName);

  /// 게임 입장 시 발생한 예기치 않은 오류
  ///
  /// In ko, this message translates to:
  /// **'게임 입장 중 예기치 않은 오류가 생겼어요'**
  String get errorGameJoinUnexpected;

  /// 다른 방에 이미 참가 중이라 새 방 참가가 거부된 경우 (409)
  ///
  /// In ko, this message translates to:
  /// **'이미 참여 중인 방이 있어요. 현재 방에서 나간 후 다시 시도해주세요'**
  String get errorAlreadyInAnotherRoom;

  /// 딥링크로 새 방 참가 시도 시 이미 참여 중인 방이 있어 현재 방으로 복귀할 때 표시하는 안내 (409)
  ///
  /// In ko, this message translates to:
  /// **'이미 참여 중인 방이 있어요'**
  String get deeplinkAlreadyInRoom;

  /// 초대 코드는 유효하지만 게임이 이미 시작된 경우 (400 이미 시작된 게임)
  ///
  /// In ko, this message translates to:
  /// **'이미 시작되어 입장할 수 없는 게임이에요'**
  String get errorGameAlreadyStarted;

  /// 방 이동 중 현재 방 퇴장 후 새 방 입장에 실패한 경우
  ///
  /// In ko, this message translates to:
  /// **'새 방에 입장하지 못했어요. 이전 방에서는 나온 상태예요'**
  String get errorRoomSwitchFailed;

  /// 이미 다른 대기방 참가 중 딥링크 진입 시 방 이동 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'방을 이동할까요?'**
  String get deeplinkSwitchRoomTitle;

  /// 방 이동 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'현재 참여 중인 방에서 나가고 새 방에 참가해요'**
  String get deeplinkSwitchRoomMessage;

  /// 방 이동 확인 다이얼로그 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'나가고 참가'**
  String get deeplinkSwitchRoomConfirm;

  /// 로그인 후 자동 join 시 SharedPreferences 읽기 실패
  ///
  /// In ko, this message translates to:
  /// **'대기 중인 초대 코드를 불러오지 못했어요'**
  String get errorPendingInviteLoad;

  /// 딥링크 → 로그인 리다이렉트 직전 SharedPreferences 쓰기 실패
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 저장에 실패했어요'**
  String get errorPendingInviteSave;

  /// join 완료 후 SharedPreferences 삭제 실패
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 삭제에 실패했어요'**
  String get errorPendingInviteClear;

  /// 카톡 등 공유 시 본문 (URL 은 별도로 append)
  ///
  /// In ko, this message translates to:
  /// **'친구가 경찰과도둑 방에 초대했어요! 초대 코드 {inviteCode}'**
  String shareInviteMessage(String inviteCode);

  /// No description provided for @errorCodeMissingRequestPart.
  ///
  /// In ko, this message translates to:
  /// **'요청에 필요한 파트가 누락됐어요'**
  String get errorCodeMissingRequestPart;

  /// No description provided for @errorCodeInvalidRequestBody.
  ///
  /// In ko, this message translates to:
  /// **'요청 본문의 형식이 잘못됐어요'**
  String get errorCodeInvalidRequestBody;

  /// No description provided for @errorCodeInvalidQueryParameter.
  ///
  /// In ko, this message translates to:
  /// **'쿼리 파라미터의 형식이 잘못됐어요'**
  String get errorCodeInvalidQueryParameter;

  /// No description provided for @errorCodeQueryParameterTypeMismatch.
  ///
  /// In ko, this message translates to:
  /// **'요청 파라미터의 타입이 잘못됐어요'**
  String get errorCodeQueryParameterTypeMismatch;

  /// No description provided for @errorCodeInvalidInputValue.
  ///
  /// In ko, this message translates to:
  /// **'입력값이 조건에 맞지 않아요'**
  String get errorCodeInvalidInputValue;

  /// ADDRESS_NOT_FOUND — 좌표에 주소·국가가 없어 게시글 생성·수정이 거절된 경우. 같은 핀으로는 재시도해도 실패하므로 공통 폴백(errorTemporaryRetry)을 쓰면 안 된다. 장소 선택 화면의 communityLocationPickerNotFound와 같은 문구.
  ///
  /// In ko, this message translates to:
  /// **'주소를 찾을 수 없는 곳이에요. 다른 곳을 골라주세요'**
  String get errorCodeAddressNotFound;

  /// No description provided for @errorCodeInvalidDestination.
  ///
  /// In ko, this message translates to:
  /// **'잘못된 연결 경로예요'**
  String get errorCodeInvalidDestination;

  /// No description provided for @errorCodeUnsupportedMediaType.
  ///
  /// In ko, this message translates to:
  /// **'지원하지 않는 형식이에요'**
  String get errorCodeUnsupportedMediaType;

  /// No description provided for @errorCodeMethodNotAllowed.
  ///
  /// In ko, this message translates to:
  /// **'허용되지 않은 요청이에요'**
  String get errorCodeMethodNotAllowed;

  /// No description provided for @errorCodeEndpointNotFound.
  ///
  /// In ko, this message translates to:
  /// **'요청 경로를 찾을 수 없어요'**
  String get errorCodeEndpointNotFound;

  /// No description provided for @errorCodeInvalidSocketSession.
  ///
  /// In ko, this message translates to:
  /// **'세션 정보를 찾을 수 없어요. 다시 연결해주세요'**
  String get errorCodeInvalidSocketSession;

  /// No description provided for @errorCodeUnauthorizedSubscription.
  ///
  /// In ko, this message translates to:
  /// **'해당 팀 전용 채널을 구독할 권한이 없어요'**
  String get errorCodeUnauthorizedSubscription;

  /// 의도적으로 백엔드 detail과 다름. INTERNAL_SERVER_ERROR·FIREBASE_INIT_ERROR·FIREBASE_CONFIG_NOT_FOUND·ENCRYPTION_FAILED·DECRYPTION_FAILED·INVALID_ENCRYPTION_KEY·FIREBASE_SERVER_ERROR·NICKNAME_GENERATION_FAILED·INVITE_CODE_GENERATION_FAILED 등 서버 내부/인프라성 5xx 코드는 내부 기술 정보(암호화 키 규격, Firebase 설정 경로, 관리자 문의 안내 등) 노출을 막기 위해 공통 문구로 collapse한다. 신규 5xx 코드도 동일 정책 적용.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeInternalServerError;

  /// No description provided for @errorCodeFirebaseInitError.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeFirebaseInitError;

  /// No description provided for @errorCodeFirebaseConfigNotFound.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeFirebaseConfigNotFound;

  /// No description provided for @errorCodeEncryptionFailed.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeEncryptionFailed;

  /// No description provided for @errorCodeDecryptionFailed.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeDecryptionFailed;

  /// No description provided for @errorCodeInvalidEncryptionKey.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeInvalidEncryptionKey;

  /// No description provided for @errorCodeSocialLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'소셜 로그인에 실패했어요'**
  String get errorCodeSocialLoginFailed;

  /// No description provided for @errorCodeAccessTokenExpired.
  ///
  /// In ko, this message translates to:
  /// **'인증 정보가 만료됐어요'**
  String get errorCodeAccessTokenExpired;

  /// No description provided for @errorCodeRefreshTokenExpired.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 만료됐어요. 다시 로그인해주세요'**
  String get errorCodeRefreshTokenExpired;

  /// No description provided for @errorCodeInvalidToken.
  ///
  /// In ko, this message translates to:
  /// **'인증 정보가 올바르지 않아요. 다시 로그인해주세요'**
  String get errorCodeInvalidToken;

  /// No description provided for @errorCodeUnauthenticatedRequest.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요해요'**
  String get errorCodeUnauthenticatedRequest;

  /// No description provided for @errorCodeExpiredFirebaseToken.
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료됐어요. 다시 시도해주세요'**
  String get errorCodeExpiredFirebaseToken;

  /// No description provided for @errorCodeInvalidFirebaseToken.
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했어요. 다시 시도해주세요'**
  String get errorCodeInvalidFirebaseToken;

  /// No description provided for @errorCodeUnsupportedSocialType.
  ///
  /// In ko, this message translates to:
  /// **'지원하지 않는 소셜 로그인 방식이에요'**
  String get errorCodeUnsupportedSocialType;

  /// No description provided for @errorCodeForbiddenAdminOnly.
  ///
  /// In ko, this message translates to:
  /// **'관리자 권한이 필요해요'**
  String get errorCodeForbiddenAdminOnly;

  /// No description provided for @errorCodeNicknameGenerationFailed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeNicknameGenerationFailed;

  /// No description provided for @errorCodeFirebaseServerError.
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 생겼어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeFirebaseServerError;

  /// No description provided for @errorCodeUserNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 유저를 찾을 수 없어요'**
  String get errorCodeUserNotFound;

  /// No description provided for @errorCodeDuplicatedNickname.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중인 닉네임이에요. 다른 닉네임을 선택해주세요'**
  String get errorCodeDuplicatedNickname;

  /// No description provided for @errorCodeCannotWithdraw.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 게임 세션이 있어 탈퇴할 수 없어요'**
  String get errorCodeCannotWithdraw;

  /// No description provided for @errorCodeRequiredTermsNotAgreed.
  ///
  /// In ko, this message translates to:
  /// **'필수 약관은 모두 동의해야 해요'**
  String get errorCodeRequiredTermsNotAgreed;

  /// No description provided for @errorCodeGameNotFound.
  ///
  /// In ko, this message translates to:
  /// **'요청하신 게임 정보가 존재하지 않아요'**
  String get errorCodeGameNotFound;

  /// No description provided for @errorCodeGameNotInProgress.
  ///
  /// In ko, this message translates to:
  /// **'게임이 진행 중인 상태가 아니에요'**
  String get errorCodeGameNotInProgress;

  /// No description provided for @errorCodeGameNotActive.
  ///
  /// In ko, this message translates to:
  /// **'대기 중이거나 진행 중인 게임에서만 조회할 수 있어요'**
  String get errorCodeGameNotActive;

  /// No description provided for @errorCodeGameNotWaiting.
  ///
  /// In ko, this message translates to:
  /// **'대기 중인 게임에서만 설정을 변경할 수 있어요'**
  String get errorCodeGameNotWaiting;

  /// No description provided for @errorCodeInvalidLocationInterval.
  ///
  /// In ko, this message translates to:
  /// **'위치 공개 주기는 라운드 시간보다 짧아야 해요'**
  String get errorCodeInvalidLocationInterval;

  /// No description provided for @errorCodeInvalidPoliceWaitTime.
  ///
  /// In ko, this message translates to:
  /// **'경찰 대기 시간은 라운드 시간보다 짧아야 해요'**
  String get errorCodeInvalidPoliceWaitTime;

  /// No description provided for @errorCodeInviteCodeGenerationFailed.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 생성에 실패했어요. 잠시 후 다시 시도해주세요'**
  String get errorCodeInviteCodeGenerationFailed;

  /// No description provided for @errorCodeInvalidJailRadius.
  ///
  /// In ko, this message translates to:
  /// **'감옥의 반지름이 플레이그라운드의 반지름보다 크거나 같을 수 없어요'**
  String get errorCodeInvalidJailRadius;

  /// No description provided for @errorCodeJailOutsidePlayground.
  ///
  /// In ko, this message translates to:
  /// **'감옥은 플레이그라운드 내부에 완전히 포함되어야 해요'**
  String get errorCodeJailOutsidePlayground;

  /// No description provided for @errorCodeGameAreaNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 게임 구역을 찾을 수 없어요'**
  String get errorCodeGameAreaNotFound;

  /// No description provided for @errorCodeAlreadyParticipating.
  ///
  /// In ko, this message translates to:
  /// **'이미 해당 게임에 참가하고 있어요'**
  String get errorCodeAlreadyParticipating;

  /// No description provided for @errorCodeGameAlreadyStarted.
  ///
  /// In ko, this message translates to:
  /// **'이미 시작된 게임에는 참여할 수 없어요'**
  String get errorCodeGameAlreadyStarted;

  /// No description provided for @errorCodeGameFull.
  ///
  /// In ko, this message translates to:
  /// **'게임에 참가할 수 있는 최대 인원을 초과했어요'**
  String get errorCodeGameFull;

  /// No description provided for @errorCodeInvalidInviteCode.
  ///
  /// In ko, this message translates to:
  /// **'입력하신 초대 코드가 유효하지 않아요'**
  String get errorCodeInvalidInviteCode;

  /// No description provided for @errorCodeParticipantNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 게임에 참가하지 않은 사용자예요'**
  String get errorCodeParticipantNotFound;

  /// No description provided for @errorCodeNotAParticipant.
  ///
  /// In ko, this message translates to:
  /// **'해당 게임의 참가자가 아니에요'**
  String get errorCodeNotAParticipant;

  /// No description provided for @errorCodeCannotLeaveDuringGame.
  ///
  /// In ko, this message translates to:
  /// **'게임이 시작된 이후에는 방을 나갈 수 없어요'**
  String get errorCodeCannotLeaveDuringGame;

  /// No description provided for @errorCodeLobbyActionNotAllowed.
  ///
  /// In ko, this message translates to:
  /// **'게임이 시작된 이후에는 로비 상태를 변경할 수 없어요'**
  String get errorCodeLobbyActionNotAllowed;

  /// No description provided for @errorCodeNotHost.
  ///
  /// In ko, this message translates to:
  /// **'방장만 할 수 있어요'**
  String get errorCodeNotHost;

  /// No description provided for @errorCodeInvalidTeamComposition.
  ///
  /// In ko, this message translates to:
  /// **'게임을 시작하려면 경찰과 도둑 팀에 각각 최소 1명 이상의 참가자가 필요해요'**
  String get errorCodeInvalidTeamComposition;

  /// No description provided for @errorCodeNotAllReady.
  ///
  /// In ko, this message translates to:
  /// **'모든 참가자가 준비 상태여야 게임을 시작할 수 있어요'**
  String get errorCodeNotAllReady;

  /// No description provided for @errorCodeNotRobberTeam.
  ///
  /// In ko, this message translates to:
  /// **'도둑 팀만 위치를 전송할 수 있어요'**
  String get errorCodeNotRobberTeam;

  /// No description provided for @errorCodeHostCannotUnready.
  ///
  /// In ko, this message translates to:
  /// **'방장은 항상 준비 상태여야 해요'**
  String get errorCodeHostCannotUnready;

  /// No description provided for @errorCodeParticipantGameMismatch.
  ///
  /// In ko, this message translates to:
  /// **'경찰과 도둑이 서로 다른 게임에 참여하고 있어요'**
  String get errorCodeParticipantGameMismatch;

  /// No description provided for @errorCodeOnlyPoliceCanArrest.
  ///
  /// In ko, this message translates to:
  /// **'경찰 팀만 도둑을 체포할 수 있어요'**
  String get errorCodeOnlyPoliceCanArrest;

  /// No description provided for @errorCodeOnlyRobberCanBeArrested.
  ///
  /// In ko, this message translates to:
  /// **'도둑 팀만 체포될 수 있어요'**
  String get errorCodeOnlyRobberCanBeArrested;

  /// No description provided for @errorCodeOnlyRobberCanEscape.
  ///
  /// In ko, this message translates to:
  /// **'도둑 팀만 탈옥할 수 있어요'**
  String get errorCodeOnlyRobberCanEscape;

  /// No description provided for @errorCodeAlreadyArrested.
  ///
  /// In ko, this message translates to:
  /// **'이미 수감된 도둑이에요'**
  String get errorCodeAlreadyArrested;

  /// No description provided for @errorCodeNotJailed.
  ///
  /// In ko, this message translates to:
  /// **'수감된 상태에서만 탈옥할 수 있어요'**
  String get errorCodeNotJailed;

  /// No description provided for @errorCodePoliceWaitingTime.
  ///
  /// In ko, this message translates to:
  /// **'경찰은 대기 시간 동안 도둑을 체포할 수 없어요'**
  String get errorCodePoliceWaitingTime;

  /// No description provided for @errorCodeCannotKickYourself.
  ///
  /// In ko, this message translates to:
  /// **'방장은 자기 자신을 강퇴할 수 없어요'**
  String get errorCodeCannotKickYourself;

  /// No description provided for @errorCodeNoticeNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 공지사항을 찾을 수 없어요'**
  String get errorCodeNoticeNotFound;

  /// No description provided for @errorCodeGameResultNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 게임 결과를 찾을 수 없어요'**
  String get errorCodeGameResultNotFound;

  /// No description provided for @errorCodeEtcReasonRequired.
  ///
  /// In ko, this message translates to:
  /// **'신고 유형이 기타일 때 사유를 입력해야 해요'**
  String get errorCodeEtcReasonRequired;

  /// No description provided for @errorCodeSelfReport.
  ///
  /// In ko, this message translates to:
  /// **'본인을 신고할 수 없어요'**
  String get errorCodeSelfReport;

  /// No description provided for @errorCodeDuplicateReport.
  ///
  /// In ko, this message translates to:
  /// **'해당 게임에서 이미 신고한 사용자예요'**
  String get errorCodeDuplicateReport;

  /// No description provided for @errorCodeReportNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 신고 내역이 존재하지 않아요'**
  String get errorCodeReportNotFound;

  /// No description provided for @errorCodeReportTargetNotFound.
  ///
  /// In ko, this message translates to:
  /// **'해당 게임에 존재하지 않는 참가자예요'**
  String get errorCodeReportTargetNotFound;

  /// No description provided for @errorCodeInvalidMeetingDate.
  ///
  /// In ko, this message translates to:
  /// **'모임 시간은 지금 이후로 골라주세요'**
  String get errorCodeInvalidMeetingDate;

  /// No description provided for @errorCodePostNotFound.
  ///
  /// In ko, this message translates to:
  /// **'이미 삭제된 모집글이에요'**
  String get errorCodePostNotFound;

  /// No description provided for @errorCodeForbiddenNotAuthor.
  ///
  /// In ko, this message translates to:
  /// **'작성자만 수정하거나 삭제할 수 있어요'**
  String get errorCodeForbiddenNotAuthor;

  /// No description provided for @errorCodeCountryNotSpecified.
  ///
  /// In ko, this message translates to:
  /// **'국가를 확인할 수 없는 곳이에요. 다른 곳에서 다시 시도해주세요'**
  String get errorCodeCountryNotSpecified;

  /// 맵 핑 선택 카드 — 상대 발견 핑 라벨
  ///
  /// In ko, this message translates to:
  /// **'발견'**
  String get pingFound;

  /// 맵 핑 선택 카드 — 상대 의심 핑 라벨
  ///
  /// In ko, this message translates to:
  /// **'의심'**
  String get pingSuspect;

  /// 핑 rate-limit 쿨다운 중 안내 (마침표 없음)
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 다시 시도해주세요'**
  String get pingCooldownNotice;

  /// 인게임 중도 퇴장 확인 다이얼로그 타이틀
  ///
  /// In ko, this message translates to:
  /// **'게임에서 나갈까요?'**
  String get gameLeaveConfirmTitle;

  /// 인게임 중도 퇴장 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 게임에서 나가게 돼요'**
  String get gameLeaveConfirmMessage;

  /// 인게임 중도 퇴장 실패 시 스낵바 메시지
  ///
  /// In ko, this message translates to:
  /// **'퇴장하지 못했어요. 잠시 후 다시 시도해주세요'**
  String get gameLeaveFailedMessage;

  /// No description provided for @gameEventArrestSuccessTitle.
  ///
  /// In ko, this message translates to:
  /// **'운영진 검거'**
  String get gameEventArrestSuccessTitle;

  /// 이벤트 모드 — 체포 성공 메시지
  ///
  /// In ko, this message translates to:
  /// **'{nickname} 검거 성공'**
  String gameEventArrestSuccessMessage(String nickname);

  /// No description provided for @gameEventArrestSuccessConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get gameEventArrestSuccessConfirm;

  /// No description provided for @errorEventArrestRequestFailed.
  ///
  /// In ko, this message translates to:
  /// **'체포 요청 전송에 실패했어요. 다시 시도해 주세요'**
  String get errorEventArrestRequestFailed;

  /// No description provided for @gameEventResultTitle.
  ///
  /// In ko, this message translates to:
  /// **'수사 종료'**
  String get gameEventResultTitle;

  /// 이벤트 모드 인게임 — 증거보드 진행판 제목
  ///
  /// In ko, this message translates to:
  /// **'검거 현황'**
  String get gameEventProgressTitle;

  /// 이벤트 모드 결과 — 검거한 운영진 수
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{운영진 {count}명 검거}}'**
  String gameEventResultArrestCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
