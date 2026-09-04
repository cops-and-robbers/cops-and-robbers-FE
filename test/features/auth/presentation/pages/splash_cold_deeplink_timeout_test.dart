import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/deeplink/deeplink_event.dart';
import 'package:cops_and_robbers/core/deeplink/deeplink_service.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:cops_and_robbers/core/services/ads/ad_service.dart';
import 'package:cops_and_robbers/core/services/analytics/analytics_service.dart';
import 'package:cops_and_robbers/core/services/fcm/push_navigation_service.dart';
import 'package:cops_and_robbers/features/auth/domain/entities/auth_result_entity.dart';
import 'package:cops_and_robbers/features/auth/presentation/pages/splash_page.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/session/domain/entities/user_game_status_entity.dart';
import 'package:cops_and_robbers/features/session/domain/repositories/session_repository.dart';
import 'package:cops_and_robbers/features/session/domain/usecases/get_my_active_game_usecase.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 콜드 스타트 딥링크 프로브가 스플래시 타임아웃(4초)을 넘겨 완료되는
/// 상황의 회귀 테스트 (#558).
///
/// 실기기·에뮬레이터에서는 프로브 지연을 재현하기 어려우므로(설치 직후
/// 첫 실행에서만 간헐 발생), 프로브 완료 시점을 직접 제어해 세 경로를
/// 고정한다: 늦은 완료 회수 → 상세 이동, 늦은 초대 → 네비게이션 양보,
/// 극단 지연 → pending 보존(안전망).

/// 구독 시점에 현재 상태를 먼저 재생하는 connectivity_plus 계약 재현
/// (splash_server_error_loop_test.dart 와 동일).
class _ReplayingConnectivity implements Connectivity {
  _ReplayingConnectivity({required List<ConnectivityResult> initial})
    : _current = initial;

  final List<ConnectivityResult> _current;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// [delay] 뒤에 [user] 를 반환하는 auth — 재확인 시점(auth 완료 직후)을
/// 프로브 완료 앞뒤로 옮기기 위해 지연을 주입한다.
class _DelayedAuthNotifier extends AuthNotifier {
  _DelayedAuthNotifier(this._user, this._delay);

  final AuthResultEntity? _user;
  final Duration _delay;

  @override
  Future<AuthResultEntity?> build() async {
    if (_delay > Duration.zero) {
      await Future<void>.delayed(_delay);
    }
    return _user;
  }
}

/// 활성 게임 없음 — 스플래시가 홈/딥링크 목적지 분기로 가게 한다.
class _NotParticipatingSessionRepository implements SessionRepository {
  @override
  Future<UserGameStatusEntity> getMyActiveGame() async =>
      const UserGameStatusEntity(isParticipating: false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _user = AuthResultEntity(
  userId: 1,
  nickname: 'u',
  isNewUser: false,
  requiresAgreement: false,
);

void main() {
  Future<GoRouter> pumpSplash(
    WidgetTester tester, {
    required Future<DeeplinkEvent?> Function(Ref) coldDeeplink,
    Duration authDelay = Duration.zero,
  }) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: RoutePaths.splash,
      routes: [
        GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashPage()),
        GoRoute(path: RoutePaths.home, builder: (_, _) => const Text('HOME')),
        GoRoute(path: RoutePaths.login, builder: (_, _) => const Text('LOGIN')),
        GoRoute(
          path: RoutePaths.communityDetail,
          builder: (_, state) =>
              Text('DETAIL:${state.pathParameters['postId']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityServiceProvider.overrideWith(
            (ref) => ConnectivityService(
              _ReplayingConnectivity(initial: [ConnectivityResult.wifi]),
            ),
          ),
          authNotifierProvider.overrideWith(
            () => _DelayedAuthNotifier(_user, authDelay),
          ),
          getMyActiveGameUsecaseProvider.overrideWithValue(
            GetMyActiveGameUsecase(
              repository: _NotParticipatingSessionRepository(),
            ),
          ),
          coldStartDeeplinkProvider.overrideWith(coldDeeplink),
          coldStartPushNavigationProvider.overrideWith((ref) async => null),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(analytics: null),
          ),
          adServiceProvider.overrideWithValue(
            AdService(
              isAdsEnabled: () => false,
              sdkInitializer: () async => true,
            ),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp.router(
            routerConfig: router,
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
    return router;
  }

  testWidgets('타임아웃 후 auth 대기 중 완료된 모집글 딥링크를 회수해 상세로 이동한다', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // 프로브 4.3초 완료(타임아웃 4초 초과), auth 는 4.8초에 완료 —
    // 재확인 시점에는 프로브 결과가 준비돼 있다.
    await pumpSplash(
      tester,
      coldDeeplink: (ref) async {
        await Future<void>.delayed(const Duration(milliseconds: 4300));
        return const DeeplinkEvent.communityPost(postId: 10);
      },
      authDelay: const Duration(milliseconds: 800),
    );

    await tester.pump(const Duration(seconds: 4)); // 프로브 타임아웃
    await tester.pump(const Duration(milliseconds: 400)); // 프로브 완료
    await tester.pump(const Duration(milliseconds: 500)); // auth 완료 → 재확인
    // 최소 스플래시 딜레이는 실제 시계(DateTime.now) 기준이라 가상 시간과
    // 무관하게 최대 2초가 남는다 — 넉넉히 흘려보낸다.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // go 이후 라우터 전환 프레임

    expect(
      find.text('DETAIL:10'),
      findsOneWidget,
      reason: '타임아웃으로 못 받은 프로브도 auth 대기 후 회수해 상세로 가야 한다 (#558)',
    );
  });

  testWidgets('타임아웃 후 완료된 초대 딥링크는 홈으로 가지 않고 양보한다', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await pumpSplash(
      tester,
      coldDeeplink: (ref) async {
        await Future<void>.delayed(const Duration(milliseconds: 4300));
        return const DeeplinkEvent.inviteJoin(inviteCode: 'ABC123');
      },
      authDelay: const Duration(milliseconds: 800),
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(
      find.byType(SplashPage),
      findsOneWidget,
      reason:
          '늦게 완료된 초대는 deeplinkEvents 리스너가 join 페이지를 띄우므로 '
          '스플래시가 home 으로 덮어쓰면 안 된다',
    );
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('재확인 시점에도 미완인 프로브는 완료되는 대로 모집글을 pending 으로 보존한다', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // auth 는 즉시 완료 — 재확인 시점(4초 직후)에 프로브(8초 완료)가
    // 아직 미완이라 최후 안전망(then → pending 저장)만 등록된다.
    await pumpSplash(
      tester,
      coldDeeplink: (ref) async {
        await Future<void>.delayed(const Duration(seconds: 8));
        return const DeeplinkEvent.communityPost(postId: 10);
      },
    );

    await tester.pump(const Duration(seconds: 4)); // 타임아웃 → 재확인(미완)
    // 최소 스플래시 딜레이(실제 시계 기준 최대 2초)를 흘려보내고 홈 도착
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // go 이후 라우터 전환 프레임

    expect(
      find.text('HOME'),
      findsOneWidget,
      reason: '프로브가 없으면 기존대로 홈으로 진행해야 한다 (시작 차단 금지)',
    );

    await tester.pump(const Duration(seconds: 4)); // 프로브 완료 → 안전망 발화
    await tester.pump(const Duration(milliseconds: 100));

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getInt('pending_community_post_id'),
      10,
      reason:
          '홈 도착 뒤에 완료된 모집글 링크는 pending 으로 남아 다음 소비 시점에 '
          '열려야 한다 — 버려지면 유실이다 (#558)',
    );
  });
}
