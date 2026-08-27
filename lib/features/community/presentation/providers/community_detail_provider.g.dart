// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityInteractionRepositoryHash() =>
    r'c194d99c3d1a43cacce149744c426e01e96d5ebf';

/// 상호작용 Repository Provider — 목데이터 교체 지점
///
/// ponytail: 좋아요·스크랩은 응답에 카운트·내 반응 필드가 없어 메모리 목을
/// 돌려준다. 댓글은 실서버로 옮겨 갔다(`communityCommentRepositoryProvider`).
/// API가 열리면 여기서 돌려주는 구현체만 실제 구현으로 바꾼다. 화면·Notifier는
/// 인터페이스만 알고 있어 손댈 곳이 없다.
///
/// `keepAlive`인 이유: 목이 상태를 메모리에 들고 있어서, 상세를 나갔다 들어올
/// 때마다 새로 만들면 방금 누른 좋아요가 풀린다. 실제 구현으로 바꾸면
/// 서버가 상태를 갖게 되므로 이 옵션은 떼도 된다.
///
/// Copied from [communityInteractionRepository].
@ProviderFor(communityInteractionRepository)
final communityInteractionRepositoryProvider =
    Provider<CommunityInteractionRepository>.internal(
      communityInteractionRepository,
      name: r'communityInteractionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityInteractionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityInteractionRepositoryRef =
    ProviderRef<CommunityInteractionRepository>;
String _$communityDetailNotifierHash() =>
    r'1f370315e187adc146060a2651e0461950e9ec6b';

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
/// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
/// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
///
/// Copied from [CommunityDetailNotifier].
@ProviderFor(CommunityDetailNotifier)
const communityDetailNotifierProvider = CommunityDetailNotifierFamily();

/// 모집글 상세 상태 관리 Notifier
///
/// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
/// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
///
/// Copied from [CommunityDetailNotifier].
class CommunityDetailNotifierFamily
    extends Family<AsyncValue<CommunityDetailState>> {
  /// 모집글 상세 상태 관리 Notifier
  ///
  /// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
  /// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
  ///
  /// Copied from [CommunityDetailNotifier].
  const CommunityDetailNotifierFamily();

  /// 모집글 상세 상태 관리 Notifier
  ///
  /// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
  /// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
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
/// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
/// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
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
  /// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
  /// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
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
