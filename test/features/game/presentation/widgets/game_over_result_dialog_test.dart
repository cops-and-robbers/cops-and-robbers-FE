import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cops_and_robbers/features/game/domain/entities/game_result_entity.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/game_result_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/player_game_record_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_over_result_dialog.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/record_format.dart';
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
      expect(path, 'assets/characters/police/result/default/win_body.svg');
    });

    test('returns_police_lose_body_when_robber_team_wins_and_im_police', () {
      final path = resolveBodyAsset(myTeam: 'POLICE', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/police/result/default/lose_body.svg');
    });

    test('returns_robber_win_body_when_my_robber_team_wins', () {
      final path = resolveBodyAsset(myTeam: 'ROBBER', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/robber/result/default/win_body.svg');
    });

    test('returns_robber_lose_body_when_police_team_wins_and_im_robber', () {
      final path = resolveBodyAsset(myTeam: 'ROBBER', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/robber/result/default/lose_body.svg');
    });
  });

  group('resolveLeftArmAsset', () {
    test('returns_police_win_left_arm_when_my_police_team_wins', () {
      final path = resolveLeftArmAsset(myTeam: 'POLICE', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/police/result/default/win_arm_left.svg');
    });

    test(
      'returns_police_lose_left_arm_when_robber_team_wins_and_im_police',
      () {
        final path = resolveLeftArmAsset(
          myTeam: 'POLICE',
          winnerTeam: 'ROBBER',
        );
        expect(
          path,
          'assets/characters/police/result/default/lose_arm_left.svg',
        );
      },
    );

    test('returns_robber_win_left_arm_when_my_robber_team_wins', () {
      final path = resolveLeftArmAsset(myTeam: 'ROBBER', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/robber/result/default/win_arm_left.svg');
    });

    test(
      'returns_robber_lose_left_arm_when_police_team_wins_and_im_robber',
      () {
        final path = resolveLeftArmAsset(
          myTeam: 'ROBBER',
          winnerTeam: 'POLICE',
        );
        expect(
          path,
          'assets/characters/robber/result/default/lose_arm_left.svg',
        );
      },
    );
  });

  group('resolveRightArmAsset', () {
    test('returns_police_win_right_arm_when_my_police_team_wins', () {
      final path = resolveRightArmAsset(myTeam: 'POLICE', winnerTeam: 'POLICE');
      expect(path, 'assets/characters/police/result/default/win_arm_right.svg');
    });

    test(
      'returns_police_lose_right_arm_when_robber_team_wins_and_im_police',
      () {
        final path = resolveRightArmAsset(
          myTeam: 'POLICE',
          winnerTeam: 'ROBBER',
        );
        expect(
          path,
          'assets/characters/police/result/default/lose_arm_right.svg',
        );
      },
    );

    test('returns_robber_win_right_arm_when_my_robber_team_wins', () {
      final path = resolveRightArmAsset(myTeam: 'ROBBER', winnerTeam: 'ROBBER');
      expect(path, 'assets/characters/robber/result/default/win_arm_right.svg');
    });

    test(
      'returns_robber_lose_right_arm_when_police_team_wins_and_im_robber',
      () {
        final path = resolveRightArmAsset(
          myTeam: 'ROBBER',
          winnerTeam: 'POLICE',
        );
        expect(
          path,
          'assets/characters/robber/result/default/lose_arm_right.svg',
        );
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

      // 단위 없이 숫자만 노출한다.
      expect(find.text('5'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5:00'), findsOneWidget);
    });

    testWidgets('lists_playtime_then_arrests_then_remaining_robbers', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 11,
        resultFuture: () async => entity,
      );

      final playtimeY = tester.getTopLeft(find.text('게임 진행 시간')).dy;
      final arrestY = tester.getTopLeft(find.text('체포 횟수')).dy;
      final remainingY = tester.getTopLeft(find.text('남은 도둑')).dy;

      expect(playtimeY, lessThan(arrestY));
      expect(arrestY, lessThan(remainingY));
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

    testWidgets('shows_distance_and_ended_date_when_record_has_movement', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 8,
        resultFuture: () async => entity,
        record: PlayerGameRecord(
          distanceMeters: 2543,
          endedAt: DateTime(2026, 7, 21, 15, 45),
        ),
      );

      // Text.rich라 find.text는 스팬을 합친 평문으로 매칭한다.
      expect(find.text('2.54 Km'), findsOneWidget);
      expect(find.text('2026.07.21 15:45'), findsOneWidget);
    });

    testWidgets('shows_no_route_placeholder_when_route_is_empty', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 9,
        resultFuture: () async => entity,
      );

      expect(find.text('이동 기록 없음'), findsOneWidget);
    });

    testWidgets('offers_save_and_share_when_share_button_tapped', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 10,
        resultFuture: () async => entity,
      );

      await tester.tap(find.byKey(const ValueKey('game_over_share_button')));
      await tester.pumpAndSettle();

      expect(find.text('이미지를 어떻게 할까요?'), findsOneWidget);
      expect(find.text('저장하기'), findsOneWidget);
      expect(find.text('공유하기'), findsOneWidget);
    });

    testWidgets('ignores_second_share_tap_while_save_in_progress', (
      tester,
    ) async {
      // gal 권한 요청을 pending으로 붙잡아 "저장이 끝나지 않은" 상태를 만든다.
      final galAccess = Completer<bool>();
      var accessRequested = false;
      const channel = MethodChannel('gal');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'requestAccess') {
          accessRequested = true;
          return galAccess.future;
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await pumpGameOverDialog(
        tester,
        gameResultId: 12,
        resultFuture: () async => entity,
      );

      await tester.tap(find.byKey(const ValueKey('game_over_share_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장하기'));

      // 캡처(toImage)는 FakeAsync 밖의 실제 비동기라 pump만으로는 끝나지 않는다.
      // runAsync로 이벤트 루프를 실제로 돌리며 저장 단계 진입까지 bounded 대기.
      for (var i = 0; i < 50 && !accessRequested; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 1)),
        );
        await tester.pump();
      }
      expect(accessRequested, isTrue); // 캡처가 끝나 아이콘이 복원된 상태

      // 저장이 끝나기 전 두 번째 탭 — 선택 다이얼로그가 다시 열리면 안 된다.
      await tester.tap(find.byKey(const ValueKey('game_over_share_button')));
      await tester.pumpAndSettle();
      expect(find.text('이미지를 어떻게 할까요?'), findsNothing);

      // 저장 플로우가 끝난 뒤에는 다시 열 수 있다 (가드 해제 확인).
      galAccess.complete(false);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('game_over_share_button')));
      await tester.pumpAndSettle();
      expect(find.text('이미지를 어떻게 할까요?'), findsOneWidget);

      // 실패 스낵바의 dismiss 타이머(3초)를 소진해 pending timer 없이 종료한다.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('swaps_buttons_for_brand_lockup_while_capturing', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 10,
        resultFuture: () async => entity,
      );

      // 라이브 화면에는 로고가 안 보인다(offstage) — 공유 이미지 전용이다.
      expect(
        find.byKey(const ValueKey('game_over_brand_lockup')),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('game_over_share_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('공유하기'));
      await tester.pump(); // _capturing = true 반영

      expect(
        find.byKey(const ValueKey('game_over_brand_lockup')),
        findsOneWidget,
      );

      // 버튼은 이미지에 남으면 안 되므로 offstage로 빠져 그려지지 않는다.
      expect(
        find.byKey(const ValueKey('game_over_go_home_button')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('game_over_rematch_button')),
        findsNothing,
      );
      // 아이콘은 자리를 유지한 채 투명해진다(제거하면 타이틀이 흔들린다).
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.byKey(const ValueKey('game_over_share_button')),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        0,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('premounts_brand_lockup_offstage_before_capture', (
      tester,
    ) async {
      await pumpGameOverDialog(
        tester,
        gameResultId: 11,
        resultFuture: () async => entity,
      );

      // 로고는 공유 전부터 offstage로 마운트돼 디코딩을 끝내 둬야 한다.
      // 캡처 프레임에 처음 마운트되면 실기기의 비동기 에셋 로딩 때문에
      // 그 프레임에 그려지지 못해 공유 이미지에서 빠진다.
      expect(
        find.byKey(
          const ValueKey('game_over_brand_lockup'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
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
  PlayerGameRecord record = const PlayerGameRecord(),
}) async {
  // 테스트 기본 화면(800×600)은 ScreenUtil designSize(375×812)와 어긋나 폭 기준 sp는
  // 2배로 커지고 높이 기준 h는 줄어든다. 실기기와 같은 비율이 되도록 맞춰준다.
  tester.view.physicalSize = const Size(375 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameResultProvider(gameResultId).overrideWith((_) => resultFuture()),
        playerGameRecordNotifierProvider.overrideWith(
          () => _FakeRecord(record),
        ),
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

/// 경로·거리 누적값을 고정해 결과 카드 렌더를 검증하기 위한 fake.
class _FakeRecord extends PlayerGameRecordNotifier {
  _FakeRecord(this._initial);
  final PlayerGameRecord _initial;
  @override
  PlayerGameRecord build() => _initial;
}
