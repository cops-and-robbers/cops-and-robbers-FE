// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deeplink_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deeplinkEventsHash() => r'a768c5c59d6bcc10554970a830aa3bfeec04f65c';

/// `app_links` 를 래핑하여 cold start + warm 양쪽의 URI 를 Broadcast Stream 으로 노출.
///
/// 앱 전역 단일 인스턴스 (keepAlive). 여러 listener 가능.
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
