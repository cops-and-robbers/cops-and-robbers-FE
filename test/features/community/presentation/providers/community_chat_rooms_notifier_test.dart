import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

int _fetches(FakeCommunityChatRepository repo) =>
    repo.calls.where((x) => x == 'getRooms').length;

/// 떠나 있다 돌아오는 순간(바텀 탭 복귀·앱 복귀·스코프 전환)에 부르는 갱신이다.
/// 실시간 채널이 없어 이 시점들이 새 메시지를 알 유일한 기회다.
void main() {
  ProviderContainer container(FakeCommunityChatRepository repo) {
    final c = ProviderContainer(
      overrides: [
        communityChatRepositoryProvider.overrideWithValue(repo),
        currentUserIdProvider.overrideWithValue(1),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('refetches_every_time_the_user_comes_back', () async {
    // 유효 시간을 두지 않는다 — 돌아왔는데 낡은 목록을 보는 쪽이 요청 한 건보다
    // 나쁘다. 요청량이 실제로 문제가 되면 그때 가드를 넣는다.
    final repo = FakeCommunityChatRepository();
    final c = container(repo);
    await c.read(communityChatRoomsProvider.future);
    expect(_fetches(repo), 1);

    await c.read(communityChatRoomsProvider.notifier).refreshOnReturn();
    await c.read(communityChatRoomsProvider.notifier).refreshOnReturn();

    expect(_fetches(repo), 3);
  });

  test('does_not_stack_a_second_request_on_the_first_load', () async {
    // 첫 로드가 아직 안 끝났으면 되살릴 목록이 없다 — 그 로드가 알아서 채운다.
    // notifier를 잡는 것만으로 첫 로드가 시작되므로 기준은 1이다.
    final repo = FakeCommunityChatRepository();
    final c = container(repo);

    await c.read(communityChatRoomsProvider.notifier).refreshOnReturn();

    expect(_fetches(repo), 1);
  });
}
