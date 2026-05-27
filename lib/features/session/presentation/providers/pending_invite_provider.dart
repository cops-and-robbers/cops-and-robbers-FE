import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'pending_invite_provider.g.dart';

/// 미로그인 상태에서 들어온 딥링크 초대 코드를 임시 보존.
///
/// 로그인 완료 시점에 root widget 이 watch 하여 자동으로 join 흐름을 재진입.
/// 앱 세션 동안 유지되어야 하므로 keepAlive: true 사용.
@Riverpod(keepAlive: true)
class PendingInvite extends _$PendingInvite {
  // SharedPreferences 저장 키
  static const _key = 'pending_invite_code';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// 딥링크 초대 코드를 저장하고 상태를 즉시 갱신한다.
  Future<void> save(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    state = AsyncValue.data(code);
  }

  /// 저장된 초대 코드를 삭제하고 상태를 null 로 초기화한다.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncValue.data(null);
  }
}
