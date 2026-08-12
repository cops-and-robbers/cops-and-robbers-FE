// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_icon_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileIconHash() => r'd77b99411ba0917641e8999392e3331dcfedf364';

/// 선택된 프로필 아이콘 상태
///
/// 서버에 프로필 아이콘 API가 아직 없어 로컬(SharedPreferences)에만 저장한다.
/// API가 생기면 이 notifier 내부의 저장·조회만 원격 호출로 바꾸면 되고,
/// 소비 측(`ref.watch(profileIconProvider)`)은 수정할 필요가 없다.
///
/// 사용 예:
/// ```dart
/// final iconId = ref.watch(profileIconProvider);
/// await ref.read(profileIconProvider.notifier).select(2);
/// ```
///
/// Copied from [ProfileIcon].
@ProviderFor(ProfileIcon)
final profileIconProvider = NotifierProvider<ProfileIcon, int>.internal(
  ProfileIcon.new,
  name: r'profileIconProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileIconHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileIcon = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
