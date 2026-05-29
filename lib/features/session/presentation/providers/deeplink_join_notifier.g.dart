// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deeplink_join_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deepLinkJoinNotifierHash() =>
    r'4ade4738bbec3122920da47b303194bd8cc1a21b';

/// 딥링크 초대 코드 수신 후 인증 확인 + join API 호출 + 에러 분기.
///
/// BuildContext 의존성이 없으므로 단위 테스트에서 ProviderContainer 만으로 검증 가능합니다.
/// UI 레이어가 [DeepLinkJoinOutcome] 을 받아 라우팅/토스트를 처리합니다.
///
/// Copied from [DeepLinkJoinNotifier].
@ProviderFor(DeepLinkJoinNotifier)
final deepLinkJoinNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DeepLinkJoinNotifier, void>.internal(
      DeepLinkJoinNotifier.new,
      name: r'deepLinkJoinNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deepLinkJoinNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeepLinkJoinNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
