// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_chat_rooms_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityChatRepositoryHash() =>
    r'd4907a7525311f88dc664f4a9f480ac23532c5cd';

/// 채팅 저장소 Provider — 목 교체 지점
///
/// ponytail: 1단계는 인메모리 목이다. 2단계에서 Retrofit + STOMP를 합친 impl로
/// 여기만 바꾼다. 화면·Notifier는 인터페이스만 알고 있어 손댈 곳이 없다.
/// 로그인 사용자가 바뀌면 목도 새로 만든다 — 에코의 `senderId`가 "나"여야
/// 내 말풍선으로 확정된다.
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
/// BE 이슈 가정 API. 서버가 아직 없으면 impl이 빈 목록을 돌려주고 사이드바는
/// 인원수만 보여준다.
///
/// Copied from [communityChatMembers].
@ProviderFor(communityChatMembers)
const communityChatMembersProvider = CommunityChatMembersFamily();

/// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
///
/// BE 이슈 가정 API. 서버가 아직 없으면 impl이 빈 목록을 돌려주고 사이드바는
/// 인원수만 보여준다.
///
/// Copied from [communityChatMembers].
class CommunityChatMembersFamily
    extends Family<AsyncValue<List<CommunityChatMemberEntity>>> {
  /// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// BE 이슈 가정 API. 서버가 아직 없으면 impl이 빈 목록을 돌려주고 사이드바는
  /// 인원수만 보여준다.
  ///
  /// Copied from [communityChatMembers].
  const CommunityChatMembersFamily();

  /// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// BE 이슈 가정 API. 서버가 아직 없으면 impl이 빈 목록을 돌려주고 사이드바는
  /// 인원수만 보여준다.
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
/// BE 이슈 가정 API. 서버가 아직 없으면 impl이 빈 목록을 돌려주고 사이드바는
/// 인원수만 보여준다.
///
/// Copied from [communityChatMembers].
class CommunityChatMembersProvider
    extends AutoDisposeFutureProvider<List<CommunityChatMemberEntity>> {
  /// 채팅방 멤버 목록 — 사이드바를 열 때마다 새로 받는다(autoDispose)
  ///
  /// BE 이슈 가정 API. 서버가 아직 없으면 impl이 빈 목록을 돌려주고 사이드바는
  /// 인원수만 보여준다.
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
