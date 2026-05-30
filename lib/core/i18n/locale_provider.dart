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

/// 앱 로캘 상태 (Locale + 시스템 추종 여부)
///
/// 두 값을 한 record로 묶어 atomic하게 갱신 — settings UI 라디오 선택과
/// 실제 적용 Locale이 항상 동기화되도록 보장.
typedef AppLocaleState = ({Locale locale, bool isFollowingSystem});

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
/// final state = ref.watch(appLocaleProvider);
/// final locale = state.locale;
/// final isFollowingSystem = state.isFollowingSystem;
/// await ref.read(appLocaleProvider.notifier).setLocale(const Locale('en'));
/// await ref.read(appLocaleProvider.notifier).followSystem();
/// ```
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  @override
  AppLocaleState build() {
    final initial = _resolveSystemLocale();
    // SharedPreferences는 비동기라 build 동기 흐름에 직접 못 넣음.
    // 첫 프레임은 시스템 로캘로, 저장값 있으면 다음 프레임에서 덮어씀.
    Future.microtask(_loadFromStorage);
    return (locale: initial, isFollowingSystem: true);
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kStorageKey);
    if (stored == null) {
      // 저장값 없음 → 시스템 추종 유지 (build()에서 이미 설정)
      return;
    }
    final isSupported = kSupportedLocales.any((l) => l.languageCode == stored);
    if (!isSupported) {
      // 지원 목록에서 제외된 언어 코드는 무시 (시스템 따름 유지)
      await prefs.remove(_kStorageKey);
      return;
    }
    final loaded = Locale(stored);
    // locale 또는 isFollowingSystem 중 하나라도 달라지면 state 갱신
    if (loaded.languageCode != state.locale.languageCode ||
        state.isFollowingSystem) {
      state = (locale: loaded, isFollowingSystem: false);
    }
  }

  /// 사용자가 명시적으로 언어 선택 — 영속 저장 + 즉시 반영
  ///
  /// Locale 값이 동일하더라도 isFollowingSystem이 바뀌면 state는 새 record라
  /// watcher가 정상 재트리거된다.
  Future<void> setLocale(Locale locale) async {
    final isSupported = kSupportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    if (!isSupported) return;
    state = (locale: Locale(locale.languageCode), isFollowingSystem: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, locale.languageCode);
  }

  /// 저장값 삭제 후 시스템 로캘 추종으로 전환
  Future<void> followSystem() async {
    state = (locale: _resolveSystemLocale(), isFollowingSystem: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStorageKey);
  }
}

/// 부팅 시점의 유효 로케일을 1회 해석한다.
///
/// 우선순위: 저장된 사용자 선택 → 시스템 로캘(지원 내) → [kDefaultLocale].
/// 위젯 트리와 무관하게 동작하므로, 앱 시작 시 아이콘 적용 등 1회성 부팅 작업에 쓴다.
/// (provider의 비동기 storage 로드 타이밍에 의존하지 않기 위함)
Future<Locale> resolveStartupLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_kStorageKey);
  final isSupported =
      stored != null && kSupportedLocales.any((l) => l.languageCode == stored);
  if (isSupported) {
    return Locale(stored);
  }
  return _resolveSystemLocale();
}
