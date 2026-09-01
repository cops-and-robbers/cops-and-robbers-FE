// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_chat_notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityChatNoticeHash() =>
    r'1fe11de7efbec27014e07c9627fec8acd2e4cef1';

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

abstract class _$CommunityChatNotice
    extends BuildlessAutoDisposeAsyncNotifier<CommunityChatNoticeEntity?> {
  late final int postId;

  FutureOr<CommunityChatNoticeEntity?> build(int postId);
}

/// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
///
/// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
/// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
/// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
///
/// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
/// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
/// 실시간 갱신 때만 아바타가 비기 때문이다.
///
/// Copied from [CommunityChatNotice].
@ProviderFor(CommunityChatNotice)
const communityChatNoticeProvider = CommunityChatNoticeFamily();

/// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
///
/// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
/// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
/// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
///
/// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
/// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
/// 실시간 갱신 때만 아바타가 비기 때문이다.
///
/// Copied from [CommunityChatNotice].
class CommunityChatNoticeFamily
    extends Family<AsyncValue<CommunityChatNoticeEntity?>> {
  /// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
  ///
  /// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
  /// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
  /// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
  ///
  /// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
  /// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
  /// 실시간 갱신 때만 아바타가 비기 때문이다.
  ///
  /// Copied from [CommunityChatNotice].
  const CommunityChatNoticeFamily();

  /// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
  ///
  /// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
  /// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
  /// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
  ///
  /// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
  /// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
  /// 실시간 갱신 때만 아바타가 비기 때문이다.
  ///
  /// Copied from [CommunityChatNotice].
  CommunityChatNoticeProvider call(int postId) {
    return CommunityChatNoticeProvider(postId);
  }

  @override
  CommunityChatNoticeProvider getProviderOverride(
    covariant CommunityChatNoticeProvider provider,
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
  String? get name => r'communityChatNoticeProvider';
}

/// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
///
/// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
/// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
/// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
///
/// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
/// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
/// 실시간 갱신 때만 아바타가 비기 때문이다.
///
/// Copied from [CommunityChatNotice].
class CommunityChatNoticeProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          CommunityChatNotice,
          CommunityChatNoticeEntity?
        > {
  /// 채팅방 고정 공지 — 화면을 열 때마다 새로 받는다(autoDispose)
  ///
  /// 방마다 하나뿐이고 이력이 없으므로(DEC-0054) 상태는 `있음(엔티티)` 또는
  /// `없음(null)` 둘뿐이다. 서버가 없음을 200 + 필드 null로 주는 것을 저장소가
  /// null로 접어 준다 — 여기서 404를 다룰 일은 없다.
  ///
  /// 전용 소켓 채널(DEC-0055)이 "바뀌었다"만 알려 오면 내용을 다시 받는다. 그
  /// payload에는 작성자 프로필 아이콘도 등록 시각도 없어 그대로 상태에 넣으면
  /// 실시간 갱신 때만 아바타가 비기 때문이다.
  ///
  /// Copied from [CommunityChatNotice].
  CommunityChatNoticeProvider(int postId)
    : this._internal(
        () => CommunityChatNotice()..postId = postId,
        from: communityChatNoticeProvider,
        name: r'communityChatNoticeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityChatNoticeHash,
        dependencies: CommunityChatNoticeFamily._dependencies,
        allTransitiveDependencies:
            CommunityChatNoticeFamily._allTransitiveDependencies,
        postId: postId,
      );

  CommunityChatNoticeProvider._internal(
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
  FutureOr<CommunityChatNoticeEntity?> runNotifierBuild(
    covariant CommunityChatNotice notifier,
  ) {
    return notifier.build(postId);
  }

  @override
  Override overrideWith(CommunityChatNotice Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityChatNoticeProvider._internal(
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
    CommunityChatNotice,
    CommunityChatNoticeEntity?
  >
  createElement() {
    return _CommunityChatNoticeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityChatNoticeProvider && other.postId == postId;
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
mixin CommunityChatNoticeRef
    on AutoDisposeAsyncNotifierProviderRef<CommunityChatNoticeEntity?> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommunityChatNoticeProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          CommunityChatNotice,
          CommunityChatNoticeEntity?
        >
    with CommunityChatNoticeRef {
  _CommunityChatNoticeProviderElement(super.provider);

  @override
  int get postId => (origin as CommunityChatNoticeProvider).postId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
