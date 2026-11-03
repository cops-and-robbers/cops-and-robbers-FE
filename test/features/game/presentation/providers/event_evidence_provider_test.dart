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
    test('third_slot_falls_back_to_second_bundled_photo', () async {
      final container = _container({'a': 1.0, 'b': 1.0, 'c': null});

      await container.read(eventEvidenceNotifierProvider.notifier).prepare([
        'a',
        'b',
        'c',
      ]);

      final photos = container.read(eventEvidenceNotifierProvider).photos;
      expect(photos, hasLength(3));
      expect(photos[2].url, isNull);
      expect(photos[2].assetPath, 'assets/events/evidence2.png');
    });

    test('uses_bundled_photos_when_no_url_is_set', () async {
      final container = _container({});

      await container
          .read(eventEvidenceNotifierProvider.notifier)
          .prepare(const []);

      expect(
        container.read(eventEvidenceNotifierProvider),
        same(EventEvidence.bundled),
      );
    });

    test('uses_first_photo_ratio_when_all_photos_load', () async {
      final container = _container({'a': 1.5, 'b': 1.5});

      await container.read(eventEvidenceNotifierProvider.notifier).prepare([
        'a',
        'b',
      ]);

      final evidence = container.read(eventEvidenceNotifierProvider);
      expect(evidence.aspectRatio, 1.5);
      expect(evidence.photos.map((p) => p.url), ['a', 'b']);
    });

    test('keeps_one_slot_when_one_url_is_set', () async {
      final container = _container({'a': 1.0});

      await container.read(eventEvidenceNotifierProvider.notifier).prepare([
        'a',
      ]);

      expect(container.read(eventEvidenceNotifierProvider).count, 1);
    });

    test('falls_back_to_bundled_photo_only_for_slot_that_failed', () async {
      final container = _container({'a': 1.0, 'b': null});

      await container.read(eventEvidenceNotifierProvider.notifier).prepare([
        'a',
        'b',
      ]);

      final photos = container.read(eventEvidenceNotifierProvider).photos;
      expect(photos[0].url, 'a');
      expect(photos[1].url, isNull);
      expect(photos[1].assetPath, 'assets/events/evidence2.png');
    });

    test('uses_bundled_ratio_when_first_photo_fails', () async {
      final container = _container({'a': null, 'b': 1.0});

      await container.read(eventEvidenceNotifierProvider.notifier).prepare([
        'a',
        'b',
      ]);

      expect(
        container.read(eventEvidenceNotifierProvider).aspectRatio,
        EventEvidence.bundledAspectRatio,
      );
    });

    test('ignores_late_result_when_next_game_already_prepared', () async {
      final slow = Completer<double?>();
      final container = _container({'old': slow.future, 'new': 1.0});
      final notifier = container.read(eventEvidenceNotifierProvider.notifier);

      final first = notifier.prepare(['old']);
      await notifier.prepare(['new']);
      slow.complete(0.5);
      await first;

      final evidence = container.read(eventEvidenceNotifierProvider);
      expect(evidence.photos.single.url, 'new');
      expect(evidence.aspectRatio, 1.0);
    });
  });
}
