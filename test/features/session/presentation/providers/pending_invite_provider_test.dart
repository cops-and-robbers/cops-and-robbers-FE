import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cops_and_robbers/features/session/presentation/providers/pending_invite_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('초기 상태는 null', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(pendingInviteProvider.future);
    expect(result, isNull);
  });

  test('save 호출시 코드가 저장되고 build 가 그 값을 반환한다', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pendingInviteProvider.notifier).save('ABC123');

    final result = await container.read(pendingInviteProvider.future);
    expect(result, equals('ABC123'));
  });

  test('clear 호출시 저장된 코드가 삭제된다', () async {
    SharedPreferences.setMockInitialValues({'pending_invite_code': 'ABC123'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(pendingInviteProvider.notifier).clear();

    final result = await container.read(pendingInviteProvider.future);
    expect(result, isNull);
  });
}
