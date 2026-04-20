import 'package:cops_and_robbers/features/auth/domain/entities/auth_result_entity.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthNotifier.markNeedsAgreement', () {
    test('requiresAgreement: false → true로 전환된다', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
            () => _TestAuthNotifier(
              const AuthResultEntity(
                userId: 1,
                nickname: '테스트',
                isNewUser: false,
                requiresAgreement: false,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 초기 상태가 AsyncValue.data로 세팅될 때까지 대기
      await container.read(authNotifierProvider.future);
      expect(
        container.read(authNotifierProvider).value?.requiresAgreement,
        isFalse,
      );

      container.read(authNotifierProvider.notifier).markNeedsAgreement();

      expect(
        container.read(authNotifierProvider).value?.requiresAgreement,
        isTrue,
      );
    });

    test('이미 requiresAgreement: true이면 state 값이 그대로 유지된다', () async {
      const initial = AuthResultEntity(
        userId: 2,
        nickname: '이미미동의',
        isNewUser: false,
        requiresAgreement: true,
      );
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _TestAuthNotifier(initial)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      final before = container.read(authNotifierProvider).value;

      container.read(authNotifierProvider.notifier).markNeedsAgreement();

      final after = container.read(authNotifierProvider).value;
      expect(after, same(before));
    });

    test('state가 null이면 무시된다 (예외 없음)', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _TestAuthNotifier(null)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      expect(container.read(authNotifierProvider).value, isNull);

      // 예외 없이 호출 가능해야 함
      container.read(authNotifierProvider.notifier).markNeedsAgreement();

      expect(container.read(authNotifierProvider).value, isNull);
    });
  });
}

/// 실제 Firebase/백엔드 의존성 없이 초기 상태만 세팅하는 테스트용 Notifier.
class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(this._initial);

  final AuthResultEntity? _initial;

  @override
  Future<AuthResultEntity?> build() async => _initial;
}
