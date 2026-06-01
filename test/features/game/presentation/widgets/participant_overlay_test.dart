import 'package:cops_and_robbers/features/game/presentation/providers/game_event_provider.dart';
import 'package:cops_and_robbers/features/game/presentation/widgets/participant_overlay.dart';
import 'package:cops_and_robbers/features/session/data/models/in_game_participants_response.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/game_participant_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';
import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParticipantOverlay', () {
    testWidgets('게임 종료 상태면 초기 참가자 조회를 시작하지 않는다', (tester) async {
      var fetchCount = 0;

      await _pumpOverlay(
        tester,
        initialGameEventState: const GameEventState(isGameOver: true),
        fetchParticipants: () async {
          fetchCount++;
          return _participants;
        },
      );

      await tester.pump();

      expect(fetchCount, 0);
    });

    testWidgets('GAME_OVER가 포함된 이벤트 갱신에서는 참가자 재조회를 하지 않는다', (tester) async {
      var fetchCount = 0;
      late _TestGameEventNotifier gameEventNotifier;

      await _pumpOverlay(
        tester,
        initialGameEventState: const GameEventState(),
        fetchParticipants: () async {
          fetchCount++;
          return _participants;
        },
        onGameEventNotifierReady: (notifier) {
          gameEventNotifier = notifier;
        },
      );
      await tester.pump();
      expect(fetchCount, 1);

      gameEventNotifier.setState(
        const GameEventState(isGameOver: true, arrestedParticipantIds: {2}),
      );
      await tester.pump();

      expect(fetchCount, 1);
    });

    testWidgets('게임 종료 400 응답은 참가자 조회 실패 로그를 남기지 않는다', (tester) async {
      final messages = <String?>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        messages.add(message);
      };

      try {
        await _pumpOverlay(
          tester,
          initialGameEventState: const GameEventState(),
          fetchParticipants: () async => throw _gameNotInProgressException(),
        );
        await tester.pump();
      } finally {
        debugPrint = previousDebugPrint;
      }

      expect(
        messages.where(
          (message) =>
              message?.contains('[ParticipantOverlay] 참가자 조회 실패') ?? false,
        ),
        isEmpty,
      );
    });
  });
}

const _gameInfo = GameParticipantInfo(
  gameId: 1,
  team: 'POLICE',
  nickname: '경찰',
  participantId: 1,
);

const _participants = InGameParticipantsResponse(
  police: [
    InGameParticipant(
      participantId: 1,
      nickname: '경찰',
      status: 'POLICE_WAITING',
    ),
  ],
  robbers: [
    InGameParticipant(participantId: 2, nickname: '도둑', status: 'ALIVE'),
  ],
);

Future<void> _pumpOverlay(
  WidgetTester tester, {
  required GameEventState initialGameEventState,
  required Future<InGameParticipantsResponse> Function() fetchParticipants,
  void Function(_TestGameEventNotifier notifier)? onGameEventNotifierReady,
}) async {
  final gameEventNotifier = _TestGameEventNotifier(initialGameEventState);
  onGameEventNotifierReady?.call(gameEventNotifier);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameParticipantNotifierProvider.overrideWith(
          () => _TestGameParticipantNotifier(_gameInfo),
        ),
        gameEventNotifierProvider.overrideWith(() => gameEventNotifier),
        fetchGameParticipantsProvider(
          _gameInfo.gameId,
        ).overrideWith((_) => fetchParticipants()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ParticipantOverlay(
              onClose: _noop,
              gameId: 1,
              myTeam: 'POLICE',
              myParticipantId: 1,
            ),
          ),
        ),
      ),
    ),
  );
}

void _noop() {}

DioException _gameNotInProgressException() {
  final requestOptions = RequestOptions(path: '/api/games/1/participants');
  return DioException.badResponse(
    statusCode: 400,
    requestOptions: requestOptions,
    response: Response<Map<String, dynamic>>(
      requestOptions: requestOptions,
      statusCode: 400,
      data: const {
        'title': '게임 진행 중 아님',
        'status': 400,
        'detail': '게임이 진행 중인 상태가 아닙니다.',
        'instance': '/api/games/1/participants',
        'errorCode': 'GAME_NOT_IN_PROGRESS',
      },
    ),
  );
}

class _TestGameParticipantNotifier extends GameParticipantNotifier {
  _TestGameParticipantNotifier(this._initial);

  final GameParticipantInfo? _initial;

  @override
  GameParticipantInfo? build() => _initial;
}

class _TestGameEventNotifier extends GameEventNotifier {
  _TestGameEventNotifier(this._initial);

  final GameEventState _initial;

  @override
  GameEventState build() => _initial;

  void setState(GameEventState value) {
    state = value;
  }
}
