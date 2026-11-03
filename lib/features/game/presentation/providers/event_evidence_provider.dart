import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/event_evidence.dart';

part 'event_evidence_provider.g.dart';

/// 증거 사진을 미리 받아 비율을 알려 준다.
class EventEvidenceImageLoader {
  const EventEvidenceImageLoader();

  /// 현장 통신이 나빠도 입장 흐름은 막지 않지만, 너무 오래 기다리지 않고 앱 사진으로 넘어간다.
  static const Duration _timeout = Duration(seconds: 15);

  /// 받으면 가로/세로 비율, 못 받으면 null. 받은 사진은 이미지 캐시에 남는다.
  Future<double?> aspectRatioOf(String url) async {
    final completer = Completer<double?>();
    final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) {
        if (completer.isCompleted) return;
        completer.complete(info.image.width / info.image.height);
      },
      onError: (_, _) {
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    stream.addListener(listener);
    try {
      return await completer.future.timeout(_timeout, onTimeout: () => null);
    } finally {
      stream.removeListener(listener);
    }
  }
}

@Riverpod(keepAlive: true)
EventEvidenceImageLoader eventEvidenceImageLoader(Ref ref) =>
    const EventEvidenceImageLoader();

/// 지금 판의 증거 사진.
///
/// 게임 중에 Remote Config가 바뀌어도 팝업과 보드의 사진이 어긋나지 않도록
/// 게임 화면에 들어갈 때 한 번만 주소를 고정한다 (#657).
@Riverpod(keepAlive: true)
class EventEvidenceNotifier extends _$EventEvidenceNotifier {
  @override
  EventEvidence build() => EventEvidence.bundled;

  /// 입장 때 호출한다. 사진 받기를 기다리지 않아도 판은 진행할 수 있다.
  Future<void> prepare(List<String> urls) async {
    final evidence = EventEvidence.fromUrls(urls);
    state = evidence;
    if (urls.isEmpty) return;

    final loader = ref.read(eventEvidenceImageLoaderProvider);
    final ratios = await Future.wait([
      for (final photo in evidence.photos) loader.aspectRatioOf(photo.url!),
    ]);

    // 그사이 다음 판에 들어갔으면 뒤늦은 결과로 덮어쓰지 않는다
    if (!identical(state, evidence)) return;
    state = EventEvidence(
      photos: [
        for (var i = 0; i < evidence.count; i++)
          ratios[i] == null ? evidence.photos[i].bundled : evidence.photos[i],
      ],
      aspectRatio: ratios.first ?? EventEvidence.bundledAspectRatio,
    );
  }
}
