import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_messaging_service.dart';
import 'push_navigation_event.dart';

part 'push_navigation_service.g.dart';

/// 콜드 스타트(앱 종료 상태)에서 앱을 실행시킨 푸시 알림의 이동 목적지.
///
/// `coldStartDeeplink`과 같은 자리다 — SplashPage가 이 프로브를 보고 홈 대신
/// 목적지로 간다. keepAlive라 1회만 계산·캐시된다.
///
/// 딥링크와 달리 dedup(SharedPreferences)이 없다. `getInitialMessage()`는
/// firebase_messaging 플러그인이 한 번 소비하면 저장소에서 지워
/// (`consumedInitialMessages`·`removeFirebaseMessage`, 16.x 실측) recents 재실행
/// 때 같은 메시지가 다시 오지 않는다.
///
/// 값은 [FirebaseMessagingService.init]이 `runApp()` 전에 채운다 — 플러그인이
/// `getInitialMessage()`를 두 번째 호출부터 null로 주므로 여기서 다시 읽을 수 없다.
@Riverpod(keepAlive: true)
Future<PushNavigationEvent?> coldStartPushNavigation(Ref ref) async {
  return FirebaseMessagingService.instance().coldStartNavigation;
}

/// 앱이 살아 있을 때(백그라운드 → 알림 탭) 도착한 이동 목적지 스트림.
///
/// `deeplinkEvents`의 warm 경로와 같다 — `_LocalizedApp`이 구독해 GoRouter로
/// push한다. 콜드 스타트는 여기로 흐르지 않는다: 그건 SplashPage가
/// [coldStartPushNavigation]으로 단독 처리한다(스플래시의 `go(home)`과 경합하면
/// 목적지가 유실되거나 상세 아래 스플래시가 남는다).
@Riverpod(keepAlive: true)
Stream<PushNavigationEvent> pushNavigationEvents(Ref ref) {
  return FirebaseMessagingService.navigationTapStream;
}
