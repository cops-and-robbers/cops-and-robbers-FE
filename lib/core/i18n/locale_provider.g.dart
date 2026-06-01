// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLocaleHash() => r'c275539744ef9fbdf938ba5ca87e97ba6488e10d';

/// 앱 로캘 상태 관리
///
/// 우선순위:
/// 1. SharedPreferences에 저장된 사용자 선택 언어
/// 2. 시스템 로캘 (지원 목록 내)
/// 3. [kDefaultLocale] (en)
///
/// 첫 프레임은 시스템 로캘로 시작 → SharedPreferences 비동기 로드 후 갱신
///
/// 사용 예:
/// ```dart
/// final state = ref.watch(appLocaleProvider);
/// final locale = state.locale;
/// final isFollowingSystem = state.isFollowingSystem;
/// await ref.read(appLocaleProvider.notifier).setLocale(const Locale('en'));
/// await ref.read(appLocaleProvider.notifier).followSystem();
/// ```
///
/// Copied from [AppLocale].
@ProviderFor(AppLocale)
final appLocaleProvider = NotifierProvider<AppLocale, AppLocaleState>.internal(
  AppLocale.new,
  name: r'appLocaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appLocaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLocale = Notifier<AppLocaleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
