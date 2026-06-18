import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cops_and_robbers/core/services/analytics/analytics_service.dart';
import 'package:cops_and_robbers/core/services/permission/game_entry_gate.dart';
import 'package:cops_and_robbers/core/services/permission/location_permission_messages.dart';
import 'package:cops_and_robbers/features/auth/domain/entities/auth_result_entity.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/session/domain/entities/game_join_result.dart';
import 'package:cops_and_robbers/features/session/domain/usecases/join_game_by_invite_usecase.dart';
import 'package:cops_and_robbers/features/session/presentation/pages/deeplink_join_page.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/pending_invite_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:cops_and_robbers/router/route_paths.dart';

class _MockJoinUseCase extends Mock implements JoinGameByInviteUseCase {}

/// 게이트 결과를 주입하는 페이크. ensure 호출 여부도 기록한다 — "게이트가
/// 평가되었는가/스킵되었는가"가 관찰 대상이므로.
class _FakeGate implements GameEntryGate {
  _FakeGate(this.result);
  final bool result;
  bool called = false;

  @override
  Future<bool> ensure({
    required BuildContext context,
    required LocationPermissionContext locationContext,
  }) async {
    called = true;
    return result;
  }
}

/// AuthNotifier 가짜 — 실제 Firebase/API 호출 없이 고정 사용자 반환
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AuthResultEntity? _user;

  @override
  Future<AuthResultEntity?> build() async => _user;
}

void main() {
  const loggedInUser = AuthResultEntity(
    userId: 1,
    nickname: 'u',
    isNewUser: false,
    requiresAgreement: false,
  );

  // join 성공 경로에서 unawaited 로 호출되는 analytics — Firebase 미초기화이므로
  // null analytics no-op 으로 안전하지만, 테스트가 Firebase 에 닿지 않도록 명시 주입.
  final fakeAnalytics = AnalyticsService(analytics: null);

  late _MockJoinUseCase joinUseCase;

  setUp(() {
    joinUseCase = _MockJoinUseCase();
    // PendingInvite.build() 가 SharedPreferences 를 사용하므로 mock 초기화 필요
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required _FakeGate gate,
    required AuthResultEntity? user,
  }) async {
    // LoadingPage 가 ScreenUtil(.w/.h/.sp)을 사용하므로 화면 크기 + ScreenUtilInit 필요
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/join/ABC123',
      routes: [
        GoRoute(
          path: '/join/:code',
          builder: (_, state) =>
              DeepLinkJoinPage(inviteCode: state.pathParameters['code']!),
        ),
        GoRoute(
          path: RoutePaths.home,
          builder: (_, _) => const Text('HOME_PAGE'),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (_, _) => const Text('LOGIN_PAGE'),
        ),
        GoRoute(
          path: '/waiting-room/:id',
          builder: (_, _) => const Text('WAITING_ROOM'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameEntryGateProvider.overrideWithValue(gate),
          authNotifierProvider.overrideWith(() => _FakeAuthNotifier(user)),
          joinGameByInviteUseCaseProvider.overrideWithValue(joinUseCase),
          analyticsServiceProvider.overrideWithValue(fakeAnalytics),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, _) => MaterialApp.router(
            routerConfig: router,
            locale: const Locale('ko'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'does_not_call_join_and_routes_home_when_logged_in_but_gate_denied',
    (tester) async {
      final gate = _FakeGate(false);
      await pumpPage(tester, gate: gate, user: loggedInUser);

      expect(gate.called, isTrue);
      verifyNever(() => joinUseCase.execute(any()));
      expect(find.text('HOME_PAGE'), findsOneWidget);
    },
  );

  testWidgets(
    'calls_join_and_routes_waiting_room_when_logged_in_and_gate_passed',
    (tester) async {
      final gate = _FakeGate(true);
      when(() => joinUseCase.execute(any())).thenAnswer(
        (_) async => const GameJoinResult(gameId: 7, participantId: 1),
      );
      await pumpPage(tester, gate: gate, user: loggedInUser);

      expect(gate.called, isTrue);
      verify(() => joinUseCase.execute('ABC123')).called(1);
      expect(find.text('WAITING_ROOM'), findsOneWidget);
    },
  );

  testWidgets(
    'skips_gate_and_saves_pending_invite_and_routes_login_when_not_logged_in',
    (tester) async {
      final gate = _FakeGate(false);
      await pumpPage(tester, gate: gate, user: null);

      expect(gate.called, isFalse);
      verifyNever(() => joinUseCase.execute(any()));
      expect(find.text('LOGIN_PAGE'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.text('LOGIN_PAGE')),
      );
      final pending = await container.read(pendingInviteProvider.future);
      expect(pending, equals('ABC123'));
    },
  );
}
