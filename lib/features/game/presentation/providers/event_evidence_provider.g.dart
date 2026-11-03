// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_evidence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventEvidenceImageLoaderHash() =>
    r'2d4fc91a6d1bedc0ef6c285bbb94aedc602f1c39';

/// See also [eventEvidenceImageLoader].
@ProviderFor(eventEvidenceImageLoader)
final eventEvidenceImageLoaderProvider =
    Provider<EventEvidenceImageLoader>.internal(
      eventEvidenceImageLoader,
      name: r'eventEvidenceImageLoaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$eventEvidenceImageLoaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventEvidenceImageLoaderRef = ProviderRef<EventEvidenceImageLoader>;
String _$eventEvidenceNotifierHash() =>
    r'e30d5702ef3033d8b7324e4bb9bd2ec939cd1b2b';

/// 지금 판의 증거 사진.
///
/// 게임 중에 Remote Config가 바뀌어도 팝업과 보드의 사진이 어긋나지 않도록
/// 게임 화면에 들어갈 때 한 번만 주소를 고정한다 (#657).
///
/// Copied from [EventEvidenceNotifier].
@ProviderFor(EventEvidenceNotifier)
final eventEvidenceNotifierProvider =
    NotifierProvider<EventEvidenceNotifier, EventEvidence>.internal(
      EventEvidenceNotifier.new,
      name: r'eventEvidenceNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$eventEvidenceNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EventEvidenceNotifier = Notifier<EventEvidence>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
