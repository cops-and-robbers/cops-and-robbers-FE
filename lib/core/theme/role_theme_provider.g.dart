// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roleThemeHash() => r'ad1a281f450f10625c60ac65db213b272a166489';

/// 역할 기반 다크/라이트 모드 상태 관리
///
/// - `true` = 다크 모드 (도둑)
/// - `false` = 라이트 모드 (경찰, 기본값)
///
/// 대기방 진입 시 팀 배정에 따라 [setDarkMode] 호출.
/// ```dart
/// // 팀 배정 시
/// ref.read(roleThemeProvider.notifier).setDarkMode(team == 'ROBBER');
///
/// // 읽기
/// final isDark = ref.watch(roleThemeProvider);
/// ```
///
/// Copied from [RoleTheme].
@ProviderFor(RoleTheme)
final roleThemeProvider = NotifierProvider<RoleTheme, bool>.internal(
  RoleTheme.new,
  name: r'roleThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roleThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RoleTheme = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
