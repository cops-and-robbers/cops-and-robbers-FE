import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/domain/entities/game_result_entity.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_result_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_over_result_dialog.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';

void main() {
  group('formatDuration', () {
    test('formats_minutes_and_zero_padded_seconds_when_given_seconds', () {
      expect(formatDuration(0), '0:00');
      expect(formatDuration(59), '0:59');
      expect(formatDuration(60), '1:00');
      expect(formatDuration(225), '3:45');
      expect(formatDuration(3600), '60:00');
      expect(formatDuration(3661), '61:01');
    });
  });

  group('resolveBodyAsset', () {
    test('returns_police_win_body_when_my_police_team_wins', () {
      final path = resolveBodyAsset(myTeam: 'POLICE', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/police/result/win_body.svg');
    });

    test('returns_police_lose_body_when_robber_team_wins_and_im_police', () {
      final path = resolveBodyAsset(myTeam: 'POLICE', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/police/result/lose_body.svg');
    });

    test('returns_robber_win_body_when_my_robber_team_wins', () {
      final path = resolveBodyAsset(myTeam: 'ROBBER', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/robber/result/win_body.svg');
    });

    test('returns_robber_lose_body_when_police_team_wins_and_im_robber', () {
      final path = resolveBodyAsset(myTeam: 'ROBBER', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/robber/result/lose_body.svg');
    });
  });

  group('resolveLeftArmAsset', () {
    test('returns_police_win_left_arm_when_my_police_team_wins', () {
      final path = resolveLeftArmAsset(myTeam: 'POLICE', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/police/result/win_arm_left.svg');
    });

    test(
      'returns_police_lose_left_arm_when_robber_team_wins_and_im_police',
      () {
        final path = resolveLeftArmAsset(
          myTeam: 'POLICE',
          winnerTeam: 'ROBBER',
        );
        expect(path, 'assets/characters/police/result/lose_arm_left.svg');
      },
    );

    test('returns_robber_win_left_arm_when_my_robber_team_wins', () {
      final path = resolveLeftArmAsset(myTeam: 'ROBBER', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/robber/result/win_arm_left.svg');
    });

    test(
      'returns_robber_lose_left_arm_when_police_team_wins_and_im_robber',
      () {
        final path = resolveLeftArmAsset(
          myTeam: 'ROBBER',
          winnerTeam: 'POLICE',
        );
        expect(path, 'assets/characters/robber/result/lose_arm_left.svg');
      },
    );
  });

  group('resolveRightArmAsset', () {
    test('returns_police_win_right_arm_when_my_police_team_wins', () {
      final path = resolveRightArmAsset(myTeam: 'POLICE', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/police/result/win_arm_right.svg');
    });

    test(
      'returns_police_lose_right_arm_when_robber_team_wins_and_im_police',
      () {
        final path = resolveRightArmAsset(
          myTeam: 'POLICE',
          winnerTeam: 'ROBBER',
        );
        expect(path, 'assets/characters/police/result/lose_arm_right.svg');
      },
    );

    test('returns_robber_win_right_arm_when_my_robber_team_wins', () {
      final path = resolveRightArmAsset(myTeam: 'ROBBER', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/robber/result/win_arm_right.svg');
    });

    test(
      'returns_robber_lose_right_arm_when_police_team_wins_and_im_robber',
      () {
        final path = resolveRightArmAsset(
          myTeam: 'ROBBER',
          winnerTeam: 'POLICE',
        );
        expect(path, 'assets/characters/robber/result/lose_arm_right.svg');
      },
    );
  });

  group('GameOverResultDialog', () {
    const entity = GameResultEntity(
      winnerTeam: 'POLICE',
      durationSeconds: 300,
      totalArrestCount: 5,
      remainingRobberCount: 1,
    );

    testWidgets('shows_stats_from_entity_when_api_returns_data', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 1,
        resultFuture: () async => entity,
      );

      expect(find.text('5회'), findsOneWidget);
      expect(find.text('1명'), findsOneWidget);
      expect(find.text('5:00'), findsOneWidget);
    });

    testWidgets('shows_placeholder_dash_for_all_stats_when_api_fails', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 2,
        resultFuture: () async => throw Exception('boom'),
      );
      // 에러 전파까지 pump
      await tester.pump();

      // 체포 횟수/남은 도둑/게임 진행 시간 3개 모두 "-"
      expect(find.text('-'), findsNWidgets(3));
    });

    testWidgets(
      'shows_placeholder_dash_for_all_stats_when_provider_still_loading',
      (tester) async {
        // Completer로 resolve 안 되는 Future 주입 → 영원히 loading 상태
        final pendingCompleter = Completer<GameResultEntity>();
        addTearDown(() {
          // 테스트 종료 시 hanging future 정리
          if (!pendingCompleter.isCompleted) {
            pendingCompleter.completeError(StateError('test teardown'));
          }
        });

        await pumpGameOverDialog(
          tester,
          gameResultId: 3,
          resultFuture: () => pendingCompleter.future,
        );

        // loading 상태도 placeholder rows 표시 (AsyncValue.loading 분기)
        expect(find.text('-'), findsNWidgets(3));
      },
    );

    testWidgets('shows_win_title_in_team_color_when_my_team_wins', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 4,
        resultFuture: () async => entity,
        myTeam: 'POLICE',
        winnerTeam: 'POLICE',
      );

      expect(find.text('승리'), findsOneWidget);
    });

    testWidgets('shows_lose_title_in_red_when_my_team_loses', (tester) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 5,
        resultFuture: () async => entity,
        myTeam: 'POLICE',
        winnerTeam: 'ROBBER',
      );

      expect(find.text('패배'), findsOneWidget);
    });

    testWidgets('triggers_on_go_home_callback_when_home_button_tapped', (
      tester,
    ) async {
      var called = false;
      await pumpGameOverDialog(
        tester,
        gameResultId: 6,
        resultFuture: () async => entity,
        onGoHome: () => called = true,
      );

      await tester.tap(find.byKey(const ValueKey('game_over_go_home_button')));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('triggers_on_rematch_callback_when_rematch_button_tapped', (
      tester,
    ) async {
      var called = false;
      await pumpGameOverDialog(
        tester,
        gameResultId: 7,
        resultFuture: () async => entity,
        onRematch: () => called = true,
      );

      await tester.tap(find.byKey(const ValueKey('game_over_rematch_button')));
      await tester.pump();

      expect(called, isTrue);
    });
  });
}

/// 다이얼로그를 pumping하는 헬퍼
///
/// [resultFuture]는 `gameResultProvider(gameResultId)`의 override 구현:
/// - data: `() async => entity`
/// - error: `() async => throw SomeException()`
/// - loading: `() => Completer<GameResultEntity>().future`  (resolve 안 되는 Future)
Future<void> pumpGameOverDialog(
  WidgetTester tester, {
  required int gameResultId,
  required Future<GameResultEntity> Function() resultFuture,
  String myTeam = 'POLICE',
  String winnerTeam = 'POLICE',
  bool isDarkMode = false,
  VoidCallback? onGoHome,
  VoidCallback? onRematch,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameResultProvider(gameResultId).overrideWith((_) => resultFuture()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              // 첫 프레임 이후 다이얼로그 오픈
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GameOverResultDialog.show(
                  context: context,
                  isDarkMode: isDarkMode,
                  myTeam: myTeam,
                  winnerTeam: winnerTeam,
                  gameResultId: gameResultId,
                  onGoHome: onGoHome ?? () {},
                  onRematch: onRematch ?? () {},
                );
              });
              return const Scaffold();
            },
          ),
        ),
      ),
    ),
  );
  // pumpAndSettle은 loading 상태에서 hang 가능 → pump 여러 번으로 대체
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}
