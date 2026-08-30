import 'dart:async';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_comment_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_comment_repository.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_detail_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../community_fakes.dart';

const _postId = 7;

CommunityPostEntity _post({CommunityPostNotificationSetting? setting}) =>
    CommunityPostEntity(
      id: _postId,
      writerId: 1,
      title: '같이 하실 분',
      content: '본문',
      meetingAt: DateTime(2026, 9, 10, 18),
      latitude: 37.5502,
      longitude: 127.0736,
      maxParticipants: 10,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime(2026, 8, 20),
      likeCount: 0,
      isLiked: false,
      scrapCount: 0,
      isScrapped: false,
      notificationSetting: setting,
    );

const _on = CommunityPostNotificationSetting(
  commentNotificationsEnabled: true,
  replyNotificationsEnabled: false,
);
const _off = CommunityPostNotificationSetting(
  commentNotificationsEnabled: false,
  replyNotificationsEnabled: false,
);
const _bothOn = CommunityPostNotificationSetting(
  commentNotificationsEnabled: true,
  replyNotificationsEnabled: true,
);

/// 서버 응답이 언제 도착할지 테스트가 정한다 — "응답 전에 뒤집혔는지"를 보려면
/// 응답을 붙들고 있어야 한다. Repository 경계에서 자른다(페이지 테스트와 같은 선).
class _FakeRepository
    with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs {
  _FakeRepository(this.post);

  final CommunityPostEntity post;
  final gate = Completer<void>();
  ({int postId, bool comment, bool reply})? lastSetting;

  @override
  Future<CommunityPostEntity> getPost(int postId) async => post;

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) async => post.copyWith(status: status, notificationSetting: null);

  @override
  Future<void> updateNotificationSetting({
    required int postId,
    required bool commentNotificationsEnabled,
    required bool replyNotificationsEnabled,
  }) async {
    lastSetting = (
      postId: postId,
      comment: commentNotificationsEnabled,
      reply: replyNotificationsEnabled,
    );
    await gate.future;
  }
}

class _FakeCommentRepository implements CommunityCommentRepository {
  _FakeCommentRepository([this.comments = const []]);

  final List<CommunityCommentEntity> comments;
  final gate = Completer<void>();
  ({int commentId, bool enabled})? lastReplySetting;

  @override
  Future<List<CommunityCommentEntity>> getComments(int postId) async =>
      comments;

