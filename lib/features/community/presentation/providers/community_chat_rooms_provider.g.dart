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
String _$communityChatPostHash() => r'e514fda22ff2e0b5cb253f572b06c2822082741b';

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
    r'262d787b9d0eca069fd268f97d76bd604c40bc9a';

/// 내가 참여 중인 채팅방 목록 (`GET /chat/rooms`)
///
/// `keepAlive`: 내 모임 탭을 오갈 때마다 다시 받지 않는다. 갱신은 소켓이 한다 —
/// 유저당 알림 채널(DEC-0045)로 모든 방의 새 메시지가 이리로 오고, 연결이 (다시)
/// 성립될 때마다 서버 기준선(`unreadCount`)을 한 번 다시 받는다. 사용자 동작은
/// 당겨서 새로고침과 에러 재시도뿐이다.
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
String _$communityChatMembersNotifierHash() =>
    r'3fdc80aaf42afc7c6734d2722bd2ec6801f2ae23';

abstract class _$CommunityChatMembersNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CommunityChatMembersEntity> {
  late final int postId;

  FutureOr<CommunityChatMembersEntity> build(int postId);
}

/// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
/// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
///
/// Copied from [CommunityChatMembersNotifier].
@ProviderFor(CommunityChatMembersNotifier)
const communityChatMembersNotifierProvider =
    CommunityChatMembersNotifierFamily();

/// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
/// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
///
/// Copied from [CommunityChatMembersNotifier].
class CommunityChatMembersNotifierFamily
    extends Family<AsyncValue<CommunityChatMembersEntity>> {
  /// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
  /// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
  ///
  /// Copied from [CommunityChatMembersNotifier].
  const CommunityChatMembersNotifierFamily();

  /// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
  /// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
  ///
  /// Copied from [CommunityChatMembersNotifier].
  CommunityChatMembersNotifierProvider call(int postId) {
    return CommunityChatMembersNotifierProvider(postId);
  }

  @override
  CommunityChatMembersNotifierProvider getProviderOverride(
    covariant CommunityChatMembersNotifierProvider provider,
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
  String? get name => r'communityChatMembersNotifierProvider';
}

/// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
/// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
///
/// Copied from [CommunityChatMembersNotifier].
class CommunityChatMembersNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CommunityChatMembersNotifier,
          CommunityChatMembersEntity
        > {
  /// 채팅방 멤버 목록 + 내 알림 수신 여부 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// 종 아이콘 토글은 낙관적이다: 먼저 뒤집고 서버에 저장하며, 실패하면 되돌리고
  /// 화면이 알린다. 서버 값은 멤버 목록 응답 최상위 `notificationEnabled`로 온다.
  ///
  /// Copied from [CommunityChatMembersNotifier].
  CommunityChatMembersNotifierProvider(int postId)
    : this._internal(
        () => CommunityChatMembersNotifier()..postId = postId,
        from: communityChatMembersNotifierProvider,
        name: r'communityChatMembersNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityChatMembersNotifierHash,
        dependencies: CommunityChatMembersNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommunityChatMembersNotifierFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommunityChatMembersNotifierProvider._internal(
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
  FutureOr<CommunityChatMembersEntity> runNotifierBuild(
    covariant CommunityChatMembersNotifier notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(CommunityChatMembersNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityChatMembersNotifierProvider._internal(
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
    CommunityChatMembersNotifier,
    CommunityChatMembersEntity
  >
  createElement() {
    return _CommunityChatMembersNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityChatMembersNotifierProvider &&
        other.postId == postId;
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
mixin CommunityChatMembersNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CommunityChatMembersEntity> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommunityChatMembersNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CommunityChatMembersNotifier,
          CommunityChatMembersEntity
        >
    with CommunityChatMembersNotifierRef {
  _CommunityChatMembersNotifierProviderElement(super.provider);

  @override
  int get postId => (origin as CommunityChatMembersNotifierProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
