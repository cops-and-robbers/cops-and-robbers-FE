import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'role_theme_provider.g.dart';

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
@Riverpod(keepAlive: true)
class RoleTheme extends _$RoleTheme {
  @override
  bool build() => false;

  /// 다크 모드 설정
  void setDarkMode(bool isDark) {
    state = isDark;
  }
}
