// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_scrap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityScrapNotifierHash() =>
    r'251acbf72de2dd168deb8421b4d6d833e6feb5aa';

/// 내 스크랩 목록 상태
///
/// 피드(`CommunityFeedNotifier`)와 나눠 두는 이유: 엔드포인트가 다르고, 커서
/// 타입도 다르고(정수), 서버 정렬이 고정이라 family 키가 필요 없다.
///
/// `keepAlive`를 쓰지 않는다 — 화면을 나가면 폐기하고 다음에 열 때 새로 받는다.
/// 다른 화면에서 스크랩한 글이 이 목록에 없는 채로 남는 문제를 배관 없이 없앤다.
///
/// Copied from [CommunityScrapNotifier].
@ProviderFor(CommunityScrapNotifier)
final communityScrapNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CommunityScrapNotifier,
      CommunityScrapState
    >.internal(
      CommunityScrapNotifier.new,
      name: r'communityScrapNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityScrapNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityScrapNotifier =
    AutoDisposeAsyncNotifier<CommunityScrapState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
