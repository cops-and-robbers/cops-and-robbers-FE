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
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) {
          completer.complete(info.image.width / info.image.height);
        }
        info.dispose();
        stream.removeListener(listener);
      },
      onError: (_, _) {
        if (!completer.isCompleted) completer.complete(null);
        stream.removeListener(listener);
      },
    );
    // 시간이 지나도 듣기를 멈추지 않는다. 듣는 쪽 없이 받기에 실패하면
    // Flutter가 처리되지 않은 오류로 보고한다.
    stream.addListener(listener);
    return completer.future.timeout(_timeout, onTimeout: () => null);
  }
}

@Riverpod(keepAlive: true)
EventEvidenceImageLoader eventEvidenceImageLoader(Ref ref) =>
    const EventEvidenceImageLoader();

/// 지금 판의 증거 사진.
///
/// 게임 중에 Remote Config가 바뀌어도 팝업과 보드의 사진이 어긋나지 않도록
/// 게임마다 한 번만 주소를 고정한다 (#657). 위치 권한을 다시 허용하면 게임 연결이
/// 한 번 더 도는데, 그때 다시 읽으면 같은 판에서 사진이 바뀐다.
@Riverpod(keepAlive: true)
class EventEvidenceNotifier extends _$EventEvidenceNotifier {
  @override
  EventEvidence build() => EventEvidence.bundled;

  int? _preparedGameId;

  /// 입장 때 호출한다. 사진 받기를 기다리지 않아도 판은 진행할 수 있다.
  Future<void> prepare(int gameId, List<String> urls) async {
    if (_preparedGameId == gameId) return;
    _preparedGameId = gameId;

    final evidence = EventEvidence.fromUrls(urls);
    state = evidence;
    if (urls.isEmpty) return;

    final loader = ref.read(eventEvidenceImageLoaderProvider);
    final ratios = await Future.wait([
      for (final photo in evidence.photos) loader.aspectRatioOf(photo.url!),
    ]);

    // 그사이 다음 판에 들어갔으면 뒤늦은 결과로 덮어쓰지 않는다
    if (!identical(state, evidence)) return;
    // 지금 못 받아도 주소는 버리지 않는다. 통신이 돌아오면 화면에서 다시 받는다.
    // 사진들은 비율이 같으니 1번을 못 받았어도 받은 사진의 비율을 쓴다.
    state = EventEvidence(
      photos: evidence.photos,
      aspectRatio:
          ratios.whereType<double>().firstOrNull ??
          EventEvidence.bundledAspectRatio,
    );
  }
}
