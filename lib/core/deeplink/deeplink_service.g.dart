// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deeplink_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coldStartDeeplinkUriHash() =>
    r'9e8390614cbe7f68fd0801c440032399205fccad';

/// 콜드 스타트로 앱을 실행시킨 초기 딥링크를 1회 평가한다.
///
/// `getInitialLink()` 를 단 한 번 읽고 dedup(직전 처리 URI 비교)까지 적용해,
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
/// 매번 같은 URI 를 반환하므로, 직전 처리 URI 와 같으면 스킵한다.
/// 콜드 스타트를 일으킨 initial link URI (없으면 null). 1회만 읽어 캐시한다.
///
/// [coldStartDeeplink] 의 재료이면서, [deeplinkEvents] 가 initial link 의 스트림
/// 재전달(echo)을 걸러낼 때 비교 기준으로도 쓴다.
///
/// Copied from [coldStartDeeplinkUri].
@ProviderFor(coldStartDeeplinkUri)
final coldStartDeeplinkUriProvider = FutureProvider<Uri?>.internal(
  coldStartDeeplinkUri,
  name: r'coldStartDeeplinkUriProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$coldStartDeeplinkUriHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ColdStartDeeplinkUriRef = FutureProviderRef<Uri?>;
String _$coldStartDeeplinkHash() => r'46bab0711f981a4f9760beaeb92a98448dde3177';

/// See also [coldStartDeeplink].
@ProviderFor(coldStartDeeplink)
final coldStartDeeplinkProvider = FutureProvider<DeeplinkEvent?>.internal(
  coldStartDeeplink,
  name: r'coldStartDeeplinkProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$coldStartDeeplinkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ColdStartDeeplinkRef = FutureProviderRef<DeeplinkEvent?>;
String _$deeplinkEventsHash() => r'7b6e0e9171e40d51e02e665dc507e1b24c2b7217';

/// `app_links` 를 래핑하여 cold start + warm 양쪽의 URI 를 Broadcast Stream 으로 노출.
///
/// 앱 전역 단일 인스턴스 (keepAlive). 여러 listener 가능.
/// 콜드 스타트는 [coldStartDeeplink] 의 결과(dedup 적용 완료)를 emit 하고,
/// warm(앱 실행 중 클릭)은 항상 처리하되 last-handled 를 갱신한다.
///
/// Copied from [deeplinkEvents].
@ProviderFor(deeplinkEvents)
final deeplinkEventsProvider = StreamProvider<DeeplinkEvent>.internal(
  deeplinkEvents,
  name: r'deeplinkEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deeplinkEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeeplinkEventsRef = StreamProviderRef<DeeplinkEvent>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
