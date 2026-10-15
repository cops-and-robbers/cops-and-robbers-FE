import 'dart:async';

import 'package:cops_and_robbers/features/game/domain/entities/game_result_entity.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/game_over_intro_modal.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _bothMvps = GameResultEntity(
  winnerTeam: 'POLICE',
  durationSeconds: 1800,
  totalArrestCount: 12,
  remainingRobberCount: 0,
  policeMvpNickname: '번개경찰',
  robberMvpNickname: '그림자',
);

/// 모달을 띄우고 열린 직후로 돌아온다. 결과는 호출부가 Future로 쥔다.
Future<void> openModal(
  WidgetTester tester, {
  required Future<GameResultEntity>? result,
  bool isDarkMode = false,
}) async {
  tester.view.physicalSize = const Size(375 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => GameOverIntroModal.show(
                context: context,
                isDarkMode: isDarkMode,
                reason: 'TIME_OVER',
                result: result,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump();
}

/// 50ms씩 나눠 진행 — 타이머 안에서 다시 건 타이머까지 제때 돈다.
Future<void> advance(WidgetTester tester, Duration d) async {
  for (var i = 0; i < d.inMilliseconds ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> tapScreen(WidgetTester tester) =>
    tester.tapAt(const Offset(187, 120));

void main() {
  // 결과가 1.4초 전에 와 있으면: 1.4초 흔들림 시작 → 2.7초 첫 공개 → 4.05초부터 탭.
  testWidgets(
    'closes_after_three_seconds_without_tease_when_server_predates_mvp',
    (tester) async {
      await openModal(
        tester,
        result: Future.value(
          const GameResultEntity(
            winnerTeam: 'POLICE',
            durationSeconds: 1800,
            totalArrestCount: 12,
            remainingRobberCount: 0,
          ),
        ),
      );

      await advance(tester, const Duration(milliseconds: 2900));
      expect(find.text('게임 종료!'), findsOneWidget);
      expect(find.text('MVP는 누굴까?!'), findsNothing);

      await advance(tester, const Duration(milliseconds: 500));
      expect(find.text('게임 종료!'), findsNothing);
    },
  );

  testWidgets('reveals_robber_mvp_first_when_police_won', (tester) async {
    final result = Completer<GameResultEntity>();
    await openModal(tester, result: result.future);

    // 응답이 2초에 도착 — 1.4초는 넘었으니 바로 흔들림.
    await advance(tester, const Duration(seconds: 2));
    result.complete(_bothMvps);
    await advance(tester, const Duration(milliseconds: 600));
    expect(find.text('MVP는 누굴까?!'), findsOneWidget);

    await advance(tester, const Duration(milliseconds: 1500));
    expect(find.text('그림자'), findsOneWidget);
    expect(find.text('번개경찰'), findsNothing);
  });

  testWidgets('ignores_taps_until_entrance_finishes_then_advances', (
    tester,
  ) async {
    await openModal(tester, result: Future.value(_bothMvps));
    await advance(tester, const Duration(milliseconds: 2900)); // 첫 공개 직후

    await tapScreen(tester); // 연출 중 — 무시
    await advance(tester, const Duration(milliseconds: 400));
    expect(find.text('그림자'), findsOneWidget);
    expect(find.text('탭하면 넘어가요'), findsOneWidget); // 투명도 0이어도 트리에 있다

    await advance(tester, const Duration(milliseconds: 1000)); // 4.3초 — 탭 가능
    await tapScreen(tester);
    await advance(tester, const Duration(milliseconds: 500));
    expect(find.text('번개경찰'), findsOneWidget);

    await advance(tester, const Duration(milliseconds: 1400));
    await tapScreen(tester);
    await advance(tester, const Duration(milliseconds: 500));
    expect(find.text('번개경찰'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('advances_on_back_button_only_after_entrance', (tester) async {
    await openModal(tester, result: Future.value(_bothMvps));
    await advance(tester, const Duration(milliseconds: 2900));

    await tester.binding.handlePopRoute(); // 연출 중 뒤로가기 — 무시
    await advance(tester, const Duration(milliseconds: 1400));
    expect(find.text('그림자'), findsOneWidget);

    await tester.binding.handlePopRoute(); // 연출 끝 — 다음 MVP
    await advance(tester, const Duration(milliseconds: 500));
    expect(find.text('번개경찰'), findsOneWidget);
  });

  testWidgets('closes_like_plain_popup_when_result_request_fails', (
    tester,
  ) async {
    // 응답이 0.8초 뒤 500으로 실패. Future.error를 바로 넘기면 모달이 handler를 붙이기
    // 전에 미처리 에러로 보고되므로, 실제처럼 시간이 지난 뒤 실패하게 만든다.
    await openModal(
      tester,
      result: Future<GameResultEntity>.delayed(
        const Duration(milliseconds: 800),
        () => throw Exception('500'),
      ),
    );

    await advance(tester, const Duration(milliseconds: 3400));
    expect(find.text('MVP는 누굴까?!'), findsNothing);
    expect(find.text('게임 종료!'), findsNothing);
  });

  testWidgets('reveals_only_police_mvp_when_every_robber_left', (tester) async {
    await openModal(
      tester,
      result: Future.value(
        const GameResultEntity(
          winnerTeam: 'POLICE',
          durationSeconds: 900,
          totalArrestCount: 4,
          remainingRobberCount: 0,
          policeMvpNickname: '번개경찰',
        ),
      ),
    );

    await advance(tester, const Duration(milliseconds: 4300));
    expect(find.text('번개경찰'), findsOneWidget);
    await tapScreen(tester);
    await advance(tester, const Duration(milliseconds: 500));
    expect(find.text('번개경찰'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  // 응답이 2.9초에 와도 공개가 3초 타임아웃에 끊기면 안 된다.
  testWidgets('keeps_revealing_when_result_arrives_just_before_timeout', (
    tester,
  ) async {
    final result = Completer<GameResultEntity>();
    await openModal(tester, result: result.future);

    await advance(tester, const Duration(milliseconds: 2900));
    result.complete(_bothMvps);
    await advance(tester, const Duration(milliseconds: 600)); // 3.5초
    expect(find.text('MVP는 누굴까?!'), findsOneWidget);
  });

  // 느린 망 — 모달이 닫힌 뒤 도착한 결과는 아무 일도 일으키지 않는다.
  testWidgets('ignores_result_when_it_arrives_after_modal_closed', (
    tester,
  ) async {
    final result = Completer<GameResultEntity>();
    await openModal(tester, result: result.future);

    await advance(tester, const Duration(milliseconds: 3400));
    expect(find.text('게임 종료!'), findsNothing);

    result.complete(_bothMvps);
    await advance(tester, const Duration(seconds: 3));
    expect(find.text('MVP는 누굴까?!'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // 카드 단계에서 설정 앱으로 가 위치 권한을 끄고 돌아오면 GamePage가 권한 안내를
  // 모달 위에 띄운다. 3초가 되면 모달만 닫혀야 하고, 위의 안내는 남아야 한다.
  testWidgets('closes_itself_not_the_dialog_above_when_timeout_hits', (
    tester,
  ) async {
    await openModal(
      tester,
      result: Future.value(
        const GameResultEntity(
          winnerTeam: 'POLICE',
          durationSeconds: 1800,
          totalArrestCount: 12,
          remainingRobberCount: 0,
        ),
      ),
    );
    await advance(tester, const Duration(seconds: 1));
    showDialog<void>(
      context: tester.element(find.text('게임 종료!')),
      builder: (_) => const AlertDialog(content: Text('위치 권한이 꺼져 있어요')),
    );
    await advance(tester, const Duration(milliseconds: 2400)); // 3.4초

    expect(find.text('위치 권한이 꺼져 있어요'), findsOneWidget);
    expect(find.text('게임 종료!'), findsNothing);
  });
}
