/// 게임 설정 상수 (PRD F1.2 기반)
/// Game Configuration Constants (Based on PRD F1.2)
class GameConfig {
  // Private 생성자 - 인스턴스화 방지
  // Private constructor to prevent instantiation
  GameConfig._();

  // ============================================
  // 라운드 시간 제약 (Round Time Constraints)
  // ============================================

  /// 최소 라운드 시간 (10분)
  /// Minimum round time (10 minutes)
  static const Duration minRoundTime = Duration(minutes: 10);

  /// 최대 라운드 시간 (180분 = 3시간)
  /// Maximum round time (180 minutes = 3 hours)
  static const Duration maxRoundTime = Duration(minutes: 180);

  /// 기본 라운드 시간 (30분)
  /// Default round time (30 minutes)
  static const Duration defaultRoundTime = Duration(minutes: 30);

  // ============================================
  // 위치 공유 주기 (Location Share Interval)
  // ============================================

  /// 최소 위치 공유 주기 (5분)
  /// Minimum location share interval (5 minutes)
  static const Duration minLocationShareInterval = Duration(minutes: 5);

  /// 기본 위치 공유 주기 (5분)
  /// Default location share interval (5 minutes)
  static const Duration defaultLocationShareInterval = Duration(minutes: 5);

  // ============================================
  // 경찰 대기 시간 (Police Wait Time)
  // ============================================

  /// 최소 경찰 대기 시간 (0분)
  /// Minimum police wait time (0 minutes)
  static const Duration minPoliceWaitTime = Duration.zero;

  /// 최대 경찰 대기 시간 (15분)
  /// Maximum police wait time (15 minutes)
  static const Duration maxPoliceWaitTime = Duration(minutes: 15);

  /// 기본 경찰 대기 시간 (5분)
  /// Default police wait time (5 minutes)
  static const Duration defaultPoliceWaitTime = Duration(minutes: 5);

  // ============================================
  // 인원 제한 (Player Limits)
  // ============================================

  /// 최대 참가 인원 (30명)
  /// Maximum players (30 players)
  static const int maxPlayers = 30;

  // ============================================
  // 위치 추적 설정 (Location Tracking)
  // ============================================

  /// 위치 업로드 주기 (3초)
  /// Location upload interval (3 seconds)
  static const Duration locationUploadInterval = Duration(seconds: 3);

  /// GPS 정확도 필터 (10m)
  /// GPS accuracy filter (10 meters)
  static const double locationDistanceFilter = 10.0;

  // ============================================
  // 구역 이탈 설정 (Zone Exit Detection)
  // ============================================

  /// 감옥 이탈 판정 시간 (30초)
  /// Jail exit detection time (30 seconds)
  static const Duration jailExitDetectionTime = Duration(seconds: 30);

  /// 감옥 이탈 시 위치 노출 시간 (10초)
  /// Location exposure time after jail exit (10 seconds)
  static const Duration jailExitExposureTime = Duration(seconds: 10);

  // ============================================
  // QR 체포 설정 (QR Arrest Settings)
  // ============================================

  /// 도둑 QR 페이로드 유효 기간 (30초)
  ///
  /// 이 시간이 지난 QR은 경찰 스캔 시 거부된다. 스크린샷 저장 후 재사용하는
  /// 리플레이 공격을 차단하기 위한 값이며, 정상 대면 체포 플로우(수 초 이내)는
  /// 충분히 여유 있게 커버한다.
  static const Duration qrPayloadTtl = Duration(seconds: 30);
}
