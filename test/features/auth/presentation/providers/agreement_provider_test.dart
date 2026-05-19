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
  // build() 진입 시 호출되는 GET /api/user/agreements의 가짜 응답.
  // 기본값은 모두 false — 기존 테스트는 "체크박스가 비어있는 상태에서 시작"을 가정.
  AgreementStatusEntity getAgreementsResult = const AgreementStatusEntity(
    termsOfService: false,
    privacyPolicy: false,
    locationTerms: false,
    marketing: false,
  );
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
  Future<AgreementStatusEntity> getAgreements() async => getAgreementsResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// build() 안의 `Future.microtask(_loadInitial)`이 완료될 때까지 대기한다.
///
/// 초기 로드는 다음과 같은 비동기 chain을 거친다:
///   1) Future.microtask로 _loadInitial 진입
///   2) await repo.getAgreements()   (fake도 async라 microtask 한 번 더)
///   3) state.copyWith(...) 적용
///
/// nested microtask가 모두 비워지도록 여러 iteration yield한다.
Future<void> _flushInitialLoad() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

ProviderContainer _makeContainer({
  required Connectivity connectivity,
  required UserRepository userRepository,
}) {
  final container = ProviderContainer(
    overrides: [
      connectivityServiceProvider.overrideWith(
        (ref) => ConnectivityService(connectivity),
      ),
      userRepositoryProvider.overrideWith((ref) => userRepository),
    ],
  );
  // @riverpod는 기본 autoDispose. read만 하면 read 사이 dispose되어
  // state(copyWith로 갱신한 값)가 초기화될 수 있다. 명시적 listener를 두어
  // 테스트 전반에 걸쳐 Notifier 인스턴스가 살아있도록 한다.
  // container.dispose()로 listener도 함께 정리되므로 subscription은 보관 불필요.
  container.listen<AgreementState>(agreementNotifierProvider, (_, _) {});
  return container;
}

void main() {
  group('AgreementNotifier — 초기 상태', () {
    test('서버 응답이 모두 false면 초기 체크박스도 모두 false이다', () async {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      container.read(agreementNotifierProvider);
      await _flushInitialLoad();

      final state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, false);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
      expect(state.hasAllRequired, false);
      expect(state.isLoading, false);
      expect(state.isSubmitting, false);
    });

    test('서버에 이미 동의된 약관은 체크된 상태로 초기화된다', () async {
      // 시나리오: 백엔드가 위치정보 약관만 v2로 갱신하여 locationTerms=false로 내려보냄.
      // 사용자는 이미 동의한 이용약관·개인정보는 체크된 상태로 봐야 한다.
      final fakeRepo = _FakeUserRepository()
        ..getAgreementsResult = const AgreementStatusEntity(
          termsOfService: true,
          privacyPolicy: true,
          locationTerms: false,
          marketing: true,
        );
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: fakeRepo,
      );
      addTearDown(container.dispose);

      container.read(agreementNotifierProvider);
      await _flushInitialLoad();

      final state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, true);
      expect(state.privacyPolicy, true);
      expect(state.locationTerms, false);
      expect(state.marketing, true);
      expect(state.hasAllRequired, false);
      expect(state.isLoading, false);
    });

    test('초기 로드 실패 시 모두 미체크 + isLoading=false로 폴백한다', () async {
      final fakeRepo = _FakeUserRepository();
      // getAgreements()가 예외를 던지도록 override (subclass 없이 손쉽게 익명 fake로).
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _ThrowingUserRepository(fakeRepo),
      );
      addTearDown(container.dispose);

      container.read(agreementNotifierProvider);
      await _flushInitialLoad();

      final state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, false);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
      expect(state.isLoading, false);
    });
  });

  group('AgreementNotifier — toggle', () {
    test('toggleTerms는 termsOfService만 뒤집는다', () async {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      await _flushInitialLoad();
      notifier.toggleTerms();

      final state = container.read(agreementNotifierProvider);
      expect(state.termsOfService, true);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
    });

    test(
      'toggleAll(true)는 4개를 모두 true로, toggleAll(false)는 모두 false로 만든다',
      () async {
        final container = _makeContainer(
          connectivity: _FakeConnectivity(true),
          userRepository: _FakeUserRepository(),
        );
        addTearDown(container.dispose);

        final notifier = container.read(agreementNotifierProvider.notifier);
        await _flushInitialLoad();
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
      },
    );

    test('hasAllRequired는 필수 3종이 모두 true일 때만 true이다', () async {
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      await _flushInitialLoad();
      notifier.toggleTerms();
      notifier.togglePrivacy();

      var state = container.read(agreementNotifierProvider);
      expect(state.hasAllRequired, false);

      notifier.toggleLocation();
      state = container.read(agreementNotifierProvider);
      expect(state.hasAllRequired, true);
    });

    test('초기 로드 중에는 toggle이 무시된다', () {
      // _flushInitialLoad()를 일부러 호출하지 않아 isLoading=true 상태에서 토글 시도.
      final container = _makeContainer(
        connectivity: _FakeConnectivity(true),
        userRepository: _FakeUserRepository(),
      );
      addTearDown(container.dispose);

      final notifier = container.read(agreementNotifierProvider.notifier);
      notifier.toggleTerms();
      notifier.toggleAll(true);

      final state = container.read(agreementNotifierProvider);
      expect(state.isLoading, true);
      expect(state.termsOfService, false);
      expect(state.privacyPolicy, false);
      expect(state.locationTerms, false);
      expect(state.marketing, false);
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
      await _flushInitialLoad();
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
      await _flushInitialLoad();
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
      await _flushInitialLoad();
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
      await _flushInitialLoad();
      notifier.toggleAll(true);

      final result = await notifier.submit();

      expect(result, AgreementSubmitResult.failure);
      expect(notifier.lastError, isA<NetworkException>());
      expect(container.read(agreementNotifierProvider).isSubmitting, false);
    });
  });
}

/// getAgreements()만 예외를 던지는 fake (초기 로드 실패 폴백 테스트용)
class _ThrowingUserRepository implements UserRepository {
  _ThrowingUserRepository(this._delegate);

  final UserRepository _delegate;

  @override
  Future<AgreementStatusEntity> getAgreements() async {
    throw const ServerException(message: 'simulated');
  }

  @override
  Future<void> updateAgreements({required bool marketing}) =>
      _delegate.updateAgreements(marketing: marketing);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
