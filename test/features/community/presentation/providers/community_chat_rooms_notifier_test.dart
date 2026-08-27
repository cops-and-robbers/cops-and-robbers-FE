import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

/// 떠나 있다 돌아오는 순간(바텀 탭 복귀·앱 복귀)에 부르는 갱신이다.
/// 실시간 채널이 없어 이 시점들이 새 메시지를 알 유일한 기회다.
void main() {
  late DateTime now;
  ProviderContainer container(FakeCommunityChatRepository repo) {
    final c = ProviderContainer(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(1),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => now = DateTime(2026, 8, 28, 10));

  test(
    'refetches_when_the_cached_list_is_older_than_the_stale_window',
    () async {
      final repo = FakeCommunityChatRepository();
      final c = container(repo);
      await c.read(communityChatRoomsProvider.future);
      expect(repo.calls.where((x) => x == 'getRooms').length, 1);

      now = now.add(const Duration(minutes: 4));
      await c.read(communityChatRoomsProvider.notifier).refreshIfStale();

      expect(repo.calls.where((x) => x == 'getRooms').length, 2);
    },
  );

  test('leaves_the_list_alone_when_it_is_still_fresh', () async {
    // 탭을 빠르게 오갈 때마다 다시 받으면 요청만 늘고 화면은 그대로다.
    final repo = FakeCommunityChatRepository();
    final c = container(repo);
    await c.read(communityChatRoomsProvider.future);

    now = now.add(const Duration(seconds: 30));
    await c.read(communityChatRoomsProvider.notifier).refreshIfStale();

    expect(repo.calls.where((x) => x == 'getRooms').length, 1);
  });

  test('does_not_stack_a_second_request_on_the_first_load', () async {
    // 첫 로드가 아직 안 끝났으면 되살릴 목록이 없다 — 그 로드가 알아서 채운다.
    // notifier를 잡는 것만으로 첫 로드가 시작되므로 기준은 1이다.
    final repo = FakeCommunityChatRepository();
    final c = container(repo);

    await c.read(communityChatRoomsProvider.notifier).refreshIfStale();

    expect(repo.calls.where((x) => x == 'getRooms').length, 1);
  });
}
