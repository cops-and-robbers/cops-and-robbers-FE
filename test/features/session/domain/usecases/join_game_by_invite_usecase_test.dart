import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/session/domain/entities/game_join_result.dart';
import 'package:cops_and_robbers/features/session/domain/repositories/session_repository.dart';
import 'package:cops_and_robbers/features/session/domain/usecases/join_game_by_invite_usecase.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepository repo;
  late JoinGameByInviteUseCase usecase;

  setUp(() {
    repo = _MockSessionRepository();
    usecase = JoinGameByInviteUseCase(repository: repo);
  });

  test('정상 응답시 Repository 결과를 그대로 반환한다', () async {
    when(() => repo.joinGameByInvite(inviteCode: 'ABC123')).thenAnswer(
      (_) async => const GameJoinResult(gameId: 1, participantId: 2),
    );

    final result = await usecase.execute('ABC123');

    expect(result, equals(const GameJoinResult(gameId: 1, participantId: 2)));
  });

  test('Repository 가 ServerException 을 던지면 그대로 전파한다', () async {
    when(() => repo.joinGameByInvite(inviteCode: 'BAD')).thenThrow(
      const ServerException(
        message: '이미 해당 게임에 참가하고 있습니다',
        messageKey: 'errorGameJoinAlreadyParticipating',
      ),
    );

    await expectLater(
      () => usecase.execute('BAD'),
      throwsA(isA<ServerException>()),
    );
  });
}
