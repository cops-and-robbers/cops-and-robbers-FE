// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLocaleHash() => r'b145f4d8fa8b85cf274150cf6d62c6efc25f0664';

/// 앱 로캘 상태 관리
///
/// 우선순위:
/// 1. SharedPreferences에 저장된 사용자 선택 언어
/// 2. 시스템 로캘 (지원 목록 내)
/// 3. [kDefaultLocale] (ko)
///
/// 첫 프레임은 시스템 로캘로 시작 → SharedPreferences 비동기 로드 후 갱신
///
/// 사용 예:
/// ```dart
/// final locale = ref.watch(appLocaleProvider);
/// await ref.read(appLocaleProvider.notifier).setLocale(const Locale('en'));
/// await ref.read(appLocaleProvider.notifier).followSystem();
/// final following = ref.read(appLocaleProvider.notifier).isFollowingSystem;
/// ```
///
/// Copied from [AppLocale].
@ProviderFor(AppLocale)
final appLocaleProvider = NotifierProvider<AppLocale, Locale>.internal(
  AppLocale.new,
  name: r'appLocaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLocale = Notifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
