import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'deeplink_event.dart';

part 'deeplink_service.g.dart';

/// 마지막으로 처리한 딥링크 URI 를 기록하는 SharedPreferences 키.
///
/// cold-start 중복 처리 방지(dedup)에 쓰이며, [coldStartDeeplink] 와
/// [deeplinkEvents] 의 warm 처리가 같은 키를 공유한다.
const _lastHandledDeeplinkKey = 'last_handled_deeplink_uri';

/// 콜드 스타트로 앱을 실행시킨 초기 딥링크를 1회 평가한다.
///
/// `getInitialLink()` 를 단 한 번 읽고 dedup(직전 처리 URI 비교, 초대에만)까지 적용해,
/// "이번 콜드 스타트에서 실제로 처리할 [DeeplinkEvent]"(없으면 null)를 반환한다.
///
/// ## 왜 별도 단일 소스인가 (cold-start 네비게이션 경합 방지)
/// [deeplinkEvents] 의 콜드 스타트 emit 과 SplashPage 의 "네비게이션 양보" 판단이
/// 이 프로바이더 하나를 공유한다. 두 곳이 "처리함/안 함"에 대해 **같은 결론**을 갖게
/// 만들어, splash 가 양보(home 이동 생략)했는데 딥링크 흐름은 dedup 으로 스킵해서
/// 화면이 splash 에 갇히는 불일치를 원천 차단한다.
///
/// keepAlive 라 1회만 계산·캐시되므로 getInitialLink/dedup 도 정확히 1회만 수행된다.
///
/// ## cold-start 중복 처리 방지 (idempotency)
/// Android `singleTop` 액티비티는 앱을 실행시킨 VIEW intent(딥링크 URI)를 보관한다.
/// recents 에서 재실행하면 OS 가 그 intent 를 다시 전달하고 `getInitialLink()` 가
/// 매번 같은 URI 를 반환하므로, 직전 처리 URI 와 같으면 스킵한다. 이 스킵은 초대에만
/// 적용한다 — 모집글은 URI 가 글마다 고정이라 같은 링크 재탭이 정상 사용이다 (#560).
/// 콜드 스타트를 일으킨 initial link URI (없으면 null). 1회만 읽어 캐시한다.
///
/// [coldStartDeeplink] 의 재료이면서, [deeplinkEvents] 가 initial link 의 스트림
/// 재전달(echo)을 걸러낼 때 비교 기준으로도 쓴다.
@Riverpod(keepAlive: true)
Future<Uri?> coldStartDeeplinkUri(Ref ref) async {
  try {
    return await AppLinks().getInitialLink();
  } catch (e, st) {
    debugPrint('[DeepLink] cold start 초기 링크 읽기 실패: $e\n$st');
    return null;
  }
}

@Riverpod(keepAlive: true)
Future<DeeplinkEvent?> coldStartDeeplink(Ref ref) async {
  final initial = await ref.read(coldStartDeeplinkUriProvider.future);
  if (initial == null) return null;

  final event = DeeplinkEvent.fromUri(initial);

  // dedup 은 초대에만 적용한다 (#560). join 은 참가 API 부작용이 있어 recents
  // 재실행의 재참가를 막아야 하지만, 모집글 링크는 글 하나에 URI 가 고정이라
  // 같은 링크를 다시 여는 것이 정상 사용이다 — 여기서 걸러 버리면 두 번째
  // 탭부터 매번 홈으로 떨어진다. 글 열람은 두 번 열려도 무해하다.
  if (event is InviteJoinEvent) {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_lastHandledDeeplinkKey) == initial.toString()) {
        // 새 클릭이 아니라 OS 가 보관한 launch intent 재전달 → 자동 재진입 차단
        debugPrint('[DeepLink] cold start 중복 스킵: $initial');
        return null;
      }
      await prefs.setString(_lastHandledDeeplinkKey, initial.toString());
    } catch (e) {
      // prefs 실패 시 dedup 을 포기하고 처리 진행 (자동 진입을 막느니 한 번 더 시도)
      debugPrint('[DeepLink] cold start last-handled 접근 실패(처리 진행): $e');
    }
  }

  debugPrint('[DeepLink] cold start: $event');
  return event;
}

/// `app_links` 를 래핑하여 cold start + warm 양쪽의 URI 를 Broadcast Stream 으로 노출.
///
/// 앱 전역 단일 인스턴스 (keepAlive). 여러 listener 가능.
/// 콜드 스타트는 [coldStartDeeplink] 의 결과(초대 dedup 적용 완료)를 emit 하고,
/// warm(앱 실행 중 클릭)은 항상 처리하되 last-handled 를 갱신한다.
@Riverpod(keepAlive: true)
Stream<DeeplinkEvent> deeplinkEvents(Ref ref) {
  final appLinks = AppLinks();
  final controller = StreamController<DeeplinkEvent>.broadcast();

  // warm 에서 처리한 URI 를 기록 — 이후 recents 재실행 cold-start 의 중복 처리 방지.
  Future<void> markHandled(Uri uri) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastHandledDeeplinkKey, uri.toString());
    } catch (e) {
      // 기록 실패는 치명적이지 않음 — 다음 실행에서 한 번 더 처리될 뿐이므로 무시
      debugPrint('[DeepLink] last-handled 저장 실패(무시): $e');
    }
  }

  // 1. cold start — 공유 프로브가 dedup 까지 끝낸 이벤트를 emit.
  //    SplashPage 도 동일 프로브를 보고 네비게이션을 양보하므로 결론이 일치한다.
  Future<void> emitColdStart() async {
    try {
      final event = await ref.read(coldStartDeeplinkProvider.future);
      if (event == null || controller.isClosed) return;
      // 모집글 이벤트의 콜드 스타트는 SplashPage 가 단독 처리한다 (푸시 알림과
      // 같은 구조). 여기서 emit 하면 splash 의 go 와 경합해 목적지가 유실된다.
      if (event is CommunityPostEvent) return;
      controller.add(event);
    } catch (e, st) {
      debugPrint('[DeepLink] cold start emit error: $e\n$st');
    }
  }

  unawaited(emitColdStart());

  // 2. warm URI 스트림 구독 — 명시적 클릭이므로 항상 처리한다.
  //
  // 단, app_links 는 콜드 스타트를 일으킨 initial link 를 스트림에도 한 번 더
  // 흘린다(실측). 그 첫 재전달은 cold 경로([coldStartDeeplink]·SplashPage)가
  // 담당하므로 걸러낸다 — 안 거르면 같은 링크가 cold 와 warm 양쪽에서 이중
  // 처리된다 (모집글이면 상세가 두 번 쌓인다).
  var initialEchoSkipped = false;

  final sub = appLinks.uriLinkStream.listen(
    (uri) {
      unawaited(() async {
        if (!initialEchoSkipped) {
          final initial = await ref.read(coldStartDeeplinkUriProvider.future);
          if (initial != null && uri.toString() == initial.toString()) {
            initialEchoSkipped = true;
            debugPrint('[DeepLink] initial link 스트림 재전달 스킵: $uri');
            return;
          }
        }
        unawaited(markHandled(uri));
        final event = DeeplinkEvent.fromUri(uri);
        debugPrint('[DeepLink] warm: $event');
        if (!controller.isClosed) controller.add(event);
      }());
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
