// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_chat_rooms_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityChatRepositoryHash() =>
    r'af9491ce99359b03fe704c5a5b545e1d9fc3e13a';

/// 채팅 저장소 Provider — REST(Retrofit) + STOMP를 합친 실서버 구현
///
/// 소켓은 이 provider의 수명을 따른다. 방을 오갈 때마다 새로 만들지 않는 이유는
/// 계약 01 — 소켓은 앱당 하나다(DEC-0026).
///
/// Copied from [communityChatRepository].
@ProviderFor(communityChatRepository)
final communityChatRepositoryProvider =
    Provider<CommunityChatRepository>.internal(
      communityChatRepository,
      name: r'communityChatRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityChatRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityChatRepositoryRef = ProviderRef<CommunityChatRepository>;
String _$communityChatMembersHash() =>
    r'bb5d13cdcc86d72d88b9882478bfe2c84bc14927';

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

/// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// Copied from [communityChatMembers].
@ProviderFor(communityChatMembers)
const communityChatMembersProvider = CommunityChatMembersFamily();

/// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// Copied from [communityChatMembers].
class CommunityChatMembersFamily
    extends Family<AsyncValue<List<CommunityChatMemberEntity>>> {
  /// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// Copied from [communityChatMembers].
  const CommunityChatMembersFamily();

  /// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// Copied from [communityChatMembers].
  CommunityChatMembersProvider call(int postId) {
    return CommunityChatMembersProvider(postId);
  }

  @override
  CommunityChatMembersProvider getProviderOverride(
    covariant CommunityChatMembersProvider provider,
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
  String? get name => r'communityChatMembersProvider';
}

/// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// Copied from [communityChatMembers].
class CommunityChatMembersProvider
    extends AutoDisposeFutureProvider<List<CommunityChatMemberEntity>> {
  /// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// Copied from [communityChatMembers].
  CommunityChatMembersProvider(int postId)
    : this._internal(
        (ref) => communityChatMembers(ref as CommunityChatMembersRef, postId),
        from: communityChatMembersProvider,
        name: r'communityChatMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityChatMembersHash,
        dependencies: CommunityChatMembersFamily._dependencies,
        allTransitiveDependencies:
            CommunityChatMembersFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommunityChatMembersProvider._internal(
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
  Override overrideWith(
    FutureOr<List<CommunityChatMemberEntity>> Function(
      CommunityChatMembersRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityChatMembersProvider._internal(
        (ref) => create(ref as CommunityChatMembersRef),
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
  AutoDisposeFutureProviderElement<List<CommunityChatMemberEntity>>
  createElement() {
    return _CommunityChatMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityChatMembersProvider && other.postId == postId;
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
mixin CommunityChatMembersRef
    on AutoDisposeFutureProviderRef<List<CommunityChatMemberEntity>> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommunityChatMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<CommunityChatMemberEntity>>
    with CommunityChatMembersRef {
  _CommunityChatMembersProviderElement(super.provider);

  @override
  int get postId => (origin as CommunityChatMembersProvider).postId;
}

String _$communityChatPostHash() => r'e514fda22ff2e0b5cb253f572b06c2822082741b';

/// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
///
/// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
/// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
/// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
///
/// Copied from [communityChatPost].
@ProviderFor(communityChatPost)
const communityChatPostProvider = CommunityChatPostFamily();

/// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
///
/// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
/// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
/// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
///
/// Copied from [communityChatPost].
class CommunityChatPostFamily extends Family<AsyncValue<CommunityPostEntity>> {
  /// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
  ///
  /// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
  /// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
  /// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
  ///
  /// Copied from [communityChatPost].
  const CommunityChatPostFamily();

  /// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
  ///
  /// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
  /// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
  /// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
  ///
  /// Copied from [communityChatPost].
  CommunityChatPostProvider call(int postId) {
    return CommunityChatPostProvider(postId);
  }

  @override
  CommunityChatPostProvider getProviderOverride(
    covariant CommunityChatPostProvider provider,
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
  String? get name => r'communityChatPostProvider';
}

/// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
///
/// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
/// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
/// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
///
/// Copied from [communityChatPost].
class CommunityChatPostProvider
    extends AutoDisposeFutureProvider<CommunityPostEntity> {
  /// 채팅방이 보는 모집글 — 상단 모임 카드와 모임 정보 화면이 쓴다
  ///
  /// 상세 화면의 provider를 같이 쓰지 않는 이유: 그쪽은 글·좋아요·댓글 셋을
  /// 한 번에 받아 하나라도 실패하면 전부 에러가 된다. 채팅방에 필요한 건 글
  /// 하나뿐인데 댓글 조회가 실패했다고 모임 카드가 사라지면 안 된다.
  ///
  /// Copied from [communityChatPost].
  CommunityChatPostProvider(int postId)
    : this._internal(
        (ref) => communityChatPost(ref as CommunityChatPostRef, postId),
        from: communityChatPostProvider,
        name: r'communityChatPostProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityChatPostHash,
        dependencies: CommunityChatPostFamily._dependencies,
        allTransitiveDependencies:
            CommunityChatPostFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommunityChatPostProvider._internal(
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
  Override overrideWith(
    FutureOr<CommunityPostEntity> Function(CommunityChatPostRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityChatPostProvider._internal(
        (ref) => create(ref as CommunityChatPostRef),
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
  AutoDisposeFutureProviderElement<CommunityPostEntity> createElement() {
    return _CommunityChatPostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityChatPostProvider && other.postId == postId;
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
mixin CommunityChatPostRef
    on AutoDisposeFutureProviderRef<CommunityPostEntity> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommunityChatPostProviderElement
    extends AutoDisposeFutureProviderElement<CommunityPostEntity>
    with CommunityChatPostRef {
  _CommunityChatPostProviderElement(super.provider);

  @override
  int get postId => (origin as CommunityChatPostProvider).postId;
}

String _$communityChatRoomsHash() =>
    r'4977be3fc0427b048b0e1561c9a4a59b60929087';

/// 내가 참여 중인 채팅방 목록 (`GET /chat/rooms`)
///
/// `keepAlive`: 내 모임 탭을 오갈 때마다 다시 받지 않는다. 갱신 경로는 당겨서
/// 새로고침, 방에 들어갈 때 목록에 없는 방(방금 참여), 나간 뒤 무효화 셋이다.
///
/// Copied from [CommunityChatRooms].
@ProviderFor(CommunityChatRooms)
final communityChatRoomsProvider =
    AsyncNotifierProvider<
      CommunityChatRooms,
      List<CommunityChatRoomEntity>
    >.internal(
      CommunityChatRooms.new,
      name: r'communityChatRoomsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityChatRoomsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityChatRooms = AsyncNotifier<List<CommunityChatRoomEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
