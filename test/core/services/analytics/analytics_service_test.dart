import 'package:clock/clock.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cops_and_robbers/core/services/analytics/analytics_service.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('AnalyticsService', () {
    late _MockFirebaseAnalytics analytics;
    late AnalyticsService service;

    setUp(() {
      analytics = _MockFirebaseAnalytics();
      service = AnalyticsService(analytics: analytics);
      when(
        () => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => analytics.logLogin(loginMethod: any(named: 'loginMethod')),
      ).thenAnswer((_) async {});
    });

    test('logGameOver_sends_snake_case_params_when_called', () async {
      await service.logGameOver(
        result: 'win',
        team: 'POLICE',
        reason: 'ALL_ARRESTED',
        durationMinutes: 32,
      );

      verify(
        () => analytics.logEvent(
          name: 'game_over',
          parameters: {
            'result': 'win',
            'team': 'POLICE',
            'reason': 'ALL_ARRESTED',
            'duration_minutes': 32,
          },
        ),
      ).called(1);
    });

    test('logGameStart_sends_once_when_same_game_reported_twice', () async {
      await service.logGameStart(
        gameId: 7,
        team: 'ROBBER',
        participantCount: 5,
      );
      await service.logGameStart(
        gameId: 7,
        team: 'ROBBER',
        participantCount: 5,
      );

      verify(
        () => analytics.logEvent(
          name: 'game_start',
          parameters: {'team': 'ROBBER', 'participant_count': 5},
        ),
      ).called(1);
    });

    test(
      'logGameStart_sends_again_when_next_round_uses_same_game_id',
      () async {
        final start = DateTime(2026, 11, 4, 12);
        await withClock(Clock.fixed(start), () async {
          await service.logGameStart(gameId: 7, team: 'POLICE');
        });
        await withClock(
          Clock.fixed(start.add(const Duration(minutes: 10))),
          () async {
            await service.logGameStart(gameId: 7, team: 'POLICE');
          },
        );

        verify(
          () => analytics.logEvent(
            name: 'game_start',
            parameters: {'team': 'POLICE'},
          ),
        ).called(2);
      },
    );

    test('logGameStart_sends_again_when_next_game_starts', () async {
      await service.logGameStart(gameId: 7, team: 'POLICE');
      await service.logGameStart(gameId: 8, team: 'POLICE');

      verify(
        () => analytics.logEvent(
          name: 'game_start',
          parameters: {'team': 'POLICE'},
        ),
      ).called(2);
    });

    test('log_methods_do_not_throw_when_firebase_unavailable', () async {
      // Firebase 초기화 실패 시 analytics=null → 전체 no-op이어야 한다
      final noFirebase = AnalyticsService(analytics: null);

      await noFirebase.logLogin(method: 'google');
      await noFirebase.logGameOver(
        result: 'lose',
        team: 'ROBBER',
        reason: 'TIME_OVER',
        durationMinutes: 5,
      );
      await noFirebase.logAdInterstitialResult(status: 'not_loaded');
    });

    test('log_methods_swallow_errors_when_sdk_throws', () async {
      when(
        () => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenThrow(Exception('sdk down'));

      // Analytics 실패가 호출자(게임 흐름)에 전파되면 안 된다
      await service.logGameJoin(method: 'code');
    });
  });
}
