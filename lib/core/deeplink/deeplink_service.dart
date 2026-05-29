import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'deeplink_event.dart';

part 'deeplink_service.g.dart';

/// `app_links` 를 래핑하여 cold start + warm 양쪽의 URI 를 Broadcast Stream 으로 노출.
///
/// 앱 전역 단일 인스턴스 (keepAlive). 여러 listener 가능.
///
/// ## cold-start 중복 처리 방지 (idempotency)
/// Android `singleTop` 액티비티는 앱을 실행시킨 VIEW intent(딥링크 URI)를 보관한다.
/// 최근 앱 목록(recents)에서 재실행하면 OS 가 그 intent 를 다시 전달하고,
/// `getInitialLink()` 는 매 실행마다 동일한 URI 를 반환한다. 가드가 없으면
/// 앱 재실행마다 같은 초대 링크로 자동 재진입/재시도가 발생한다.
/// → 직전 처리한 URI 를 영속 기록해, 동일 URI 의 cold-start 는 스킵한다.
@Riverpod(keepAlive: true)
Stream<DeeplinkEvent> deeplinkEvents(Ref ref) {
  final appLinks = AppLinks();
  final controller = StreamController<DeeplinkEvent>.broadcast();

  // 마지막으로 처리한 딥링크 URI (SharedPreferences 키)
  const lastHandledKey = 'last_handled_deeplink_uri';

  // 처리한 URI 를 기록한다. 이후 cold-start 에서 동일 URI 재전달 시 스킵 판단에 사용.
  Future<void> markHandled(Uri uri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(lastHandledKey, uri.toString());
    } catch (e) {
      // 기록 실패는 치명적이지 않음 — 다음 실행에서 한 번 더 처리될 뿐이므로 무시
      debugPrint('[DeepLink] last-handled 저장 실패(무시): $e');
    }
  }

  // 1. cold start URI 1회 처리 — 직전 처리한 URI 와 같으면 스킵(재실행 재전달).
  Future<void> handleInitial() async {
    try {
      final initial = await appLinks.getInitialLink();
      if (initial == null) return;

      String? last;
      try {
        final prefs = await SharedPreferences.getInstance();
        last = prefs.getString(lastHandledKey);
      } catch (e) {
        // 읽기 실패 시 가드를 포기하고 처리 진행 (자동 진입을 막느니 한 번 더 시도)
        debugPrint('[DeepLink] last-handled 읽기 실패(처리 진행): $e');
      }

      if (initial.toString() == last) {
        // 새 클릭이 아니라 OS 가 보관한 launch intent 재전달 → 자동 재시도 차단
        debugPrint('[DeepLink] cold start 중복 스킵: $initial');
        return;
      }

      await markHandled(initial);
      final event = DeeplinkEvent.fromUri(initial);
      debugPrint('[DeepLink] cold start: $event');
      controller.add(event);
    } catch (e, st) {
      debugPrint('[DeepLink] cold start error: $e\n$st');
    }
  }

  unawaited(handleInitial());

  // 2. warm URI 스트림 구독 — 명시적 클릭이므로 항상 처리하되, marker 를 갱신해
  //    이후 recents 재실행 시 같은 URI cold-start 가 중복 처리되지 않게 한다.
  final sub = appLinks.uriLinkStream.listen(
    (uri) {
      unawaited(markHandled(uri));
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
