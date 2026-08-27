// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityDetailNotifierHash() =>
    r'35edfd681a8e8a7772c8b2a50543e809591d60b7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CommunityDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CommunityDetailState> {
  late final int postId;

  FutureOr<CommunityDetailState> build(int postId);
}

/// 모집글 상세 상태 관리 Notifier
///
/// Copied from [CommunityDetailNotifier].
@ProviderFor(CommunityDetailNotifier)
const communityDetailNotifierProvider = CommunityDetailNotifierFamily();

/// 모집글 상세 상태 관리 Notifier
///
/// Copied from [CommunityDetailNotifier].
class CommunityDetailNotifierFamily
    extends Family<AsyncValue<CommunityDetailState>> {
  /// 모집글 상세 상태 관리 Notifier
  ///
  /// Copied from [CommunityDetailNotifier].
  const CommunityDetailNotifierFamily();

  /// 모집글 상세 상태 관리 Notifier
  ///
  /// Copied from [CommunityDetailNotifier].
  CommunityDetailNotifierProvider call(int postId) {
    return CommunityDetailNotifierProvider(postId);
  }

  @override
  CommunityDetailNotifierProvider getProviderOverride(
    covariant CommunityDetailNotifierProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityDetailNotifierProvider';
}

/// 모집글 상세 상태 관리 Notifier
///
/// Copied from [CommunityDetailNotifier].
class CommunityDetailNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CommunityDetailNotifier,
          CommunityDetailState
        > {
  /// 모집글 상세 상태 관리 Notifier
  ///
  /// Copied from [CommunityDetailNotifier].
  CommunityDetailNotifierProvider(int postId)
    : this._internal(
        () => CommunityDetailNotifier()..postId = postId,
        from: communityDetailNotifierProvider,
        name: r'communityDetailNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityDetailNotifierHash,
        dependencies: CommunityDetailNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommunityDetailNotifierFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommunityDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final int postId;

  @override
  FutureOr<CommunityDetailState> runNotifierBuild(
    covariant CommunityDetailNotifier notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(CommunityDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityDetailNotifierProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    CommunityDetailNotifier,
    CommunityDetailState
  >
  createElement() {
    return _CommunityDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityDetailNotifierProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CommunityDetailState> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommunityDetailNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CommunityDetailNotifier,
          CommunityDetailState
        >
    with CommunityDetailNotifierRef {
  _CommunityDetailNotifierProviderElement(super.provider);

  @override
  int get postId => (origin as CommunityDetailNotifierProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
