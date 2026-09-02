// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_icon_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileIconHash() => r'5405673ae5231540c2df3e162f26f6080c2f4e79';

/// 선택된 프로필 아이콘 상태
///
/// 정본은 서버(`GET /api/user/me`의 `profileIcon`)다. 로컬(SharedPreferences)은
/// 첫 프레임을 그리기 위한 캐시일 뿐이라, 서버 값이 오면 덮어쓴다 — 캐시를 없애면
/// 콜드 스타트마다 기본 아이콘이 한 번 번쩍인다.
///
/// 소비 측(`ref.watch(profileIconProvider)`)은 여전히 `int` 하나만 본다.
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
