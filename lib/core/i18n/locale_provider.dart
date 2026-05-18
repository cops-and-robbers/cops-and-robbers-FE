import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

/// 앱이 지원하는 로캘 목록
///
/// 추후 언어 추가 시 이 리스트만 갱신하고 `lib/l10n/app_<code>.arb` 파일 추가
const List<Locale> kSupportedLocales = [
  Locale('ko'),
  Locale('en'),
  Locale('ja'),
];

/// 기본 로캘 — 지원 외 시스템 로캘이거나 첫 실행 시 폴백
const Locale kDefaultLocale = Locale('ko');

/// SharedPreferences 키 — 명시적으로 선택한 언어 코드 저장 (없으면 시스템 따름)
const String _kStorageKey = 'app_locale_code';

/// 시스템 로캘이 지원 목록에 있으면 그대로, 아니면 [kDefaultLocale]
Locale _resolveSystemLocale() {
  final code = PlatformDispatcher.instance.locale.languageCode;
  final supported = kSupportedLocales.any((l) => l.languageCode == code);
  return supported ? Locale(code) : kDefaultLocale;
}

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
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  // 사용자가 명시적으로 언어를 골랐는지 여부 (false면 시스템 로캘 추종)
  bool _followingSystem = true;

  /// "시스템 따름" 상태인지 — settings UI에서 라디오 선택 표시용
  ///
  /// 이 값은 Provider state가 아니라 notifier 내부 상태이므로 watch 불가.
  /// 변화 감지가 필요한 경우 setLocale/followSystem 호출 후 별도 갱신 필요.
  bool get isFollowingSystem => _followingSystem;

  @override
  Locale build() {
    final initial = _resolveSystemLocale();
    // SharedPreferences는 비동기라 build 동기 흐름에 직접 못 넣음.
    // 첫 프레임은 시스템 로캘로, 저장값 있으면 다음 프레임에서 덮어씀.
    Future.microtask(_loadFromStorage);
    return initial;
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kStorageKey);
    if (stored == null) {
      _followingSystem = true;
      return;
    }
    final isSupported = kSupportedLocales.any((l) => l.languageCode == stored);
    if (!isSupported) {
      // 지원 목록에서 제외된 언어 코드는 무시 (시스템 따름 유지)
      await prefs.remove(_kStorageKey);
      return;
    }
    _followingSystem = false;
    final loaded = Locale(stored);
    if (loaded.languageCode != state.languageCode) {
      state = loaded;
    }
  }

  /// 사용자가 명시적으로 언어 선택 — 영속 저장 + 즉시 반영
  Future<void> setLocale(Locale locale) async {
    final isSupported = kSupportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    if (!isSupported) return;
    _followingSystem = false;
    state = Locale(locale.languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, locale.languageCode);
  }

  /// 저장값 삭제 후 시스템 로캘 추종으로 전환
  Future<void> followSystem() async {
    _followingSystem = true;
    state = _resolveSystemLocale();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStorageKey);
  }
}
