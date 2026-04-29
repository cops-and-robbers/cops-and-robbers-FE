/// 게임 진행 중 백그라운드 위치 추적/STOMP 유지용 native 인프라 추상화
///
/// 역할:
/// - Android: Foreground Service start/stop 호출 (영구 알림 표시)
/// - iOS: no-op (UIBackgroundModes=location + geolocator 설정만으로 OS가 처리)
///
/// 멱등성: start()는 이미 실행 중이면 no-op. stop()도 마찬가지.
abstract class BackgroundService {
  /// 백그라운드 service 시작
  ///
  /// [gameId] 추적용 (현재는 사용 안 하지만 향후 알림 텍스트 등에 활용 가능)
  Future<void> start({required int gameId});

  /// 백그라운드 service 종료
  Future<void> stop();

  /// 현재 실행 중인지
  bool get isRunning;
}
