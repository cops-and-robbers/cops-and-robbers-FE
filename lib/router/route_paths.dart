import '../core/constants/legal_doc.dart';

/// 앱 전체의 라우트 경로 상수를 정의하는 클래스
///
/// 모든 라우트 경로는 이 클래스를 통해 접근하여
/// 오타로 인한 버그를 방지하고 유지보수성을 향상시킵니다.
///
/// 사용법:
/// ```dart
/// // 1. 기본 네비게이션 (경로로 이동)
/// context.go(RoutePaths.home)
/// context.push(RoutePaths.login)
///
/// // 2. Named 네비게이션 (이름으로 이동)
/// context.goNamed(RoutePaths.homeName)
/// context.pushNamed(RoutePaths.loginName)
///
/// // 3. 동적 경로 (파라미터 포함)
/// context.go(RoutePaths.waitingRoomWithId('session123'))
/// context.go(RoutePaths.gameWithId('session123'))
///
/// // 4. 뒤로가기
/// context.pop()
///
/// // 5. go vs push 차이
/// // go: 히스토리 스택 전체를 새 경로로 교체 (뒤로가기 불가능)
/// //     예: 스플래시 → 로그인 → go(홈) → 뒤로가기 불가
/// //     사용: 로그인 성공 후, 온보딩 완료 후 등 (이전 화면으로 못 돌아가게)
/// // push: 히스토리 스택에 새 페이지 추가 (뒤로가기로 이전 페이지로)
/// //      예: 홈 → push(설정) → 뒤로가기 → 홈으로 복귀
/// //      사용: 임시 화면, 상세 화면, 설정 화면 등 (뒤로가기 필요)
/// ```
class RoutePaths {
  // Private constructor to prevent instantiation
  RoutePaths._();

  // ============================================================================
  // Root & Authentication Routes
  // ============================================================================

  /// 초기 스플래시 화면 (인증 상태 체크 및 자동 리다이렉트)
  static const String splash = '/';

  /// 로그인 화면 (Google Sign-In)
  static const String login = '/login';

  /// 온보딩 화면 (첫 로그인 시: 이용약관 동의, 닉네임 설정)
  static const String onboarding = '/onboarding';

  /// 닉네임 설정 화면 (신규 회원: isNewUser == true)
  static const String nicknameSetup = '/nickname-setup';

  /// 약관 동의 화면 (로그인 후 필수 약관 미동의 시 진입)
  static const String agreement = '/agreement';

  /// 홈 화면 (인증 필수, 게임 세션 생성/참가 선택)
  static const String home = '/home';

  /// 커뮤니티 화면 (바텀 네비게이션 탭 — 현재 준비중 placeholder)
  static const String community = '/community';

  /// 바텀 네비에서 커뮤니티가 몇 번째 브랜치인가 (`app_router.dart`의
  /// `StatefulShellBranch` 순서 — 홈 0 · 커뮤니티 1 · 마이페이지 2).
  ///
  /// 탭 화면이 "지금 내가 보이는가"를 판정할 때 쓴다. 브랜치 순서를 바꾸면
  /// 여기도 함께 고쳐야 한다.
  static const int communityBranchIndex = 1;

  /// 모집글 작성 화면 (커뮤니티 목록의 작성 버튼에서 진입)
  static const String communityCreate = '/community/create';

  /// 모집글 검색 화면 (커뮤니티 목록 상단 돋보기에서 진입)
  ///
  /// `:postId`보다 먼저 등록해야 한다 — 뒤에 두면 `/community/search`가
  /// postId="search"로 잡힌다 (`create`와 같은 이유).
  static const String communitySearch = '/community/search';

  /// 모집글 상세 화면 (목록 카드 탭에서 진입)
  ///
  /// `create`보다 뒤에 등록해야 한다 — 먼저 두면 `/community/create`가
  /// postId="create"로 잡힌다.
  static const String communityDetail = '/community/:postId';

  /// 상세 절대 경로 — 푸시 알림 탭처럼 셸 밖에서 `go`로 진입할 때 쓴다.
  /// `go`는 커뮤니티 탭 셸까지 함께 세우므로 뒤로가기가 커뮤니티 목록으로 간다.
  static String communityDetailWithId(int postId) => '/community/$postId';

  /// 모집글 딥링크 경로 별칭 (웹 주소와 동일 — ko·ja·en)
  ///
  /// 엔진이 warm 인텐트의 원시 URI 경로를 라우터로 전달하므로
  /// (AndroidManifest 의 flutter_deeplinking_enabled=false 를 존중하지 않는
  /// 것을 실기기에서 확인), 딥링크 경로는 라우터에 실제 라우트로 존재해야
  /// 404 가 화면을 덮지 않는다. /join 과 같은 원리이며 전부 상세로 넘긴다.
  static const List<String> communityPostDeeplinkAliases = [
    '/g/:postId',
    '/ja/g/:postId',
    '/en/g/:postId',
  ];

