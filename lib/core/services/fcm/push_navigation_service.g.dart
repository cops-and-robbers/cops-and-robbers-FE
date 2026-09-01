// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_navigation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coldStartPushNavigationHash() =>
    r'b78bbb6179c056a98b69d61d8dc36a793e3f11af';

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
///
/// Copied from [coldStartPushNavigation].
@ProviderFor(coldStartPushNavigation)
final coldStartPushNavigationProvider =
    FutureProvider<PushNavigationEvent?>.internal(
      coldStartPushNavigation,
      name: r'coldStartPushNavigationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$coldStartPushNavigationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ColdStartPushNavigationRef = FutureProviderRef<PushNavigationEvent?>;
String _$pushNavigationEventsHash() =>
    r'9fa6240bd8f15c69c20f3ca5e9bcd52bc8ef9ad2';

/// 앱이 살아 있을 때(백그라운드 → 알림 탭) 도착한 이동 목적지 스트림.
///
/// `deeplinkEvents`의 warm 경로와 같다 — `_LocalizedApp`이 구독해 GoRouter로
/// push한다. 콜드 스타트는 여기로 흐르지 않는다: 그건 SplashPage가
/// [coldStartPushNavigation]으로 단독 처리한다(스플래시의 `go(home)`과 경합하면
/// 목적지가 유실되거나 상세 아래 스플래시가 남는다).
///
/// Copied from [pushNavigationEvents].
@ProviderFor(pushNavigationEvents)
final pushNavigationEventsProvider =
    StreamProvider<PushNavigationEvent>.internal(
      pushNavigationEvents,
      name: r'pushNavigationEventsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pushNavigationEventsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushNavigationEventsRef = StreamProviderRef<PushNavigationEvent>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
