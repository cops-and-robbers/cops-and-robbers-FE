// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityNotificationUnreadCountHash() =>
    r'd3caa12522083c8fea2acc674cbba1a72dd80282';

/// 안 읽은 알림 개수 (종 아이콘 배지용)
///
/// 커뮤니티 페이지가 항상 watch하므로 `keepAlive`를 쓰지 않는다 — 알림함을
/// 열었다 나올 때 [invalidate]해 다시 받으면 배지가 즉시 내려간다.
///
/// Copied from [communityNotificationUnreadCount].
@ProviderFor(communityNotificationUnreadCount)
final communityNotificationUnreadCountProvider =
    AutoDisposeFutureProvider<int>.internal(
      communityNotificationUnreadCount,
      name: r'communityNotificationUnreadCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityNotificationUnreadCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityNotificationUnreadCountRef = AutoDisposeFutureProviderRef<int>;
String _$communityNotificationNotifierHash() =>
    r'1e990fc91840e0651578faa81c54c3f5c624aa5b';

/// 내 알림함 목록 상태
///
/// `keepAlive`를 쓰지 않는다 — 화면을 나가면 폐기하고 다음에 열 때 새로 받는다.
///
/// Copied from [CommunityNotificationNotifier].
@ProviderFor(CommunityNotificationNotifier)
final communityNotificationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CommunityNotificationNotifier,
      CommunityNotificationState
    >.internal(
      CommunityNotificationNotifier.new,
      name: r'communityNotificationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityNotificationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityNotificationNotifier =
    AutoDisposeAsyncNotifier<CommunityNotificationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
