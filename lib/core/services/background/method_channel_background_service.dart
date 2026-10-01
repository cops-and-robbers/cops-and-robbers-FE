import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'background_service.dart';
import 'lock_screen_status.dart';

/// Android·iOS 공용 BackgroundService — MainActivity.kt / AppDelegate.swift의
/// `cops_and_robbers/background_service` 채널과 통신한다.
class MethodChannelBackgroundService implements BackgroundService {
  /// MethodChannel 명. MainActivity.kt·AppDelegate.swift와 반드시 일치해야 함.
  @visibleForTesting
  static const channelName = 'cops_and_robbers/background_service';

  final MethodChannel _channel;
  // null: Dart 재시작 직후에는 OS에 이전 Live Activity가 남아 있을 수 있다.
  bool? _isRunning;
  int? _gameId;

  /// 마지막 현황. 게임 화면은 서비스 시작(비동기 초기화 뒤)보다 먼저 현황을 만들고,
  /// 컨트롤러는 같은 값을 다시 보내지 않는다 — 여기서 보관했다가 시작 직후 보내지 않으면
  /// 표시가 영영 비어 있을 수 있다.
  LockScreenStatus? _latest;

  MethodChannelBackgroundService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  @override
  bool get isRunning => _isRunning == true;

  @override
  Future<void> start({required int gameId}) async {
    // 멱등 + 동시성 가드: 상태를 await 이전에 선반영(optimistic)해서
    // start/stop 교차 호출(예: 게임 화면 진입 직후 즉시 dispose) 시
    // stop 쪽 멱등 가드가 잘못 빠져나가는 race를 방지.
    if (isRunning) return;
    _isRunning = true;
    _gameId = gameId;

    try {
      await _channel.invokeMethod('start');
      debugPrint('[BackgroundService] ✅ start (gameId=$gameId)');
    } catch (e, stack) {
      _isRunning = false; // 실패 시 롤백 — 보관 값은 다음 start 성공 때 보낸다
      debugPrint('[BackgroundService] ❌ start 실패: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }

    if (!isRunning || _gameId != gameId) return;
    final latest = _latest;
    if (latest != null) await _send(latest);
  }

  @override
  Future<void> update(LockScreenStatus status) async {
    _latest = status;
    if (!isRunning) return;
    await _send(status);
  }

  @override
  Future<void> stop() async {
    // 실행 중이 아니어도 비운다 — 이전 게임 값이 다음 게임 시작 때 재생되지 않게.
    _latest = null;
    _gameId = null;
    // 멱등 + 동시성 가드: start와 동일한 이유로 선반영.
    if (_isRunning == false) return;
    _isRunning = false;

    try {
      await _channel.invokeMethod('stop');
      debugPrint('[BackgroundService] ✅ stop');
    } catch (e, stack) {
      // native stop 실패해도 Dart 상태는 종료로 유지.
      // FGS는 어차피 OS가 정리하거나 다음 start에서 재초기화됨.
      debugPrint('[BackgroundService] ❌ stop 실패: $e');
      debugPrint('Stack: $stack');
    }
  }

  Future<void> _send(LockScreenStatus status) async {
    try {
      await _channel.invokeMethod('update', {
        ...status.toMap(),
        'gameId': _gameId,
      });
    } catch (e) {
      // 표시 실패가 게임 진행을 막으면 안 된다.
      debugPrint('[BackgroundService] ❌ update 실패: $e');
    }
  }
}