  /// 모집글 수정 화면 (상세·목록 카드의 더보기 메뉴에서 진입)
  ///
  /// 고칠 글을 `extra`로 함께 넘겨야 한다 — 없으면 상세로 되돌린다(딥링크 방지).
  static const String communityEdit = '/community/:postId/edit';

  /// 모집글 채팅방 (상세의 참여 버튼 또는 내 모임 목록에서 진입)
  ///
  /// `:postId` 하위에 등록한다 — 상세·채팅방·사이드바가 같은 글 id를 공유한다.
  static const String communityChat = '/community/:postId/chat';
  static String communityChatWithId(int postId) => '/community/$postId/chat';

  /// 채팅방 사이드바 — 시안이 전체 화면이라 drawer 대신 push한다
  static const String communityChatMenu = '/community/:postId/chat/menu';
  static String communityChatMenuWithId(int postId) =>
      '/community/$postId/chat/menu';

  /// 채팅방 고정 공지 — 상단 모임 카드를 누르면 전체 화면으로 연다
  static const String communityChatNotice = '/community/:postId/chat/notice';
  static String communityChatNoticeWithId(int postId) =>
      '/community/$postId/chat/notice';

  /// 공지글 작성·수정. 기존 본문은 `extra`로 넘긴다 — 있으면 수정이다.
  static const String communityChatNoticeEdit =
      '/community/:postId/chat/notice/edit';
  static String communityChatNoticeEditWithId(int postId) =>
      '/community/$postId/chat/notice/edit';

  /// 마이페이지 화면 (바텀 네비게이션 탭 — 설정 메뉴)
  static const String mypage = '/mypage';

  /// 내 스크랩 목록 (마이페이지 계정 섹션에서 진입)
  static const String myScraps = '/mypage/scraps';

  /// 언어 설정 화면
  static const String languageSettings = '/mypage/language';

  /// 약관 설정 화면
  static const String agreementSettings = '/mypage/agreements';

  /// 버그 제보 화면
  static const String bugReport = '/mypage/bug-report';

  /// 법적 문서 화면 (최상위)
  ///
  /// 로그인, 가입 동의, 약관 설정 세 곳에서 같은 화면을 열기 때문에 마이페이지
  /// 하위가 아니라 최상위에 둡니다.
  /// 신고 유형 선택 — 어느 화면에서든 열리므로 최상위에 둔다.
  /// `extra`로 `ReportTarget`을 넘긴다.
  static const String report = '/report';

  /// 기타 신고 사유 작성 (신고 유형 선택의 자식 — 뒤로 가면 유형 목록으로)
  static const String reportReason = '/report/reason';

  static const String legalDocument = '/legal';

  /// 문서 종류에 해당하는 법적 문서 화면 경로
  static String legalDocumentOf(LegalDoc doc) => '$legalDocument/${doc.slug}';

  /// 크레딧 화면 (버전 5회 탭 이스터에그)
  static const String credits = '/mypage/credits';

  /// 공지사항 화면
  static const String notices = '/home/notices';

  // ============================================================================
  // Session Creation Flow Routes (PRD F1.1)
  // ============================================================================

  /// 세션 생성 플로우 (단일 PageView 페이지)
  /// - Step 0: 구역 선택
  /// - Step 1: 인원 설정
  /// - Step 2: 게임 설정
  /// - Step 3: 초대 코드
  static const String sessionCreationFlow = '/home/create-session';

  // ============================================================================
  // Game Flow Routes (PRD F1.6, F2.2)
  // ============================================================================

  /// F1.6: 대기실 (팀 선택, 준비 완료)
  /// 경로 파라미터: sessionId
  static const String waitingRoom = '/waiting-room/:sessionId';

  /// F2.2: 인게임 지도 화면 (실시간 위치 추적, GPS 3-5초 주기)
  /// 경로 파라미터: sessionId
  static const String game = '/game/:sessionId';

  /// 게임 설정 화면 (대기실에서 접근)
  /// 경로 파라미터: sessionId
  static const String gameSettings = '/waiting-room/:sessionId/game-settings';

  /// 게임 설정 수정 화면 (설정 슬라이더)
  static const String gameSettingsEdit =
      '/waiting-room/:sessionId/game-settings/edit-settings';

  /// 플레이그라운드 구역 수정 화면
  static const String gameSettingsPlayground =
      '/waiting-room/:sessionId/game-settings/edit-playground';

  /// 감옥 구역 수정 화면
  static const String gameSettingsPrison =
      '/waiting-room/:sessionId/game-settings/edit-prison';

