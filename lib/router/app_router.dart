import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/spacing_and_radius.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/custom_page_transitions.dart';
import 'route_paths.dart';

// Auth Provider Import
import '../features/auth/presentation/providers/auth_provider.dart';

// Page Imports
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/nickname_setup_page.dart';
import '../features/session/presentation/pages/home_page.dart';
import '../features/session/presentation/pages/session_creation_flow_page.dart';
import '../features/session/presentation/pages/setup_playground_page.dart';
import '../features/session/presentation/pages/setup_prison_page.dart';
import '../features/session/presentation/pages/waiting_room_page.dart';
import '../features/game/presentation/pages/game_page.dart';
import '../features/notice/presentation/pages/notices_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/lifecycle_test/presentation/pages/lifecycle_test_page.dart';

/// GoRouter 인스턴스를 제공하는 Riverpod Provider
///
/// 앱 전체의 네비게이션을 관리하며, 인증 및 세션 상태에 따라
/// 자동으로 리다이렉트를 수행합니다.
///
/// 사용법:
/// ```dart
/// // 1. main.dart에서 MaterialApp.router에 연결
/// final router = ref.watch(routerProvider);
/// return MaterialApp.router(
///   routerConfig: router,
/// );
///
/// // 2. 페이지에서 네비게이션 사용
/// // 경로로 이동
/// context.go(RoutePaths.home);              // 현재 페이지 대체
/// context.push(RoutePaths.login);           // 새 페이지 추가
///
/// // 이름으로 이동
/// context.goNamed(RoutePaths.homeName);
/// context.pushNamed(RoutePaths.loginName);
///
/// // 동적 파라미터 전달
/// context.go(RoutePaths.waitingRoomWithId('session123'));
/// context.goNamed(
///   RoutePaths.waitingRoomName,
///   pathParameters: {'sessionId': 'session123'},
/// );
///
/// // 뒤로가기
/// context.pop();                            // 이전 페이지로
/// context.pop(result);                      // 결과값과 함께 돌아가기
///
/// // 3. 라우팅 가드 (자동 리다이렉트)
/// // - 비로그인 시 → 로그인 페이지로
/// // - 온보딩 미완료 시 → 온보딩 페이지로
/// // - 게임 진행 중 시 → 게임 페이지로 강제 이동
/// ```
///
/// 주요 기능:
/// - 선언적 라우팅: routes 리스트로 모든 경로 정의
/// - 중첩 라우팅: 부모-자식 관계로 URL 구조화
/// - 자동 리다이렉트: redirect 함수로 접근 제어
/// - Deep Link 지원: URL로 직접 특정 페이지 접근
/// - 404 에러 처리: errorBuilder로 잘못된 경로 처리
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true, // 개발 중 라우팅 로그 확인
    // refreshListenable 활성화 (auth 상태 변경 감지)
    // authNotifierProvider 사용: 즉시 반영되는 인증 상태
    refreshListenable: _GoRouterRefreshNotifier(ref, authNotifierProvider),
    redirect: (BuildContext context, GoRouterState state) {
      // ====================================================================
      // 실제 Provider에서 인증 상태 가져오기
      // ====================================================================
      // authNotifierProvider 사용: 즉시 반영되는 인증 상태
      // authStateProvider (Stream 기반)는 비동기 업데이트 지연 가능
      final authState = ref.read(authNotifierProvider);

      // 인증 상태 로딩 중 (Firebase 토큰 갱신 등)이면 리다이렉트 보류
      // → loading 중 null로 판단해 로그인으로 보내는 것을 방지
      if (authState.isLoading) return null;

      final authUser = authState.value;
      final isAuthenticated = authUser != null;

      final currentPath = state.uri.path;

      // 인증이 불필요한 공개 경로 (Splash, Login, 개발자 도구)
      final publicPaths = [
        RoutePaths.splash,
        RoutePaths.login,
        RoutePaths.lifecycleTest, // 생명주기 테스트는 로그인 불필요
      ];

      // ====================================================================
      // 1. 인증 체크 - 로그인 필요한 페이지 보호
      // ====================================================================
      if (!isAuthenticated) {
        // 스플래시, 로그인 페이지, 개발자 도구는 허용
        if (publicPaths.contains(currentPath)) {
          return null;
        }
        // 그 외 모든 페이지는 로그인으로 리다이렉트
        return RoutePaths.login;
      }

      // ====================================================================
      // 2. 인증된 사용자가 로그인/스플래시 페이지 접근 시
      // ====================================================================
      if (currentPath == RoutePaths.login || currentPath == RoutePaths.splash) {
        // 신규 회원 → 닉네임 설정 페이지로
        if (authUser.isNewUser) {
          final encodedNickname = Uri.encodeComponent(authUser.nickname);
          return '${RoutePaths.nicknameSetup}?nickname=$encodedNickname';
        }
        // 기존 회원 → 홈으로
        return RoutePaths.home;
      }

      return null; // 리다이렉트 불필요
    },

    routes: [
      // ====================================================================
      // Root & Authentication Routes
      // ====================================================================
      GoRoute(
        path: RoutePaths.splash,
        name: RoutePaths.splashName,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: RoutePaths.login,
        name: RoutePaths.loginName,
        pageBuilder: (context, state) =>
            buildSmoothFade(key: state.pageKey, child: const LoginPage()),
      ),

      GoRoute(
        path: RoutePaths.onboarding,
        name: RoutePaths.onboardingName,
        pageBuilder: (context, state) =>
            buildSmoothFade(key: state.pageKey, child: const OnboardingPage()),
      ),

      GoRoute(
        path: RoutePaths.nicknameSetup,
        name: RoutePaths.nicknameSetupName,
        pageBuilder: (context, state) {
          final nickname = state.uri.queryParameters['nickname'] ?? '';
          return buildSmoothFade(
            key: state.pageKey,
            child: NicknameSetupPage(initialNickname: nickname),
          );
        },
      ),

      // ====================================================================
      // Home & Main Navigation
      // ====================================================================
      GoRoute(
        path: RoutePaths.home,
        name: RoutePaths.homeName,
        pageBuilder: (context, state) =>
            buildSmoothFade(key: state.pageKey, child: const HomePage()),
        routes: [
          // ==============================================================
          // Settings Page
          // ==============================================================
          GoRoute(
            path: 'settings',
            name: RoutePaths.settingsName,
            pageBuilder: (context, state) => buildDirectionalSlide(
              key: state.pageKey,
              child: const SettingsPage(),
              isForward: true,
            ),
          ),

          // ==============================================================
          // Notices Page
          // ==============================================================
          GoRoute(
            path: 'notices',
            name: RoutePaths.noticesName,
            pageBuilder: (context, state) => buildDirectionalSlide(
              key: state.pageKey,
              child: const NoticesPage(),
              isForward: true,
            ),
          ),

          // ==============================================================
          // Session Creation Flow (Single PageView Page) - NEW
          // ==============================================================
          GoRoute(
            path: 'create-session',
            pageBuilder: (context, state) => buildDirectionalSlide(
              key: state.pageKey,
              child: const SessionCreationFlowPage(),
              isForward: true,
            ),
            routes: [
              // 플레이그라운드 설정 (모달 페이지)
              GoRoute(
                path: 'playground',
                name: 'setupPlaygroundFromFlow',
                pageBuilder: (context, state) => buildDirectionalSlide(
                  key: state.pageKey,
                  child: const SetupPlaygroundPage(),
                  isForward: true,
                ),
              ),
              // 감옥 설정 (모달 페이지)
              GoRoute(
                path: 'prison',
                name: 'setupPrisonFromFlow',
                pageBuilder: (context, state) => buildDirectionalSlide(
                  key: state.pageKey,
                  child: const SetupPrisonPage(),
                  isForward: true,
                ),
              ),
            ],
          ),
        ],
      ),

      // ====================================================================
      // Game Flow Routes (Top-level with sessionId parameter)
      // ====================================================================
      GoRoute(
        path: RoutePaths.waitingRoom,
        name: RoutePaths.waitingRoomName,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final inviteCode = state.uri.queryParameters['inviteCode'];
          final showInviteDialog =
              state.uri.queryParameters['showInvite'] == 'true';
          return WaitingRoomPage(
            sessionId: sessionId,
            inviteCode: inviteCode,
            showInviteDialog: showInviteDialog,
          );
        },
      ),

      GoRoute(
        path: RoutePaths.game,
        name: RoutePaths.gameName,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final mapType = state.uri.queryParameters['mapType'] ?? 'google';
          final team = state.uri.queryParameters['team'] ?? 'POLICE';
          // TODO: participantId는 로비 API 연동 후 실제 값으로 교체
          final participantId =
              int.tryParse(state.uri.queryParameters['pid'] ?? '') ?? 1;
          final isDummy = state.uri.queryParameters['dummy'] == 'true';
          return GamePage(
            sessionId: sessionId,
            mapType: mapType,
            team: team,
            participantId: participantId,
            isDummy: isDummy,
          );
        },
      ),

      // ====================================================================
      // Developer Tools (개발/테스트용)
      // ====================================================================
      GoRoute(
        path: RoutePaths.lifecycleTest,
        name: RoutePaths.lifecycleTestName,
        builder: (context, state) => const LifecycleTestPage(),
      ),
    ],

    // ====================================================================
    // Error Handling (404 Page)
    // ====================================================================
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: Text('페이지를 찾을 수 없습니다', style: AppTextStyles.label_16),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.red),
              SizedBox(height: AppSpacing.vertical16),
              Text('요청하신 페이지가 존재하지 않습니다.', style: AppTextStyles.label_16),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                '경로: ${state.uri.path}',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
              ),
              SizedBox(height: AppSpacing.vertical24),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: Text('홈으로 돌아가기', style: AppTextStyles.paragraph_14),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

// ============================================================================
// GoRouter용 Refresh Notifier (StreamProvider 감지용)
// ============================================================================

/// GoRouter용 Refresh Notifier
///
/// auth 상태가 실질적으로 변경될 때만 GoRouter에 리다이렉트 재실행을 트리거합니다.
/// loading → loading 또는 data(same) 전환은 무시하여 불필요한 리다이렉트를 방지합니다.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this._ref, this._provider) {
    bool? prevIsAuthenticated;
    _ref.listen<AsyncValue<dynamic>>(_provider, (previous, next) {
      // loading 중이면 notify 생략 (중간 상태로 인한 오류 화면 방지)
      if (next.isLoading) return;

      // 인증 여부(bool)만 비교하여 로그인/로그아웃 전환 시에만 notify
      // authNotifierProvider.build()가 새 객체를 생성해도 인증 여부가 같으면 무시
      final isAuthenticated = next.valueOrNull != null;
      if (prevIsAuthenticated == isAuthenticated) return;
      prevIsAuthenticated = isAuthenticated;

      notifyListeners();
    });
  }

  final Ref _ref;
  final ProviderListenable<AsyncValue<dynamic>> _provider;
}
