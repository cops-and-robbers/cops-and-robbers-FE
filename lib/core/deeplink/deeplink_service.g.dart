// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deeplink_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deeplinkEventsHash() => r'fb8b629dd67ca7e7fd6b4612eae1328cd1aa3e69';

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
