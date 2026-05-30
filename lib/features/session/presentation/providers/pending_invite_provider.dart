import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/app_exception.dart';

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
    // 로컬 스토리지 읽기 실패는 DatabaseException으로 래핑.
    // 호출자가 AsyncError로 받아 사용자에게 안내할 수 있게 한다.
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    } catch (e) {
      throw DatabaseException(
        message: '대기 중인 초대 코드를 불러오지 못했습니다',
        messageKey: 'errorPendingInviteLoad',
        originalException: e,
      );
    }
  }

  /// 딥링크 초대 코드를 저장하고 상태를 즉시 갱신한다.
  ///
  /// 저장 실패 시 [DatabaseException]을 던지고 state도 AsyncError로 반영해
  /// 상위 흐름이 일관된 상태 관찰 + 예외 catch 두 경로로 복구할 수 있게 한다.
  /// SharedPreferences.setString은 시그니처상 false 반환이 가능하므로 ok도 검증.
  Future<void> save(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_key, code);
      if (!ok) {
        throw const DatabaseException(
          message: '초대 코드 저장에 실패했습니다',
          messageKey: 'errorPendingInviteSave',
        );
      }
      state = AsyncValue.data(code);
    } catch (e, stack) {
      final exception = DatabaseException(
        message: '초대 코드 저장에 실패했습니다',
        messageKey: 'errorPendingInviteSave',
        originalException: e,
      );
      state = AsyncValue.error(exception, stack);
      throw exception;
    }
  }

  /// 저장된 초대 코드를 삭제하고 상태를 null 로 초기화한다.
  ///
  /// SharedPreferences.remove도 시그니처상 false 반환이 가능하므로 ok 검증 후 throw.
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.remove(_key);
      if (!ok) {
        throw const DatabaseException(
          message: '초대 코드 삭제에 실패했습니다',
          messageKey: 'errorPendingInviteClear',
        );
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      final exception = DatabaseException(
        message: '초대 코드 삭제에 실패했습니다',
        messageKey: 'errorPendingInviteClear',
        originalException: e,
      );
      state = AsyncValue.error(exception, stack);
      throw exception;
    }
  }
}
