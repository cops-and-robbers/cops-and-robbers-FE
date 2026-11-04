import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'remote_config_keys.dart';

/// Firebase Remote Config 서비스
///
/// 앱 버전 관리 및 점검 모드 파라미터를 서버에서 가져온다.
/// 싱글톤으로 관리하며, 앱 시작 시 [initialize]를 호출해야 한다.
///
/// Remote Config 파라미터:
/// - `minimum_version` (String): 최소 허용 버전
/// - `latest_version` (String): 최신 버전 (권고 업데이트용)
/// - `force_update` (bool): 강제 업데이트 여부
/// - `maintenance` (bool): 서버 점검 모드
/// - `maintenance_message` (String): 점검 안내 메시지 (시간 등)
/// - `ads_enabled` (bool): 광고 전역 스위치 (kill switch)
/// - `community_ads_enabled` (bool): 커뮤니티 목록·상세 광고 스위치
/// - `game_end_ads_enabled` (bool): 게임 종료 전면 광고 스위치
/// - `banner_enabled` (bool): 원격 배너 활성 여부
/// - `banner_image_url` (String): 원격 배너 이미지 주소
/// - `banner_link_url` (String): 원격 배너 이동 링크
/// - `event_evidence_image_1_url` ~ `event_evidence_image_3_url` (String): 이벤트 증거 사진 주소
class RemoteConfigService {
  RemoteConfigService._([this._injectedRemoteConfig]);

  /// 가짜 Remote Config로 만든 인스턴스 (테스트 전용)
  @visibleForTesting
  factory RemoteConfigService.forTesting(FirebaseRemoteConfig remoteConfig) =>
      RemoteConfigService._(remoteConfig);

  static final RemoteConfigService _instance = RemoteConfigService._();

  /// 싱글톤 인스턴스
  static RemoteConfigService get instance => _instance;

  final FirebaseRemoteConfig? _injectedRemoteConfig;
  late final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;
  final StreamController<void> _updates = StreamController<void>.broadcast();

  /// Remote Config 초기화 및 서버 값 fetch
  ///
  /// [fetchTimeout]: fetch 타임아웃 (기본 10초)
  /// [minimumFetchInterval]: 최소 fetch 간격 (디버그: 0초, 릴리스: 1시간)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _remoteConfig = _injectedRemoteConfig ?? FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );

    // 기본값 설정 (서버 연결 실패 시 사용) — RemoteConfigDefaults 단일 정의
    await _remoteConfig.setDefaults(RemoteConfigDefaults.values);

    // 서버에서 최신 값 가져오기
    try {
      await _remoteConfig.fetchAndActivate();
      debugPrint('✅ Remote Config fetched successfully');
    } catch (e) {
      debugPrint('⚠️ Remote Config fetch failed, using defaults: $e');
    }

    _isInitialized = true;
    _listenForUpdates();

    // 디버그: Remote Config 값 및 현재 앱 버전 출력
    if (kDebugMode) {
      final packageInfo = await PackageInfo.fromPlatform();
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint(
        '📱 현재 앱 버전: ${packageInfo.version} (${packageInfo.buildNumber})',
      );
      debugPrint('🔧 Remote Config 값:');
      debugPrint('   minimum_version: $minimumVersion');
      debugPrint('   latest_version:  $latestVersion');
      debugPrint('   force_update:    $forceUpdate');
      debugPrint('   maintenance:     $maintenance');
      debugPrint('   maintenance_msg: $maintenanceMessage');
      debugPrint('   ads_enabled:     $adsEnabled');
      debugPrint('   banner_enabled:  $bannerEnabled');
      debugPrint('   banner_image_set: ${bannerImageUrl.isNotEmpty}');
      debugPrint('   banner_link_set:  ${bannerLinkUrl.isNotEmpty}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// 게시 신호를 앱이 켜져 있는 동안 받아 새 값을 활성화한다.
  ///
  /// 화면마다 구독하면 그 화면이 사라진 사이의 게시가 활성화되지 않는다.
  /// 실시간 신호는 minimumFetchInterval과 상관없이 오고, 연결 재시도와
  /// 백그라운드 중단은 SDK가 맡는다.
  void _listenForUpdates() {
    _remoteConfig.onConfigUpdated
        .asyncMap((_) async {
          try {
            await _remoteConfig.activate();
          } catch (e) {
            debugPrint('⚠️ Remote Config activate failed: $e');
          }
        })
        .listen(
          (_) => _updates.add(null),
          onError: (Object error) {
            debugPrint('⚠️ Remote Config 실시간 연결 실패: $error');
          },
        );
  }

  /// 게시된 값이 활성화될 때마다 알린다.
  Stream<void> get onConfigUpdated => _updates.stream;

  /// 최소 허용 버전
  String get minimumVersion =>
      _remoteConfig.getString(RemoteConfigKeys.minimumVersion);

  /// 최신 버전 (권고 업데이트용)
  String get latestVersion =>
      _remoteConfig.getString(RemoteConfigKeys.latestVersion);

  /// 강제 업데이트 여부
  bool get forceUpdate => _remoteConfig.getBool(RemoteConfigKeys.forceUpdate);

  /// 서버 점검 모드 여부
  ///
  /// 초기화 전에는 false. 라우터가 초기화 전부터 이 값을 읽는다.
  bool get maintenance =>
      _isInitialized && _remoteConfig.getBool(RemoteConfigKeys.maintenance);

  /// 점검 안내 메시지 (시간 등, 빈 문자열이면 기본 메시지 사용)
  String get maintenanceMessage => _isInitialized
      ? _remoteConfig.getString(RemoteConfigKeys.maintenanceMessage)
      : '';

  /// 광고 전역 스위치 (kill switch)
  ///
  /// 기본값 false — 배포 후 Firebase 콘솔에서 켜는 안전한 롤아웃.
  /// 미초기화(Firebase 실패 등) 시에도 false (광고 끔 = fail-safe)
  bool get adsEnabled =>
      _isInitialized && _remoteConfig.getBool(RemoteConfigKeys.adsEnabled);

  /// 커뮤니티 하위 스위치. 미설정 시 기존 전역 스위치 동작을 유지한다.
  bool get communityAdsEnabled =>
      !_isInitialized ||
      _remoteConfig.getBool(RemoteConfigKeys.communityAdsEnabled);

  /// 게임 종료 전면 광고 하위 스위치.
  bool get gameEndAdsEnabled =>
      !_isInitialized ||
      _remoteConfig.getBool(RemoteConfigKeys.gameEndAdsEnabled);

  /// 원격 배너 활성 여부
  bool get bannerEnabled =>
      _isInitialized && _remoteConfig.getBool(RemoteConfigKeys.bannerEnabled);

  /// 원격 배너 이미지 주소
  String get bannerImageUrl => _isInitialized
      ? _remoteConfig.getString(RemoteConfigKeys.bannerImageUrl)
      : '';

  /// 원격 배너 이동 링크
  String get bannerLinkUrl => _isInitialized
      ? _remoteConfig.getString(RemoteConfigKeys.bannerLinkUrl)
      : '';

  /// 이벤트 증거 사진 주소 값 3개. 빈 값 처리 규칙은 게임 기능이 정한다.
  List<String> get eventEvidenceImageValues => _isInitialized
      ? [
          _remoteConfig.getString(RemoteConfigKeys.eventEvidenceImage1Url),
          _remoteConfig.getString(RemoteConfigKeys.eventEvidenceImage2Url),
          _remoteConfig.getString(RemoteConfigKeys.eventEvidenceImage3Url),
        ]
      : const [];
}
