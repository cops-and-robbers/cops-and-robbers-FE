import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/auth/domain/repositories/auth_repository.dart';
import 'package:cops_and_robbers/features/session/domain/entities/user_game_status_entity.dart';
import 'package:cops_and_robbers/features/session/domain/repositories/session_repository.dart';
import 'package:cops_and_robbers/features/user/domain/usecases/prepare_account_deletion_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late _MockAuthRepository auth;
  late _MockSessionRepository session;
  late PrepareAccountDeletionUseCase useCase;

  void participating(bool value) {
    when(
      () => session.getMyActiveGame(),
    ).thenAnswer((_) async => UserGameStatusEntity(isParticipating: value));
  }

  setUp(() {
    auth = _MockAuthRepository();
    session = _MockSessionRepository();
    useCase = PrepareAccountDeletionUseCase(
      authRepository: auth,
      sessionRepository: session,
    );
  });

  test('execute_doesNothing_when_notAppleAccount', () async {
    when(() => auth.isAppleAccount).thenReturn(false);

    await useCase.execute();

    verifyNever(() => session.getMyActiveGame());
    verifyNever(() => auth.revokeAppleToken());
  });

  test('execute_revokesToken_when_appleAccountHasNoActiveGame', () async {
    when(() => auth.isAppleAccount).thenReturn(true);
    when(() => auth.revokeAppleToken()).thenAnswer((_) async {});
    participating(false);

    await useCase.execute();

    verify(() => auth.revokeAppleToken()).called(1);
  });

  test('execute_keepsAppleLink_when_appleAccountHasActiveGame', () async {
    when(() => auth.isAppleAccount).thenReturn(true);
    participating(true);

    await expectLater(
      useCase.execute(),
      throwsA(
        isA<ServerException>().having((e) => e.code, 'code', 'CANNOT_WITHDRAW'),
      ),
    );
    verifyNever(() => auth.revokeAppleToken());
  });

  test('execute_passesCancellation_when_userCancelsAppleSheet', () async {
    when(() => auth.isAppleAccount).thenReturn(true);
    when(
      () => auth.revokeAppleToken(),
    ).thenThrow(const AuthCancelledException());
    participating(false);

    await expectLater(
      useCase.execute(),
      throwsA(isA<AuthCancelledException>()),
    );
  });
}
