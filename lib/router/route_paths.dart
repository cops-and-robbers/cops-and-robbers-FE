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

  /// 설정 화면
  static const String settings = '/home/settings';

  /// 공지사항 화면
  static const String notices = '/home/notices';

  /// 크레딧 페이지 (히든)
  static const String credits = '/home/settings/credits';

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
  static const String waitingRoomName = 'waitingRoom';
  static const String gameName = 'game';
  static const String settingsName = 'settings';
  static const String noticesName = 'notices';
  static const String creditsName = 'credits';
  static const String gameSettingsName = 'gameSettings';
  static const String gameSettingsEditName = 'gameSettingsEdit';
  static const String gameSettingsPlaygroundName = 'gameSettingsPlayground';
  static const String gameSettingsPrisonName = 'gameSettingsPrison';
  static const String gameSettingsZonePreviewName = 'gameSettingsZonePreview';
  static const String maintenanceName = 'maintenance';
  static const String forceUpdateName = 'forceUpdate';
  static const String lifecycleTestName = 'lifecycleTest';
}
