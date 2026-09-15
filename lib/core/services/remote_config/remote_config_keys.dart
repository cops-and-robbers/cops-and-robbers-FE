/// Firebase Remote Config 파라미터 키 및 fail-safe 기본값.
///
/// Firebase 콘솔에 아래 11개 파라미터를 동일한 키로 생성해야 한다.
class RemoteConfigKeys {
  RemoteConfigKeys._();

  /// 최소 허용 버전 (String)
  static const String minimumVersion = 'minimum_version';

  /// 최신 버전 (String, 권고 업데이트용)
  static const String latestVersion = 'latest_version';

  /// 강제 업데이트 여부 (bool)
  static const String forceUpdate = 'force_update';

  /// 서버 점검 모드 (bool)
  static const String maintenance = 'maintenance';

  /// 점검 안내 메시지 (String)
  static const String maintenanceMessage = 'maintenance_message';

  /// 광고 전역 스위치 (bool, kill switch)
  static const String adsEnabled = 'ads_enabled';

  /// 커뮤니티 광고 스위치 (전역 ads_enabled도 켜져 있어야 함)
  static const String communityAdsEnabled = 'community_ads_enabled';

  /// 게임 종료 전면 광고 스위치 (전역 ads_enabled도 켜져 있어야 함)
  static const String gameEndAdsEnabled = 'game_end_ads_enabled';

  /// 원격 배너 활성 여부 (bool)
  static const String bannerEnabled = 'banner_enabled';

  /// 원격 배너 이미지 주소 (String)
  static const String bannerImageUrl = 'banner_image_url';

  /// 원격 배너 이동 링크 (String)
  static const String bannerLinkUrl = 'banner_link_url';
}

/// Remote Config fetch 실패 시 사용하는 fail-safe 기본값.
///
/// 전역 광고는 기본 OFF. 광고별 하위 스위치는 기존 노출을 유지하도록 ON.
class RemoteConfigDefaults {
  RemoteConfigDefaults._();

  static const Map<String, Object> values = {
    RemoteConfigKeys.minimumVersion: '1.0.0',
    RemoteConfigKeys.latestVersion: '1.0.0',
    RemoteConfigKeys.forceUpdate: false,
    RemoteConfigKeys.maintenance: false,
    RemoteConfigKeys.maintenanceMessage: '',
    RemoteConfigKeys.adsEnabled: false,
    RemoteConfigKeys.communityAdsEnabled: true,
    RemoteConfigKeys.gameEndAdsEnabled: true,
    RemoteConfigKeys.bannerEnabled: false,
    RemoteConfigKeys.bannerImageUrl: '',
    RemoteConfigKeys.bannerLinkUrl: '',
  };
}
