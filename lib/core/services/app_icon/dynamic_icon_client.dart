import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';

/// flutter_dynamic_icon 패키지에 대한 얇은 경계 래퍼.
///
/// 테스트에서는 이 인터페이스를 fake로 대체해 서비스 로직만 검증한다
/// (시스템 경계만 모킹 — `.claude/rules/Agents.md`).
abstract class DynamicIconClient {
  /// 단말이 alternate 아이콘을 지원하는지
  Future<bool> supportsAlternateIcons();

  /// 현재 적용된 alternate 식별자(null = Primary)
  Future<String?> currentAlternateIconName();

  /// 아이콘 적용(null = Primary로 리셋)
  Future<void> setAlternateIconName(String? name);
}

/// flutter_dynamic_icon 실제 호출 구현.
class FlutterDynamicIconClient implements DynamicIconClient {
  const FlutterDynamicIconClient();

  @override
  Future<bool> supportsAlternateIcons() =>
      FlutterDynamicIcon.supportsAlternateIcons;

  @override
  Future<String?> currentAlternateIconName() =>
      FlutterDynamicIcon.getAlternateIconName();

  @override
  Future<void> setAlternateIconName(String? name) async {
    // 패키지가 Future<dynamic>을 반환하므로 await로 감싸 Future<void>로 맞춘다.
    // showAlert는 기본 true(=iOS 시스템 알럿 노출) — 의도된 동작이라 건드리지 않는다.
    await FlutterDynamicIcon.setAlternateIconName(name);
  }
}
