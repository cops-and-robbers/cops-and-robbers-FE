import 'dart:async';

import 'package:cops_and_robbers/features/game/domain/event_evidence.dart';
import 'package:cops_and_robbers/features/game/presentation/providers/event_evidence_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 네트워크 경계만 대신한다. 주소별로 받은 결과를 정해 둔다.
class _FakeLoader extends EventEvidenceImageLoader {
  _FakeLoader(this.results);

  final Map<String, FutureOr<double?>> results;

  @override
  Future<double?> aspectRatioOf(String url) async => results[url];
}

ProviderContainer _container(Map<String, FutureOr<double?>> results) {
  final container = ProviderContainer(
    overrides: [
      eventEvidenceImageLoaderProvider.overrideWithValue(_FakeLoader(results)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('eventEvidenceUrlsFrom', () {
    test('returns_three_photos_when_all_urls_exist', () {
      expect(eventEvidenceUrlsFrom(['a', 'b', 'c']), ['a', 'b', 'c']);
    });

    test('returns_one_photo_when_second_url_is_empty', () {
      expect(eventEvidenceUrlsFrom(['a', ' ', 'c']), ['a']);
    });

    test('returns_nothing_when_first_url_is_empty', () {
      expect(eventEvidenceUrlsFrom(['', 'b', '']), isEmpty);
    });
  });

  group('EventEvidence', () {
    test('last_photo_repeats_when_arrests_exceed_photo_count', () {
      final evidence = EventEvidence.fromUrls(['a']);

      expect(evidence.photoFor(1).url, 'a');
      expect(evidence.photoFor(3).url, 'a');
      expect(EventEvidence.bundled.photoFor(0).assetPath, contains('1.png'));
      expect(EventEvidence.bundled.photoFor(5).assetPath, contains('2.png'));
    });
  });

  group('EventEvidenceNotifier', () {
    EventEvidenceNotifier notifierOf(ProviderContainer c) =>
        c.read(eventEvidenceNotifierProvider.notifier);

    test('uses_bundled_photos_when_no_url_is_set', () async {
      final container = _container({});

      await notifierOf(container).prepare(1, const []);

      expect(
        container.read(eventEvidenceNotifierProvider),
        same(EventEvidence.bundled),
      );
    });

    test('uses_first_photo_ratio_when_all_photos_load', () async {
      final container = _container({'a': 1.5, 'b': 1.5});

      await notifierOf(container).prepare(1, ['a', 'b']);

      final evidence = container.read(eventEvidenceNotifierProvider);
      expect(evidence.aspectRatio, 1.5);
      expect(evidence.photos.map((p) => p.url), ['a', 'b']);
    });

    test('keeps_one_slot_when_one_url_is_set', () async {
      final container = _container({'a': 1.0});

      await notifierOf(container).prepare(1, ['a']);

      expect(container.read(eventEvidenceNotifierProvider).count, 1);
    });

    test('keeps_url_so_screen_can_retry_when_photo_fails_to_load', () async {
      final container = _container({'a': 1.0, 'b': null});

      await notifierOf(container).prepare(1, ['a', 'b']);

      final photos = container.read(eventEvidenceNotifierProvider).photos;
      expect(photos[1].url, 'b');
      expect(photos[1].assetPath, 'assets/events/evidence2.png');
    });

    test('third_slot_falls_back_to_second_bundled_photo', () async {
      final container = _container({'a': 1.0, 'b': 1.0, 'c': null});

      await notifierOf(container).prepare(1, ['a', 'b', 'c']);

      final photos = container.read(eventEvidenceNotifierProvider).photos;
      expect(photos, hasLength(3));
      expect(photos[2].assetPath, 'assets/events/evidence2.png');
    });

    test('uses_loaded_photo_ratio_when_first_photo_fails', () async {
      final container = _container({'a': null, 'b': 16 / 9, 'c': 16 / 9});

      await notifierOf(container).prepare(1, ['a', 'b', 'c']);

      expect(container.read(eventEvidenceNotifierProvider).aspectRatio, 16 / 9);
    });

    test('uses_bundled_ratio_when_no_photo_loads', () async {
      final container = _container({'a': null});

      await notifierOf(container).prepare(1, ['a']);

      expect(
        container.read(eventEvidenceNotifierProvider).aspectRatio,
        EventEvidence.bundledAspectRatio,
      );
    });

    test('keeps_first_photos_when_same_game_prepares_again', () async {
      final container = _container({'old': 1.0, 'new': 1.0});
      final notifier = notifierOf(container);

      await notifier.prepare(1, ['old']);
      await notifier.prepare(1, ['new']);

      expect(
        container.read(eventEvidenceNotifierProvider).photos.single.url,
        'old',
      );
    });

    test('ignores_late_result_when_next_game_already_prepared', () async {
      final slow = Completer<double?>();
      final container = _container({'old': slow.future, 'new': 1.0});
      final notifier = notifierOf(container);

      final first = notifier.prepare(1, ['old']);
      await notifier.prepare(2, ['new']);
      slow.complete(0.5);
      await first;

      final evidence = container.read(eventEvidenceNotifierProvider);
      expect(evidence.photos.single.url, 'new');
      expect(evidence.aspectRatio, 1.0);
    });
  });
}
