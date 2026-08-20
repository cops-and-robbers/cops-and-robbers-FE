import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/game_team.dart';
import '../core/constants/spacing_and_radius.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/custom_page_transitions.dart';
import '../l10n/app_localizations.dart';
import 'route_paths.dart';

// Auth Provider Import
import '../features/auth/presentation/providers/auth_provider.dart';

// Page Imports
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/nickname_setup_page.dart';
import '../features/auth/presentation/pages/agreement_page.dart';
import '../features/session/presentation/pages/home_page.dart';
import '../features/community/presentation/pages/community_create_page.dart';
import '../features/community/presentation/pages/community_detail_page.dart';
import '../features/community/presentation/pages/community_page.dart';
import '../features/mypage/presentation/pages/my_page.dart';
import 'main_scaffold.dart';
import '../features/session/presentation/pages/session_creation_flow_page.dart';
import '../features/session/presentation/pages/setup_playground_page.dart';
import '../features/session/presentation/pages/setup_prison_page.dart';
import '../features/game/domain/entities/area_shape.dart';
import '../features/session/presentation/pages/zone_preview_page.dart';
import '../features/session/presentation/pages/waiting_room_page.dart';
import '../features/session/presentation/pages/game_settings_page.dart';
import '../features/session/presentation/pages/game_settings_edit_page.dart';
import '../features/session/data/models/game_settings_response.dart';
import '../features/game/presentation/pages/game_page.dart';
import '../features/notice/presentation/pages/notices_page.dart';
import '../features/tutorial/presentation/pages/in_game_tutorial_page.dart';
import '../features/tutorial/presentation/pages/tutorial_catalog_page.dart';
import '../features/lifecycle_test/presentation/pages/lifecycle_test_page.dart';
import '../core/widgets/buttons/previous_button.dart';
import '../core/widgets/pages/maintenance_page.dart';
import '../core/widgets/pages/force_update_page.dart';
import '../features/session/presentation/pages/deeplink_join_page.dart';

