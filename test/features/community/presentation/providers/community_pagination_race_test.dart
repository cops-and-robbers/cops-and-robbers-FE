import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/core/network/dio_client.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_notification_provider.dart';
import 'package:cops_and_robbers/features/community/presentation/providers/community_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// HTTP 응답 순서만 제어한다. provider → repository → Retrofit 파싱은 실물이다.
class _PendingRequest {
  _PendingRequest(this.options);
  final RequestOptions options;
  final response = Completer<ResponseBody>();

  void complete(List<int> ids, {Object? next, bool fail = false}) {
    final notifications = options.path.endsWith('/notifications');
    final content = [
      for (final id in ids)
        if (notifications)
          {
            'id': id,
            'type': 'COMMENT',
            'communityPostId': 1,
            'postTitle': '알림 $id',
            'content': '댓글',
            'read': false,
            'createdAt': '2026-09-26T12:00:00+09:00',
          }
        else
          {
            'id': id,
            'writerId': 7,
            'writerNickname': '테스트',
            'title': '모집글 $id',
            'content': '본문',
            'meetingAt': '2027-01-01T18:00:00+09:00',
            'createdAt': '2026-09-26T12:00:00+09:00',
            'location': {
              'latitude': 37.5,
              'longitude': 127.0,
              'placeName': '공원',
            },
            'maxParticipants': 10,
            'status': 'RECRUITING',
            'likeCount': 0,
            'scrapCount': 0,
            'isLikedByRequester': false,
            'isScrappedByRequester': false,
          },
    ];
    response.complete(
      ResponseBody.fromString(
        jsonEncode({
          'content': content,
          if (notifications) ...{
            'nextCursor': next,
            'hasNext': next != null,
          } else
            'cursor': {'nextCursor': next, 'hasNext': next != null},
        }),
        fail ? 500 : 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }
}

class _Http implements HttpClientAdapter {
  final _requests = StreamController<_PendingRequest>();
  late final _iterator = StreamIterator(_requests.stream);

  Future<_PendingRequest> next() async {
    expect(await _iterator.moveNext(), isTrue);
    return _iterator.current;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final request = _PendingRequest(options);
    _requests.add(request);
    return request.response.future;
  }

  @override
  void close({bool force = false}) {
    unawaited(_iterator.cancel());
    unawaited(_requests.close());
  }
}

ProviderContainer _container(_Http http) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
    ..httpClientAdapter = http
    ..transformer = SyncTransformer();
  addTearDown(dio.close);
  final container = ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(dio),
      currentPositionResolverProvider.overrideWith(
        (ref) =>
            () async => null,
      ),
      deviceCountryCodeProvider.overrideWithValue('KR'),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

final _feed = communityFeedNotifierProvider(
  CommunityScope.all,
  CommunitySortOption.latest,
  null,
);

void main() {
  test(
    'feed_waits_for_refresh_before_accepting_more_scroll_requests',
    () async {
      final http = _Http();
      final c = _container(http);
      final sub = c.listen(_feed, (_, _) {});
      addTearDown(sub.close);
      final initial = c.read(_feed.future);
      (await http.next()).complete([3, 2], next: 'older');
      await initial;
      final notifier = c.read(_feed.notifier);
      final refresh = notifier.refresh();
      final request = await http.next();
      final before = c.read(_feed);
      final attempted = notifier.loadMore();
      expect(c.read(_feed), before);
      await attempted;
      request.complete([5, 4], next: 'fresh');
      await refresh;
      expect(c.read(_feed).requireValue.items.map((p) => p.id), [5, 4]);
    },
  );

  for (final remove in [false, true]) {
    for (final fail in [false, true]) {
      test(
        'feed_preserves_${remove ? 'deletion' : 'edit'}_and_finishes_loading_'
        'when_pending_page_${fail ? 'fails' : 'succeeds'}',
        () async {
          final http = _Http();
          final c = _container(http);
          final initial = c.read(_feed.future);
          (await http.next()).complete([3, 2], next: 'older');
          await initial;
          final notifier = c.read(_feed.notifier);
          final pending = notifier.loadMore();
          final request = await http.next();
          final changed = c
              .read(_feed)
              .requireValue
              .items
              .first
              .copyWith(status: CommunityPostStatus.completed);
          if (remove) {
            notifier.removePost(3);
          } else {
            notifier.replacePost(changed);
          }
          final edited = c.read(_feed).requireValue;
          final result = fail
              ? expectLater(pending, throwsA(isA<AppException>()))
              : pending;
          request.complete([1], fail: fail);
          await result;
          final state = c.read(_feed).requireValue;
          expect(state.isLoadingMore, isFalse);
          expect(state.items.take(edited.items.length), edited.items);
          expect(state.items.map((p) => p.id), [
            if (!remove) 3,
            2,
            if (!fail) 1,
          ]);
          expect((
            state.nextCursor,
            state.hasMore,
          ), fail ? ('older', true) : (null, false));
          if (fail) {
            final retry = notifier.loadMore();
            (await http.next()).complete([1]);
            await retry;
            expect(c.read(_feed).requireValue.items.map((p) => p.id), [
              if (!remove) 3,
              2,
              1,
            ]);
          }
        },
      );
    }
  }

  for (final fail in [false, true]) {
    test('feed_keeps_refreshed_page_loading_when_obsolete_page_'
        '${fail ? 'fails' : 'succeeds'}', () async {
      final http = _Http();
      final c = _container(http);
      final sub = c.listen(_feed, (_, _) {});
      addTearDown(sub.close);
      final initial = c.read(_feed.future);
      (await http.next()).complete([3, 2], next: 'older');
      await initial;
      final notifier = c.read(_feed.notifier);
      final old = notifier.loadMore();
      final oldRequest = await http.next();
      final refresh = notifier.refresh();
      (await http.next()).complete([5, 4], next: 'fresh');
      await refresh;
      final next = notifier.loadMore();
      final nextRequest = await http.next();
      final before = c.read(_feed).requireValue;
      oldRequest.complete([1], fail: fail);
      await old;
      expect(c.read(_feed).requireValue, before);
      nextRequest.complete([3, 2, 1]);
      await next;
      expect(c.read(_feed).requireValue.items.map((p) => p.id), [
        5,
        4,
        3,
        2,
        1,
      ]);
      expect(c.read(_feed).requireValue.isLoadingMore, isFalse);
    });
  }

  for (final refreshFirst in [false, true]) {
    for (final fail in [false, true]) {
      test('notifications_keep_contiguous_pages_when_refresh_'
          '${refreshFirst ? 'precedes' : 'follows'}_old_page_'
          '${fail ? 'failure' : 'success'}', () async {
        final http = _Http();
        final c = _container(http);
        final provider = communityNotificationNotifierProvider;
        final sub = c.listen(provider, (_, _) {});
        addTearDown(sub.close);
        final initial = c.read(provider.future);
        (await http.next()).complete([4, 3], next: 3);
        await initial;
        final notifier = c.read(provider.notifier);
        final old = notifier.loadMore();
        final oldRequest = await http.next();
        final oldResult = fail && !refreshFirst
            ? expectLater(old, throwsA(isA<AppException>()))
            : old;
        final refresh = notifier.refresh();
        final refreshRequest = await http.next();
        if (!refreshFirst) {
          oldRequest.complete([2, 1], fail: fail);
          await oldResult;
        }
        refreshRequest.complete([5, 4], next: 4);
        await refresh;
        final next = notifier.loadMore();
        final nextRequest = await http.next();
        final before = c.read(provider).requireValue;
        expect(nextRequest.options.queryParameters['cursor'], 4);
        if (refreshFirst) {
          oldRequest.complete([2, 1], fail: fail);
          await oldResult;
        }
        expect(c.read(provider).requireValue, before);
        nextRequest.complete([3, 2, 1]);
        await next;
        final state = c.read(provider).requireValue;
        expect(state.items.map((n) => n.id), [5, 4, 3, 2, 1]);
        expect(
          (state.nextCursor, state.hasMore, state.isLoadingMore),
          (null, false, false),
        );
      });
    }
  }

  test('notifications_can_finish_pagination_when_refresh_fails', () async {
    final http = _Http();
    final c = _container(http);
    final provider = communityNotificationNotifierProvider;
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    final initial = c.read(provider.future);
    (await http.next()).complete([4, 3], next: 3);
    await initial;
    final notifier = c.read(provider.notifier);
    final page = notifier.loadMore();
    final pageRequest = await http.next();
    final refresh = expectLater(
      notifier.refresh(),
      throwsA(isA<AppException>()),
    );
    (await http.next()).complete([], fail: true);
    await refresh;
    pageRequest.complete([2, 1]);
    await page;
    final state = c.read(provider).requireValue;
    expect(state.items.map((n) => n.id), [4, 3, 2, 1]);
    expect(state.isLoadingMore, isFalse);
  });
  for (final fail in [false, true]) {
    test('notifications_keep_latest_refresh_when_older_refresh_'
        '${fail ? 'fails' : 'succeeds'}', () async {
      final http = _Http();
      final c = _container(http);
      final provider = communityNotificationNotifierProvider;
      final sub = c.listen(provider, (_, _) {});
      addTearDown(sub.close);
      final initial = c.read(provider.future);
      (await http.next()).complete([3, 2], next: 2);
      await initial;
      final notifier = c.read(provider.notifier);
      final old = notifier.refresh();
      final oldRequest = await http.next();
      final fresh = notifier.refresh();
      (await http.next()).complete([5, 4], next: 4);
      await fresh;
      final before = c.read(provider).requireValue;
      oldRequest.complete([4, 3], next: 3, fail: fail);
      await old;
      expect(c.read(provider).requireValue, before);
    });

    for (final notifications in [false, true]) {
      test('${notifications ? 'notifications' : 'feed'}_ignores_page_'
          '${fail ? 'failure' : 'success'}_after_disposal', () async {
        final http = _Http();
        final c = _container(http);
        if (notifications) {
          final provider = communityNotificationNotifierProvider;
          final sub = c.listen(provider, (_, _) {});
          final initial = c.read(provider.future);
          (await http.next()).complete([3, 2], next: 2);
          await initial;
          final old = c.read(provider.notifier).loadMore();
          final request = await http.next();
          sub.close();
          c.invalidate(provider);
          request.complete([1], fail: fail);
          await old;
        } else {
          final initial = c.read(_feed.future);
          (await http.next()).complete([3, 2], next: 'older');
          await initial;
          final old = c.read(_feed.notifier).loadMore();
          final request = await http.next();
          c.invalidate(_feed);
          request.complete([1], fail: fail);
          await old;
        }
      });
    }
  }
}
