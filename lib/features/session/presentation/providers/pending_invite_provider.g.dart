// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingInviteHash() => r'aa86fc5c5b27356a1b87d5c1b533acadf0c27dbc';

/// 미로그인 상태에서 들어온 딥링크 초대 코드를 임시 보존.
///
/// 로그인 완료 시점에 root widget 이 watch 하여 자동으로 join 흐름을 재진입.
/// 앱 세션 동안 유지되어야 하므로 keepAlive: true 사용.
///
/// Copied from [PendingInvite].
@ProviderFor(PendingInvite)
final pendingInviteProvider =
    AsyncNotifierProvider<PendingInvite, String?>.internal(
      PendingInvite.new,
      name: r'pendingInviteProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingInviteHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingInvite = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