/// 딥링크 수신 후 GoRouter 외부에서 네비게이션이 필요한 경우(Task 9: DeepLinkService)에
/// Navigator 에 직접 접근하기 위한 루트 NavigatorKey.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

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
  debugPrint('🔧 [routerProvider] GoRouter 생성 시작');
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true, // 개발 중 라우팅 로그 확인
    // 화면 전환 자동 수집 (screen_view) — Firebase 미초기화 시 생략 (fail-open)
    observers: [
      if (Firebase.apps.isNotEmpty)
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    // refreshListenable 활성화 (auth 상태 변경 감지)
    // authNotifierProvider 사용: 즉시 반영되는 인증 상태
    refreshListenable: _GoRouterRefreshNotifier(ref, authNotifierProvider),
    redirect: (BuildContext context, GoRouterState state) {
      try {
        // ====================================================================
        // 실제 Provider에서 인증 상태 가져오기
        // ====================================================================
        // authNotifierProvider 사용: 즉시 반영되는 인증 상태
        // authStateProvider (Stream 기반)는 비동기 업데이트 지연 가능
        final authState = ref.read(authNotifierProvider);

        debugPrint(
          '🔀 [GoRouter redirect] path=${state.uri.path}, '
          'authState=$authState',
        );

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
          RoutePaths.maintenance,
          RoutePaths.forceUpdate,
          if (kDebugMode) RoutePaths.lifecycleTest,
        ];

        // ====================================================================
        // 1. 인증 체크 - 로그인 필요한 페이지 보호
        // ====================================================================
        if (!isAuthenticated) {
          // 스플래시, 로그인 페이지, 개발자 도구는 허용
          if (publicPaths.contains(currentPath)) {
            return null;
          }
          // 딥링크 진입 (/join/{code}) 도 허용 — DeepLinkJoinPage 가 자체적으로
          // PendingInvite 를 저장한 후 로그인 화면으로 보낸다.
          // 미로그인 상태에서 이 경로를 차단하면 pending invite 가 저장되지 않아
          // 로그인 직후 자동 join 흐름이 깨진다.
          if (currentPath.startsWith('${RoutePaths.joinByInvite}/')) {
            return null;
          }
          // 그 외 모든 페이지는 로그인으로 리다이렉트
          return RoutePaths.login;
        }

        // ====================================================================
        // 2. 필수 약관 미동의 → 약관 동의 화면만 허용
        // ====================================================================
        if (authUser.requiresAgreement) {
          if (currentPath == RoutePaths.agreement) {
            return null;
          }
          return RoutePaths.agreement;
        }

        // ====================================================================
        // 3. 신규 회원 → 닉네임 설정 페이지만 허용
        // ====================================================================
        if (authUser.isNewUser) {
          if (currentPath == RoutePaths.nicknameSetup) {
            return null;
          }
          final encodedNickname = Uri.encodeComponent(authUser.nickname);
          return '${RoutePaths.nicknameSetup}?nickname=$encodedNickname';
        }

        // ====================================================================
        // 4. 기존 회원이 로그인 접근 시 → 활성 게임 복귀 또는 홈으로
        //    로그인 성공 시 활성 게임이 있으면 대기실/게임으로 직접 이동
        //    (닉네임설정은 설정 페이지에서 닉네임 변경 시 접근 가능)
        // ====================================================================
        if (currentPath == RoutePaths.login) {
          final destination = ref.read(postLoginDestinationProvider);
          if (destination != null) {
            debugPrint(
              '🎯 [GoRouter redirect] postLoginDestination 소비: $destination',
            );
            ref.read(postLoginDestinationProvider.notifier).state = null;
            return destination;
          }
          return RoutePaths.home;
        }

        // ====================================================================
        // 5. 약관 동의 완료 후 /agreement에 남아있는 경우 홈으로 이동
        //    markAgreementCompleted → requiresAgreement=false → 리다이렉트 재평가 시
        //    이 분기가 탈출 경로 역할 (신규 회원은 step 3에서 이미 처리됨)
        // ====================================================================
        if (currentPath == RoutePaths.agreement) {
          return RoutePaths.home;
        }

        return null; // 리다이렉트 불필요
      } catch (e, stack) {
        debugPrint('🚨 [GoRouter redirect] 예외 발생: $e');
        debugPrint('🚨 [GoRouter redirect] 스택: $stack');
        // 안전 실패: 보호 경로 우회 방지를 위해 로그인으로 리다이렉트
        return RoutePaths.login;
      }
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

      GoRoute(
        path: RoutePaths.agreement,
        name: RoutePaths.agreementName,
        pageBuilder: (context, state) =>
            buildSmoothFade(key: state.pageKey, child: const AgreementPage()),
      ),

      // ====================================================================
      // Tutorial Routes (튜토리얼 — 카탈로그 + 항목별 디테일)
      // ====================================================================
      GoRoute(
        path: '/tutorial',
        pageBuilder: (context, state) => buildDirectionalSlide(
          key: state.pageKey,
          child: const TutorialCatalogPage(),
          isForward: true,
        ),
      ),
      GoRoute(
        path: '/tutorial/in-game',
        pageBuilder: (context, state) => buildDirectionalSlide(
          key: state.pageKey,
          child: const InGameTutorialPage(),
          isForward: true,
        ),
      ),

      // ====================================================================
      // Home & Main Navigation
      // ====================================================================
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) =>
            buildInstantTransition(
              key: state.pageKey,
              child: MainScaffold(navigationShell: navigationShell),
            ),
        branches: [
          // ==============================================================
          // Home Branch
          // ==============================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RoutePaths.homeName,
                builder: (context, state) => HomePage(
                  // fromGameExit: 게임 종료 후 "홈으로" 이탈 직후 진입 —
                  // 퇴장 API가 비행 중일 수 있어 활성 게임 안전망을 1회 건너뛴다
                  skipActiveGameCheck:
                      state.uri.queryParameters['fromGameExit'] == 'true',
                ),
                routes: [
                  // ======================================================
                  // Notices Page
                  // ======================================================
                  GoRoute(
                    path: 'notices',
                    name: RoutePaths.noticesName,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => buildDirectionalSlide(
                      key: state.pageKey,
                      child: const NoticesPage(),
                      isForward: true,
                    ),
                  ),

                  // ======================================================
                  // Session Creation Flow (Single PageView Page) - NEW
                  // ======================================================
                  GoRoute(
                    path: 'create-session',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => buildDirectionalSlide(
                      key: state.pageKey,
                      child: const SessionCreationFlowPage(),
                      isForward: true,
                    ),
                    routes: [
                      // 플레이그라운드 설정 (모달 페이지)
                      GoRoute(
                        path: 'playground',
                        name: RoutePaths.setupPlaygroundFromFlowName,
                        // go_router는 parentNavigatorKey를 자식에 상속하지 않으므로
                        // 각 라우트에 명시적으로 지정해야 한다
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => buildDirectionalSlide(
                          key: state.pageKey,
                          child: const SetupPlaygroundPage(),
                          isForward: true,
                        ),
                      ),
                      // 감옥 설정 (모달 페이지)
                      GoRoute(
                        path: 'prison',
                        name: RoutePaths.setupPrisonFromFlowName,
                        parentNavigatorKey: rootNavigatorKey,
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
            ],
          ),

          // ==============================================================
          // Community Branch (준비중 placeholder)
          // ==============================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.community,
                name: RoutePaths.communityName,
                pageBuilder: (context, state) => buildSmoothFade(
                  key: state.pageKey,
                  child: const CommunityPage(),
                ),
                routes: [
                  // ======================================================
                  // 모집글 작성 (바텀 네비 위 전체 화면)
                  // ======================================================
                  GoRoute(
                    path: 'create',
                    name: RoutePaths.communityCreateName,
                    parentNavigatorKey: rootNavigatorKey,
                    // 목록 하단 버튼에서 여는 화면이라 그 자리에서 솟아오른다.
                    pageBuilder: (context, state) => buildSlideUp(
                      key: state.pageKey,
                      child: const CommunityCreatePage(),
                    ),
                  ),
                  // ======================================================
                  // 모집글 상세 (바텀 네비 위 전체 화면)
                  //
                  // `create`보다 뒤에 둔다 — 앞에 두면 `/community/create`가
                  // postId="create"로 잡힌다.
                  // ======================================================
                  GoRoute(
                    path: ':postId',
                    name: RoutePaths.communityDetailName,
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      // 숫자가 아닌 경로가 들어오면 목록으로 돌려보내는 대신
                      // 0으로 조회해 404 화면을 그린다 — 잘못된 링크임을
                      // 사용자가 알 수 있어야 한다.
                      final postId =
                          int.tryParse(state.pathParameters['postId'] ?? '') ??
                          0;
                      return buildSmoothFade(
                        key: state.pageKey,
                        child: CommunityDetailPage(postId: postId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ==============================================================
          // MyPage Branch (준비중 placeholder)
          // ==============================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.mypage,
                name: RoutePaths.mypageName,
                pageBuilder: (context, state) =>
                    buildSmoothFade(key: state.pageKey, child: const MyPage()),
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
        // LoadingPage(재접속)·Home(방 만들기/참가)에서 넘어올 때 체감되던
        // 플랫폼 기본 전환을 제거. 다른 라우트(180ms fade)와 톤을 맞춘다.
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final inviteCode = state.uri.queryParameters['inviteCode'];
          final showInviteDialog =
              state.uri.queryParameters['showInvite'] == 'true';
          return buildInstantTransition(
            key: state.pageKey,
            child: WaitingRoomPage(
              sessionId: sessionId,
              inviteCode: inviteCode,
              showInviteDialog: showInviteDialog,
            ),
          );
        },
        routes: [
          // 게임 설정 페이지
          GoRoute(
            path: 'game-settings',
            name: RoutePaths.gameSettingsName,
            pageBuilder: (context, state) {
              final sessionId = state.pathParameters['sessionId']!;
              return buildDirectionalSlide(
                key: state.pageKey,
                child: GameSettingsPage(sessionId: sessionId),
                isForward: true,
              );
            },
            routes: [
              // 설정 수정 페이지 (슬라이더)
              GoRoute(
                path: 'edit-settings',
                name: RoutePaths.gameSettingsEditName,
                pageBuilder: (context, state) {
                  final sessionId = state.pathParameters['sessionId']!;
                  final settings = state.extra as GameSettingsResponse?;
                  if (settings == null) {
                    // extra 누락 (딥링크 등 비정상 진입) → 이전 화면으로
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) Navigator.of(context).pop();
                    });
                    return buildDirectionalSlide(
                      key: state.pageKey,
                      isForward: true,
                      child: const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  return buildDirectionalSlide(
                    key: state.pageKey,
                    child: GameSettingsEditPage(
                      sessionId: sessionId,
                      initialSettings: settings,
                    ),
                    isForward: true,
                  );
                },
              ),
              // 플레이그라운드 수정 페이지
              GoRoute(
                path: 'edit-playground',
                name: RoutePaths.gameSettingsPlaygroundName,
                pageBuilder: (context, state) {
                  return buildDirectionalSlide(
                    key: state.pageKey,
                    child: SetupPlaygroundPage(
                      editInitialShape: state.extra as AreaShape?,
                    ),
                    isForward: true,
                  );
                },
              ),
              // 감옥 수정 페이지
              GoRoute(
                path: 'edit-prison',
                name: RoutePaths.gameSettingsPrisonName,
                pageBuilder: (context, state) {
                  return buildDirectionalSlide(
                    key: state.pageKey,
                    child: SetupPrisonPage(
                      editArgs: state.extra as PrisonEditArgs?,
                    ),
                    isForward: true,
                  );
                },
              ),
              // 구역 읽기전용 프리뷰 페이지
              GoRoute(
                path: 'zone-preview',
                name: RoutePaths.gameSettingsZonePreviewName,
                pageBuilder: (context, state) {
                  final area = state.extra as GameAreaEntity?;

                  // 구역 정보가 없으면 빈 페이지 (비정상 접근 방어)
                  if (area == null) {
                    return buildDirectionalSlide(
                      key: state.pageKey,
                      child: Scaffold(
                        appBar: AppBar(
                          leading: PreviousButton(
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        body: Center(
                          child: Text(
                            AppLocalizations.of(context).errorAreaLoadFailed,
                          ),
                        ),
                      ),
                      isForward: true,
                    );
                  }

                  return buildDirectionalSlide(
                    key: state.pageKey,
                    child: ZonePreviewPage(area: area),
                    isForward: true,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: RoutePaths.game,
        name: RoutePaths.gameName,
        // LoadingPage(재접속)·대기방(게임 시작)에서 진입 시 플랫폼 기본 전환 제거.
        // 몰입감을 위해 즉시 전환이 더 적합하다.
        pageBuilder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final team = state.uri.queryParameters['team'] ?? GameTeam.police;
          final participantId =
              int.tryParse(state.uri.queryParameters['pid'] ?? '') ?? 1;
          final isDummy = state.uri.queryParameters['dummy'] == 'true';
          return buildInstantTransition(
            key: state.pageKey,
            child: GamePage(
              sessionId: sessionId,
              team: team,
              participantId: participantId,
              isDummy: isDummy,
            ),
          );
        },
      ),

      // ====================================================================
      // Deep Link Routes (딥링크 초대 코드 진입 — 인증 여부 불문)
      // ====================================================================
      GoRoute(
        path: '${RoutePaths.joinByInvite}/:inviteCode',
        name: RoutePaths.joinByInviteName,
        // 다른 라우트와 톤을 맞춰 플랫폼 기본 전환 제거 (즉시 전환)
        pageBuilder: (context, state) {
          final code = state.pathParameters['inviteCode'] ?? '';
          return buildInstantTransition(
            key: state.pageKey,
            child: DeepLinkJoinPage(inviteCode: code),
          );
        },
      ),

      // ====================================================================
      // System Status Routes (인증 불필요)
      // ====================================================================
      GoRoute(
        path: RoutePaths.maintenance,
        name: RoutePaths.maintenanceName,
        pageBuilder: (context, state) =>
            buildSmoothFade(key: state.pageKey, child: const MaintenancePage()),
      ),

      GoRoute(
        path: RoutePaths.forceUpdate,
        name: RoutePaths.forceUpdateName,
        pageBuilder: (context, state) =>
            buildSmoothFade(key: state.pageKey, child: const ForceUpdatePage()),
      ),

      // ====================================================================
      // Developer Tools (개발/테스트용 — 릴리스 빌드에서는 등록되지 않음)
      // ====================================================================
      if (kDebugMode)
        GoRoute(
          path: RoutePaths.lifecycleTest,
          name: RoutePaths.lifecycleTestName,
          builder: (context, state) => const LifecycleTestPage(),
        ),
    ],

    // ====================================================================
    // Error Handling (404 Page)
    // ====================================================================
    errorBuilder: (context, state) => _ErrorPage(path: state.uri.path),
  );
});

// ============================================================================
// 404 에러 페이지 (로그아웃 기능 포함)
// ============================================================================

/// 존재하지 않는 페이지 접근 시 표시되는 에러 페이지
///
/// 로그아웃 버튼을 통해 인증 상태를 초기화하고 로그인 화면으로 이동합니다.
class _ErrorPage extends ConsumerWidget {
  const _ErrorPage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pageNotFoundTitle, style: AppTextStyles.label_16),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: AppPadding.all20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/icon_not_found.svg', width: 110.w),
              SizedBox(height: AppSpacing.vertical16),
              Text(l10n.pageNotFoundMessage, style: AppTextStyles.label_16),
              SizedBox(height: AppSpacing.vertical8),
              Text(
                l10n.pageNotFoundPath(path),
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black400),
              ),
              SizedBox(height: AppSpacing.vertical24),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(RoutePaths.login);
                  }
                },
                child: Text(
                  l10n.buttonLogout,
                  style: AppTextStyles.paragraph_14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GoRouter용 Refresh Notifier (StreamProvider 감지용)
// ============================================================================

/// GoRouter용 Refresh Notifier
///
/// auth 상태가 실질적으로 변경될 때만 GoRouter에 리다이렉트 재실행을 트리거합니다.
/// loading → loading 또는 data(same) 전환은 무시하여 불필요한 리다이렉트를 방지합니다.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this._ref, this._provider) {
    debugPrint('🔧 [_GoRouterRefreshNotifier] 생성 시작');
    bool? prevIsAuthenticated;
    bool? prevIsNewUser;
    bool? prevRequiresAgreement;
    _ref.listen<AsyncValue<dynamic>>(_provider, (previous, next) {
      debugPrint(
        '🔧 [_GoRouterRefreshNotifier] listen callback: '
        'prev=$previous, next=$next',
      );
      // loading 중이면 notify 생략 (중간 상태로 인한 오류 화면 방지)
      if (next.isLoading) return;

      // 인증 여부, 신규 회원 여부, 약관 동의 여부 모두 비교하여 변경 시에만 notify
      final user = next.valueOrNull;
      final isAuthenticated = user != null;
      final isNewUser = user?.isNewUser as bool?;
      final requiresAgreement = user?.requiresAgreement as bool?;

      if (prevIsAuthenticated == isAuthenticated &&
          prevIsNewUser == isNewUser &&
          prevRequiresAgreement == requiresAgreement) {
        return;
      }
      prevIsAuthenticated = isAuthenticated;
      prevIsNewUser = isNewUser;
      prevRequiresAgreement = requiresAgreement;

      notifyListeners();
    });
  }

  final Ref _ref;
  final ProviderListenable<AsyncValue<dynamic>> _provider;
}
