import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:cops_and_robbers/core/deeplink/deeplink_service.dart';
import 'package:cops_and_robbers/core/services/ads/ad_service.dart';
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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 실제 connectivity_plus는 새 리스너가 붙을 때마다 현재 상태를 먼저 재생한다
/// (connectivity_service_test.dart의 FakeConnectivity와 동일 계약 — 이 재현이
/// 없으면 이 테스트가 검증하려는 자가 루프가 애초에 발생하지 않는다).
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

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AuthResultEntity? _user;

  @override
  Future<AuthResultEntity?> build() async => _user;
}

/// 항상 500(서버 장애)을 던지는 세션 레포지토리. 호출 횟수를 세어
/// "차단 후에도 계속 재시도하는가"를 관찰한다.
class _AlwaysServerErrorSessionRepository implements SessionRepository {
  int callCount = 0;

  @override
  Future<UserGameStatusEntity> getMyActiveGame() async {
    callCount++;
    throw ServerException(
      message: '서버 오류',
      originalException: DioException(
        requestOptions: RequestOptions(path: '/api/user/me/game'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/user/me/game'),
          statusCode: 500,
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    '게임 상태 조회가 500을 반환해도 재구독 재생 이벤트로 재시도를 폭주시키지 않는다',
    (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _AlwaysServerErrorSessionRepository();
      const user = AuthResultEntity(
        userId: 1,
        nickname: 'u',
        isNewUser: false,
        requiresAgreement: false,
      );

      final router = GoRouter(
        initialLocation: RoutePaths.splash,
        routes: [
          GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashPage()),
          GoRoute(path: RoutePaths.home, builder: (_, _) => const SizedBox()),
          GoRoute(path: RoutePaths.login, builder: (_, _) => const SizedBox()),
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
            authNotifierProvider.overrideWith(() => _FakeAuthNotifier(user)),
            getMyActiveGameUsecaseProvider.overrideWithValue(
              GetMyActiveGameUsecase(repository: repository),
            ),
            coldStartDeeplinkProvider.overrideWith((ref) async => null),
            coldStartPushNavigationProvider.overrideWith((ref) async => null),
            adServiceProvider.overrideWithValue(
              AdService(isAdsEnabled: () => false, sdkInitializer: () async => true),
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

      // 최소 스플래시 딜레이(2초) + 500 실패 판정까지 흘려보낸다.
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(SplashPage), findsOneWidget);
      final callsAfterFirstBlock = repository.callCount;
      expect(
        callsAfterFirstBlock,
        1,
        reason: '500은 네트워크성 실패가 아니므로 내부 재시도 없이 즉시 1회로 차단해야 한다',
      );

      // 차단 화면이 연결 스트림을 구독한 뒤로 8초를 더 흘려보낸다. 재구독이
      // "재생" 이벤트를 자가 발화로 오인하면 이 구간에서 재시도가 계속 쌓인다.
      await tester.pump(const Duration(seconds: 8));

      expect(
        repository.callCount,
        callsAfterFirstBlock,
        reason:
            '기기 연결은 처음부터 끊긴 적이 없다 — 재구독 재생 이벤트만으로 재시도가 '
            '늘어나면 서버가 죽어 있는 동안 무한 루프를 타는 회귀다',
      );

      await tester.pump(const Duration(milliseconds: 1));
    },
  );
}
