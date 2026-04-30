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

  /// 앱 상세 설정 화면 열기 (사용자 명시적 [설정 열기] 탭에 의해서만 호출).
  ///
  /// Android: 설정 → 앱 → 경찰과 도둑 으로 이동.
  /// 거기서 사용자가 "배터리" 메뉴 → "제한 없음" 직접 선택.
  ///
  /// iOS: 별도 배터리 설정이 없어 no-op.
  Future<void> openAppSettings();

  /// 배터리 최적화 무시 권한 보유 여부.
  ///
  /// Android: PowerManager.isIgnoringBatteryOptimizations(packageName) 결과.
  /// Samsung "제한 없음" 설정이 이 API에 매핑됨.
  /// iOS: 항상 true (해당 사항 없음).
  Future<bool> isIgnoringBatteryOptimizations();
}
