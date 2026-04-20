import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/connectivity_service.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/agreement_provider.dart';
import 'package:cops_and_robbers/features/user/domain/entities/agreement_status_entity.dart';
import 'package:cops_and_robbers/features/user/domain/repositories/user_repository.dart';
import 'package:cops_and_robbers/features/user/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeConnectivity implements Connectivity {
  _FakeConnectivity(this.connected);
  bool connected;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      connected ? [ConnectivityResult.wifi] : [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  bool? lastMarketing;
  Object? errorToThrow;
  int callCount = 0;

  @override
  Future<void> updateAgreements({required bool marketing}) async {
    callCount++;
    if (errorToThrow != null) throw errorToThrow!;
    lastMarketing = marketing;
  }

  @override
  Future<AgreementStatusEntity> getAgreements() => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderContainer _makeContainer({
  required Connectivity connectivity,
  required UserRepository userRepository,
}) {
  return ProviderContainer(
    overrides: [
      connectivityServiceProvider.overrideWith(
        (ref) => ConnectivityService(connectivity),
      ),
      userRepositoryProvider.overrideWith((ref) => userRepository),
    ],
  );
}

void main() {
  group('AgreementNotifier — 초기 상태', () {
    test('모든 체크박스는 초기에 false이다', () {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, false);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
      expect(state.hasAllRequired, false);
      expect(state.isSubmitting, false);
    });
  });

  group('AgreementNotifier — toggle', () {
    test('toggleTerms는 termsOfService만 뒤집는다', () {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleTerms();

      final state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, true);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
    });

    test('toggleAll(true)는 4개를 모두 true로, toggleAll(false)는 모두 false로 만든다', () {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleAll(true);

      var state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, true);
      expect(state.privacyPolicy, true);
      expect(state.locationTerms, true);
      expect(state.marketing, true);
      expect(state.allAgreed, true);

      notifier.toggleAll(false);
      state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, false);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
    });

    test('hasAllRequired는 필수 3종이 모두 true일 때만 true이다', () {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleTerms();
      notifier.togglePrivacy();

      var state = container.read(agreementNotifierProvider);
      expect(state.hasAllRequired, false);

      notifier.toggleLocation();
      state = container.read(agreementNotifierProvider);
      expect(state.hasAllRequired, true);
    });
  });

  group('AgreementNotifier.submit', () {
    test('네트워크 미연결이면 저장소 호출 없이 종료한다', () async {
      final fakeRepo = _FakeUserRepository();
      final container = _makeContainer(
        connectivity: _FakeConnectivity(false),
        userRepository: fakeRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleAll(true);

      final result = await notifier.submit();

      expect(result, AgreementSubmitResult.offline);
      expect(fakeRepo.callCount, 0);
      expect(container.read(agreementNotifierProvider).isSubmitting, false);
    });

    test('필수 미체크면 저장소 호출 없이 종료한다', () async {
      final fakeRepo = _FakeUserRepository();
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: fakeRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleTerms();
      notifier.togglePrivacy();

      final result = await notifier.submit();

      expect(result, AgreementSubmitResult.missingRequired);
      expect(fakeRepo.callCount, 0);
    });

    test('성공 시 marketing 값만 Repository에 전달된다', () async {
      final fakeRepo = _FakeUserRepository();
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: fakeRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleAll(true);

      final result = await notifier.submit();

      expect(result, AgreementSubmitResult.success);
      expect(fakeRepo.callCount, 1);
      expect(fakeRepo.lastMarketing, true);
    });

    test('실패 시 isSubmitting이 false로 복원되고 에러를 반환한다', () async {
      final fakeRepo = _FakeUserRepository()
        ..errorToThrow = const NetworkException(message: 'net');
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: fakeRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleAll(true);

      final result = await notifier.submit();

      expect(result, AgreementSubmitResult.failure);
      expect(notifier.lastError, isA<NetworkException>());
      expect(container.read(agreementNotifierProvider).isSubmitting, false);
    });
  });
}
