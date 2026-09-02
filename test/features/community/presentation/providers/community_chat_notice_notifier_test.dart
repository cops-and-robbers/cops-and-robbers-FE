import 'package:cops_and_robbers/core/services/lifecycle/lifecycle_provider.dart';
import 'package:cops_and_robbers/features/auth/presentation/providers/auth_provider.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_event.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_chat_notice_entity.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_notice_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_rooms_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_chat_socket_provider.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_chat_fakes.dart';

const _postId = 42;

final _notice = CommunityChatNoticeEntity(
  id: 9,
  writerId: 7,
  writerNickname: '경도매우러버',
  writerProfileIcon: 3,
  content: '오늘 오후 7시 정문에서 만나요!',
  createdAt: DateTime(2026, 9, 19, 13, 24),
  updatedAt: DateTime(2026, 9, 19, 13, 24),
);

ProviderContainer _container(FakeCommunityChatRepository repo) {
  final c = ProviderContainer(
    overrides: [
      communityChatRepositoryProvider.overrideWithValue(repo),
      // 공지 provider가 소켓 이벤트를 듣는다 — 소켓 provider가 세워지면서
      // 로그인·앱 수명 provider까지 끌고 오므로 경계를 여기서 끊는다.
      currentUserIdProvider.overrideWithValue(1),
      lifecycleStateProvider.overrideWith(
        (ref) => const Stream<AppLifecycleState>.empty(),
      ),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('CommunityChatNoticeNotifier', () {
    test('exposes_no_notice_when_room_has_none', () async {
      // 서버는 없음을 200 + 필드 null로 준다 — 에러가 아니라 빈 상태다.
      final repo = FakeCommunityChatRepository();
      final c = _container(repo);

      expect(await c.read(communityChatNoticeProvider(_postId).future), isNull);
    });

    test('exposes_the_notice_when_room_has_one', () async {
      final repo = FakeCommunityChatRepository()..notice = _notice;
      final c = _container(repo);

      final notice = await c.read(communityChatNoticeProvider(_postId).future);

      expect(notice?.content, '오늘 오후 7시 정문에서 만나요!');
      expect(notice?.writerNickname, '경도매우러버');
    });

    test('shows_the_saved_notice_right_after_registering', () async {
      final repo = FakeCommunityChatRepository();
      final c = _container(repo);
      await c.read(communityChatNoticeProvider(_postId).future);

      await c
          .read(communityChatNoticeProvider(_postId).notifier)
          .register('경도 마치고 뒷풀이가 있습니다!');

      expect(
        c.read(communityChatNoticeProvider(_postId)).requireValue?.content,
        '경도 마치고 뒷풀이가 있습니다!',
      );
    });

    test('replaces_the_content_when_edited', () async {
      final repo = FakeCommunityChatRepository()..notice = _notice;
      final c = _container(repo);
      await c.read(communityChatNoticeProvider(_postId).future);

      await c
          .read(communityChatNoticeProvider(_postId).notifier)
          .edit('장소가 후문으로 변경되었습니다!');

      expect(
        c.read(communityChatNoticeProvider(_postId)).requireValue?.content,
        '장소가 후문으로 변경되었습니다!',
      );
      expect(repo.calls, contains('updateNotice:$_postId'));
    });

    test('leaves_the_room_without_a_notice_when_deleted', () async {
      final repo = FakeCommunityChatRepository()..notice = _notice;
      final c = _container(repo);
      await c.read(communityChatNoticeProvider(_postId).future);

      await c.read(communityChatNoticeProvider(_postId).notifier).delete();

      expect(c.read(communityChatNoticeProvider(_postId)).requireValue, isNull);
    });

    test('refetches_when_the_socket_says_this_room_changed', () async {
      // 배너 payload에는 프로필 아이콘도 등록 시각도 없다 — 신호만 받고 내용은
      // 서버에서 다시 받는다.
      final repo = FakeCommunityChatRepository();
      final c = _container(repo);
      c.read(communityChatSocketProvider);
      // autoDispose다 — 청취자가 없으면 읽자마자 버려져 소켓 이벤트를 못 받는다.
      c.listen(communityChatNoticeProvider(_postId), (_, _) {});
      await c.read(communityChatNoticeProvider(_postId).future);
      expect(c.read(communityChatNoticeProvider(_postId)).requireValue, isNull);

      repo.notice = _notice;
      repo.emit(const CommunityChatEvent.noticeChanged(_postId));
      await Future<void>.delayed(Duration.zero);

      expect(
        c.read(communityChatNoticeProvider(_postId)).requireValue?.content,
        '오늘 오후 7시 정문에서 만나요!',
      );
    });

    test('ignores_notice_changes_from_another_room', () async {
      final repo = FakeCommunityChatRepository();
      final c = _container(repo);
      c.read(communityChatSocketProvider);
      // autoDispose다 — 청취자가 없으면 읽자마자 버려져 소켓 이벤트를 못 받는다.
      c.listen(communityChatNoticeProvider(_postId), (_, _) {});
      await c.read(communityChatNoticeProvider(_postId).future);
      final before = repo.calls.where((x) => x.startsWith('getNotice')).length;

      repo.emit(const CommunityChatEvent.noticeChanged(_postId + 1));
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls.where((x) => x.startsWith('getNotice')).length, before);
    });
  });
}
