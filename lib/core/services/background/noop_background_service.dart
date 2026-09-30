import 'background_service.dart';
import 'lock_screen_status.dart';

/// 웹·데스크톱 등 native 백그라운드 인프라가 없는 플랫폼용 no-op 구현체.
class NoopBackgroundService implements BackgroundService {
  bool _isRunning = false;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> start({required int gameId}) async => _isRunning = true;

  @override
  Future<void> update(LockScreenStatus status) async {}

  @override
  Future<void> stop() async => _isRunning = false;
}
