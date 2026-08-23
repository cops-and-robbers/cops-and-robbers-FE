// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_recent_keyword_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityRecentKeywordStorageHash() =>
    r'84036b3e52f78628a0f21176d133b764bb5b9a48';

/// 최근 검색어 저장소 Provider
///
/// SharedPreferences는 시스템 경계라 여기서 한 번 갈라 둔다 — 테스트는 이
/// provider만 갈아끼우면 플랫폼 채널을 건드리지 않는다.
///
/// Copied from [communityRecentKeywordStorage].
@ProviderFor(communityRecentKeywordStorage)
final communityRecentKeywordStorageProvider =
    AutoDisposeProvider<CommunityRecentKeywordStorage>.internal(
      communityRecentKeywordStorage,
      name: r'communityRecentKeywordStorageProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityRecentKeywordStorageHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityRecentKeywordStorageRef =
    AutoDisposeProviderRef<CommunityRecentKeywordStorage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
