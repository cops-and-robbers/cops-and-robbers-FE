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
  String get chatSystemGameStartReady => '잠시 후 게임이 시작됩니다.  모든 플레이어는 준비하세요!';

  @override
  String get chatSystemGameStartReportTip =>
      '게임 중 채팅을 길게 눌러 불편한 유저를 신고 및 차단할 수 있습니다';

  @override
  String get chatSystemGameStartGo => '게임 시작!  행운을 빕니다!';

  @override
  String get chatSystemPoliceMoveWarning => '경찰이 곧 출동합니다.  도둑은 서둘러 이동하세요!';

  @override
  String get chatSystemPoliceMove => '경찰 출동!  도둑은 도망치세요!';

  @override
  String get chatSystemLocationReveal => '현재 도둑의 위치가 공개됩니다!';

  @override
  String chatSystemRemainingRobbers(int count) {
    return '현재 $count명 도주 중!';
  }

  @override
  String chatSystemArrest(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname]님이 @icon_robber [$robberNickname]님을 체포했습니다!';
  }

  @override
  String get chatSystemEscapeNotice => '도둑이 탈옥했습니다! 지금 바로 체포하세요!';

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
  String get buttonGoogleSignIn => 'Google로 시작하기';

  @override
  String get buttonAppleSignIn => 'Apple로 시작하기';

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
  String get asset_loading_joinRoom477c => '작전에 합류하는 중...';

  @override
  String get asset_loading_joinRoom24a9 => '비밀 통로로 진입 중...';

  @override
  String get asset_loading_joinRoomCb98 => '변장 확인 중...';

  @override
  String get asset_loading_joinRoomF964 => '작전 투입 인원 확인 중...';

  @override
  String get asset_loading_joinRoomB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_joinRoomAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_joinRoom25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_createRoom => '작전 본부 설치 중...';

  @override
  String get asset_loading_createRoomF1fe => '비밀 아지트 준비 중...';

  @override
  String get asset_loading_createRoom01f8 => '작전 구역 확보 중...';

  @override
  String get asset_loading_createRoom5076 => '비밀 지도 펼치는 중...';

  @override
  String get asset_loading_createRoomDd9e => '무전기 주파수 맞추는 중...';

  @override
  String get asset_loading_createRoomB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_createRoomAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_createRoom25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_changeTeam => '변장 중...';

  @override
  String get asset_loading_changeTeam681d => '위장 신분 변경 중...';

  @override
  String get asset_loading_changeTeam1106 => '신분 세탁 중...';

  @override
  String get asset_loading_changeTeam4d7a => '이중 스파이 전환 중...';

  @override
  String get asset_loading_changeTeam4cdc => '새 신분증 발급 중...';

  @override
  String get asset_loading_changeTeamB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_changeTeamAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_changeTeam25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_startGame => '작전 개시 준비 중...';

  @override
  String get asset_loading_startGameA35d => '출동 준비 중...';

  @override
  String get asset_loading_startGame64c3 => '카운트다운 시작...';

  @override
  String get asset_loading_startGame7a2f => '무전기 켜는 중...';

  @override
  String get asset_loading_startGame1b41 => '현장 요원 배치 중...';

  @override
  String get asset_loading_startGameB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_startGameAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_startGame25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_updateArea => '작전 구역 설정 중...';

  @override
  String get asset_loading_updateArea8c32 => '관할 구역 지정 중...';

  @override
  String get asset_loading_updateArea0183 => '지도 위에 점 찍는 중...';

  @override
  String get asset_loading_updateArea2433 => '위성 사진 분석 중...';

  @override
  String get asset_loading_updateAreaDc8b => '작전 범위 계산 중...';

  @override
  String get asset_loading_updateAreaB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_updateAreaAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_updateArea25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_saveSettings => '작전 지침 수정 중...';

  @override
  String get asset_loading_saveSettingsFb58 => '규칙 업데이트 중...';

  @override
  String get asset_loading_saveSettings65dc => '새로운 룰 적용 중...';

  @override
  String get asset_loading_saveSettings5e80 => '암호 변경 중...';

  @override
  String get asset_loading_saveSettings128d => '새 작전 코드 적용 중...';

  @override
  String get asset_loading_saveSettingsB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_saveSettingsAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_saveSettings25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_loadProfile => '신원 조회 중...';

  @override
  String get asset_loading_loadProfile27ee => '수배서 확인 중...';

  @override
  String get asset_loading_loadProfile6dac => '신분증 검사 중...';

  @override
  String get asset_loading_loadProfile23c6 => '지문 대조 중...';

  @override
  String get asset_loading_loadProfile221d => '용의자 프로필 분석 중...';

  @override
  String get asset_loading_loadProfileB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_loadProfileAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_loadProfile25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_logout => '철수 중...';

  @override
  String get asset_loading_logout3031 => '잠적 중...';

  @override
  String get asset_loading_logoutCe40 => '흔적 지우는 중...';

  @override
  String get asset_loading_logout0ba9 => '증거 인멸 중...';

  @override
  String get asset_loading_logoutFc0d => '비밀 통로로 탈출 중...';

  @override
  String get asset_loading_logoutB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_logoutAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_logout25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_deleteAccount => '탈퇴 처리 중...';

  @override
  String get asset_loading_deleteAccountC5fd => '기록 말소 중...';

  @override
  String get asset_loading_deleteAccount517f => '신원 삭제 중...';

  @override
  String get asset_loading_reconnect => '다시 현장으로 복귀 중...';

  @override
  String get asset_loading_reconnectBa5f => '작전에 재합류하는 중...';

  @override
  String get asset_loading_reconnect098b => '현장 복귀 준비 중...';

  @override
  String get asset_loading_reconnect429b => '무전 채널 복구 중...';

  @override
  String get asset_loading_reconnect6b88 => '비밀 주파수 재탐색 중...';

  @override
  String get asset_loading_reconnectB36a => '설정 어딘가를 계속 누르면 비밀이 열린다던데...';

  @override
  String get asset_loading_reconnectAaf8 => '앱 버전을 자꾸 누르면 뭔가 나올지도...?';

  @override
  String get asset_loading_reconnect25aa => '누군가 버전 번호에 비밀을 숨겨뒀다는 소문이...';

  @override
  String get asset_loading_bugReport => '신고서 작성 중...';

  @override
  String get asset_loading_bugReportDd4b => '본부에 보고서 제출 중...';

  @override
  String get asset_loading_bugReport5d70 => '현장 사진 첨부 중...';

  @override
  String get asset_loading_bugReport3c49 => '사건 번호 부여 중...';

  @override
  String get asset_loading_bugReport83ca => '수사반에 인계 중...';

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
  String get dialogsessionRepositoryImplMessage =>
      '게임 방 생성 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialogsessionRepositoryImplMessageAddf =>
      '참여 중인 게임 조회 중 예기치 않은 오류가 발생했습니다';

  @override
  String session_sessionSettings_L22(String maxPlayers) {
    return '$maxPlayers명';
  }

  @override
  String session_sessionSettings_L27(int roundTimeMinutes) {
    return '$roundTimeMinutes분';
  }

  @override
  String session_sessionSettings_L32(int locationShareMinutes) {
    return '$locationShareMinutes분';
  }

  @override
  String session_sessionSettings_L37(int policeStartDelayMinutes) {
    return '도둑 도망 후 $policeStartDelayMinutes분 뒤';
  }

  @override
  String session_zoneInfo_L25(String km) {
    return '반경 ${km}km';
  }

  @override
  String session_zoneInfo_L27(String radiusMeters) {
    return '반경 ${radiusMeters}m';
  }

  @override
  String get session_gameSettingsEditPage_L110 => '설정 저장에 실패했습니다';

  @override
  String get session_gameSettingsEditPage_L146 => '설정 수정';

  @override
  String get session_gameSettingsEditPage_L197 => '저장 중...';

  @override
  String get session_gameSettingsEditPage_L197_1 => '저장';

  @override
  String get session_gameSettingsPage_L140 => '영역 저장에 실패했습니다';

  @override
  String get session_gameSettingsPage_L190 => '게임 설정';

  @override
  String get session_gameSettingsPage_L210 => '구역 정보를 불러올 수 없습니다';

  @override
  String get session_gameSettingsPage_L228 => '설정 정보를 불러올 수 없습니다';

  @override
  String get session_gameSettingsPage_L270 => '플레이그라운드';

  @override
  String get session_gameSettingsPage_L275 => '감옥';

  @override
  String get session_homePage_L108 => '새로운 게임을 만들 수 있어요';

  @override
  String get session_homePage_L113 => '초대 코드를 입력하면 게임에 참가할 수 있어요';

  @override
  String get dialoghomePageTitle => '주변을 확인하며 이용해 주세요';

  @override
  String get dialoghomePageMessage =>
      '게임 중 화면에만 집중하면 위험할 수 있어요\n도로 및 보행 환경을 확인하며 안전하게 이용해 주세요';

  @override
  String get dialoghomePageConfirm => '확인했어요!';

  @override
  String get session_homePage_L158 => '오늘은 다시 보지 않기';

  @override
  String get dialoghomePageMessage50b3 => '이미 참가 중인 게임이 있습니다';

  @override
  String get dialoghomePageMessage89ff => '알 수 없는 게임 상태입니다';

  @override
  String get dialoghomePageConfirm5435 => '설정으로 이동';

  @override
  String get dialoghomePageCancel => '취소';

  @override
  String get dialoghomePageTitleEeea => '끊김 없는 게임을 위해';

  @override
  String get session_homePage_L332 => '앱 설정 → 배터리 → 제한 없음으로 변경해주세요\n';

  @override
  String get session_homePage_L333 => '그래야 화면이 꺼져도 게임이 끊기지 않아요';

  @override
  String get session_homePage_L432 => '참여에 실패했습니다. 초대 코드를 확인해주세요';

  @override
  String get dialoghomePageMessage8155 => '참여에 실패했습니다. 다시 시도해주세요';

  @override
  String get dialoghomePageTitle879f => '방 참여하기';

  @override
  String get fieldhomePageHint => '참여코드를 입력하세요';

  @override
  String get dialoghomePageTitle86c1 => '초대코드 QR을 스캔하세요';

  @override
  String get dialoghomePageCancel218e => '닫기';

  @override
  String get dialoghomePageConfirm665b => '참여하기';

  @override
  String get session_homePage_L601 => '경찰과도둑';

  @override
  String get dialoghomePageMessage9e36 => '준비중입니다';

  @override
  String get session_homePage_L661 => '너무 기대 돼\n이번에는 어떤 역할을 할까?';

  @override
  String get session_homePage_L677 => '방 만들기';

  @override
  String get session_homePage_L684 => '방 참여하기';

  @override
  String get session_sessionCreationFlowPage_L160 =>
      '게임할 구역을 설정해요.\n먼저 플레이그라운드를 지정하세요';

  @override
  String get session_sessionCreationFlowPage_L167 =>
      '게임 규칙을 정해요\n숫자를 탭하면 직접 입력할 수 있어요';

  @override
  String get session_sessionCreationFlowPage_L374 =>
      '게임 방 생성에 실패했습니다. 다시 시도해주세요';

  @override
  String get dialogsessionCreationFlowPageMessage => '이미 참가 중인 게임이 있습니다';

  @override
  String get dialogsessionCreationFlowPageMessage89ff => '알 수 없는 게임 상태입니다';

  @override
  String get session_sessionCreationFlowPage_L483 => '구역 선택을 먼저 설정할까요?';

  @override
  String get session_sessionCreationFlowPage_L484 => '인원을 설정해요';

  @override
  String get session_sessionCreationFlowPage_L485 => '기본 정보를 설정해요';

  @override
  String get session_sessionCreationFlowPage_L486 => '최종 설정을 확인해요';

  @override
  String get session_sessionCreationFlowPage_L491 => '게임에 필요한 구역을 설정해요';

  @override
  String get session_sessionCreationFlowPage_L492 => '최소 2명부터 게임 진행이 가능해요';

  @override
  String get session_sessionCreationFlowPage_L493 => '게임을 진행할 때, 꼭 필요한 정보들이에요';

  @override
  String get session_sessionCreationFlowPage_L494 => '방 생성 전 마지막으로 설정을 확인할까요?';

  @override
  String get session_sessionCreationFlowPage_L503 => '다음';

  @override
  String get session_sessionCreationFlowPage_L505 => '방 생성하기';

  @override
  String get session_sessionCreationFlowPage_L507 => '다음';

  @override
  String get session_sessionCreationFlowPage_L660 => '플레이그라운드';

  @override
  String get session_sessionCreationFlowPage_L665 => '감옥';

  @override
  String get session_sessionCreationFlowPage_L676 => '구역 정보를 먼저 설정해주세요';

  @override
  String get session_setupPlaygroundPage_L135 => '여기를 누르면 반경을 직접 입력할 수 있어요';

  @override
  String get session_setupPlaygroundPage_L195 => '플레이그라운드';

  @override
  String get session_setupPlaygroundPage_L212 => '플레이그라운드';

  @override
  String get session_setupPlaygroundPage_L233 => '게임이 진행될 전체 구역의 크기를 설정해요';

  @override
  String get session_setupPlaygroundPage_L267 => '완료';

  @override
  String get session_setupPrisonPage_L210 => '감옥';

  @override
  String get session_setupPrisonPage_L227 => '감옥';

  @override
  String get session_setupPrisonPage_L248 => '도둑을 잡아둘 감옥의 위치와 크기를 설정해요';

  @override
  String get session_setupPrisonPage_L286 => '플레이그라운드를 먼저 설정해주세요';

  @override
  String get session_setupPrisonPage_L287 => '감옥이 플레이그라운드 범위를 벗어났어요';

  @override
  String get session_setupPrisonPage_L299 => '완료';

  @override
  String get dialogwaitingRoomPageConfirm => '설정으로 이동';

  @override
  String get dialogwaitingRoomPageCancel => '나가기';

  @override
  String get session_waitingRoomPage_L364 => '포근포근곰...';

  @override
  String get dialogwaitingRoomPageTitle => '방에 참여할 수 없어요';

  @override
  String get session_waitingRoomPage_L545 => '해당 게임에 참가하지 않은 사용자입니다';

  @override
  String get dialogwaitingRoomPageConfirm3ce8 => '확인';

  @override
  String get session_waitingRoomPage_L631 => '이 버튼을 눌러 다른 팀으로 이동할 수 있어요';

  @override
  String get session_waitingRoomPage_L637 => '친구에게 초대 코드를 공유할 수 있어요';

  @override
  String get session_waitingRoomPage_L642 => '게임 설정을 확인할 수 있어요';

  @override
  String get session_waitingRoomPage_L647 => '준비가 되면 눌러주세요';

  @override
  String get dialogwaitingRoomPageTitle1946 => '인게임 화면 미리 보기';

  @override
  String get dialogwaitingRoomPageMessage =>
      '게임이 시작되면 어떻게 동작하는지\n한 번 확인하고 시작해볼까요?';

  @override
  String get dialogwaitingRoomPageConfirmA2d8 => '보러 가기';

  @override
  String dialogwaitingRoomPageTitleBc54(String nickname) {
    return '$nickname님을 내보낼까요?';
  }

  @override
  String get dialogwaitingRoomPageMessageB302 =>
      '강퇴된 유저는 방에서 즉시 내보내져요\n다시 방에 참가하려면 초대코드를 입력해야 해요';

  @override
  String get dialogwaitingRoomPageCancelD9de => '취소';

  @override
  String get dialogwaitingRoomPageConfirmC08c => '내보내기';

  @override
  String get dialogwaitingRoomPageMessageE87b => '강퇴 처리 중 오류가 발생했어요';

  @override
  String get dialogwaitingRoomPageTitle8208 => '방에서 내보내졌어요';

  @override
  String get dialogwaitingRoomPageMessage64a2 => '다시 참가하려면 초대코드를 입력해야 해요';

  @override
  String dialogwaitingRoomPageMessage36a5(String kickedNickname) {
    return '$kickedNickname님이 내보내졌어요';
  }

  @override
  String get session_waitingRoomPage_L1030 => '팀 변경에 실패했어요';

  @override
  String get session_waitingRoomPage_L1062 => '준비 상태 변경에 실패했어요';

  @override
  String get session_waitingRoomPage_L1099 => '게임 시작에 실패했어요';

  @override
  String get dialogwaitingRoomPageTitleFfec => '방을 나가시겠어요?';

  @override
  String get dialogwaitingRoomPageMessage3930 => '나가면 다시 초대코드를 입력해야 해요';

  @override
  String get dialogwaitingRoomPageConfirmC0a3 => '나가기';

  @override
  String get session_waitingRoomPage_L1130 => '퇴장 처리 중 오류가 발생했습니다';

  @override
  String get dialogwaitingRoomPageTitleA5bb => '초대코드를 생성했어요';

  @override
  String get dialogwaitingRoomPageMessage06a6 => '친구에게 코드를 공유하고 게임에 참여해 보세요!';

  @override
  String get dialogwaitingRoomPageMessage4785 => '코드가 복사되었습니다';

  @override
  String get dialogwaitingRoomPageCancel218e => '닫기';

  @override
  String get dialogwaitingRoomPageConfirm27f8 => '공유하기';

  @override
  String get session_waitingRoomPage_L1511 => '게임 시작';

  @override
  String get session_waitingRoomPage_L1526 => '준비 완료';

  @override
  String get session_waitingRoomPage_L1537 => '준비';

  @override
  String get session_zonePreviewPage_L122 => '게임 구역';

  @override
  String get session_zonePreviewPage_L145 => '현재 설정된 게임 구역이에요';

  @override
  String get session_waitingRoomParticipantsProvider_L81 => '포근포근곰...';

  @override
  String get session_waitingRoomParticipantsProvider_L87 => '오동통 너구리';

  @override
  String get session_waitingRoomParticipantsProvider_L93 => '닉네임';

  @override
  String get session_waitingRoomParticipantsProvider_L99 => '닉네임';

  @override
  String get dialoggameRulesContentTitle => '게임 규칙';

  @override
  String get dialoggameRulesContentCancel => '확인';

  @override
  String get dialoggameRulesContentConfirm => '인게임 보기';

  @override
  String get session_gameRulesContent_L95 => '경찰은 모든 도둑을 잡아서';

  @override
  String get session_gameRulesContent_L96 => '체포하면,';

  @override
  String get session_gameRulesContent_L97 => '\n도둑은';

  @override
  String get session_gameRulesContent_L98 => '제한 시간이 끝날 때까지 버티면';

  @override
  String get session_gameRulesContent_L99 => '승리해요';

  @override
  String get session_gameRulesContent_L108 => '도둑팀의 위치는';

  @override
  String session_gameRulesContent_L109(int minutes) {
    return '$minutes분마다';
  }

  @override
  String get session_gameRulesContent_L110 => '경찰팀에게 공유돼요';

  @override
  String get session_gameRulesContent_L118 => '지정된 게임 구역에서 벗어나면 안 돼요';

  @override
  String get session_gameRulesContent_L119 => '\n→ 구역 밖으로 나가면 화면이 잠겨요';

  @override
  String get dialogsessionCodeCardMessage => '코드가 복사되었습니다';

  @override
  String get dialogstep0SelectAreaContentTitle => '플레이그라운드';

  @override
  String get dialogstep0SelectAreaContentTitle5bc0 => '감옥';

  @override
  String get fieldstep1ParticipantSettingsContentLabel => '최대 참가자';

  @override
  String get session_step1ParticipantSettingsContent_L52 => '명';

  @override
  String get fieldstep2GameSettingsContentLabel => '라운드 제한 시간';

  @override
  String get session_step2GameSettingsContent_L79 => '분';

  @override
  String get fieldstep2GameSettingsContentLabel5ab2 => '도둑 위치 공유 간격';

  @override
  String get session_step2GameSettingsContent_L97 => '분';

  @override
  String get session_step2GameSettingsContent_L104 => '도둑의 위치가 공유되지 않아요!';

  @override
  String get fieldstep2GameSettingsContentLabelCe3b => '경찰 출동 시간';

  @override
  String get session_step2GameSettingsContent_L115 => '분';

  @override
  String get session_step2GameSettingsContent_L117 => '도둑 도망 후';

  @override
  String get session_step2GameSettingsContent_L118 => '뒤';

  @override
  String get session_sessionStepLayout_L42 => '다음';

  @override
  String get dialogsettingListCardTitle => '설정';

  @override
  String get fieldsettingListCardLabel => '참여 인원';

  @override
  String get fieldsettingListCardLabelEc5e => '라운드 제한 시간';

  @override
  String get fieldsettingListCardLabelA1b3 => '위치 공유 간격';

  @override
  String get fieldsettingListCardLabelCe3b => '경찰 출동 시간';

  @override
  String get session_teamSection_L116 => '경찰팀';

  @override
  String get session_teamSection_L116_1 => '도둑팀';

  @override
  String session_teamSection_L178(int length) {
    return '현재 $length명';
  }

  @override
  String get dialogzoneListCardTitle => '구역';

  @override
  String get dialogauthRepositoryImplMessage => '로그인 중 오류가 발생했습니다';

  @override
  String get dialogauthRepositoryImplMessage993d => '로그아웃 중 오류가 발생했습니다';

  @override
  String get auth_firebaseAuthErrorHandler_L31 =>
      '로그인 정보를 가져올 수 없습니다. 다시 시도해주세요';

  @override
  String get auth_firebaseAuthErrorHandler_L33 => '인증 토큰 발급에 실패했습니다. 다시 시도해주세요';

  @override
  String get auth_firebaseAuthErrorHandler_L35 =>
      'Firebase 인증 토큰 검증에 실패했습니다. 다시 로그인해주세요';

  @override
  String get auth_firebaseAuthErrorHandler_L37 => '로그인이 취소되었습니다';

  @override
  String get auth_firebaseAuthErrorHandler_L39 => '네트워크 연결을 확인해주세요';

  @override
  String get auth_firebaseAuthErrorHandler_L41 => '잘못된 인증 정보입니다';

  @override
  String get auth_firebaseAuthErrorHandler_L43 => '비활성화된 계정입니다';

  @override
  String get auth_firebaseAuthErrorHandler_L45 =>
      '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get auth_firebaseAuthErrorHandler_L47 => '이 로그인 방법은 현재 사용할 수 없습니다';

  @override
  String get auth_firebaseAuthErrorHandler_L49 =>
      'Firebase 설정에 문제가 있습니다. 잠시 후 다시 시도해주세요';

  @override
  String get auth_firebaseAuthErrorHandler_L51 =>
      'Firebase 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String auth_firebaseAuthErrorHandler_L55(int provider) {
    return '$provider 로그인에 실패했습니다. 다시 시도해주세요';
  }

  @override
  String get auth_firebaseAuthErrorHandler_L57 => '로그인에 실패했습니다. 다시 시도해주세요';

  @override
  String get dialogagreementPageTitle => '이용약관';

  @override
  String get dialogagreementPageTitleBe29 => '개인정보 처리방침';

  @override
  String get dialogagreementPageTitle6dcc => '위치정보 이용약관';

  @override
  String get dialogagreementPageTitle76b8 => '마케팅 정보 수신';

  @override
  String get auth_agreementPage_L107 => '동의하고 시작하기';

  @override
  String get auth_agreementPage_L127 => '서비스 이용을 위해\n약관에 동의해주세요';

  @override
  String get auth_agreementPage_L135 => '필수 약관에 모두 동의해야 서비스를 이용하실 수 있어요';

  @override
  String get dialogagreementPageMessage => '아직 네트워크에 연결되지 않았어요';

  @override
  String get dialogagreementPageMessage24a8 => '필수 약관에 모두 동의해주세요';

  @override
  String get auth_agreementPage_L184 => '일시적인 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String get dialogloginPageTitle => '개인정보 처리방침';

  @override
  String get dialogloginPageTitle2aa8 => '이용약관';

  @override
  String get dialogloginPageTitle6dcc => '위치정보 이용약관';

  @override
  String get dialogloginPageMessage => '회원탈퇴가 완료되었습니다';

  @override
  String get dialogloginPageTitleA40f => '만 14세 이상이신가요?';

  @override
  String get dialogloginPageMessageBa5d =>
      '경찰과 도둑은 만 14세 미만 회원가입이 불가능해요.\n해당 정보는 가입 금지 확인 용도로만 사용하고 있어요';

  @override
  String get dialogloginPageConfirm => '네';

  @override
  String get dialogloginPageCancel => '아니요';

  @override
  String get dialogloginPageMessageFe9d => '로그인이 취소되었습니다';

  @override
  String get auth_loginPage_L166 => '로그인 중 오류가 발생했습니다';

  @override
  String get auth_loginPage_L191 => 'Apple 로그인 중 오류가 발생했습니다';

  @override
  String get auth_loginPage_L260 => '만 14세 미만은 서비스를 이용할 수 없습니다';

  @override
  String get auth_loginPage_L284 => '로그인 시';

  @override
  String get auth_loginPage_L286 => '개인정보 처리방침';

  @override
  String get auth_loginPage_L295 => '이용약관';

  @override
  String get auth_loginPage_L304 => '위치정보 이용약관';

  @override
  String get auth_loginPage_L311 => '에 동의합니다';

  @override
  String get dialognicknameSetupPageMessage => '닉네임이 저장되었어요';

  @override
  String get auth_nicknameSetupPage_L248 => '닉네임을 설정해요';

  @override
  String get auth_nicknameSetupPage_L257 =>
      '서비스 내에서 계속 사용될 닉네임이에요\n1~10글자로 생성할 수 있어요';

  @override
  String get auth_nicknameSetupPage_L281 => '확인';

  @override
  String get auth_nicknameSetupPage_L308 => '닉네임을 입력하세요';

  @override
  String get auth_nicknameSetupPage_L336 => '중복 확인';

  @override
  String get auth_nicknameSetupPage_L354 => '1글자 미만의 닉네임은 사용할 수 없어요';

  @override
  String get auth_nicknameSetupPage_L359 => '중복된 닉네임이에요. 다른 닉네임을 입력하세요';

  @override
  String get auth_nicknameSetupPage_L364 => '사용 가능한 닉네임이에요';

  @override
  String get auth_nicknameSetupPage_L369 => '오류가 발생했어요. 다시 시도해주세요';

  @override
  String get auth_splashPage_L48 => '다시 현장으로 복귀 중...';

  @override
  String get auth_splashPage_L208 => '다시 현장으로 복귀 중...';

  @override
  String get dialogsplashPageMessage => '아직 네트워크에 연결되지 않았어요';

  @override
  String get dialogsplashPageTitle => '네트워크 연결 실패';

  @override
  String get dialogsplashPageMessage665f => '인터넷 연결을 확인한 후\n다시 시도해주세요';

  @override
  String get dialogsplashPageConfirm => '재시도';

  @override
  String get auth_splashPage_L395 => '잠시만 기다려주세요';

  @override
  String get auth_splashPage_L412 => 'by 동심지키미';

  @override
  String get auth_splashPage_L444 => '인터넷 연결이 필요합니다';

  @override
  String get auth_splashPage_L450 => '연결 상태를 확인한 후\n다시 시도해주세요';

  @override
  String get auth_splashPage_L461 => '다시 시도';

  @override
  String get dialogagreementProviderMessage => '일시적인 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String auth_authProvider_L129(String message) {
    return '사유: $message';
  }

  @override
  String get dialogauthProviderMessage => '알 수 없는 오류가 발생했습니다';

  @override
  String get dialogauthProviderMessage222f => '로그아웃에 실패했습니다';

  @override
  String get auth_agreementAllCheckbox_L35 => '전체 동의';

  @override
  String get auth_agreementItem_L39 => '[필수]';

  @override
  String get auth_agreementItem_L39_1 => '[선택]';

  @override
  String get dialoggamePageConfirm => '설정으로 이동';

  @override
  String get game_gamePage_L379 => '도둑이 도망치는 중이에요!';

  @override
  String get game_gamePage_L1026 => '게임 종료!';

  @override
  String get game_gamePage_L1034 => '도둑이 모두 체포되었습니다!';

  @override
  String get game_gamePage_L1034_1 => '제한 시간이 종료되었습니다!';

  @override
  String get game_gamePage_L1086 => '경찰팀';

  @override
  String get game_gamePage_L1086_1 => '도둑팀';

  @override
  String get game_gamePage_L1090 => '승리';

  @override
  String get game_gamePage_L1090_1 => '패배';

  @override
  String dialoggamePageMessage(String winnerTeamLabel) {
    return '$winnerTeamLabel의 승리입니다!';
  }

  @override
  String get dialoggamePageCancel => '홈으로';

  @override
  String get dialoggamePageConfirm5863 => '한 번 더';

  @override
  String get game_gamePage_L1289 => '경찰';

  @override
  String get game_gamePage_L1290 => '도둑';

  @override
  String get dialoggamePageMessage5e97 => '경찰 대기 시간 중에는 도둑을 체포할 수 없습니다';

  @override
  String get dialoggamePageTitle => '도둑의 수배 QR을 스캔하세요';

  @override
  String get dialoggamePageMessage6487 => '만료된 QR입니다. QR 새로고침을 요청하세요';

  @override
  String get dialoggamePageMessage4b5f => '이미 체포된 도둑입니다';

  @override
  String get game_gameEventProvider_L337 => '인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다';

  @override
  String get game_gameEventProvider_L452 => '체포 요청 실패';

  @override
  String get game_gameEventProvider_L492 => '탈옥 요청 실패';

  @override
  String get game_gameEventProvider_L520 => '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요';

  @override
  String get game_gameEventProvider_L702 => '경찰';

  @override
  String get game_gameEventProvider_L703 => '도둑';

  @override
  String get game_gameEventProvider_L866 => '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요';

  @override
  String get game_gameEventProvider_L937 => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get game_gameEventProvider_L951 => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get game_arrestLockOverlay_L71 => '체포되었어요!';

  @override
  String get game_arrestLockOverlay_L78 =>
      '체포되어 있는 동안에는 게임 상황을 확인할 수 없어요\n같은 팀에게 구조 요청을 하며 빠르게 탈옥해요!';

  @override
  String get game_arrestLockOverlay_L89 => '탈옥 완료';

  @override
  String get dialogarrestLockOverlayTitle => '탈옥';

  @override
  String get dialogarrestLockOverlayMessage => '탈옥하시겠습니까?';

  @override
  String get game_arrestLockOverlay_L102 => '탈옥';

  @override
  String get game_gameActionModal_L63 => '아니요';

  @override
  String get game_gameActionModal_L63_1 => '취소';

  @override
  String get game_gameOverResultDialog_L324 => '승리';

  @override
  String get game_gameOverResultDialog_L324_1 => '패배';

  @override
  String get fieldgameOverResultDialogLabel => '체포 횟수';

  @override
  String game_gameOverResultDialog_L345(int totalArrestCount) {
    return '$totalArrestCount회';
  }

  @override
  String get fieldgameOverResultDialogLabelD8df => '남은 도둑';

  @override
  String game_gameOverResultDialog_L351(int remainingRobberCount) {
    return '$remainingRobberCount명';
  }

  @override
  String get fieldgameOverResultDialogLabelAb0c => '게임 진행 시간';

  @override
  String get game_gameOverResultDialog_L438 => '홈으로';

  @override
  String get game_gameOverResultDialog_L452 => '한 번 더';

  @override
  String game_locationRevealCountdown_L109(String _formatted) {
    return '다음 도둑 위치 공개까지 $_formatted';
  }

  @override
  String get dialogparticipantOverlayMessage => '경찰 대기 시간 중에는 도둑을 체포할 수 없습니다';

  @override
  String get dialogparticipantOverlayTitle => '해당 플레이어를 체포하셨나요?';

  @override
  String get game_participantOverlay_L139 => '네';

  @override
  String get dialogparticipantOverlayTitle4167 => '탈옥';

  @override
  String get dialogparticipantOverlayMessage9497 => '탈옥을 시도하시겠습니까?';

  @override
  String get game_participantOverlay_L166 => '탈옥';

  @override
  String get game_participantOverlay_L297 => '현재';

  @override
  String game_participantOverlay_L299(int count) {
    return '$count명';
  }

  @override
  String get game_participantOverlay_L305 => '도주 중!';

  @override
  String game_policeStartCountdown_L79(String _formatted) {
    return '경찰 시작까지 $_formatted';
  }

  @override
  String get game_qrDisplayDialog_L62 => '수배 QR';

  @override
  String get game_qrDisplayDialog_L86 => '경찰에게 QR을 보여주세요';

  @override
  String get game_qrDisplayDialog_L97 => '닫기';

  @override
  String get dialogqrScannerPageTitle => '카메라 권한 필요';

  @override
  String get dialogqrScannerPageMessage =>
      'QR코드를 스캔하려면 카메라 권한이 필요합니다.\n설정에서 카메라 권한을 허용해주세요';

  @override
  String get dialogqrScannerPageConfirm => '설정으로 이동';

  @override
  String get dialogqrScannerPageCancel => '닫기';

  @override
  String get game_qrScannerPage_L90 => '카메라를 사용할 수 없습니다';

  @override
  String get game_zoneExitBanner_L66 => '플레이그라운드를 벗어났어요';

  @override
  String get chat_chatProvider_L190 => '인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다';

  @override
  String get chat_chatProvider_L254 => '나';

  @override
  String get dialogchatProviderMessage => '[팀]';

  @override
  String get chat_chatProvider_L265 => '팀원닉네임';

  @override
  String get chat_chatProvider_L265_1 => '상대닉네임';

  @override
  String get chat_chatProvider_L286 => '시스템';

  @override
  String get dialogchatProviderMessageDfca => '제한 시간은 30분입니다';

  @override
  String get chat_chatProvider_L381 => '시스템';

  @override
  String get dialogchatProviderMessage2119 => '게임이 곧 시작됩니다. 모든 플레이어는 준비하세요!';

  @override
  String get chat_chatProvider_L388 => '시스템';

  @override
  String get dialogchatProviderMessageC357 => '도둑 잘 도망쳐 봐요~';

  @override
  String get chat_chatProvider_L395 => '닉네임';

  @override
  String get dialogchatProviderMessageEa9a => '이겨봅시다!';

  @override
  String get chat_chatProvider_L402 => '닉네임';

  @override
  String get chat_chatProvider_L564 => '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요';

  @override
  String get chat_chatProvider_L655 => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get chat_chatProvider_L676 => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get dialogchatContextMenuMessage => '메시지가 복사되었어요';

  @override
  String get dialogchatContextMenuMessage2c60 => '해당 유저를 차단했어요';

  @override
  String get dialogchatContextMenuTitle => '신고하기';

  @override
  String get fieldchatContextMenuLabel => '신고 내용';

  @override
  String get fieldchatContextMenuHint =>
      '신고 사유를 자세히 작성해 주세요\n(상황 또는 대화 내용을 포함해 주세요)';

  @override
  String get chat_chatContextMenu_L140 => '신고하기';

  @override
  String get dialogchatContextMenuMessageDf78 => '신고가 접수되었어요';

  @override
  String get dialogchatContextMenuMessage9d41 => '신고에 실패했어요';

  @override
  String get dialogchatContextMenuTitle5ccb => '해당 유저를 신고할까요?';

  @override
  String get dialogchatContextMenuCancel => '취소';

  @override
  String get dialogchatContextMenuConfirm => '신고하기';

  @override
  String get chat_chatContextMenu_L190 => '선택한 신고 사유:';

  @override
  String get chat_chatContextMenu_L202 => '\n신고된 내용은 검토 후 조치할게요';

  @override
  String get fieldchatContextMenuLabelA83e => '복사하기';

  @override
  String get fieldchatContextMenuLabel7812 => '신고하기';

  @override
  String get fieldchatContextMenuLabel2f14 => '차단하기';

  @override
  String get chat_chatContextMenu_L478 => '신고 유형 선택';

  @override
  String chat_chatInputBar_L98(String all) {
    return '전체 $all개';
  }

  @override
  String chat_chatInputBar_L99(String team) {
    return '팀 $team개';
  }

  @override
  String get chat_chatInputBar_L158 => '연결 중...';

  @override
  String get chat_chatInputBar_L159 => '채팅을 입력하세요';

  @override
  String get chat_chatMessageList_L152 => '채팅을 시작해보세요';

  @override
  String get fieldchatMessageListLabel => '최신 메시지로 이동';

  @override
  String get chat_chatMessageList_L276 => '월';

  @override
  String get chat_chatMessageList_L276_1 => '화';

  @override
  String get chat_chatMessageList_L276_2 => '수';

  @override
  String get chat_chatMessageList_L276_3 => '목';

  @override
  String get chat_chatMessageList_L276_4 => '금';

  @override
  String get chat_chatMessageList_L276_5 => '토';

  @override
  String get chat_chatMessageList_L276_6 => '일';

  @override
  String chat_chatMessageList_L278(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year년 $month월 $day일 $weekday요일';
  }

  @override
  String get chat_chatOverlay_L428 => '전체 채팅';

  @override
  String get chat_chatOverlay_L428_1 => '팀 채팅';

  @override
  String get chat_chatPreviewCard_L116 => '공지';

  @override
  String get chat_chatPreviewCard_L120 => '팀';

  @override
  String get chat_chatPreviewCard_L124 => '전체';

  @override
  String get dialogagreementSettingsPageMessage => '아직 네트워크에 연결되지 않았어요';

  @override
  String get dialogagreementSettingsPageMessageEfc5 => '변경사항이 저장되었어요';

  @override
  String get settings_agreementSettingsPage_L102 =>
      '일시적인 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String get settings_agreementSettingsPage_L142 => '이용약관 및 정책';

  @override
  String get settings_agreementSettingsPage_L159 => '약관 동의 현황을 불러올 수 없습니다';

  @override
  String get settings_agreementSettingsPage_L176 => '다시 시도';

  @override
  String get dialogagreementSettingsPageTitle => '이용약관';

  @override
  String get dialogagreementSettingsPageTitleBe29 => '개인정보 처리방침';

  @override
  String get dialogagreementSettingsPageTitle6dcc => '위치정보 이용약관';

  @override
  String get dialogagreementSettingsPageTitle76b8 => '마케팅 정보 수신';

  @override
  String get settings_agreementSettingsPage_L261 => '변경사항 저장';

  @override
  String get settings_legalDocumentPage_L105 => '문서를 불러올 수 없습니다';

  @override
  String get settings_settingsPage_L104 => '설정';

  @override
  String get settings_settingsPage_L115 => '계정';

  @override
  String get settings_settingsPage_L117 => '닉네임 변경';

  @override
  String get settings_settingsPage_L128 => '앱 설정';

  @override
  String get settings_settingsPage_L130 => '게임 알림';

  @override
  String get settings_settingsPage_L131 => '게임 진행 중 발생하는 이벤트 알림을 설정해요';

  @override
  String get settings_settingsPage_L137 => '알림';

  @override
  String get settings_settingsPage_L143 => '게임 중 알림';

  @override
  String get settings_settingsPage_L149 => '을 포함한 앱에서 보내는 모든 알림을 설정해요';

  @override
  String get settings_settingsPage_L164 => '위치 권한 관리';

  @override
  String get settings_settingsPage_L165 => '기기 설정에서 위치 권한을 변경할 수 있어요';

  @override
  String get settings_settingsPage_L176 => '이용 안내';

  @override
  String get settings_settingsPage_L179 => '버그 제보';

  @override
  String get settings_settingsPage_L182 => '튜토리얼 다시 보기';

  @override
  String get settings_settingsPage_L186 => '튜토리얼 초기화';

  @override
  String get settings_settingsPage_L189 => '이용약관 및 정책';

  @override
  String get settings_settingsPage_L202 => '기타';

  @override
  String get settings_settingsPage_L204 => '로그아웃';

  @override
  String get settings_settingsPage_L210 => '회원 탈퇴';

  @override
  String get settings_settingsPage_L292 => '앱 버전';

  @override
  String get dialogsettingsPageMessage => '게임 알림 설정을 변경하지 못했어요';

  @override
  String get dialogsettingsPageTitle => '버그 제보';

  @override
  String get fieldsettingsPageLabel => '버그 내용';

  @override
  String get fieldsettingsPageHint =>
      '어떤 문제가 발생했나요?\n발생 상황을 자세히 적어주세요(시간, 기기 정보 포함)';

  @override
  String get settings_settingsPage_L498 => '제보하기';

  @override
  String get dialogsettingsPageMessage1b8e => '버그 제보가 접수되었어요';

  @override
  String get dialogsettingsPageTitleD4a4 => '튜토리얼 초기화';

  @override
  String get dialogsettingsPageMessageA4c9 =>
      '모든 화면의 튜토리얼을\n다시 볼 수 있도록 초기화할까요?';

  @override
  String get dialogsettingsPageConfirm => '초기화';

  @override
  String get dialogsettingsPageMessageC8cb => '튜토리얼이 초기화되었어요';

  @override
  String get dialogsettingsPageTitle9ab1 => '로그아웃';

  @override
  String get dialogsettingsPageMessageE675 => '정말 로그아웃 하시겠어요?';

  @override
  String get dialogsettingsPageConfirm9ab1 => '로그아웃';

  @override
  String get settings_settingsPage_L590 => '로그아웃에 실패했습니다';

  @override
  String get settings_settingsPage_L590_1 => '로그아웃되었습니다';

  @override
  String get dialogsettingsPageTitle5e0d => '회원 탈퇴';

  @override
  String get settings_settingsPage_L603 =>
      '탈퇴하면 모든 데이터가 삭제되며\n되돌릴 수 없습니다\n\n계속하려면 \"delete\"를 입력하세요';

  @override
  String get fieldsettingsPageHint2960 => 'delete';

  @override
  String get dialogsettingsPageCancel => '취소';

  @override
  String get dialogsettingsPageConfirm9140 => '탈퇴';

  @override
  String get settings_settingsPage_L613 => '탈퇴하기';

  @override
  String get tutorial_inGameTutorialPage_L62 => '경찰1';

  @override
  String get tutorial_inGameTutorialPage_L72 => '도둑킹';

  @override
  String get tutorial_inGameTutorialPage_L78 => '도둑이게아니게';

  @override
  String get tutorial_inGameTutorialPage_L84 => '잡힌도둑';

  @override
  String get dialoginGameTutorialPageTitle => '튜토리얼 완료!';

  @override
  String get dialoginGameTutorialPageMessage => '핵심 흐름을 익혔어요\n실제 게임에서 활용해보세요';

  @override
  String get dialoginGameTutorialPageConfirm => '튜토리얼 끝내기';

  @override
  String get dialoginGameTutorialPageMessage8372 => '내 위치로 카메라가 이동했어요';

  @override
  String get tutorial_inGameTutorialPage_L391 => '지도 미리보기';

  @override
  String get tutorial_inGameTutorialPage_L434 => '다음 도둑 위치 공개까지 04:30';

  @override
  String get dialoginGameTutorialPageMessage9b3f => '게임 룰 안내가 열려요';

  @override
  String get tutorial_inGameTutorialPage_L491 =>
      '내 수배 QR이 화면에 표시돼요. 경찰에게 보여주면 체포';

  @override
  String get tutorial_inGameTutorialPage_L492 =>
      '카메라가 켜지고 도둑의 QR을 스캔해 체포할 수 있어요';

  @override
  String get tutorial_inGameTutorialPage_L509 => '참가자 보기 버튼을 눌러보세요';

  @override
  String get tutorial_inGameTutorialPage_L509_1 => 'QR 버튼을 눌러보세요';

  @override
  String get tutorial_inGameTutorialPage_L509_2 => '지도로 돌아가 보세요';

  @override
  String tutorial_inGameTutorialPage_L525(String _missionStep) {
    return '미션 $_missionStep/3';
  }

  @override
  String get tutorial_inGameTutorialPage_L608 => '도둑 시점 보는 중';

  @override
  String get tutorial_inGameTutorialPage_L608_1 => '경찰 시점 보는 중';

  @override
  String get dialoginGameTutorialPageMessageA1c5 =>
      '본인이 수감됐다면 카드 탭으로 탈옥을 시도할 수 있어요';

  @override
  String get dialoginGameTutorialPageMessage9331 => '실제 게임에서는 QR 스캔으로 도둑을 체포해요';

  @override
  String get tutorial_inGameTutorialPage_L688 => '현재';

  @override
  String tutorial_inGameTutorialPage_L690(int count) {
    return '$count명';
  }

  @override
  String get tutorial_inGameTutorialPage_L696 => '도주 중!';

  @override
  String get dialoginGameTutorialPageMessage7650 => '핸들을 위로 드래그하면 채팅이 펼쳐져요';

  @override
  String get dialoginGameTutorialPageMessageDb39 =>
      '여기에 메시지를 입력하면 팀/전체 채팅으로 보낼 수 있어요';

  @override
  String get tutorial_inGameTutorialPage_L806 => '채팅을 입력하세요';

  @override
  String get dialogtutorialCatalogPageTitle => '방 만들기';

  @override
  String get tutorial_tutorialCatalogPage_L20 => '플레이그라운드·감옥 설정과 슬라이더 조작';

  @override
  String get dialogtutorialCatalogPageTitle879f => '방 참여하기';

  @override
  String get tutorial_tutorialCatalogPage_L25 => '초대 코드 입력과 QR 스캔';

  @override
  String get dialogtutorialCatalogPageTitle2421 => '대기방';

  @override
  String get tutorial_tutorialCatalogPage_L30 => '팀 변경, 게임 설정, 준비 완료';

  @override
  String get dialogtutorialCatalogPageTitle8700 => '인게임';

  @override
  String get tutorial_tutorialCatalogPage_L35 => '타이머·지도·참가자·채팅·QR';

  @override
  String get tutorial_tutorialCatalogPage_L62 => '튜토리얼';

  @override
  String get tutorial_tutorialCatalogPage_L69 => '게임을 처음 한다면 한 번씩 보고 시작해보세요';

  @override
  String get tutorial_tutorialCatalogPage_L200 => '준비 중';

  @override
  String get credits_creditMember_L78 => '홍의민';

  @override
  String get credits_creditMember_L97 => '박찬빈';

  @override
  String get credits_creditMember_L110 => '이창희';

  @override
  String get credits_creditMember_L122 => '정상희';

  @override
  String get credits_creditMember_L137 => '황혜림';

  @override
  String get credits_creditMember_L149 => '윤지희';

  @override
  String get credits_creditMember_L220 => '신지훈';

  @override
  String get credits_creditMember_L227 => '남해윤';

  @override
  String get credits_creditMember_L233 => '송혜정';

  @override
  String get credits_creditMember_L239 => '이진';

  @override
  String get credits_creditMember_L246 => '안금서';

  @override
  String get credits_creditMember_L252 => '손건우';

  @override
  String get credits_creditMember_L258 => '신혜빈';

  @override
  String get credits_creditMember_L264 => '정창우';

  @override
  String get credits_creditMember_L270 => '허석준';

  @override
  String get credits_creditMember_L276 => '서현진';

  @override
  String get credits_creditMember_L282 => '오동현';

  @override
  String get credits_creditMember_L288 => '최승훈';

  @override
  String get credits_creditMember_L294 => '김민욱';

  @override
  String get credits_creditMember_L300 => '정명준';

  @override
  String get credits_creditMember_L306 => '강대현';

  @override
  String get credits_creditMember_L312 => '심 혁';

  @override
  String get credits_creditsPage_L45 => '경찰과 도둑을 만든 사람들';

  @override
  String get dialogreportRepositoryImplMessage => '신고 처리 중 오류가 발생했습니다';

  @override
  String get report_reportCategories_L7 => '낚시/놀람/도배';

  @override
  String get report_reportCategories_L8 => '욕설/비하';

  @override
  String get report_reportCategories_L9 => '사칭/사기';

  @override
  String get report_reportCategories_L10 => '광고/스팸';

  @override
  String get report_reportCategories_L11 => '부정 행위/버그 악용';

  @override
  String get report_reportCategories_L12 => '팀 사기 저하';

  @override
  String get report_reportCategories_L13 => '기타(직접 작성)';

  @override
  String get dialoguserRepositoryImplMessage => '닉네임 확인 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessageAc72 =>
      '닉네임 변경 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessage243c => '사용자 정보 조회 중 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessage220e => '회원 탈퇴 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessage05b0 =>
      '약관 동의 상태 조회 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessage2357 =>
      '약관 동의 저장 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessage3d3a =>
      '게임 푸시 알림 동의 조회 중 예기치 않은 오류가 발생했습니다';

  @override
  String get dialoguserRepositoryImplMessage5fe2 =>
      '게임 푸시 알림 동의 업데이트 중 예기치 않은 오류가 발생했습니다';

  @override
  String get lobby_lobbyProvider_L139 => '인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다';

  @override
  String get lobby_lobbyProvider_L187 => '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요';

  @override
  String get lobby_lobbyProvider_L319 => '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요';

  @override
  String get lobby_lobbyProvider_L381 => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get lobby_lobbyProvider_L399 => '인증이 만료되었습니다. 재로그인이 필요합니다';

  @override
  String get dialognoticeRepositoryImplMessage => '공지사항을 불러오는 중 오류가 발생했습니다';

  @override
  String get dialognoticesPageMessage => '공지사항을 불러오는 중...';

  @override
  String get dialognoticesPageMessage4982 => '공지사항을 불러오지 못했어요';

  @override
  String get notice_noticesPage_L131 => '공지사항';

  @override
  String get notice_noticesPage_L152 => '등록된 공지사항이 없습니다';

  @override
  String get router_appRouter_L477 => '구역 정보를 불러올 수 없습니다';

  @override
  String get router_appRouter_L575 => '페이지를 찾을 수 없습니다';

  @override
  String get router_appRouter_L586 => '요청하신 페이지가 존재하지 않습니다';

  @override
  String router_appRouter_L589(String path) {
    return '경로: $path';
  }

  @override
  String get router_appRouter_L600 => '로그아웃';

  @override
  String get dialogbugRepositoryImplMessage => '버그 제보 처리 중 오류가 발생했습니다';

  @override
  String get dialogmainTitle => '경찰과도둑';

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
  String get gameEventPoliceMoveWarning => '경찰이 곧 출동합니다.  도둑은 서둘러 이동하세요!';

  @override
  String get gameEventPoliceMove => '경찰 출동!  도둑은 도망치세요!';

  @override
  String get gameEventLocationReveal => '현재 도둑의 위치가 공개됩니다!';

  @override
  String gameEventRemainingRobbers(int count) {
    return '현재 $count명 도주 중!';
  }

  @override
  String gameEventArrestNotice(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname]님이 @icon_robber [$robberNickname]님을 체포했습니다!';
  }

  @override
  String get gameEventEscapeNotice => '도둑이 탈옥했습니다! 지금 바로 체포하세요!';

  @override
  String get gameEventFiveMinutesLeft => '게임 종료까지 5분 남았습니다. 마지막 기회를 놓치지 마세요!';

  @override
  String mapErrorLoadFailed(String mapName) {
    return '$mapName 로드 실패';
  }
}