  @override
  Future<void> updateReplyNotification({
    required int commentId,
    required bool enabled,
  }) async {
    lastReplySetting = (commentId: commentId, enabled: enabled);
    await gate.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

ProviderContainer _container(
  _FakeRepository repo, [
  _FakeCommentRepository? comments,
]) {
  final container = ProviderContainer(
    overrides: [
      communityRepositoryProvider.overrideWithValue(repo),
      communityCommentRepositoryProvider.overrideWithValue(
        comments ?? _FakeCommentRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

CommunityPostNotificationSetting? _settingOf(ProviderContainer container) =>
    container
        .read(communityDetailNotifierProvider(_postId))
        .valueOrNull
        ?.post
        .notificationSetting;

CommunityCommentEntity _comment(
  int id, {
  int? parentId,
  bool replyNotificationsEnabled = true,
  List<CommunityCommentEntity> replies = const [],
}) => CommunityCommentEntity(
  id: id,
  parentId: parentId,
  writerId: 1,
  writerNickname: '나',
  writerProfileIconId: 1,
  content: '댓글 $id',
  createdAt: DateTime(2026, 8, 27),
  replyNotificationsEnabled: replyNotificationsEnabled,
  replies: replies,
);

bool? _replyFlagOf(ProviderContainer container, int commentId) {
  final matches = container
      .read(communityDetailNotifierProvider(_postId))
      .valueOrNull
      ?.comments
      .where((c) => c.id == commentId);
  if (matches == null || matches.isEmpty) return null;
  return matches.first.replyNotificationsEnabled;
}

void main() {
  group('CommunityDetailNotifier.toggleNotification', () {
    test(
      'turns_both_flags_off_before_the_server_answers_and_sends_them',
      () async {
        final repo = _FakeRepository(_post(setting: _on));
        final container = _container(repo);
        await container.read(communityDetailNotifierProvider(_postId).future);

        final pending = container
            .read(communityDetailNotifierProvider(_postId).notifier)
            .toggleNotification();

        expect(_settingOf(container), _off);
        expect(repo.lastSetting, (
          postId: _postId,
          comment: false,
          reply: false,
        ));

        repo.gate.complete();
        await pending;

        expect(_settingOf(container), _off);
      },
    );

    // 남의 글 기본값(둘 다 off)에서 켜면 댓글·답글을 같이 켠다 — 요청이 둘 다
    // required라 하나만 보낼 수 없다.
    test('turns_both_flags_on_when_the_post_was_muted', () async {
      final repo = _FakeRepository(_post(setting: _off));
      final container = _container(repo);
      await container.read(communityDetailNotifierProvider(_postId).future);

      final pending = container
          .read(communityDetailNotifierProvider(_postId).notifier)
          .toggleNotification();

      expect(_settingOf(container), _bothOn);
      expect(repo.lastSetting, (postId: _postId, comment: true, reply: true));

      repo.gate.complete();
      await pending;
    });

    test('rolls_back_and_rethrows_when_the_server_rejects', () async {
      final repo = _FakeRepository(_post(setting: _on));
      final container = _container(repo);
      await container.read(communityDetailNotifierProvider(_postId).future);

      final pending = container
          .read(communityDetailNotifierProvider(_postId).notifier)
          .toggleNotification();
      expect(_settingOf(container), _off);

      repo.gate.completeError(
        const ServerException(message: 'x', messageKey: 'y'),
      );

      await expectLater(pending, throwsA(isA<AppException>()));
      expect(_settingOf(container), _on);
    });
  });

  group('CommunityDetailNotifier.toggleStatus', () {
    test(
      'keeps_notification_setting_when_the_status_response_omits_it',
      () async {
        final repo = _FakeRepository(_post(setting: _on));
        final container = _container(repo);
        await container.read(communityDetailNotifierProvider(_postId).future);

        await container
            .read(communityDetailNotifierProvider(_postId).notifier)
            .toggleStatus();

        expect(_settingOf(container), _on);
      },
    );

    test('keeps_notification_setting_when_an_edited_post_omits_it', () async {
      final repo = _FakeRepository(_post(setting: _on));
      final container = _container(repo);
      await container.read(communityDetailNotifierProvider(_postId).future);

      container
          .read(communityDetailNotifierProvider(_postId).notifier)
          .applyUpdatedPost(_post(setting: null).copyWith(title: '고친 제목'));

      expect(_settingOf(container), _on);
    });
  });

  group('CommunityDetailNotifier.toggleReplyNotification', () {
    test(
      'flips_the_comment_before_the_server_answers_and_sends_the_new_value',
      () async {
        final comments = _FakeCommentRepository([_comment(5)]);
        final container = _container(_FakeRepository(_post()), comments);
        await container.read(communityDetailNotifierProvider(_postId).future);

        final pending = container
            .read(communityDetailNotifierProvider(_postId).notifier)
            .toggleReplyNotification(5);

        expect(_replyFlagOf(container, 5), isFalse);
        expect(comments.lastReplySetting, (commentId: 5, enabled: false));

        comments.gate.complete();
        await pending;

        expect(_replyFlagOf(container, 5), isFalse);
      },
    );

    test(
      'rolls_the_comment_back_and_rethrows_when_the_server_rejects',
      () async {
        final comments = _FakeCommentRepository([_comment(5)]);
        final container = _container(_FakeRepository(_post()), comments);
        await container.read(communityDetailNotifierProvider(_postId).future);

        final pending = container
            .read(communityDetailNotifierProvider(_postId).notifier)
            .toggleReplyNotification(5);
        expect(_replyFlagOf(container, 5), isFalse);

        comments.gate.completeError(
          const ServerException(message: 'x', messageKey: 'y'),
        );

        await expectLater(pending, throwsA(isA<AppException>()));
        expect(_replyFlagOf(container, 5), isTrue);
      },
    );

    // 답글(2depth)엔 메뉴 항목이 없어 여기 올 일이 없지만, 와도 서버를 부르지 않는다.
    test('ignores_ids_that_are_not_top_level_comments', () async {
      final comments = _FakeCommentRepository([
        _comment(5, replies: [_comment(6, parentId: 5)]),
      ]);
      final container = _container(_FakeRepository(_post()), comments);
      await container.read(communityDetailNotifierProvider(_postId).future);

      await container
          .read(communityDetailNotifierProvider(_postId).notifier)
          .toggleReplyNotification(6);

      expect(comments.lastReplySetting, isNull);
    });
  });
}