  // ============================================================================
  // Note: 게임 종료 결과 화면 (F3.4)
  // ============================================================================
  // 결과 화면은 별도 라우트가 아닌 GamePage 내부에서 Dialog/Modal로 표시됩니다.
  // 설계 의도: 게임 종료 후에도 지도 UI를 유지하면서 결과를 오버레이로 표시하여
  // 사용자가 게임 맥락을 유지한 상태에서 결과를 확인할 수 있도록 합니다.

  // ============================================================================
  // System Status Routes (점검/업데이트)
  // ============================================================================

  /// 서버 점검 중 페이지
  static const String maintenance = '/maintenance';

  /// 강제 업데이트 페이지
  static const String forceUpdate = '/force-update';

  // ============================================================================
  // Developer Tools (개발/테스트용)
  // ============================================================================

  /// 생명주기 테스트 화면 (WidgetsBindingObserver 테스트용)
  /// ⚠️ 개발 전용 - 프로덕션 배포 시 제거 또는 숨김 처리 필요
  static const String lifecycleTest = '/lifecycle-test';

  // ============================================================================
  // Dynamic Route Helpers
  // ============================================================================

  /// 특정 세션 ID로 대기실 경로 생성
  ///
  /// Example:
  /// ```dart
  /// context.go(RoutePaths.waitingRoomWithId('abc123'));
  /// ```
  static String waitingRoomWithId(String sessionId) =>
      '/waiting-room/$sessionId';

  /// 특정 세션 ID로 게임 경로 생성
  ///
  /// Example:
  /// ```dart
  /// context.go(RoutePaths.gameWithId('abc123'));
  /// ```
  static String gameWithId(String sessionId) => '/game/$sessionId';

  /// 특정 세션 ID로 게임 설정 경로 생성
  static String gameSettingsWithId(String sessionId) =>
      '/waiting-room/$sessionId/game-settings';

  /// 딥링크 초대 코드 진입용 path builder (예: /join/ABC123)
  static String joinByInviteWithCode(String code) => '/join/$code';

  // ============================================================================
  // Route Names (for named navigation)
  // ============================================================================

  /// 라우트 이름 상수 (go_router의 name 파라미터용,커스텀 가능)
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String onboardingName = 'onboarding';
  static const String nicknameSetupName = 'nicknameSetup';
  static const String agreementName = 'agreement';
  static const String homeName = 'home';
  static const String communityName = 'community';
  static const String communityCreateName = 'communityCreate';
  static const String communitySearchName = 'communitySearch';
  static const String communityNotificationName = 'communityNotification';
  static const String communityDetailName = 'communityDetail';
  static const String communityEditName = 'communityEdit';
  static const String communityChatName = 'communityChat';
  static const String communityChatMenuName = 'communityChatMenu';
  static const String communityChatNoticeName = 'communityChatNotice';
  static const String communityChatNoticeEditName = 'communityChatNoticeEdit';
  static const String mypageName = 'mypage';
  static const String myScrapsName = 'myScraps';
  static const String languageSettingsName = 'languageSettings';
  static const String agreementSettingsName = 'agreementSettings';
  static const String bugReportName = 'bugReport';
  static const String reportName = 'report';
  static const String reportReasonName = 'reportReason';
  static const String legalDocumentName = 'legalDocument';
  static const String creditsName = 'credits';
  static const String waitingRoomName = 'waitingRoom';
  static const String gameName = 'game';
  static const String noticesName = 'notices';
  static const String setupPlaygroundFromFlowName = 'setupPlaygroundFromFlow';
  static const String setupPrisonFromFlowName = 'setupPrisonFromFlow';
  static const String gameSettingsName = 'gameSettings';
  static const String gameSettingsEditName = 'gameSettingsEdit';
  static const String gameSettingsPlaygroundName = 'gameSettingsPlayground';
  static const String gameSettingsPrisonName = 'gameSettingsPrison';
  static const String gameSettingsZonePreviewName = 'gameSettingsZonePreview';
  static const String maintenanceName = 'maintenance';
  static const String forceUpdateName = 'forceUpdate';
  static const String lifecycleTestName = 'lifecycleTest';
  static const String joinByInviteName = 'joinByInvite';

  // ============================================================================
  // Deep Link Path Constants
  // ============================================================================

  /// 딥링크 초대 코드 진입 (예: /join/ABC123)
  static const String joinByInvite = '/join';
}

/// 모집글 상세를 여는 방식.
///
/// 목록 카드에서 "수정"을 고르면 상세를 깐 **직후** 그 위로 수정 화면이 솟아
/// 오른다. 이때 상세까지 전환 애니메이션을 타면 화면이 두 번 움직여 어디로
/// 가는지가 흐려진다 — 그 경우만 전환을 생략한다.
enum CommunityDetailEntry {
  /// 목록 카드를 탭해 상세 자체를 보러 온 경우 — 평소의 페이드 전환.
  normal,

  /// 수정 화면으로 가는 길목으로만 깔리는 경우 — 전환 없음.
  silent,
}
