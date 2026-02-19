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

      // ====================================================================
      // 4. 세션 상태 체크 (게임 진행 중인 경우 강제 리다이렉트)
      // ====================================================================
      // TODO: Session Provider 구현 후 활성화
      // if (currentSession != null) {
      //   switch (currentSession.status) {
      //     case SessionStatus.lobby:
      //       if (!currentPath.startsWith('/waiting-room/')) {
      //         return RoutePaths.waitingRoomWithId(currentSession.id);
      //       }
      //       break;
      //     case SessionStatus.playing:
      //     case SessionStatus.ended:
      //       // playing 및 ended 상태 모두 game 화면 유지
      //       // ended 상태에서는 GamePage 내부에서 결과 모달(Dialog)이 표시됨
      //       if (!currentPath.startsWith('/game/')) {
      //         return RoutePaths.gameWithId(currentSession.id);
      //       }
      //       break;
      //   }
      // }

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
          return WaitingRoomPage(sessionId: sessionId);
        },
      ),

      GoRoute(
        path: RoutePaths.game,
        name: RoutePaths.gameName,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final mapType = state.uri.queryParameters['mapType'] ?? 'google';
          return GamePage(sessionId: sessionId, mapType: mapType);
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
/// StreamProvider의 상태 변경을 감지하여 GoRouter에게
/// 리다이렉트 재실행을 트리거합니다.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this._ref, this._provider) {
    _ref.listen<AsyncValue<dynamic>>(_provider, (previous, next) {
      notifyListeners(); // 상태 변경 시 GoRouter에 알림
    });
  }

  final Ref _ref;
  final ProviderListenable<AsyncValue<dynamic>> _provider;
}
