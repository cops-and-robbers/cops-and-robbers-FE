import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_member_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

const _postId = 42;

ProviderContainer _container(FakeCommunityChatRepository repo) {
  final c = ProviderContainer(
    overrides: [communityChatRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('CommunityChatMembersNotifier', () {
    test('exposes_the_server_notification_state', () async {
      final repo = FakeCommunityChatRepository()
        ..members = const CommunityChatMembersEntity(
          notificationEnabled: false,
          members: [],
        );
      final c = _container(repo);

      final s = await c.read(
        communityChatMembersNotifierProvider(_postId).future,
      );

      expect(s.notificationEnabled, isFalse);
    });

    test('flips_notification_and_saves_it', () async {
      final repo = FakeCommunityChatRepository();
      final c = _container(repo);
      await c.read(communityChatMembersNotifierProvider(_postId).future);

      await c
          .read(communityChatMembersNotifierProvider(_postId).notifier)
          .toggleNotification();

      expect(
        c
            .read(communityChatMembersNotifierProvider(_postId))
            .requireValue
            .notificationEnabled,
        isFalse,
      );
      expect(repo.calls, contains('setNotification:$_postId:false'));
    });

    test('reverts_the_flip_when_saving_fails', () async {
      final repo = FakeCommunityChatRepository()
        ..setNotificationError = const ServerException(
          message: 'fail',
          messageKey: 'errorTemporaryRetry',
        );
      final c = _container(repo);
      await c.read(communityChatMembersNotifierProvider(_postId).future);

      await expectLater(
        c
            .read(communityChatMembersNotifierProvider(_postId).notifier)
            .toggleNotification(),
        throwsA(isA<AppException>()),
      );

      expect(
        c
            .read(communityChatMembersNotifierProvider(_postId))
            .requireValue
            .notificationEnabled,
        isTrue,
      );
    });
  });
}
