/// 게임 설정 상수 (PRD F1.2 기반)
/// Game Configuration Constants (Based on PRD F1.2)
class GameConfig {
  // Private 생성자 - 인스턴스화 방지
  // Private constructor to prevent instantiation
  GameConfig._();

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

  // ============================================
  // 핑 설정 (Ping Settings)
  // ============================================

  /// 핑 표시 후 자동 소멸 시간 (2.5초)
  /// Ping auto-dismiss lifetime (2.5 seconds)
  static const Duration pingLifetime = Duration(milliseconds: 2500);

  /// 핑 rate-limit 관측 윈도우 (5초)
  /// Ping rate-limit sliding window (5 seconds)
  static const Duration pingRateWindow = Duration(seconds: 5);

  /// 윈도우 내 허용 핑 횟수 (8회)
  /// Allowed pings within the window (8 times)
  static const int pingRateMaxCount = 8;

  /// rate-limit 초과 시 핑 금지 시간 (3초)
  /// Cooldown after exceeding the rate-limit (3 seconds)
  static const Duration pingRateCooldown = Duration(seconds: 3);

  // ============================================
  // 폴리곤 구역 설정 (Polygon Area Settings)
  // ============================================

  /// 인게임 지도 카메라가 플레이그라운드 경계 밖으로 나갈 수 있는 여유
  /// (구역 boundingRadius 대비 비율, 0.3 = 반경의 30%)
  /// In-game camera pan margin beyond the playground (ratio of bounding radius)
  static const double cameraPanMarginRatio = 0.3;

  /// 폴리곤 최소 꼭짓점 수 (3개)
  /// Minimum polygon vertex count (3)
  static const int minPolygonVertexCount = 3;

  /// 폴리곤 최대 꼭짓점 수 (10개)
  /// Maximum polygon vertex count (10)
  static const int maxPolygonVertexCount = 10;

  /// 핀 간 최소 간격 (10m) — 연타·중복 꼭짓점으로 인한 퇴화 다각형 방지
  /// Minimum spacing between pins (10 meters)
  static const double minPinSpacingInMeters = 10.0;

  /// 감옥 ⊂ 플레이그라운드 포함 판정 허용 오차 (1m)
  ///
  /// 좌표·거리 계산의 부동소수점 오차로 경계에 딱 맞춘 배치가 반려되는 것을 막는다.
  /// Tolerance for the jail-inside-playground check (1 meter)
  static const double zoneContainmentToleranceInMeters = 1.0;
}
