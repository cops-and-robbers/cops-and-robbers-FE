import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'deeplink_event.dart';

part 'deeplink_service.g.dart';

/// `app_links` 를 래핑하여 cold start + warm 양쪽의 URI 를 Broadcast Stream 으로 노출.
///
/// 앱 전역 단일 인스턴스 (keepAlive). 여러 listener 가능.
@Riverpod(keepAlive: true)
Stream<DeeplinkEvent> deeplinkEvents(Ref ref) {
  final appLinks = AppLinks();
  final controller = StreamController<DeeplinkEvent>.broadcast();

  // 1. cold start URI 1회 처리
  Future<void> handleInitial() async {
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        final event = DeeplinkEvent.fromUri(initial);
        debugPrint('[DeepLink] cold start: $event');
        controller.add(event);
      }
    } catch (e, st) {
      debugPrint('[DeepLink] cold start error: $e\n$st');
    }
  }

  unawaited(handleInitial());

  // 2. warm URI 스트림 구독
  final sub = appLinks.uriLinkStream.listen(
    (uri) {
      final event = DeeplinkEvent.fromUri(uri);
      debugPrint('[DeepLink] warm: $event');
      controller.add(event);
    },
    onError: (e, st) {
      debugPrint('[DeepLink] stream error: $e\n$st');
    },
  );

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
}
