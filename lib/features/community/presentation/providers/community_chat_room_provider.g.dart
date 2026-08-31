// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_chat_room_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityChatRoomNotifierHash() =>
    r'19903072aea02972cfbbadb718475c21f2450eb3';

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

abstract class _$CommunityChatRoomNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CommunityChatRoomState> {
  late final int postId;

  FutureOr<CommunityChatRoomState> build(int postId);
}

/// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
///
/// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
/// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
/// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
/// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
/// 끊긴 동안의 공백 메우기를 한다.
///
/// Copied from [CommunityChatRoomNotifier].
@ProviderFor(CommunityChatRoomNotifier)
const communityChatRoomNotifierProvider = CommunityChatRoomNotifierFamily();

/// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
///
/// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
/// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
/// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
/// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
/// 끊긴 동안의 공백 메우기를 한다.
///
/// Copied from [CommunityChatRoomNotifier].
class CommunityChatRoomNotifierFamily
    extends Family<AsyncValue<CommunityChatRoomState>> {
  /// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
  ///
  /// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
  /// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
  /// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
  /// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
  /// 끊긴 동안의 공백 메우기를 한다.
  ///
  /// Copied from [CommunityChatRoomNotifier].
  const CommunityChatRoomNotifierFamily();

  /// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
  ///
  /// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
  /// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
  /// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
  /// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
  /// 끊긴 동안의 공백 메우기를 한다.
  ///
  /// Copied from [CommunityChatRoomNotifier].
  CommunityChatRoomNotifierProvider call(int postId) {
    return CommunityChatRoomNotifierProvider(postId);
  }

  @override
  CommunityChatRoomNotifierProvider getProviderOverride(
    covariant CommunityChatRoomNotifierProvider provider,
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
  String? get name => r'communityChatRoomNotifierProvider';
}

/// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
///
/// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
/// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
/// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
/// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
/// 끊긴 동안의 공백 메우기를 한다.
///
/// Copied from [CommunityChatRoomNotifier].
class CommunityChatRoomNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CommunityChatRoomNotifier,
          CommunityChatRoomState
        > {
  /// 채팅방 하나의 상태 — 방 구독·타임라인·인원수·읽음·나가기
  ///
  /// 소켓은 여기서 열지 않는다. 로그인 수명의 `CommunityChatSocket`이 열어 두고,
  /// 이 Notifier는 제 방을 **구독**만 한다 — dispose면 구독만 풀린다("보고 있는
  /// 방만 구독", DEC-0026 계약 02·03). 재연결·재연결 소진·인증 에러는 소켓
  /// Notifier의 일이고, 여기서는 그 결과(연결 상태 전이)만 받아 띠·전송 가드·
  /// 끊긴 동안의 공백 메우기를 한다.
  ///
  /// Copied from [CommunityChatRoomNotifier].
  CommunityChatRoomNotifierProvider(int postId)
    : this._internal(
        () => CommunityChatRoomNotifier()..postId = postId,
        from: communityChatRoomNotifierProvider,
        name: r'communityChatRoomNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityChatRoomNotifierHash,
        dependencies: CommunityChatRoomNotifierFamily._dependencies,
        allTransitiveDependencies:
            CommunityChatRoomNotifierFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommunityChatRoomNotifierProvider._internal(
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
  FutureOr<CommunityChatRoomState> runNotifierBuild(
    covariant CommunityChatRoomNotifier notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(CommunityChatRoomNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityChatRoomNotifierProvider._internal(
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
    CommunityChatRoomNotifier,
    CommunityChatRoomState
  >
  createElement() {
    return _CommunityChatRoomNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityChatRoomNotifierProvider && other.postId == postId;
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
mixin CommunityChatRoomNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CommunityChatRoomState> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommunityChatRoomNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CommunityChatRoomNotifier,
          CommunityChatRoomState
        >
    with CommunityChatRoomNotifierRef {
  _CommunityChatRoomNotifierProviderElement(super.provider);

  @override
  int get postId => (origin as CommunityChatRoomNotifierProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
