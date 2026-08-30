// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_community_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingCommunityPostHash() =>
    r'647331ace4dfa18456c44b67e1e32f9ac5d3fad5';

/// 미로그인 상태에서 들어온 모집글 딥링크의 글 id 를 임시 보존.
///
/// 진입 절차(약관 동의, 닉네임 설정)까지 끝난 시점에 root widget 이 읽어
/// 상세로 보낸다. 초대 코드 보존(pending_invite_provider)과 같은 자리이지만
/// 예외를 던지지 않는다 — 초대는 join 흐름이 실패를 사용자에게 안내해야
/// 하지만, 글 열람 링크는 저장이 실패하면 조용히 포기하고 홈으로 여는 편이
/// 안내 팝업보다 자연스럽다.
///
/// Copied from [PendingCommunityPost].
@ProviderFor(PendingCommunityPost)
final pendingCommunityPostProvider =
    AsyncNotifierProvider<PendingCommunityPost, int?>.internal(
      PendingCommunityPost.new,
      name: r'pendingCommunityPostProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingCommunityPostHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingCommunityPost = AsyncNotifier<int?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
