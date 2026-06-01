import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/auth/domain/entities/auth_result_entity.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/session/domain/entities/game_join_result.dart';
import 'package:cops_and_robbers/features/session/domain/entities/user_game_status_entity.dart';
import 'package:cops_and_robbers/features/session/domain/usecases/get_my_active_game_usecase.dart';
import 'package:cops_and_robbers/features/session/domain/usecases/join_game_by_invite_usecase.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/deeplink_join_notifier.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/pending_invite_provider.dart';
import 'package:cops_and_robbers/features/session/presentation/providers/session_provider.dart';

class _MockJoinUseCase extends Mock implements JoinGameByInviteUseCase {}

class _MockActiveGameUseCase extends Mock implements GetMyActiveGameUsecase {}

void main() {
  late _MockJoinUseCase joinUseCase;
  late _MockActiveGameUseCase activeGameUseCase;

  setUp(() {
    joinUseCase = _MockJoinUseCase();
    activeGameUseCase = _MockActiveGameUseCase();
    // PendingInvite.build() 가 SharedPreferences 를 사용하므로 mock 초기화 필요
    SharedPreferences.setMockInitialValues({});
  });

  /// AuthResultEntity는 requiresAgreement 필드가 필수이므로 명시적으로 포함
  ProviderContainer makeContainer({AuthResultEntity? user}) {
    return ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(() => _FakeAuthNotifier(user)),
        joinGameByInviteUseCaseProvider.overrideWithValue(joinUseCase),
        getMyActiveGameUsecaseProvider.overrideWithValue(activeGameUseCase),
      ],
    );
  }

  const loggedInUser = AuthResultEntity(
    userId: 1,
    nickname: 'u',
    isNewUser: false,
    requiresAgreement: false,
  );

  test('미로그인이면 PendingInvite 저장 후 LoginRedirect 결과 반환', () async {
    final container = makeContainer(user: null);
    addTearDown(container.dispose);

    final outcome = await container
        .read(deepLinkJoinNotifierProvider.notifier)
        .handle('ABC123');

    expect(outcome, equals(const DeepLinkJoinOutcome.loginRedirect()));
    final pending = await container.read(pendingInviteProvider.future);
    expect(pending, equals('ABC123'));
  });

  test('로그인 + 정상 응답이면 JoinedRoom 결과 반환', () async {
    final container = makeContainer(
      user: const AuthResultEntity(
        userId: 1,
        nickname: 'u',
        isNewUser: false,
        requiresAgreement: false,
      ),
    );
    addTearDown(container.dispose);
    when(() => joinUseCase.execute('ABC123')).thenAnswer(
      (_) async => const GameJoinResult(gameId: 7, participantId: 2),
    );

    final outcome = await container
        .read(deepLinkJoinNotifierProvider.notifier)
        .handle('ABC123');

    expect(outcome, equals(const DeepLinkJoinOutcome.joinedRoom(gameId: 7)));
  });

  group('409 conflict — 이미 방 참가 중', () {
    // DioExceptionHandler 는 409 를 ServerException(messageKey: 'errorTemporaryRetry',
    // code: 백엔드 errorCode) 으로 변환한다. deeplink 는 code == 'ALREADY_PARTICIPATING' 로 분기한다.
    const conflict = ServerException(
      message: 'conflict',
      messageKey: 'errorTemporaryRetry',
      code: 'ALREADY_PARTICIPATING',
    );

    test(
      '활성 게임이 WAITING 이면 해당 대기실 participation 을 실어 AlreadyInRoom 반환',
      () async {
        final container = makeContainer(user: loggedInUser);
        addTearDown(container.dispose);
        when(() => joinUseCase.execute('ABC123')).thenThrow(conflict);
        when(() => activeGameUseCase.execute()).thenAnswer(
          (_) async => const UserGameStatusEntity(
            isParticipating: true,
            participationInfo: UserGameParticipationEntity(
              gameId: 7,
              participantId: 2,
              gameStatus: 'WAITING',
              team: 'POLICE',
            ),
          ),
        );

        final outcome = await container
            .read(deepLinkJoinNotifierProvider.notifier)
            .handle('ABC123');

        expect(
          outcome,
          equals(
            const DeepLinkJoinOutcome.alreadyInRoom(
              participation: UserGameParticipationEntity(
                gameId: 7,
                participantId: 2,
                gameStatus: 'WAITING',
                team: 'POLICE',
              ),
            ),
          ),
        );
      },
    );

    test(
      '활성 게임이 IN_PROGRESS 이면 해당 게임 participation 을 실어 AlreadyInRoom 반환',
      () async {
        final container = makeContainer(user: loggedInUser);
        addTearDown(container.dispose);
        when(() => joinUseCase.execute('ABC123')).thenThrow(conflict);
        when(() => activeGameUseCase.execute()).thenAnswer(
          (_) async => const UserGameStatusEntity(
            isParticipating: true,
            participationInfo: UserGameParticipationEntity(
              gameId: 9,
              participantId: 5,
              gameStatus: 'IN_PROGRESS',
              team: 'ROBBER',
            ),
          ),
        );

        final outcome = await container
            .read(deepLinkJoinNotifierProvider.notifier)
            .handle('ABC123');

        expect(
          (outcome as AlreadyInRoomOutcome).participation,
          equals(
            const UserGameParticipationEntity(
              gameId: 9,
              participantId: 5,
              gameStatus: 'IN_PROGRESS',
              team: 'ROBBER',
            ),
          ),
        );
      },
    );

    test('활성 게임 조회가 실패하면 participation 없는 AlreadyInRoom 으로 폴백', () async {
      final container = makeContainer(user: loggedInUser);
      addTearDown(container.dispose);
      when(() => joinUseCase.execute('ABC123')).thenThrow(conflict);
      when(() => activeGameUseCase.execute()).thenThrow(
        const ServerException(
          message: 'boom',
          messageKey: 'errorServerInternal',
        ),
      );

      final outcome = await container
          .read(deepLinkJoinNotifierProvider.notifier)
          .handle('ABC123');

      expect(outcome, equals(const DeepLinkJoinOutcome.alreadyInRoom()));
    });

    test(
      '미참가(isParticipating=false)면 participation 없는 AlreadyInRoom 으로 폴백',
      () async {
        final container = makeContainer(user: loggedInUser);
        addTearDown(container.dispose);
        when(() => joinUseCase.execute('ABC123')).thenThrow(conflict);
        when(() => activeGameUseCase.execute()).thenAnswer(
          (_) async => const UserGameStatusEntity(isParticipating: false),
        );

        final outcome = await container
            .read(deepLinkJoinNotifierProvider.notifier)
            .handle('ABC123');

        expect(outcome, equals(const DeepLinkJoinOutcome.alreadyInRoom()));
      },
    );
  });

  test('NetworkException 은 errorNetworkOffline Failure 결과 반환', () async {
    // DioExceptionHandler 는 timeout/connection 오류를 NetworkException 으로 변환한다.
    final container = makeContainer(
      user: const AuthResultEntity(
        userId: 1,
        nickname: 'u',
        isNewUser: false,
        requiresAgreement: false,
      ),
    );
    addTearDown(container.dispose);
    when(() => joinUseCase.execute('ABC123')).thenThrow(
      const NetworkException(
        message: 'network offline',
        messageKey: 'errorNetworkOffline',
      ),
    );

    final outcome = await container
        .read(deepLinkJoinNotifierProvider.notifier)
        .handle('ABC123');

    expect(outcome, isA<FailureOutcome>());
    expect(
      (outcome as FailureOutcome).messageKey,
      equals('errorNetworkOffline'),
    );
  });

  test(
    '인원 초과 ValidationException 은 errorCode=GAME_FULL Failure 결과 반환',
    () async {
      // DioExceptionHandler 는 400 을 ValidationException 으로 변환하며
      // code 필드에 백엔드 errorCode('GAME_FULL')를 전달한다.
      // Notifier 는 errorCode 를 그대로 FailureOutcome 에 실어 UI 에 위임한다.
      final container = makeContainer(
        user: const AuthResultEntity(
          userId: 1,
          nickname: 'u',
          isNewUser: false,
          requiresAgreement: false,
        ),
      );
      addTearDown(container.dispose);
      when(() => joinUseCase.execute('ABC123')).thenThrow(
        const ValidationException(
          message: 'bad request',
          messageKey: 'errorBadRequest',
          code: 'GAME_FULL',
        ),
      );

      final outcome = await container
          .read(deepLinkJoinNotifierProvider.notifier)
          .handle('ABC123');

      expect(outcome, isA<FailureOutcome>());
      expect((outcome as FailureOutcome).errorCode, equals('GAME_FULL'));
      expect(outcome.messageKey, isNull);
    },
  );

  test('AuthNotifier 가 throw 하면 errorServerInternal Failure 결과 반환', () async {
    // authNotifierProvider.future 가 throw 해도 Notifier 가 Outcome 으로 감싸서 반환한다.
    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(() => _ThrowingAuthNotifier()),
        joinGameByInviteUseCaseProvider.overrideWithValue(joinUseCase),
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(deepLinkJoinNotifierProvider.notifier)
        .handle('ABC123');

    expect(outcome, isA<FailureOutcome>());
    expect(
      (outcome as FailureOutcome).messageKey,
      equals('errorServerInternal'),
    );
  });
}

/// AuthNotifier 가짜 구현 — 실제 Firebase/API 호출 없이 고정 사용자 반환
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AuthResultEntity? _user;

  @override
  Future<AuthResultEntity?> build() async => _user;
}

/// AuthNotifier 가짜 구현 — build() 에서 항상 throw
class _ThrowingAuthNotifier extends AuthNotifier {
  @override
  Future<AuthResultEntity?> build() async {
    throw Exception('auth read failed');
  }
}
