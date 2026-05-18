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

  /// auto-imported from lib/core/services/loading_message_service.dart:49
  ///
  /// In ko, this message translates to:
  /// **'처리 중...'**
  String get loadingDefault;

  /// auto-imported from lib/core/services/permission/location_permission_messages.dart:48
  ///
  /// In ko, this message translates to:
  /// **'위치 권한 안내'**
  String get permissionLocationFallbackTitle;

  /// auto-imported from lib/core/services/permission/location_permission_messages.dart:49
  ///
  /// In ko, this message translates to:
  /// **'위치 권한을 허용해주세요'**
  String get permissionLocationFallbackMessage;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:53
  ///
  /// In ko, this message translates to:
  /// **'새 버전 안내'**
  String get dialogUpdateOptionalTitle;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:54
  ///
  /// In ko, this message translates to:
  /// **'더 좋아진 새 버전이 있어요.\n업데이트하시겠어요?'**
  String get dialogUpdateOptionalMessage;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:55
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get dialogUpdateOptionalConfirm;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:56
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get dialogUpdateOptionalCancel;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:68
  ///
  /// In ko, this message translates to:
  /// **'업데이트 안내'**
  String get dialogUpdateMandatoryTitle;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:69
  ///
  /// In ko, this message translates to:
  /// **'새로운 버전이 출시되었어요.\n업데이트하시겠어요?'**
  String get dialogUpdateMandatoryMessage;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:70
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get dialogUpdateMandatoryConfirm;

  /// auto-imported from lib/core/services/remote_config/update_dialog_helper.dart:71
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get dialogUpdateMandatoryCancel;

  /// auto-imported from lib/core/constants/game_event_messages.dart:11
  ///
  /// In ko, this message translates to:
  /// **'제한 시간은 {minutes}분입니다'**
  String chatSystemGameStartTime(int minutes);

  /// auto-imported from lib/core/constants/game_event_messages.dart:14
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 게임이 시작됩니다.  모든 플레이어는 준비하세요!'**
  String get chatSystemGameStartReady;

  /// auto-imported from lib/core/constants/game_event_messages.dart:17
  ///
  /// In ko, this message translates to:
  /// **'게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다'**
  String get chatSystemGameStartReportTip;

  /// auto-imported from lib/core/constants/game_event_messages.dart:20
  ///
  /// In ko, this message translates to:
  /// **'게임 시작!  행운을 빕니다!'**
  String get chatSystemGameStartGo;

  /// auto-imported from lib/core/constants/game_event_messages.dart:25
  ///
  /// In ko, this message translates to:
  /// **'경찰이 곧 출동합니다.  도둑은 서둘러 이동하세요!'**
  String get chatSystemPoliceMoveWarning;

  /// auto-imported from lib/core/constants/game_event_messages.dart:28
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동!  도둑은 도망치세요!'**
  String get chatSystemPoliceMove;

  /// auto-imported from lib/core/constants/game_event_messages.dart:33
  ///
  /// In ko, this message translates to:
  /// **'현재 도둑의 위치가 공개됩니다!'**
  String get chatSystemLocationReveal;

  /// auto-imported from lib/core/constants/game_event_messages.dart:36
  ///
  /// In ko, this message translates to:
  /// **'현재 {count}명 도주 중!'**
  String chatSystemRemainingRobbers(int count);

  /// auto-imported from lib/core/constants/game_event_messages.dart:42
  ///
  /// In ko, this message translates to:
  /// **'@icon_police [{policeNickname}]님이 @icon_robber [{robberNickname}]님을 체포했습니다!'**
  String chatSystemArrest(String policeNickname, String robberNickname);

  /// auto-imported from lib/core/constants/game_event_messages.dart:47
  ///
  /// In ko, this message translates to:
  /// **'도둑이 탈옥했습니다! 지금 바로 체포하세요!'**
  String get chatSystemEscapeNotice;

  /// auto-imported from lib/core/constants/game_event_messages.dart:52
  ///
  /// In ko, this message translates to:
  /// **'게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!'**
  String get chatSystemFiveMinutesLeft;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:41
  ///
  /// In ko, this message translates to:
  /// **'서버 연결 시간이 초과되었습니다'**
  String get errorNetworkTimeout;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:49
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인하세요'**
  String get errorNetworkOffline;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:63
  ///
  /// In ko, this message translates to:
  /// **'서버에 문제가 발생했습니다'**
  String get errorServerInternal;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:71
  ///
  /// In ko, this message translates to:
  /// **'잘못된 요청입니다'**
  String get errorBadRequest;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:76
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했습니다'**
  String get errorUnauthorized;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:81
  ///
  /// In ko, this message translates to:
  /// **'접근 권한이 없습니다'**
  String get errorForbidden;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:86
  ///
  /// In ko, this message translates to:
  /// **'요청한 리소스를 찾을 수 없습니다'**
  String get errorNotFound;

  /// auto-imported from lib/core/network/dio_exception_handler.dart:91
  ///
  /// In ko, this message translates to:
  /// **'요청이 현재 상태와 충돌합니다'**
  String get errorConflict;

  /// auto-imported from lib/core/widgets/dialogs/app_dialog.dart:79
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get buttonConfirm;

  /// auto-imported from lib/core/widgets/dialogs/app_dialog.dart:267
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get buttonCancel;

  /// auto-imported from lib/core/widgets/dialogs/reconnect_modal.dart:158
  ///
  /// In ko, this message translates to:
  /// **'연결이 끊어졌어요. 재연결이 필요해요'**
  String get dialogReconnectMessage;

  /// auto-imported from lib/core/widgets/dialogs/reconnect_modal.dart:169
  ///
  /// In ko, this message translates to:
  /// **'연결 중...'**
  String get dialogReconnectButtonConnecting;

  /// auto-imported from lib/core/widgets/dialogs/reconnect_modal.dart:169
  ///
  /// In ko, this message translates to:
  /// **'재연결'**
  String get dialogReconnectButtonRetry;

  /// auto-imported from lib/core/widgets/pages/force_update_page.dart:41
  ///
  /// In ko, this message translates to:
  /// **'업데이트 필요'**
  String get pageForceUpdateTitle;

  /// auto-imported from lib/core/widgets/pages/force_update_page.dart:49
  ///
  /// In ko, this message translates to:
  /// **'새로운 버전이 출시되었어요\n업데이트 후 이용해 주세요!'**
  String get pageForceUpdateMessage;

  /// auto-imported from lib/core/widgets/pages/force_update_page.dart:60
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get pageForceUpdateButton;

  /// auto-imported from lib/core/widgets/pages/maintenance_page.dart:39
  ///
  /// In ko, this message translates to:
  /// **'서버 점검 중'**
  String get pageMaintenanceTitle;

  /// auto-imported from lib/core/widgets/pages/maintenance_page.dart:47
  ///
  /// In ko, this message translates to:
  /// **'더 나은 서비스를 위해 점검 중이에요\n잠시 후 다시 접속해 주세요!'**
  String get pageMaintenanceMessage;

  /// auto-imported from lib/core/widgets/buttons/social_login_button.dart:39
  ///
  /// In ko, this message translates to:
  /// **'Google로 시작하기'**
  String get buttonGoogleSignIn;

  /// auto-imported from lib/core/widgets/buttons/social_login_button.dart:86
  ///
  /// In ko, this message translates to:
  /// **'Apple로 시작하기'**
  String get buttonAppleSignIn;

  /// auto-imported from lib/core/widgets/buttons/zone_setting_button.dart:129
  ///
  /// In ko, this message translates to:
  /// **'반경 {km}km'**
  String zoneRadiusKm(String km);

  /// auto-imported from lib/core/widgets/buttons/zone_setting_button.dart:131
  ///
  /// In ko, this message translates to:
  /// **'반경 {radiusMeters}m'**
  String zoneRadiusMeter(String radiusMeters);

  /// auto-imported from lib/core/widgets/map/zone_setting_widget.dart:364
  ///
  /// In ko, this message translates to:
  /// **'반경'**
  String get zoneRadiusLabel;

  /// auto-imported from lib/core/utils/agreement_error_handler.dart:15
  ///
  /// In ko, this message translates to:
  /// **'필수 약관 미동의'**
  String get dialogAgreementRequiredTermsTitle;

  /// auto-imported from lib/core/errors/app_exception.dart:57
  ///
  /// In ko, this message translates to:
  /// **'로그인이 취소되었습니다'**
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

  /// auto-imported from assets/messages/loading_messages.json :: join_room.0
  ///
  /// In ko, this message translates to:
  /// **'잠입 준비 중...'**
  String get asset_loading_joinRoom;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.1
  ///
  /// In ko, this message translates to:
  /// **'작전에 합류하는 중...'**
  String get asset_loading_joinRoom477c;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.2
  ///
  /// In ko, this message translates to:
  /// **'비밀 통로로 진입 중...'**
  String get asset_loading_joinRoom24a9;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.3
  ///
  /// In ko, this message translates to:
  /// **'변장 확인 중...'**
  String get asset_loading_joinRoomCb98;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.4
  ///
  /// In ko, this message translates to:
  /// **'작전 투입 인원 확인 중...'**
  String get asset_loading_joinRoomF964;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_joinRoomB36a;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_joinRoomAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: join_room.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_joinRoom25aa;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.0
  ///
  /// In ko, this message translates to:
  /// **'작전 본부 설치 중...'**
  String get asset_loading_createRoom;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.1
  ///
  /// In ko, this message translates to:
  /// **'비밀 아지트 준비 중...'**
  String get asset_loading_createRoomF1fe;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.2
  ///
  /// In ko, this message translates to:
  /// **'작전 구역 확보 중...'**
  String get asset_loading_createRoom01f8;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.3
  ///
  /// In ko, this message translates to:
  /// **'비밀 지도 펼치는 중...'**
  String get asset_loading_createRoom5076;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.4
  ///
  /// In ko, this message translates to:
  /// **'무전기 주파수 맞추는 중...'**
  String get asset_loading_createRoomDd9e;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_createRoomB36a;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_createRoomAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: create_room.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_createRoom25aa;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.0
  ///
  /// In ko, this message translates to:
  /// **'변장 중...'**
  String get asset_loading_changeTeam;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.1
  ///
  /// In ko, this message translates to:
  /// **'위장 신분 변경 중...'**
  String get asset_loading_changeTeam681d;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.2
  ///
  /// In ko, this message translates to:
  /// **'신분 세탁 중...'**
  String get asset_loading_changeTeam1106;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.3
  ///
  /// In ko, this message translates to:
  /// **'이중 스파이 전환 중...'**
  String get asset_loading_changeTeam4d7a;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.4
  ///
  /// In ko, this message translates to:
  /// **'새 신분증 발급 중...'**
  String get asset_loading_changeTeam4cdc;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_changeTeamB36a;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_changeTeamAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: change_team.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_changeTeam25aa;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.0
  ///
  /// In ko, this message translates to:
  /// **'작전 개시 준비 중...'**
  String get asset_loading_startGame;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.1
  ///
  /// In ko, this message translates to:
  /// **'출동 준비 중...'**
  String get asset_loading_startGameA35d;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.2
  ///
  /// In ko, this message translates to:
  /// **'카운트다운 시작...'**
  String get asset_loading_startGame64c3;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.3
  ///
  /// In ko, this message translates to:
  /// **'무전기 켜는 중...'**
  String get asset_loading_startGame7a2f;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.4
  ///
  /// In ko, this message translates to:
  /// **'현장 요원 배치 중...'**
  String get asset_loading_startGame1b41;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_startGameB36a;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_startGameAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: start_game.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_startGame25aa;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.0
  ///
  /// In ko, this message translates to:
  /// **'작전 구역 설정 중...'**
  String get asset_loading_updateArea;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.1
  ///
  /// In ko, this message translates to:
  /// **'관할 구역 지정 중...'**
  String get asset_loading_updateArea8c32;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.2
  ///
  /// In ko, this message translates to:
  /// **'지도 위에 점 찍는 중...'**
  String get asset_loading_updateArea0183;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.3
  ///
  /// In ko, this message translates to:
  /// **'위성 사진 분석 중...'**
  String get asset_loading_updateArea2433;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.4
  ///
  /// In ko, this message translates to:
  /// **'작전 범위 계산 중...'**
  String get asset_loading_updateAreaDc8b;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_updateAreaB36a;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_updateAreaAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: update_area.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_updateArea25aa;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.0
  ///
  /// In ko, this message translates to:
  /// **'작전 지침 수정 중...'**
  String get asset_loading_saveSettings;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.1
  ///
  /// In ko, this message translates to:
  /// **'규칙 업데이트 중...'**
  String get asset_loading_saveSettingsFb58;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.2
  ///
  /// In ko, this message translates to:
  /// **'새로운 룰 적용 중...'**
  String get asset_loading_saveSettings65dc;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.3
  ///
  /// In ko, this message translates to:
  /// **'암호 변경 중...'**
  String get asset_loading_saveSettings5e80;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.4
  ///
  /// In ko, this message translates to:
  /// **'새 작전 코드 적용 중...'**
  String get asset_loading_saveSettings128d;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_saveSettingsB36a;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_saveSettingsAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: save_settings.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_saveSettings25aa;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.0
  ///
  /// In ko, this message translates to:
  /// **'신원 조회 중...'**
  String get asset_loading_loadProfile;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.1
  ///
  /// In ko, this message translates to:
  /// **'수배서 확인 중...'**
  String get asset_loading_loadProfile27ee;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.2
  ///
  /// In ko, this message translates to:
  /// **'신분증 검사 중...'**
  String get asset_loading_loadProfile6dac;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.3
  ///
  /// In ko, this message translates to:
  /// **'지문 대조 중...'**
  String get asset_loading_loadProfile23c6;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.4
  ///
  /// In ko, this message translates to:
  /// **'용의자 프로필 분석 중...'**
  String get asset_loading_loadProfile221d;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_loadProfileB36a;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_loadProfileAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: load_profile.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_loadProfile25aa;

  /// auto-imported from assets/messages/loading_messages.json :: logout.0
  ///
  /// In ko, this message translates to:
  /// **'철수 중...'**
  String get asset_loading_logout;

  /// auto-imported from assets/messages/loading_messages.json :: logout.1
  ///
  /// In ko, this message translates to:
  /// **'잠적 중...'**
  String get asset_loading_logout3031;

  /// auto-imported from assets/messages/logout_messages.json :: logout.2
  ///
  /// In ko, this message translates to:
  /// **'흔적 지우는 중...'**
  String get asset_loading_logoutCe40;

  /// auto-imported from assets/messages/loading_messages.json :: logout.3
  ///
  /// In ko, this message translates to:
  /// **'증거 인멸 중...'**
  String get asset_loading_logout0ba9;

  /// auto-imported from assets/messages/loading_messages.json :: logout.4
  ///
  /// In ko, this message translates to:
  /// **'비밀 통로로 탈출 중...'**
  String get asset_loading_logoutFc0d;

  /// auto-imported from assets/messages/loading_messages.json :: logout.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_logoutB36a;

  /// auto-imported from assets/messages/loading_messages.json :: logout.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_logoutAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: logout.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_logout25aa;

  /// auto-imported from assets/messages/loading_messages.json :: delete_account.0
  ///
  /// In ko, this message translates to:
  /// **'탈퇴 처리 중...'**
  String get asset_loading_deleteAccount;

  /// auto-imported from assets/messages/loading_messages.json :: delete_account.1
  ///
  /// In ko, this message translates to:
  /// **'기록 말소 중...'**
  String get asset_loading_deleteAccountC5fd;

  /// auto-imported from assets/messages/loading_messages.json :: delete_account.2
  ///
  /// In ko, this message translates to:
  /// **'신원 삭제 중...'**
  String get asset_loading_deleteAccount517f;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.0
  ///
  /// In ko, this message translates to:
  /// **'다시 현장으로 복귀 중...'**
  String get asset_loading_reconnect;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.1
  ///
  /// In ko, this message translates to:
  /// **'작전에 재합류하는 중...'**
  String get asset_loading_reconnectBa5f;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.2
  ///
  /// In ko, this message translates to:
  /// **'현장 복귀 준비 중...'**
  String get asset_loading_reconnect098b;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.3
  ///
  /// In ko, this message translates to:
  /// **'무전 채널 복구 중...'**
  String get asset_loading_reconnect429b;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.4
  ///
  /// In ko, this message translates to:
  /// **'비밀 주파수 재탐색 중...'**
  String get asset_loading_reconnect6b88;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.5
  ///
  /// In ko, this message translates to:
  /// **'설정 어딘가를 계속 누르면 비밀이 열린다던데...'**
  String get asset_loading_reconnectB36a;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.6
  ///
  /// In ko, this message translates to:
  /// **'앱 버전을 자꾸 누르면 뭔가 나올지도...?'**
  String get asset_loading_reconnectAaf8;

  /// auto-imported from assets/messages/loading_messages.json :: reconnect.7
  ///
  /// In ko, this message translates to:
  /// **'누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...'**
  String get asset_loading_reconnect25aa;

  /// auto-imported from assets/messages/loading_messages.json :: bug_report.0
  ///
  /// In ko, this message translates to:
  /// **'신고서 작성 중...'**
  String get asset_loading_bugReport;

  /// auto-imported from assets/messages/loading_messages.json :: bug_report.1
  ///
  /// In ko, this message translates to:
  /// **'본부에 보고서 제출 중...'**
  String get asset_loading_bugReportDd4b;

  /// auto-imported from assets/messages/loading_messages.json :: bug_report.2
  ///
  /// In ko, this message translates to:
  /// **'현장 사진 첨부 중...'**
  String get asset_loading_bugReport5d70;

  /// auto-imported from assets/messages/loading_messages.json :: bug_report.3
  ///
  /// In ko, this message translates to:
  /// **'사건 번호 부여 중...'**
  String get asset_loading_bugReport3c49;

  /// auto-imported from assets/messages/loading_messages.json :: bug_report.4
  ///
  /// In ko, this message translates to:
  /// **'수사반에 인계 중...'**
  String get asset_loading_bugReport83ca;

  /// auto-imported from assets/messages/location_permission_messages.json :: service_disabled.title
  ///
  /// In ko, this message translates to:
  /// **'위치 서비스가 꺼져 있습니다'**
  String get asset_locationpermission_serviceDisabledTitle;

  /// auto-imported from assets/messages/location_permission_messages.json :: service_disabled.home
  ///
  /// In ko, this message translates to:
  /// **'게임 중 도둑 위치를 경찰 팀에게 공유하고,\n구역 이탈을 감지하기 위해 위치 정보를 사용합니다\n기기 설정에서 위치 서비스를 켜주세요'**
  String get asset_locationpermission_serviceDisabledHome;

  /// auto-imported from assets/messages/location_permission_messages.json :: service_disabled.game
  ///
  /// In ko, this message translates to:
  /// **'게임에 복귀하려면 위치 서비스를 켜주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_serviceDisabledGame;

  /// auto-imported from assets/messages/location_permission_messages.json :: service_disabled.waiting_room
  ///
  /// In ko, this message translates to:
  /// **'게임 참가를 위해 위치 서비스를 켜주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_serviceDisabledWaitingRoom;

  /// auto-imported from assets/messages/location_permission_messages.json :: permission_denied.title
  ///
  /// In ko, this message translates to:
  /// **'위치 권한이 필요합니다'**
  String get asset_locationpermission_permissionDeniedTitle;

  /// auto-imported from assets/messages/location_permission_messages.json :: permission_denied.home
  ///
  /// In ko, this message translates to:
  /// **'게임 중 도둑 위치를 경찰 팀에게 공유하고,\n구역 이탈을 감지하기 위해 위치 정보를 사용합니다\n위치는 게임 참가자에게만 공유되며,\n게임 종료 시 즉시 중단됩니다'**
  String get asset_locationpermission_permissionDeniedHome;

  /// auto-imported from assets/messages/location_permission_messages.json :: permission_denied.game
  ///
  /// In ko, this message translates to:
  /// **'게임에 복귀하려면 위치 권한을 허용해주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_permissionDeniedGame;

  /// auto-imported from assets/messages/location_permission_messages.json :: permission_denied.waiting_room
  ///
  /// In ko, this message translates to:
  /// **'게임 참가를 위해 위치 권한을 허용해주세요\n설정에서 허용 후 앱을 재시작해주세요'**
  String get asset_locationpermission_permissionDeniedWaitingRoom;

  /// auto-imported from lib/features/session/data/repositories/session_repository_impl.dart:80
  ///
  /// In ko, this message translates to:
  /// **'게임 방 생성 중 예기치 않은 오류가 발생했습니다'**
  String get dialogsessionRepositoryImplMessage;

  /// auto-imported from lib/features/session/data/repositories/session_repository_impl.dart:105
  ///
  /// In ko, this message translates to:
  /// **'참여 중인 게임 조회 중 예기치 않은 오류가 발생했습니다'**
  String get dialogsessionRepositoryImplMessageAddf;

  /// auto-imported from lib/features/session/domain/entities/session_settings.dart:22
  ///
  /// In ko, this message translates to:
  /// **'{maxPlayers}명'**
  String session_sessionSettings_L22(String maxPlayers);

  /// auto-imported from lib/features/session/domain/entities/session_settings.dart:27
  ///
  /// In ko, this message translates to:
  /// **'{roundTimeMinutes}분'**
  String session_sessionSettings_L27(int roundTimeMinutes);

  /// auto-imported from lib/features/session/domain/entities/session_settings.dart:32
  ///
  /// In ko, this message translates to:
  /// **'{locationShareMinutes}분'**
  String session_sessionSettings_L32(int locationShareMinutes);

  /// auto-imported from lib/features/session/domain/entities/session_settings.dart:37
  ///
  /// In ko, this message translates to:
  /// **'도둑 도망 후 {policeStartDelayMinutes}분 뒤'**
  String session_sessionSettings_L37(int policeStartDelayMinutes);

  /// auto-imported from lib/features/session/domain/entities/zone_info.dart:25
  ///
  /// In ko, this message translates to:
  /// **'반경 {km}km'**
  String session_zoneInfo_L25(String km);

  /// auto-imported from lib/features/session/domain/entities/zone_info.dart:27
  ///
  /// In ko, this message translates to:
  /// **'반경 {radiusMeters}m'**
  String session_zoneInfo_L27(String radiusMeters);

  /// auto-imported from lib/features/session/presentation/pages/game_settings_edit_page.dart:110
  ///
  /// In ko, this message translates to:
  /// **'설정 저장에 실패했습니다'**
  String get session_gameSettingsEditPage_L110;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_edit_page.dart:146
  ///
  /// In ko, this message translates to:
  /// **'설정 수정'**
  String get session_gameSettingsEditPage_L146;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_edit_page.dart:197
  ///
  /// In ko, this message translates to:
  /// **'저장 중...'**
  String get session_gameSettingsEditPage_L197;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_edit_page.dart:197
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get session_gameSettingsEditPage_L197_1;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_page.dart:140
  ///
  /// In ko, this message translates to:
  /// **'영역 저장에 실패했습니다'**
  String get session_gameSettingsPage_L140;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_page.dart:190
  ///
  /// In ko, this message translates to:
  /// **'게임 설정'**
  String get session_gameSettingsPage_L190;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_page.dart:210
  ///
  /// In ko, this message translates to:
  /// **'구역 정보를 불러올 수 없습니다'**
  String get session_gameSettingsPage_L210;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_page.dart:228
  ///
  /// In ko, this message translates to:
  /// **'설정 정보를 불러올 수 없습니다'**
  String get session_gameSettingsPage_L228;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_page.dart:270
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get session_gameSettingsPage_L270;

  /// auto-imported from lib/features/session/presentation/pages/game_settings_page.dart:275
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get session_gameSettingsPage_L275;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:108
  ///
  /// In ko, this message translates to:
  /// **'새로운 게임을 만들 수 있어요'**
  String get session_homePage_L108;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:113
  ///
  /// In ko, this message translates to:
  /// **'초대 코드를 입력하면 게임에 참가할 수 있어요'**
  String get session_homePage_L113;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:136
  ///
  /// In ko, this message translates to:
  /// **'주변을 확인하며 이용해 주세요'**
  String get dialoghomePageTitle;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:137
  ///
  /// In ko, this message translates to:
  /// **'게임 중 화면에만 집중하면 위험할 수 있어요\n도로 및 보행 환경을 확인하며 안전하게 이용해 주세요'**
  String get dialoghomePageMessage;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:138
  ///
  /// In ko, this message translates to:
  /// **'확인했어요!'**
  String get dialoghomePageConfirm;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:158
  ///
  /// In ko, this message translates to:
  /// **'오늘은 다시 보지 않기'**
  String get session_homePage_L158;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:250
  ///
  /// In ko, this message translates to:
  /// **'이미 참가 중인 게임이 있습니다'**
  String get dialoghomePageMessage50b3;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:241
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 게임 상태입니다'**
  String get dialoghomePageMessage89ff;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:334
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get dialoghomePageConfirm5435;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:286
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get dialoghomePageCancel;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:330
  ///
  /// In ko, this message translates to:
  /// **'끊김 없는 게임을 위해'**
  String get dialoghomePageTitleEeea;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:332
  ///
  /// In ko, this message translates to:
  /// **'앱 설정 → 배터리 → 제한 없음으로 변경해주세요\n'**
  String get session_homePage_L332;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:333
  ///
  /// In ko, this message translates to:
  /// **'그래야 화면이 꺼져도 게임이 끊기지 않아요'**
  String get session_homePage_L333;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:432
  ///
  /// In ko, this message translates to:
  /// **'참여에 실패했습니다. 초대 코드를 확인해주세요'**
  String get session_homePage_L432;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:445
  ///
  /// In ko, this message translates to:
  /// **'참여에 실패했습니다. 다시 시도해주세요'**
  String get dialoghomePageMessage8155;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:487
  ///
  /// In ko, this message translates to:
  /// **'방 참여하기'**
  String get dialoghomePageTitle879f;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:490
  ///
  /// In ko, this message translates to:
  /// **'참여코드를 입력하세요'**
  String get fieldhomePageHint;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:502
  ///
  /// In ko, this message translates to:
  /// **'초대코드 QR을 스캔하세요'**
  String get dialoghomePageTitle86c1;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:534
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get dialoghomePageCancel218e;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:535
  ///
  /// In ko, this message translates to:
  /// **'참여하기'**
  String get dialoghomePageConfirm665b;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:601
  ///
  /// In ko, this message translates to:
  /// **'경찰과도둑'**
  String get session_homePage_L601;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:652
  ///
  /// In ko, this message translates to:
  /// **'준비중입니다'**
  String get dialoghomePageMessage9e36;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:661
  ///
  /// In ko, this message translates to:
  /// **'너무 기대 돼\n이번에는 어떤 역할을 할까?'**
  String get session_homePage_L661;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:677
  ///
  /// In ko, this message translates to:
  /// **'방 만들기'**
  String get session_homePage_L677;

  /// auto-imported from lib/features/session/presentation/pages/home_page.dart:684
  ///
  /// In ko, this message translates to:
  /// **'방 참여하기'**
  String get session_homePage_L684;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:160
  ///
  /// In ko, this message translates to:
  /// **'게임할 구역을 설정해요.\n먼저 플레이그라운드를 지정하세요'**
  String get session_sessionCreationFlowPage_L160;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:167
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙을 정해요\n숫자를 탭하면 직접 입력할 수 있어요'**
  String get session_sessionCreationFlowPage_L167;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:374
  ///
  /// In ko, this message translates to:
  /// **'게임 방 생성에 실패했습니다. 다시 시도해주세요'**
  String get session_sessionCreationFlowPage_L374;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:401
  ///
  /// In ko, this message translates to:
  /// **'이미 참가 중인 게임이 있습니다'**
  String get dialogsessionCreationFlowPageMessage;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:423
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 게임 상태입니다'**
  String get dialogsessionCreationFlowPageMessage89ff;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:483
  ///
  /// In ko, this message translates to:
  /// **'구역 선택을 먼저 설정할까요?'**
  String get session_sessionCreationFlowPage_L483;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:484
  ///
  /// In ko, this message translates to:
  /// **'인원을 설정해요'**
  String get session_sessionCreationFlowPage_L484;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:485
  ///
  /// In ko, this message translates to:
  /// **'기본 정보를 설정해요'**
  String get session_sessionCreationFlowPage_L485;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:486
  ///
  /// In ko, this message translates to:
  /// **'최종 설정을 확인해요'**
  String get session_sessionCreationFlowPage_L486;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:491
  ///
  /// In ko, this message translates to:
  /// **'게임에 필요한 구역을 설정해요'**
  String get session_sessionCreationFlowPage_L491;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:492
  ///
  /// In ko, this message translates to:
  /// **'최소 2명부터 게임 진행이 가능해요'**
  String get session_sessionCreationFlowPage_L492;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:493
  ///
  /// In ko, this message translates to:
  /// **'게임을 진행할 때, 꼭 필요한 정보들이에요'**
  String get session_sessionCreationFlowPage_L493;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:494
  ///
  /// In ko, this message translates to:
  /// **'방 생성 전 마지막으로 설정을 확인할까요?'**
  String get session_sessionCreationFlowPage_L494;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:503
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get session_sessionCreationFlowPage_L503;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:505
  ///
  /// In ko, this message translates to:
  /// **'방 생성하기'**
  String get session_sessionCreationFlowPage_L505;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:507
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get session_sessionCreationFlowPage_L507;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:660
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get session_sessionCreationFlowPage_L660;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:665
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get session_sessionCreationFlowPage_L665;

  /// auto-imported from lib/features/session/presentation/pages/session_creation_flow_page.dart:676
  ///
  /// In ko, this message translates to:
  /// **'구역 정보를 먼저 설정해주세요'**
  String get session_sessionCreationFlowPage_L676;

  /// auto-imported from lib/features/session/presentation/pages/setup_playground_page.dart:135
  ///
  /// In ko, this message translates to:
  /// **'여기를 누르면 반경을 직접 입력할 수 있어요'**
  String get session_setupPlaygroundPage_L135;

  /// auto-imported from lib/features/session/presentation/pages/setup_playground_page.dart:195
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get session_setupPlaygroundPage_L195;

  /// auto-imported from lib/features/session/presentation/pages/setup_playground_page.dart:212
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get session_setupPlaygroundPage_L212;

  /// auto-imported from lib/features/session/presentation/pages/setup_playground_page.dart:233
  ///
  /// In ko, this message translates to:
  /// **'게임이 진행될 전체 구역의 크기를 설정해요'**
  String get session_setupPlaygroundPage_L233;

  /// auto-imported from lib/features/session/presentation/pages/setup_playground_page.dart:267
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get session_setupPlaygroundPage_L267;

  /// auto-imported from lib/features/session/presentation/pages/setup_prison_page.dart:210
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get session_setupPrisonPage_L210;

  /// auto-imported from lib/features/session/presentation/pages/setup_prison_page.dart:227
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get session_setupPrisonPage_L227;

  /// auto-imported from lib/features/session/presentation/pages/setup_prison_page.dart:248
  ///
  /// In ko, this message translates to:
  /// **'도둑을 잡아둘 감옥의 위치와 크기를 설정해요'**
  String get session_setupPrisonPage_L248;

  /// auto-imported from lib/features/session/presentation/pages/setup_prison_page.dart:286
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드를 먼저 설정해주세요'**
  String get session_setupPrisonPage_L286;

  /// auto-imported from lib/features/session/presentation/pages/setup_prison_page.dart:287
  ///
  /// In ko, this message translates to:
  /// **'감옥이 플레이그라운드 범위를 벗어났어요'**
  String get session_setupPrisonPage_L287;

  /// auto-imported from lib/features/session/presentation/pages/setup_prison_page.dart:299
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get session_setupPrisonPage_L299;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:201
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get dialogwaitingRoomPageConfirm;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:202
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get dialogwaitingRoomPageCancel;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:364
  ///
  /// In ko, this message translates to:
  /// **'포근포근곰...'**
  String get session_waitingRoomPage_L364;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:544
  ///
  /// In ko, this message translates to:
  /// **'방에 참여할 수 없어요'**
  String get dialogwaitingRoomPageTitle;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:545
  ///
  /// In ko, this message translates to:
  /// **'해당 게임에 참가하지 않은 사용자입니다'**
  String get session_waitingRoomPage_L545;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:546
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get dialogwaitingRoomPageConfirm3ce8;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:631
  ///
  /// In ko, this message translates to:
  /// **'이 버튼을 눌러 다른 팀으로 이동할 수 있어요'**
  String get session_waitingRoomPage_L631;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:637
  ///
  /// In ko, this message translates to:
  /// **'친구에게 초대 코드를 공유할 수 있어요'**
  String get session_waitingRoomPage_L637;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:642
  ///
  /// In ko, this message translates to:
  /// **'게임 설정을 확인할 수 있어요'**
  String get session_waitingRoomPage_L642;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:647
  ///
  /// In ko, this message translates to:
  /// **'준비가 되면 눌러주세요'**
  String get session_waitingRoomPage_L647;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:679
  ///
  /// In ko, this message translates to:
  /// **'인게임 화면 미리 보기'**
  String get dialogwaitingRoomPageTitle1946;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:680
  ///
  /// In ko, this message translates to:
  /// **'게임이 시작되면 어떻게 동작하는지\n한 번 확인하고 시작해볼까요?'**
  String get dialogwaitingRoomPageMessage;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:681
  ///
  /// In ko, this message translates to:
  /// **'보러 가기'**
  String get dialogwaitingRoomPageConfirmA2d8;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:772
  ///
  /// In ko, this message translates to:
  /// **'{nickname}님을 내보낼까요?'**
  String dialogwaitingRoomPageTitleBc54(String nickname);

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:773
  ///
  /// In ko, this message translates to:
  /// **'강퇴된 유저는 방에서 즉시 내보내져요\n다시 방에 참가하려면 초대코드를 입력해야 해요'**
  String get dialogwaitingRoomPageMessageB302;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:774
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get dialogwaitingRoomPageCancelD9de;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:775
  ///
  /// In ko, this message translates to:
  /// **'내보내기'**
  String get dialogwaitingRoomPageConfirmC08c;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:804
  ///
  /// In ko, this message translates to:
  /// **'강퇴 처리 중 오류가 발생했어요'**
  String get dialogwaitingRoomPageMessageE87b;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:932
  ///
  /// In ko, this message translates to:
  /// **'방에서 내보내졌어요'**
  String get dialogwaitingRoomPageTitle8208;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:933
  ///
  /// In ko, this message translates to:
  /// **'다시 참가하려면 초대코드를 입력해야 해요'**
  String get dialogwaitingRoomPageMessage64a2;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:942
  ///
  /// In ko, this message translates to:
  /// **'{kickedNickname}님이 내보내졌어요'**
  String dialogwaitingRoomPageMessage36a5(String kickedNickname);

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1030
  ///
  /// In ko, this message translates to:
  /// **'팀 변경에 실패했어요'**
  String get session_waitingRoomPage_L1030;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1062
  ///
  /// In ko, this message translates to:
  /// **'준비 상태 변경에 실패했어요'**
  String get session_waitingRoomPage_L1062;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1099
  ///
  /// In ko, this message translates to:
  /// **'게임 시작에 실패했어요'**
  String get session_waitingRoomPage_L1099;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1110
  ///
  /// In ko, this message translates to:
  /// **'방을 나가시겠어요?'**
  String get dialogwaitingRoomPageTitleFfec;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1111
  ///
  /// In ko, this message translates to:
  /// **'나가면 다시 초대코드를 입력해야 해요'**
  String get dialogwaitingRoomPageMessage3930;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1112
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get dialogwaitingRoomPageConfirmC0a3;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1130
  ///
  /// In ko, this message translates to:
  /// **'퇴장 처리 중 오류가 발생했습니다'**
  String get session_waitingRoomPage_L1130;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1176
  ///
  /// In ko, this message translates to:
  /// **'초대코드를 생성했어요'**
  String get dialogwaitingRoomPageTitleA5bb;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1177
  ///
  /// In ko, this message translates to:
  /// **'친구에게 코드를 공유하고 게임에 참여해 보세요!'**
  String get dialogwaitingRoomPageMessage06a6;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1200
  ///
  /// In ko, this message translates to:
  /// **'코드가 복사되었습니다'**
  String get dialogwaitingRoomPageMessage4785;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1234
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get dialogwaitingRoomPageCancel218e;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1235
  ///
  /// In ko, this message translates to:
  /// **'공유하기'**
  String get dialogwaitingRoomPageConfirm27f8;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1511
  ///
  /// In ko, this message translates to:
  /// **'게임 시작'**
  String get session_waitingRoomPage_L1511;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1526
  ///
  /// In ko, this message translates to:
  /// **'준비 완료'**
  String get session_waitingRoomPage_L1526;

  /// auto-imported from lib/features/session/presentation/pages/waiting_room_page.dart:1537
  ///
  /// In ko, this message translates to:
  /// **'준비'**
  String get session_waitingRoomPage_L1537;

  /// auto-imported from lib/features/session/presentation/pages/zone_preview_page.dart:122
  ///
  /// In ko, this message translates to:
  /// **'게임 구역'**
  String get session_zonePreviewPage_L122;

  /// auto-imported from lib/features/session/presentation/pages/zone_preview_page.dart:145
  ///
  /// In ko, this message translates to:
  /// **'현재 설정된 게임 구역이에요'**
  String get session_zonePreviewPage_L145;

  /// auto-imported from lib/features/session/presentation/providers/waiting_room_participants_provider.dart:81
  ///
  /// In ko, this message translates to:
  /// **'포근포근곰...'**
  String get session_waitingRoomParticipantsProvider_L81;

  /// auto-imported from lib/features/session/presentation/providers/waiting_room_participants_provider.dart:87
  ///
  /// In ko, this message translates to:
  /// **'오동통 너구리'**
  String get session_waitingRoomParticipantsProvider_L87;

  /// auto-imported from lib/features/session/presentation/providers/waiting_room_participants_provider.dart:93
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get session_waitingRoomParticipantsProvider_L93;

  /// auto-imported from lib/features/session/presentation/providers/waiting_room_participants_provider.dart:99
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get session_waitingRoomParticipantsProvider_L99;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:38
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙'**
  String get dialoggameRulesContentTitle;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:49
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get dialoggameRulesContentCancel;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:50
  ///
  /// In ko, this message translates to:
  /// **'인게임 보기'**
  String get dialoggameRulesContentConfirm;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:95
  ///
  /// In ko, this message translates to:
  /// **'경찰은 모든 도둑을 잡아서'**
  String get session_gameRulesContent_L95;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:96
  ///
  /// In ko, this message translates to:
  /// **'체포하면,'**
  String get session_gameRulesContent_L96;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:97
  ///
  /// In ko, this message translates to:
  /// **'\n도둑은'**
  String get session_gameRulesContent_L97;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:98
  ///
  /// In ko, this message translates to:
  /// **'제한 시간이 끝날 때까지 버티면'**
  String get session_gameRulesContent_L98;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:99
  ///
  /// In ko, this message translates to:
  /// **'승리해요'**
  String get session_gameRulesContent_L99;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:108
  ///
  /// In ko, this message translates to:
  /// **'도둑팀의 위치는'**
  String get session_gameRulesContent_L108;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:109
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분마다'**
  String session_gameRulesContent_L109(int minutes);

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:110
  ///
  /// In ko, this message translates to:
  /// **'경찰팀에게 공유돼요'**
  String get session_gameRulesContent_L110;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:118
  ///
  /// In ko, this message translates to:
  /// **'지정된 게임 구역에서 벗어나면 안 돼요'**
  String get session_gameRulesContent_L118;

  /// auto-imported from lib/features/session/presentation/widgets/game_rules_content.dart:119
  ///
  /// In ko, this message translates to:
  /// **'\n→ 구역 밖으로 나가면 화면이 잠겨요'**
  String get session_gameRulesContent_L119;

  /// auto-imported from lib/features/session/presentation/widgets/session_code_card.dart:42
  ///
  /// In ko, this message translates to:
  /// **'코드가 복사되었습니다'**
  String get dialogsessionCodeCardMessage;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart:97
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드'**
  String get dialogstep0SelectAreaContentTitle;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_0_select_area_content.dart:108
  ///
  /// In ko, this message translates to:
  /// **'감옥'**
  String get dialogstep0SelectAreaContentTitle5bc0;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart:48
  ///
  /// In ko, this message translates to:
  /// **'최대 참가자'**
  String get fieldstep1ParticipantSettingsContentLabel;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_1_participant_settings_content.dart:52
  ///
  /// In ko, this message translates to:
  /// **'명'**
  String get session_step1ParticipantSettingsContent_L52;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:75
  ///
  /// In ko, this message translates to:
  /// **'라운드 제한 시간'**
  String get fieldstep2GameSettingsContentLabel;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:79
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get session_step2GameSettingsContent_L79;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:92
  ///
  /// In ko, this message translates to:
  /// **'도둑 위치 공유 간격'**
  String get fieldstep2GameSettingsContentLabel5ab2;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:97
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get session_step2GameSettingsContent_L97;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:104
  ///
  /// In ko, this message translates to:
  /// **'도둑의 위치가 공유되지 않아요!'**
  String get session_step2GameSettingsContent_L104;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:111
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동 시간'**
  String get fieldstep2GameSettingsContentLabelCe3b;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:115
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get session_step2GameSettingsContent_L115;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:117
  ///
  /// In ko, this message translates to:
  /// **'도둑 도망 후'**
  String get session_step2GameSettingsContent_L117;

  /// auto-imported from lib/features/session/presentation/widgets/session_creation_steps/step_2_game_settings_content.dart:118
  ///
  /// In ko, this message translates to:
  /// **'뒤'**
  String get session_step2GameSettingsContent_L118;

  /// auto-imported from lib/features/session/presentation/widgets/session_step_layout.dart:42
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get session_sessionStepLayout_L42;

  /// auto-imported from lib/features/session/presentation/widgets/setting_list_card.dart:52
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get dialogsettingListCardTitle;

  /// auto-imported from lib/features/session/presentation/widgets/setting_list_card.dart:79
  ///
  /// In ko, this message translates to:
  /// **'참여 인원'**
  String get fieldsettingListCardLabel;

  /// auto-imported from lib/features/session/presentation/widgets/setting_list_card.dart:85
  ///
  /// In ko, this message translates to:
  /// **'라운드 제한 시간'**
  String get fieldsettingListCardLabelEc5e;

  /// auto-imported from lib/features/session/presentation/widgets/setting_list_card.dart:91
  ///
  /// In ko, this message translates to:
  /// **'위치 공유 간격'**
  String get fieldsettingListCardLabelA1b3;

  /// auto-imported from lib/features/session/presentation/widgets/setting_list_card.dart:97
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동 시간'**
  String get fieldsettingListCardLabelCe3b;

  /// auto-imported from lib/features/session/presentation/widgets/team_section.dart:116
  ///
  /// In ko, this message translates to:
  /// **'경찰팀'**
  String get session_teamSection_L116;

  /// auto-imported from lib/features/session/presentation/widgets/team_section.dart:116
  ///
  /// In ko, this message translates to:
  /// **'도둑팀'**
  String get session_teamSection_L116_1;

  /// auto-imported from lib/features/session/presentation/widgets/team_section.dart:178
  ///
  /// In ko, this message translates to:
  /// **'현재 {length}명'**
  String session_teamSection_L178(int length);

  /// auto-imported from lib/features/session/presentation/widgets/zone_list_card.dart:51
  ///
  /// In ko, this message translates to:
  /// **'구역'**
  String get dialogzoneListCardTitle;

  /// auto-imported from lib/features/auth/data/repositories/auth_repository_impl.dart:136
  ///
  /// In ko, this message translates to:
  /// **'로그인 중 오류가 발생했습니다'**
  String get dialogauthRepositoryImplMessage;

  /// auto-imported from lib/features/auth/data/repositories/auth_repository_impl.dart:180
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 중 오류가 발생했습니다'**
  String get dialogauthRepositoryImplMessage993d;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:31
  ///
  /// In ko, this message translates to:
  /// **'로그인 정보를 가져올 수 없습니다. 다시 시도해주세요'**
  String get auth_firebaseAuthErrorHandler_L31;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:33
  ///
  /// In ko, this message translates to:
  /// **'인증 토큰 발급에 실패했습니다. 다시 시도해주세요'**
  String get auth_firebaseAuthErrorHandler_L33;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:35
  ///
  /// In ko, this message translates to:
  /// **'Firebase 인증 토큰 검증에 실패했습니다. 다시 로그인해주세요'**
  String get auth_firebaseAuthErrorHandler_L35;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:37
  ///
  /// In ko, this message translates to:
  /// **'로그인이 취소되었습니다'**
  String get auth_firebaseAuthErrorHandler_L37;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:39
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요'**
  String get auth_firebaseAuthErrorHandler_L39;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:41
  ///
  /// In ko, this message translates to:
  /// **'잘못된 인증 정보입니다'**
  String get auth_firebaseAuthErrorHandler_L41;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:43
  ///
  /// In ko, this message translates to:
  /// **'비활성화된 계정입니다'**
  String get auth_firebaseAuthErrorHandler_L43;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:45
  ///
  /// In ko, this message translates to:
  /// **'너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요'**
  String get auth_firebaseAuthErrorHandler_L45;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:47
  ///
  /// In ko, this message translates to:
  /// **'이 로그인 방법은 현재 사용할 수 없습니다'**
  String get auth_firebaseAuthErrorHandler_L47;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:49
  ///
  /// In ko, this message translates to:
  /// **'Firebase 설정에 문제가 있습니다. 잠시 후 다시 시도해주세요'**
  String get auth_firebaseAuthErrorHandler_L49;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:51
  ///
  /// In ko, this message translates to:
  /// **'Firebase 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요'**
  String get auth_firebaseAuthErrorHandler_L51;

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:55
  ///
  /// In ko, this message translates to:
  /// **'{provider} 로그인에 실패했습니다. 다시 시도해주세요'**
  String auth_firebaseAuthErrorHandler_L55(int provider);

  /// auto-imported from lib/features/auth/domain/utils/firebase_auth_error_handler.dart:57
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다. 다시 시도해주세요'**
  String get auth_firebaseAuthErrorHandler_L57;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:57
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get dialogagreementPageTitle;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:73
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get dialogagreementPageTitleBe29;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:85
  ///
  /// In ko, this message translates to:
  /// **'위치정보 이용약관'**
  String get dialogagreementPageTitle6dcc;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:97
  ///
  /// In ko, this message translates to:
  /// **'마케팅 정보 수신'**
  String get dialogagreementPageTitle76b8;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:107
  ///
  /// In ko, this message translates to:
  /// **'동의하고 시작하기'**
  String get auth_agreementPage_L107;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:127
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용을 위해\n약관에 동의해주세요'**
  String get auth_agreementPage_L127;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:135
  ///
  /// In ko, this message translates to:
  /// **'필수 약관에 모두 동의해야 서비스를 이용하실 수 있어요'**
  String get auth_agreementPage_L135;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:173
  ///
  /// In ko, this message translates to:
  /// **'아직 네트워크에 연결되지 않았어요'**
  String get dialogagreementPageMessage;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:179
  ///
  /// In ko, this message translates to:
  /// **'필수 약관에 모두 동의해주세요'**
  String get dialogagreementPageMessage24a8;

  /// auto-imported from lib/features/auth/presentation/pages/agreement_page.dart:184
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 발생했습니다. 다시 시도해주세요'**
  String get auth_agreementPage_L184;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:64
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get dialogloginPageTitle;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:74
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get dialogloginPageTitle2aa8;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:84
  ///
  /// In ko, this message translates to:
  /// **'위치정보 이용약관'**
  String get dialogloginPageTitle6dcc;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:107
  ///
  /// In ko, this message translates to:
  /// **'회원탈퇴가 완료되었습니다'**
  String get dialogloginPageMessage;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:127
  ///
  /// In ko, this message translates to:
  /// **'만 14세 이상이신가요?'**
  String get dialogloginPageTitleA40f;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:128
  ///
  /// In ko, this message translates to:
  /// **'경찰과 도둑은 만 14세 미만 회원가입이 불가능해요.\n해당 정보는 가입 금지 확인 용도로만 사용하고 있어요'**
  String get dialogloginPageMessageBa5d;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:129
  ///
  /// In ko, this message translates to:
  /// **'네'**
  String get dialogloginPageConfirm;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:130
  ///
  /// In ko, this message translates to:
  /// **'아니요'**
  String get dialogloginPageCancel;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:188
  ///
  /// In ko, this message translates to:
  /// **'로그인이 취소되었습니다'**
  String get dialogloginPageMessageFe9d;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:166
  ///
  /// In ko, this message translates to:
  /// **'로그인 중 오류가 발생했습니다'**
  String get auth_loginPage_L166;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:191
  ///
  /// In ko, this message translates to:
  /// **'Apple 로그인 중 오류가 발생했습니다'**
  String get auth_loginPage_L191;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:260
  ///
  /// In ko, this message translates to:
  /// **'만 14세 미만은 서비스를 이용할 수 없습니다'**
  String get auth_loginPage_L260;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:284
  ///
  /// In ko, this message translates to:
  /// **'로그인 시'**
  String get auth_loginPage_L284;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:286
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get auth_loginPage_L286;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:295
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get auth_loginPage_L295;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:304
  ///
  /// In ko, this message translates to:
  /// **'위치정보 이용약관'**
  String get auth_loginPage_L304;

  /// auto-imported from lib/features/auth/presentation/pages/login_page.dart:311
  ///
  /// In ko, this message translates to:
  /// **'에 동의합니다'**
  String get auth_loginPage_L311;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:190
  ///
  /// In ko, this message translates to:
  /// **'닉네임이 저장되었어요'**
  String get dialognicknameSetupPageMessage;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:248
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 설정해요'**
  String get auth_nicknameSetupPage_L248;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:257
  ///
  /// In ko, this message translates to:
  /// **'서비스 내에서 계속 사용될 닉네임이에요\n1~10글자로 생성할 수 있어요'**
  String get auth_nicknameSetupPage_L257;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:281
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get auth_nicknameSetupPage_L281;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:308
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 입력하세요'**
  String get auth_nicknameSetupPage_L308;

  /// auto-imported from lib/features/auth/presentation/widgets/nickname_setup_page.dart:336
  ///
  /// In ko, this message translates to:
  /// **'중복 확인'**
  String get auth_nicknameSetupPage_L336;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:354
  ///
  /// In ko, this message translates to:
  /// **'1글자 미만의 닉네임은 사용할 수 없어요'**
  String get auth_nicknameSetupPage_L354;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:359
  ///
  /// In ko, this message translates to:
  /// **'중복된 닉네임이에요. 다른 닉네임을 입력하세요'**
  String get auth_nicknameSetupPage_L359;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:364
  ///
  /// In ko, this message translates to:
  /// **'사용 가능한 닉네임이에요'**
  String get auth_nicknameSetupPage_L364;

  /// auto-imported from lib/features/auth/presentation/pages/nickname_setup_page.dart:369
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했어요. 다시 시도해주세요'**
  String get auth_nicknameSetupPage_L369;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:48
  ///
  /// In ko, this message translates to:
  /// **'다시 현장으로 복귀 중...'**
  String get auth_splashPage_L48;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:208
  ///
  /// In ko, this message translates to:
  /// **'다시 현장으로 복귀 중...'**
  String get auth_splashPage_L208;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:329
  ///
  /// In ko, this message translates to:
  /// **'아직 네트워크에 연결되지 않았어요'**
  String get dialogsplashPageMessage;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:350
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결 실패'**
  String get dialogsplashPageTitle;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:351
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결을 확인한 후\n다시 시도해주세요'**
  String get dialogsplashPageMessage665f;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:352
  ///
  /// In ko, this message translates to:
  /// **'재시도'**
  String get dialogsplashPageConfirm;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:395
  ///
  /// In ko, this message translates to:
  /// **'잠시만 기다려주세요'**
  String get auth_splashPage_L395;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:412
  ///
  /// In ko, this message translates to:
  /// **'by 동심지키미'**
  String get auth_splashPage_L412;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:444
  ///
  /// In ko, this message translates to:
  /// **'인터넷 연결이 필요합니다'**
  String get auth_splashPage_L444;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:450
  ///
  /// In ko, this message translates to:
  /// **'연결 상태를 확인한 후\n다시 시도해주세요'**
  String get auth_splashPage_L450;

  /// auto-imported from lib/features/auth/presentation/pages/splash_page.dart:461
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get auth_splashPage_L461;

  /// auto-imported from lib/features/auth/presentation/providers/agreement_provider.dart:129
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 발생했습니다. 다시 시도해주세요'**
  String get dialogagreementProviderMessage;

  /// auto-imported from lib/features/auth/presentation/providers/auth_provider.dart:129
  ///
  /// In ko, this message translates to:
  /// **'사유: {message}'**
  String auth_authProvider_L129(String message);

  /// auto-imported from lib/features/auth/presentation/providers/auth_provider.dart:260
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다'**
  String get dialogauthProviderMessage;

  /// auto-imported from lib/features/auth/presentation/providers/auth_provider.dart:319
  ///
  /// In ko, this message translates to:
  /// **'로그아웃에 실패했습니다'**
  String get dialogauthProviderMessage222f;

  /// auto-imported from lib/features/auth/presentation/widgets/agreement_all_checkbox.dart:35
  ///
  /// In ko, this message translates to:
  /// **'전체 동의'**
  String get auth_agreementAllCheckbox_L35;

  /// auto-imported from lib/features/auth/presentation/widgets/agreement_item.dart:39
  ///
  /// In ko, this message translates to:
  /// **'[필수]'**
  String get auth_agreementItem_L39;

  /// auto-imported from lib/features/auth/presentation/widgets/agreement_item.dart:39
  ///
  /// In ko, this message translates to:
  /// **'[선택]'**
  String get auth_agreementItem_L39_1;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:245
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get dialoggamePageConfirm;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:379
  ///
  /// In ko, this message translates to:
  /// **'도둑이 도망치는 중이에요!'**
  String get game_gamePage_L379;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1026
  ///
  /// In ko, this message translates to:
  /// **'게임 종료!'**
  String get game_gamePage_L1026;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1034
  ///
  /// In ko, this message translates to:
  /// **'도둑이 모두 체포되었습니다!'**
  String get game_gamePage_L1034;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1034
  ///
  /// In ko, this message translates to:
  /// **'제한 시간이 종료되었습니다!'**
  String get game_gamePage_L1034_1;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1086
  ///
  /// In ko, this message translates to:
  /// **'경찰팀'**
  String get game_gamePage_L1086;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1086
  ///
  /// In ko, this message translates to:
  /// **'도둑팀'**
  String get game_gamePage_L1086_1;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1090
  ///
  /// In ko, this message translates to:
  /// **'승리'**
  String get game_gamePage_L1090;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1090
  ///
  /// In ko, this message translates to:
  /// **'패배'**
  String get game_gamePage_L1090_1;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1091
  ///
  /// In ko, this message translates to:
  /// **'{winnerTeamLabel}의 승리입니다!'**
  String dialoggamePageMessage(String winnerTeamLabel);

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1101
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get dialoggamePageCancel;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1102
  ///
  /// In ko, this message translates to:
  /// **'한 번 더'**
  String get dialoggamePageConfirm5863;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1289
  ///
  /// In ko, this message translates to:
  /// **'경찰'**
  String get game_gamePage_L1289;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1290
  ///
  /// In ko, this message translates to:
  /// **'도둑'**
  String get game_gamePage_L1290;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1723
  ///
  /// In ko, this message translates to:
  /// **'경찰 대기 시간 중에는 도둑을 체포할 수 없습니다'**
  String get dialoggamePageMessage5e97;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1732
  ///
  /// In ko, this message translates to:
  /// **'도둑의 수배 QR을 스캔하세요'**
  String get dialoggamePageTitle;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1741
  ///
  /// In ko, this message translates to:
  /// **'만료된 QR입니다. QR 새로고침을 요청하세요'**
  String get dialoggamePageMessage6487;

  /// auto-imported from lib/features/game/presentation/pages/game_page.dart:1756
  ///
  /// In ko, this message translates to:
  /// **'이미 체포된 도둑입니다'**
  String get dialoggamePageMessage4b5f;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:337
  ///
  /// In ko, this message translates to:
  /// **'인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다'**
  String get game_gameEventProvider_L337;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:452
  ///
  /// In ko, this message translates to:
  /// **'체포 요청 실패'**
  String get game_gameEventProvider_L452;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:492
  ///
  /// In ko, this message translates to:
  /// **'탈옥 요청 실패'**
  String get game_gameEventProvider_L492;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:520
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요'**
  String get game_gameEventProvider_L520;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:702
  ///
  /// In ko, this message translates to:
  /// **'경찰'**
  String get game_gameEventProvider_L702;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:703
  ///
  /// In ko, this message translates to:
  /// **'도둑'**
  String get game_gameEventProvider_L703;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:866
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요'**
  String get game_gameEventProvider_L866;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:937
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료되었습니다. 재로그인이 필요합니다'**
  String get game_gameEventProvider_L937;

  /// auto-imported from lib/features/game/presentation/providers/game_event_provider.dart:951
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료되었습니다. 재로그인이 필요합니다'**
  String get game_gameEventProvider_L951;

  /// auto-imported from lib/features/game/presentation/widgets/arrest_lock_overlay.dart:71
  ///
  /// In ko, this message translates to:
  /// **'체포되었어요!'**
  String get game_arrestLockOverlay_L71;

  /// auto-imported from lib/features/game/presentation/widgets/arrest_lock_overlay.dart:78
  ///
  /// In ko, this message translates to:
  /// **'체포되어 있는 동안에는 게임 상황을 확인할 수 없어요\n같은 팀에게 구조 요청을 하며 빠르게 탈옥해요!'**
  String get game_arrestLockOverlay_L78;

  /// auto-imported from lib/features/game/presentation/widgets/arrest_lock_overlay.dart:89
  ///
  /// In ko, this message translates to:
  /// **'탈옥 완료'**
  String get game_arrestLockOverlay_L89;

  /// auto-imported from lib/features/game/presentation/widgets/arrest_lock_overlay.dart:100
  ///
  /// In ko, this message translates to:
  /// **'탈옥'**
  String get dialogarrestLockOverlayTitle;

  /// auto-imported from lib/features/game/presentation/widgets/arrest_lock_overlay.dart:101
  ///
  /// In ko, this message translates to:
  /// **'탈옥하시겠습니까?'**
  String get dialogarrestLockOverlayMessage;

  /// auto-imported from lib/features/game/presentation/widgets/arrest_lock_overlay.dart:102
  ///
  /// In ko, this message translates to:
  /// **'탈옥'**
  String get game_arrestLockOverlay_L102;

  /// auto-imported from lib/features/game/presentation/widgets/game_action_modal.dart:63
  ///
  /// In ko, this message translates to:
  /// **'아니요'**
  String get game_gameActionModal_L63;

  /// auto-imported from lib/features/game/presentation/widgets/game_action_modal.dart:63
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get game_gameActionModal_L63_1;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:324
  ///
  /// In ko, this message translates to:
  /// **'승리'**
  String get game_gameOverResultDialog_L324;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:324
  ///
  /// In ko, this message translates to:
  /// **'패배'**
  String get game_gameOverResultDialog_L324_1;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:344
  ///
  /// In ko, this message translates to:
  /// **'체포 횟수'**
  String get fieldgameOverResultDialogLabel;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:345
  ///
  /// In ko, this message translates to:
  /// **'{totalArrestCount}회'**
  String game_gameOverResultDialog_L345(int totalArrestCount);

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:371
  ///
  /// In ko, this message translates to:
  /// **'남은 도둑'**
  String get fieldgameOverResultDialogLabelD8df;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:351
  ///
  /// In ko, this message translates to:
  /// **'{remainingRobberCount}명'**
  String game_gameOverResultDialog_L351(int remainingRobberCount);

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:373
  ///
  /// In ko, this message translates to:
  /// **'게임 진행 시간'**
  String get fieldgameOverResultDialogLabelAb0c;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:438
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get game_gameOverResultDialog_L438;

  /// auto-imported from lib/features/game/presentation/widgets/game_over_result_dialog.dart:452
  ///
  /// In ko, this message translates to:
  /// **'한 번 더'**
  String get game_gameOverResultDialog_L452;

  /// auto-imported from lib/features/game/presentation/widgets/location_reveal_countdown.dart:109
  ///
  /// In ko, this message translates to:
  /// **'다음 도둑 위치 공개까지 {_formatted}'**
  String game_locationRevealCountdown_L109(String _formatted);

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:119
  ///
  /// In ko, this message translates to:
  /// **'경찰 대기 시간 중에는 도둑을 체포할 수 없습니다'**
  String get dialogparticipantOverlayMessage;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:137
  ///
  /// In ko, this message translates to:
  /// **'해당 플레이어를 체포하셨나요?'**
  String get dialogparticipantOverlayTitle;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:139
  ///
  /// In ko, this message translates to:
  /// **'네'**
  String get game_participantOverlay_L139;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:164
  ///
  /// In ko, this message translates to:
  /// **'탈옥'**
  String get dialogparticipantOverlayTitle4167;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:165
  ///
  /// In ko, this message translates to:
  /// **'탈옥을 시도하시겠습니까?'**
  String get dialogparticipantOverlayMessage9497;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:166
  ///
  /// In ko, this message translates to:
  /// **'탈옥'**
  String get game_participantOverlay_L166;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:297
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get game_participantOverlay_L297;

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:299
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String game_participantOverlay_L299(int count);

  /// auto-imported from lib/features/game/presentation/widgets/participant_overlay.dart:305
  ///
  /// In ko, this message translates to:
  /// **'도주 중!'**
  String get game_participantOverlay_L305;

  /// auto-imported from lib/features/game/presentation/widgets/police_start_countdown.dart:79
  ///
  /// In ko, this message translates to:
  /// **'경찰 시작까지 {_formatted}'**
  String game_policeStartCountdown_L79(String _formatted);

  /// auto-imported from lib/features/game/presentation/widgets/qr_display_dialog.dart:62
  ///
  /// In ko, this message translates to:
  /// **'수배 QR'**
  String get game_qrDisplayDialog_L62;

  /// auto-imported from lib/features/game/presentation/widgets/qr_display_dialog.dart:86
  ///
  /// In ko, this message translates to:
  /// **'경찰에게 QR을 보여주세요'**
  String get game_qrDisplayDialog_L86;

  /// auto-imported from lib/features/game/presentation/widgets/qr_display_dialog.dart:97
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get game_qrDisplayDialog_L97;

  /// auto-imported from lib/features/game/presentation/widgets/qr_scanner_page.dart:60
  ///
  /// In ko, this message translates to:
  /// **'카메라 권한 필요'**
  String get dialogqrScannerPageTitle;

  /// auto-imported from lib/features/game/presentation/widgets/qr_scanner_page.dart:61
  ///
  /// In ko, this message translates to:
  /// **'QR코드를 스캔하려면 카메라 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요'**
  String get dialogqrScannerPageMessage;

  /// auto-imported from lib/features/game/presentation/widgets/qr_scanner_page.dart:62
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get dialogqrScannerPageConfirm;

  /// auto-imported from lib/features/game/presentation/widgets/qr_scanner_page.dart:63
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get dialogqrScannerPageCancel;

  /// auto-imported from lib/features/game/presentation/widgets/qr_scanner_page.dart:90
  ///
  /// In ko, this message translates to:
  /// **'카메라를 사용할 수 없습니다'**
  String get game_qrScannerPage_L90;

  /// auto-imported from lib/features/game/presentation/widgets/zone_exit_banner.dart:66
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드를 벗어났어요'**
  String get game_zoneExitBanner_L66;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:190
  ///
  /// In ko, this message translates to:
  /// **'인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다'**
  String get chat_chatProvider_L190;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:254
  ///
  /// In ko, this message translates to:
  /// **'나'**
  String get chat_chatProvider_L254;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:262
  ///
  /// In ko, this message translates to:
  /// **'[팀]'**
  String get dialogchatProviderMessage;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:265
  ///
  /// In ko, this message translates to:
  /// **'팀원닉네임'**
  String get chat_chatProvider_L265;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:265
  ///
  /// In ko, this message translates to:
  /// **'상대닉네임'**
  String get chat_chatProvider_L265_1;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:286
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get chat_chatProvider_L286;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:378
  ///
  /// In ko, this message translates to:
  /// **'제한 시간은 30분입니다'**
  String get dialogchatProviderMessageDfca;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:381
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get chat_chatProvider_L381;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:385
  ///
  /// In ko, this message translates to:
  /// **'게임이 곧 시작됩니다. 모든 플레이어는 준비하세요!'**
  String get dialogchatProviderMessage2119;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:388
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get chat_chatProvider_L388;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:392
  ///
  /// In ko, this message translates to:
  /// **'도둑 잘 도망쳐 봐요~'**
  String get dialogchatProviderMessageC357;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:395
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get chat_chatProvider_L395;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:399
  ///
  /// In ko, this message translates to:
  /// **'이겨봅시다!'**
  String get dialogchatProviderMessageEa9a;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:402
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get chat_chatProvider_L402;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:564
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요'**
  String get chat_chatProvider_L564;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:655
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료되었습니다. 재로그인이 필요합니다'**
  String get chat_chatProvider_L655;

  /// auto-imported from lib/features/chat/presentation/providers/chat_provider.dart:676
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료되었습니다. 재로그인이 필요합니다'**
  String get chat_chatProvider_L676;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:106
  ///
  /// In ko, this message translates to:
  /// **'메시지가 복사되었어요'**
  String get dialogchatContextMenuMessage;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:121
  ///
  /// In ko, this message translates to:
  /// **'해당 유저를 차단했어요'**
  String get dialogchatContextMenuMessage2c60;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:137
  ///
  /// In ko, this message translates to:
  /// **'신고하기'**
  String get dialogchatContextMenuTitle;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:138
  ///
  /// In ko, this message translates to:
  /// **'신고 내용'**
  String get fieldchatContextMenuLabel;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:139
  ///
  /// In ko, this message translates to:
  /// **'신고 사유를 자세히 작성해 주세요\n(상황 또는 대화 내용을 포함해 주세요)'**
  String get fieldchatContextMenuHint;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:140
  ///
  /// In ko, this message translates to:
  /// **'신고하기'**
  String get chat_chatContextMenu_L140;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:220
  ///
  /// In ko, this message translates to:
  /// **'신고가 접수되었어요'**
  String get dialogchatContextMenuMessageDf78;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:227
  ///
  /// In ko, this message translates to:
  /// **'신고에 실패했어요'**
  String get dialogchatContextMenuMessage9d41;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:178
  ///
  /// In ko, this message translates to:
  /// **'해당 유저를 신고할까요?'**
  String get dialogchatContextMenuTitle5ccb;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:179
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get dialogchatContextMenuCancel;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:180
  ///
  /// In ko, this message translates to:
  /// **'신고하기'**
  String get dialogchatContextMenuConfirm;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:190
  ///
  /// In ko, this message translates to:
  /// **'선택한 신고 사유:'**
  String get chat_chatContextMenu_L190;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:202
  ///
  /// In ko, this message translates to:
  /// **'\n신고된 내용은 검토 후 조치할게요'**
  String get chat_chatContextMenu_L202;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:422
  ///
  /// In ko, this message translates to:
  /// **'복사하기'**
  String get fieldchatContextMenuLabelA83e;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:432
  ///
  /// In ko, this message translates to:
  /// **'신고하기'**
  String get fieldchatContextMenuLabel7812;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:441
  ///
  /// In ko, this message translates to:
  /// **'차단하기'**
  String get fieldchatContextMenuLabel2f14;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_context_menu.dart:478
  ///
  /// In ko, this message translates to:
  /// **'신고 유형 선택'**
  String get chat_chatContextMenu_L478;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_input_bar.dart:98
  ///
  /// In ko, this message translates to:
  /// **'전체 {all}개'**
  String chat_chatInputBar_L98(String all);

  /// auto-imported from lib/features/chat/presentation/widgets/chat_input_bar.dart:99
  ///
  /// In ko, this message translates to:
  /// **'팀 {team}개'**
  String chat_chatInputBar_L99(String team);

  /// auto-imported from lib/features/chat/presentation/widgets/chat_input_bar.dart:158
  ///
  /// In ko, this message translates to:
  /// **'연결 중...'**
  String get chat_chatInputBar_L158;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_input_bar.dart:159
  ///
  /// In ko, this message translates to:
  /// **'채팅을 입력하세요'**
  String get chat_chatInputBar_L159;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:152
  ///
  /// In ko, this message translates to:
  /// **'채팅을 시작해보세요'**
  String get chat_chatMessageList_L152;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:229
  ///
  /// In ko, this message translates to:
  /// **'최신 메시지로 이동'**
  String get fieldchatMessageListLabel;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get chat_chatMessageList_L276;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get chat_chatMessageList_L276_1;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get chat_chatMessageList_L276_2;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get chat_chatMessageList_L276_3;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get chat_chatMessageList_L276_4;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get chat_chatMessageList_L276_5;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:276
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get chat_chatMessageList_L276_6;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_message_list.dart:278
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일 {weekday}요일'**
  String chat_chatMessageList_L278(
    String year,
    String month,
    String day,
    String weekday,
  );

  /// auto-imported from lib/features/chat/presentation/widgets/chat_overlay.dart:428
  ///
  /// In ko, this message translates to:
  /// **'전체 채팅'**
  String get chat_chatOverlay_L428;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_overlay.dart:428
  ///
  /// In ko, this message translates to:
  /// **'팀 채팅'**
  String get chat_chatOverlay_L428_1;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_preview_card.dart:116
  ///
  /// In ko, this message translates to:
  /// **'공지'**
  String get chat_chatPreviewCard_L116;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_preview_card.dart:120
  ///
  /// In ko, this message translates to:
  /// **'팀'**
  String get chat_chatPreviewCard_L120;

  /// auto-imported from lib/features/chat/presentation/widgets/chat_preview_card.dart:124
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get chat_chatPreviewCard_L124;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:75
  ///
  /// In ko, this message translates to:
  /// **'아직 네트워크에 연결되지 않았어요'**
  String get dialogagreementSettingsPageMessage;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:97
  ///
  /// In ko, this message translates to:
  /// **'변경사항이 저장되었어요'**
  String get dialogagreementSettingsPageMessageEfc5;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:102
  ///
  /// In ko, this message translates to:
  /// **'일시적인 오류가 발생했습니다. 다시 시도해주세요'**
  String get settings_agreementSettingsPage_L102;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:142
  ///
  /// In ko, this message translates to:
  /// **'이용약관 및 정책'**
  String get settings_agreementSettingsPage_L142;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:159
  ///
  /// In ko, this message translates to:
  /// **'약관 동의 현황을 불러올 수 없습니다'**
  String get settings_agreementSettingsPage_L159;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:176
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get settings_agreementSettingsPage_L176;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:203
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get dialogagreementSettingsPageTitle;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:221
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get dialogagreementSettingsPageTitleBe29;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:236
  ///
  /// In ko, this message translates to:
  /// **'위치정보 이용약관'**
  String get dialogagreementSettingsPageTitle6dcc;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:251
  ///
  /// In ko, this message translates to:
  /// **'마케팅 정보 수신'**
  String get dialogagreementSettingsPageTitle76b8;

  /// auto-imported from lib/features/settings/presentation/pages/agreement_settings_page.dart:261
  ///
  /// In ko, this message translates to:
  /// **'변경사항 저장'**
  String get settings_agreementSettingsPage_L261;

  /// auto-imported from lib/features/settings/presentation/pages/legal_document_page.dart:105
  ///
  /// In ko, this message translates to:
  /// **'문서를 불러올 수 없습니다'**
  String get settings_legalDocumentPage_L105;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:104
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings_settingsPage_L104;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:115
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get settings_settingsPage_L115;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:117
  ///
  /// In ko, this message translates to:
  /// **'닉네임 변경'**
  String get settings_settingsPage_L117;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:128
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get settings_settingsPage_L128;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:130
  ///
  /// In ko, this message translates to:
  /// **'게임 알림'**
  String get settings_settingsPage_L130;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:131
  ///
  /// In ko, this message translates to:
  /// **'게임 진행 중 발생하는 이벤트 알림을 설정해요'**
  String get settings_settingsPage_L131;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:137
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get settings_settingsPage_L137;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:143
  ///
  /// In ko, this message translates to:
  /// **'게임 중 알림'**
  String get settings_settingsPage_L143;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:149
  ///
  /// In ko, this message translates to:
  /// **'을 포함한 앱에서 보내는 모든 알림을 설정해요'**
  String get settings_settingsPage_L149;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:164
  ///
  /// In ko, this message translates to:
  /// **'위치 권한 관리'**
  String get settings_settingsPage_L164;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:165
  ///
  /// In ko, this message translates to:
  /// **'기기 설정에서 위치 권한을 변경할 수 있어요'**
  String get settings_settingsPage_L165;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:176
  ///
  /// In ko, this message translates to:
  /// **'이용 안내'**
  String get settings_settingsPage_L176;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:179
  ///
  /// In ko, this message translates to:
  /// **'버그 제보'**
  String get settings_settingsPage_L179;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:182
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 다시 보기'**
  String get settings_settingsPage_L182;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:186
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 초기화'**
  String get settings_settingsPage_L186;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:189
  ///
  /// In ko, this message translates to:
  /// **'이용약관 및 정책'**
  String get settings_settingsPage_L189;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:202
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get settings_settingsPage_L202;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:204
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get settings_settingsPage_L204;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:210
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴'**
  String get settings_settingsPage_L210;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:292
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get settings_settingsPage_L292;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:452
  ///
  /// In ko, this message translates to:
  /// **'게임 알림 설정을 변경하지 못했어요'**
  String get dialogsettingsPageMessage;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:495
  ///
  /// In ko, this message translates to:
  /// **'버그 제보'**
  String get dialogsettingsPageTitle;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:496
  ///
  /// In ko, this message translates to:
  /// **'버그 내용'**
  String get fieldsettingsPageLabel;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:497
  ///
  /// In ko, this message translates to:
  /// **'어떤 문제가 발생했나요?\n발생 상황을 자세히 적어주세요(시간, 기기 정보 포함)'**
  String get fieldsettingsPageHint;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:498
  ///
  /// In ko, this message translates to:
  /// **'제보하기'**
  String get settings_settingsPage_L498;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:524
  ///
  /// In ko, this message translates to:
  /// **'버그 제보가 접수되었어요'**
  String get dialogsettingsPageMessage1b8e;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:549
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 초기화'**
  String get dialogsettingsPageTitleD4a4;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:550
  ///
  /// In ko, this message translates to:
  /// **'모든 화면의 튜토리얼을\n다시 볼 수 있도록 초기화할까요?'**
  String get dialogsettingsPageMessageA4c9;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:551
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get dialogsettingsPageConfirm;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:559
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼이 초기화되었어요'**
  String get dialogsettingsPageMessageC8cb;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:568
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get dialogsettingsPageTitle9ab1;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:569
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃 하시겠어요?'**
  String get dialogsettingsPageMessageE675;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:570
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get dialogsettingsPageConfirm9ab1;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:590
  ///
  /// In ko, this message translates to:
  /// **'로그아웃에 실패했습니다'**
  String get settings_settingsPage_L590;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:590
  ///
  /// In ko, this message translates to:
  /// **'로그아웃되었습니다'**
  String get settings_settingsPage_L590_1;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:601
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴'**
  String get dialogsettingsPageTitle5e0d;

  /// 회원 탈퇴 확인 다이얼로그 본문 — 사용자에게 비가역성 경고 + 확인 키워드 입력 요구
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하면 모든 데이터가 삭제되며\n되돌릴 수 없습니다\n\n계속하려면 \"delete\"를 입력하세요'**
  String get settings_settingsPage_L603;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:606
  ///
  /// In ko, this message translates to:
  /// **'delete'**
  String get fieldsettingsPageHint2960;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:608
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get dialogsettingsPageCancel;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:609
  ///
  /// In ko, this message translates to:
  /// **'탈퇴'**
  String get dialogsettingsPageConfirm9140;

  /// auto-imported from lib/features/settings/presentation/pages/settings_page.dart:613
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하기'**
  String get settings_settingsPage_L613;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:62
  ///
  /// In ko, this message translates to:
  /// **'경찰1'**
  String get tutorial_inGameTutorialPage_L62;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:72
  ///
  /// In ko, this message translates to:
  /// **'도둑킹'**
  String get tutorial_inGameTutorialPage_L72;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:78
  ///
  /// In ko, this message translates to:
  /// **'도둑이게아니게'**
  String get tutorial_inGameTutorialPage_L78;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:84
  ///
  /// In ko, this message translates to:
  /// **'잡힌도둑'**
  String get tutorial_inGameTutorialPage_L84;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:139
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 완료!'**
  String get dialoginGameTutorialPageTitle;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:140
  ///
  /// In ko, this message translates to:
  /// **'핵심 흐름을 익혔어요\n실제 게임에서 활용해보세요'**
  String get dialoginGameTutorialPageMessage;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:141
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼 끝내기'**
  String get dialoginGameTutorialPageConfirm;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:262
  ///
  /// In ko, this message translates to:
  /// **'내 위치로 카메라가 이동했어요'**
  String get dialoginGameTutorialPageMessage8372;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:391
  ///
  /// In ko, this message translates to:
  /// **'지도 미리보기'**
  String get tutorial_inGameTutorialPage_L391;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:434
  ///
  /// In ko, this message translates to:
  /// **'다음 도둑 위치 공개까지 04:30'**
  String get tutorial_inGameTutorialPage_L434;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:447
  ///
  /// In ko, this message translates to:
  /// **'게임 룰 안내가 열려요'**
  String get dialoginGameTutorialPageMessage9b3f;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:491
  ///
  /// In ko, this message translates to:
  /// **'내 수배 QR이 화면에 표시돼요. 경찰에게 보여주면 체포'**
  String get tutorial_inGameTutorialPage_L491;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:492
  ///
  /// In ko, this message translates to:
  /// **'카메라가 켜지고 도둑의 QR을 스캔해 체포할 수 있어요'**
  String get tutorial_inGameTutorialPage_L492;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:509
  ///
  /// In ko, this message translates to:
  /// **'참가자 보기 버튼을 눌러보세요'**
  String get tutorial_inGameTutorialPage_L509;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:509
  ///
  /// In ko, this message translates to:
  /// **'QR 버튼을 눌러보세요'**
  String get tutorial_inGameTutorialPage_L509_1;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:509
  ///
  /// In ko, this message translates to:
  /// **'지도로 돌아가 보세요'**
  String get tutorial_inGameTutorialPage_L509_2;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:525
  ///
  /// In ko, this message translates to:
  /// **'미션 {_missionStep}/3'**
  String tutorial_inGameTutorialPage_L525(String _missionStep);

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:608
  ///
  /// In ko, this message translates to:
  /// **'도둑 시점 보는 중'**
  String get tutorial_inGameTutorialPage_L608;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:608
  ///
  /// In ko, this message translates to:
  /// **'경찰 시점 보는 중'**
  String get tutorial_inGameTutorialPage_L608_1;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:661
  ///
  /// In ko, this message translates to:
  /// **'본인이 수감됐다면 카드 탭으로 탈옥을 시도할 수 있어요'**
  String get dialoginGameTutorialPageMessageA1c5;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:667
  ///
  /// In ko, this message translates to:
  /// **'실제 게임에서는 QR 스캔으로 도둑을 체포해요'**
  String get dialoginGameTutorialPageMessage9331;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:688
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get tutorial_inGameTutorialPage_L688;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:690
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String tutorial_inGameTutorialPage_L690(int count);

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:696
  ///
  /// In ko, this message translates to:
  /// **'도주 중!'**
  String get tutorial_inGameTutorialPage_L696;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:756
  ///
  /// In ko, this message translates to:
  /// **'핸들을 위로 드래그하면 채팅이 펼쳐져요'**
  String get dialoginGameTutorialPageMessage7650;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:788
  ///
  /// In ko, this message translates to:
  /// **'여기에 메시지를 입력하면 팀/전체 채팅으로 보낼 수 있어요'**
  String get dialoginGameTutorialPageMessageDb39;

  /// auto-imported from lib/features/tutorial/presentation/pages/in_game_tutorial_page.dart:806
  ///
  /// In ko, this message translates to:
  /// **'채팅을 입력하세요'**
  String get tutorial_inGameTutorialPage_L806;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:19
  ///
  /// In ko, this message translates to:
  /// **'방 만들기'**
  String get dialogtutorialCatalogPageTitle;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:20
  ///
  /// In ko, this message translates to:
  /// **'플레이그라운드·감옥 설정과 슬라이더 조작'**
  String get tutorial_tutorialCatalogPage_L20;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:24
  ///
  /// In ko, this message translates to:
  /// **'방 참여하기'**
  String get dialogtutorialCatalogPageTitle879f;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:25
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 입력과 QR 스캔'**
  String get tutorial_tutorialCatalogPage_L25;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:29
  ///
  /// In ko, this message translates to:
  /// **'대기방'**
  String get dialogtutorialCatalogPageTitle2421;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:30
  ///
  /// In ko, this message translates to:
  /// **'팀 변경, 게임 설정, 준비 완료'**
  String get tutorial_tutorialCatalogPage_L30;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:34
  ///
  /// In ko, this message translates to:
  /// **'인게임'**
  String get dialogtutorialCatalogPageTitle8700;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:35
  ///
  /// In ko, this message translates to:
  /// **'타이머·지도·참가자·채팅·QR'**
  String get tutorial_tutorialCatalogPage_L35;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:62
  ///
  /// In ko, this message translates to:
  /// **'튜토리얼'**
  String get tutorial_tutorialCatalogPage_L62;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:69
  ///
  /// In ko, this message translates to:
  /// **'게임을 처음 한다면 한 번씩 보고 시작해보세요'**
  String get tutorial_tutorialCatalogPage_L69;

  /// auto-imported from lib/features/tutorial/presentation/pages/tutorial_catalog_page.dart:200
  ///
  /// In ko, this message translates to:
  /// **'준비 중'**
  String get tutorial_tutorialCatalogPage_L200;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:78
  ///
  /// In ko, this message translates to:
  /// **'홍의민'**
  String get credits_creditMember_L78;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:97
  ///
  /// In ko, this message translates to:
  /// **'박찬빈'**
  String get credits_creditMember_L97;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:110
  ///
  /// In ko, this message translates to:
  /// **'이창희'**
  String get credits_creditMember_L110;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:122
  ///
  /// In ko, this message translates to:
  /// **'정상희'**
  String get credits_creditMember_L122;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:137
  ///
  /// In ko, this message translates to:
  /// **'황혜림'**
  String get credits_creditMember_L137;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:149
  ///
  /// In ko, this message translates to:
  /// **'윤지희'**
  String get credits_creditMember_L149;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:220
  ///
  /// In ko, this message translates to:
  /// **'신지훈'**
  String get credits_creditMember_L220;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:227
  ///
  /// In ko, this message translates to:
  /// **'남해윤'**
  String get credits_creditMember_L227;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:233
  ///
  /// In ko, this message translates to:
  /// **'송혜정'**
  String get credits_creditMember_L233;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:239
  ///
  /// In ko, this message translates to:
  /// **'이진'**
  String get credits_creditMember_L239;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:246
  ///
  /// In ko, this message translates to:
  /// **'안금서'**
  String get credits_creditMember_L246;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:252
  ///
  /// In ko, this message translates to:
  /// **'손건우'**
  String get credits_creditMember_L252;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:258
  ///
  /// In ko, this message translates to:
  /// **'신혜빈'**
  String get credits_creditMember_L258;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:264
  ///
  /// In ko, this message translates to:
  /// **'정창우'**
  String get credits_creditMember_L264;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:270
  ///
  /// In ko, this message translates to:
  /// **'허석준'**
  String get credits_creditMember_L270;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:276
  ///
  /// In ko, this message translates to:
  /// **'서현진'**
  String get credits_creditMember_L276;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:282
  ///
  /// In ko, this message translates to:
  /// **'오동현'**
  String get credits_creditMember_L282;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:288
  ///
  /// In ko, this message translates to:
  /// **'최승훈'**
  String get credits_creditMember_L288;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:294
  ///
  /// In ko, this message translates to:
  /// **'김민욱'**
  String get credits_creditMember_L294;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:300
  ///
  /// In ko, this message translates to:
  /// **'정명준'**
  String get credits_creditMember_L300;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:306
  ///
  /// In ko, this message translates to:
  /// **'강대현'**
  String get credits_creditMember_L306;

  /// auto-imported from lib/features/credits/domain/credit_member.dart:312
  ///
  /// In ko, this message translates to:
  /// **'심 혁'**
  String get credits_creditMember_L312;

  /// auto-imported from lib/features/credits/presentation/pages/credits_page.dart:45
  ///
  /// In ko, this message translates to:
  /// **'경찰과 도둑을 만든 사람들'**
  String get credits_creditsPage_L45;

  /// auto-imported from lib/features/report/data/repositories/report_repository_impl.dart:39
  ///
  /// In ko, this message translates to:
  /// **'신고 처리 중 오류가 발생했습니다'**
  String get dialogreportRepositoryImplMessage;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:7
  ///
  /// In ko, this message translates to:
  /// **'낚시/놀람/도배'**
  String get report_reportCategories_L7;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:8
  ///
  /// In ko, this message translates to:
  /// **'욕설/비하'**
  String get report_reportCategories_L8;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:9
  ///
  /// In ko, this message translates to:
  /// **'사칭/사기'**
  String get report_reportCategories_L9;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:10
  ///
  /// In ko, this message translates to:
  /// **'광고/스팸'**
  String get report_reportCategories_L10;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:11
  ///
  /// In ko, this message translates to:
  /// **'부정 행위/버그 악용'**
  String get report_reportCategories_L11;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:12
  ///
  /// In ko, this message translates to:
  /// **'팀 사기 저하'**
  String get report_reportCategories_L12;

  /// auto-imported from lib/features/report/domain/constants/report_categories.dart:13
  ///
  /// In ko, this message translates to:
  /// **'기타(직접 작성)'**
  String get report_reportCategories_L13;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:36
  ///
  /// In ko, this message translates to:
  /// **'닉네임 확인 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:56
  ///
  /// In ko, this message translates to:
  /// **'닉네임 변경 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessageAc72;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:82
  ///
  /// In ko, this message translates to:
  /// **'사용자 정보 조회 중 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage243c;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:100
  ///
  /// In ko, this message translates to:
  /// **'회원 탈퇴 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage220e;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:132
  ///
  /// In ko, this message translates to:
  /// **'약관 동의 상태 조회 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage05b0;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:158
  ///
  /// In ko, this message translates to:
  /// **'약관 동의 저장 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage2357;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:179
  ///
  /// In ko, this message translates to:
  /// **'게임 푸시 알림 동의 조회 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage3d3a;

  /// auto-imported from lib/features/user/data/repositories/user_repository_impl.dart:200
  ///
  /// In ko, this message translates to:
  /// **'게임 푸시 알림 동의 업데이트 중 예기치 않은 오류가 발생했습니다'**
  String get dialoguserRepositoryImplMessage5fe2;

  /// auto-imported from lib/features/lobby/presentation/providers/lobby_provider.dart:139
  ///
  /// In ko, this message translates to:
  /// **'인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다'**
  String get lobby_lobbyProvider_L139;

  /// auto-imported from lib/features/lobby/presentation/providers/lobby_provider.dart:187
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요'**
  String get lobby_lobbyProvider_L187;

  /// auto-imported from lib/features/lobby/presentation/providers/lobby_provider.dart:319
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요'**
  String get lobby_lobbyProvider_L319;

  /// auto-imported from lib/features/lobby/presentation/providers/lobby_provider.dart:381
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료되었습니다. 재로그인이 필요합니다'**
  String get lobby_lobbyProvider_L381;

  /// auto-imported from lib/features/lobby/presentation/providers/lobby_provider.dart:399
  ///
  /// In ko, this message translates to:
  /// **'인증이 만료되었습니다. 재로그인이 필요합니다'**
  String get lobby_lobbyProvider_L399;

  /// auto-imported from lib/features/notice/data/repositories/notice_repository_impl.dart:49
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 불러오는 중 오류가 발생했습니다'**
  String get dialognoticeRepositoryImplMessage;

  /// auto-imported from lib/features/notice/presentation/pages/notices_page.dart:64
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 불러오는 중...'**
  String get dialognoticesPageMessage;

  /// auto-imported from lib/features/notice/presentation/pages/notices_page.dart:99
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 불러오지 못했어요'**
  String get dialognoticesPageMessage4982;

  /// auto-imported from lib/features/notice/presentation/pages/notices_page.dart:131
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get notice_noticesPage_L131;

  /// auto-imported from lib/features/notice/presentation/pages/notices_page.dart:152
  ///
  /// In ko, this message translates to:
  /// **'등록된 공지사항이 없습니다'**
  String get notice_noticesPage_L152;

  /// auto-imported from lib/router/app_router.dart:477
  ///
  /// In ko, this message translates to:
  /// **'구역 정보를 불러올 수 없습니다'**
  String get router_appRouter_L477;

  /// auto-imported from lib/router/app_router.dart:575
  ///
  /// In ko, this message translates to:
  /// **'페이지를 찾을 수 없습니다'**
  String get router_appRouter_L575;

  /// auto-imported from lib/router/app_router.dart:586
  ///
  /// In ko, this message translates to:
  /// **'요청하신 페이지가 존재하지 않습니다'**
  String get router_appRouter_L586;

  /// auto-imported from lib/router/app_router.dart:589
  ///
  /// In ko, this message translates to:
  /// **'경로: {path}'**
  String router_appRouter_L589(String path);

  /// auto-imported from lib/router/app_router.dart:600
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get router_appRouter_L600;

  /// auto-imported from lib/features/bug/data/repositories/bug_repository_impl.dart:25
  ///
  /// In ko, this message translates to:
  /// **'버그 제보 처리 중 오류가 발생했습니다'**
  String get dialogbugRepositoryImplMessage;

  /// auto-imported from lib/main.dart:181
  ///
  /// In ko, this message translates to:
  /// **'경찰과도둑'**
  String get dialogmainTitle;

  /// START 1단계 — 제한 시간 안내
  ///
  /// In ko, this message translates to:
  /// **'제한 시간은 {minutes}분입니다.'**
  String gameEventStartTime(int minutes);

  /// START 2단계 — 게임 시작 예고
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 게임이 시작됩니다.  모든 플레이어는 준비하세요!'**
  String get gameEventStartReady;

  /// START 3단계 — 신고/차단 안내
  ///
  /// In ko, this message translates to:
  /// **'게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다.'**
  String get gameEventStartReportTip;

  /// START 4단계 — 게임 시작 확정
  ///
  /// In ko, this message translates to:
  /// **'게임 시작!  행운을 빕니다!'**
  String get gameEventStartGo;

  /// 경찰 출동 예고
  ///
  /// In ko, this message translates to:
  /// **'경찰이 곧 출동합니다.  도둑은 서둘러 이동하세요!'**
  String get gameEventPoliceMoveWarning;

  /// 경찰 출동 확정
  ///
  /// In ko, this message translates to:
  /// **'경찰 출동!  도둑은 도망치세요!'**
  String get gameEventPoliceMove;

  /// 도둑 위치 공개 안내
  ///
  /// In ko, this message translates to:
  /// **'현재 도둑의 위치가 공개됩니다!'**
  String get gameEventLocationReveal;

  /// 도주 중인 도둑 인원
  ///
  /// In ko, this message translates to:
  /// **'현재 {count}명 도주 중!'**
  String gameEventRemainingRobbers(int count);

  /// 체포 공지 — @icon_police/@icon_robber 마커는 채팅 버블에서 SVG로 치환
  ///
  /// In ko, this message translates to:
  /// **'@icon_police [{policeNickname}]님이 @icon_robber [{robberNickname}]님을 체포했습니다!'**
  String gameEventArrestNotice(String policeNickname, String robberNickname);

  /// 탈옥 공지
  ///
  /// In ko, this message translates to:
  /// **'도둑이 탈옥했습니다! 지금 바로 체포하세요!'**
  String get gameEventEscapeNotice;

  /// 게임 종료 5분 전 경고
  ///
  /// In ko, this message translates to:
  /// **'게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!'**
  String get gameEventFiveMinutesLeft;

  /// 지도 로드 실패 시 표시 메시지
  ///
  /// In ko, this message translates to:
  /// **'{mapName} 로드 실패'**
  String mapErrorLoadFailed(String mapName);
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
