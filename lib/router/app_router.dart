import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/spacing_and_radius.dart';
import '../core/constants/text_styles.dart';
import 'route_paths.dart';

// Auth Provider Import
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';

// Page Imports
import 'package:cops_and_robbers/features/auth/presentation/pages/splash_page.dart';
import 'package:cops_and_robbers/features/auth/presentation/pages/login_page.dart';
import 'package:cops_and_robbers/features/auth/presentation/pages/onboarding_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/home_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/select_area_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_playground_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/setup_prison_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/session_settings_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/invite_code_page.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/waiting_room_page.dart';
import 'package:cops_and_robbers/features/game/presentation/pages/game_page.dart';
import 'package:cops_and_robbers/features/game/presentation/pages/results_page.dart';
import 'package:cops_and_robbers/features/lifecycle_test/presentation/pages/lifecycle_test_page.dart';

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
    refreshListenable: _GoRouterRefreshNotifier(ref, authStateProvider),
    redirect: (BuildContext context, GoRouterState state) {
      // ====================================================================
      // 실제 Provider에서 인증 상태 가져오기
      // ====================================================================
      final authUser = ref.read(authStateProvider).value;
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
      // 2. 인증된 사용자가 로그인 페이지 접근 시
      // ====================================================================
      if (currentPath == RoutePaths.login) {
        // 로그인 완료 시 홈으로
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
      //       if (!currentPath.startsWith('/game/')) {
      //         return RoutePaths.gameWithId(currentSession.id);
      //       }
      //       break;
      //     case SessionStatus.ended:
      //       if (!currentPath.startsWith('/results/')) {
      //         return RoutePaths.resultsWithId(currentSession.id);
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
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: RoutePaths.onboarding,
        name: RoutePaths.onboardingName,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ====================================================================
      // Home & Main Navigation
      // ====================================================================
      GoRoute(
        path: RoutePaths.home,
        name: RoutePaths.homeName,
        builder: (context, state) => const HomePage(),
        routes: [
          // ==============================================================
          // Session Creation Flow (Nested Routes)
          // ==============================================================
          GoRoute(
            path: 'create-session/select-area',
            name: RoutePaths.selectAreaName,
            builder: (context, state) => const SelectAreaPage(),
            routes: [
              // 플레이그라운드 설정
              GoRoute(
                path: 'playground',
                name: RoutePaths.setupPlaygroundName,
                builder: (context, state) => const SetupPlaygroundPage(),
              ),
              // 감옥 설정
              GoRoute(
                path: 'prison',
                name: RoutePaths.setupPrisonName,
                builder: (context, state) => const SetupPrisonPage(),
              ),
              // 기본 정보 설정
              GoRoute(
                path: 'settings',
                name: RoutePaths.sessionSettingsName,
                builder: (context, state) => const SessionSettingsPage(),
                // TODO: redirect 로직 추가 (구역 설정 완료 체크)
                // redirect: (context, state) {
                //   final sessionState = ref.read(sessionNotifierProvider);
                //   final isAreaSetupCompleted =
                //       sessionState.playgroundArea != null &&
                //       sessionState.prisonArea != null;
                //   if (!isAreaSetupCompleted) {
                //     return RoutePaths.selectArea;
                //   }
                //   return null;
                // },
              ),
              // 초대 코드 생성
              GoRoute(
                path: 'invite-code',
                name: RoutePaths.inviteCodeName,
                builder: (context, state) => const InviteCodePage(),
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
          return GamePage(sessionId: sessionId);
        },
      ),

      GoRoute(
        path: RoutePaths.results,
        name: RoutePaths.resultsName,
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return ResultsPage(sessionId: sessionId);
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
      appBar: AppBar(title: Text('페이지를 찾을 수 없습니다', style: AppTextStyles.label)),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: AppSpacing.vertical16),
              Text('요청하신 페이지가 존재하지 않습니다.', style: AppTextStyles.label),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                '경로: ${state.uri.path}',
                style: AppTextStyles.callout.copyWith(color: Colors.grey),
              ),
              SizedBox(height: AppSpacing.vertical24),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: Text('홈으로 돌아가기', style: AppTextStyles.paragraph),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

// ============================================================================
// GoRouter용 Stream 래퍼 (상태 변경 감지)
// ============================================================================

/// GoRouter의 refreshListenable로 사용할 Stream 래퍼
///
/// 여러 Provider의 상태 변경을 감지하여 GoRouter에게
/// 리다이렉트 재실행을 트리거합니다.
class GoRouterRefreshStream extends ChangeNotifier {
  late final List<StreamSubscription<dynamic>> _subscriptions;

  /// 여러 Stream을 받아 변경 사항을 감지합니다.
  ///
  /// Example:
  /// ```dart
  /// GoRouterRefreshStream([
  ///   authNotifierProvider.stream,
  ///   sessionNotifierProvider.stream,
  /// ])
  /// ```
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    _subscriptions = streams
        .map((stream) => stream.listen((_) => notifyListeners()))
        .toList();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

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
