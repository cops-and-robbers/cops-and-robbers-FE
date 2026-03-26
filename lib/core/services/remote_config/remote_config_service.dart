import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
class RemoteConfigService {
  RemoteConfigService._();

  static final RemoteConfigService _instance = RemoteConfigService._();

  /// 싱글톤 인스턴스
  static RemoteConfigService get instance => _instance;

  late final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;

  /// Remote Config 초기화 및 서버 값 fetch
  ///
  /// [fetchTimeout]: fetch 타임아웃 (기본 10초)
  /// [minimumFetchInterval]: 최소 fetch 간격 (디버그: 0초, 릴리스: 1시간)
  Future<void> initialize() async {
    if (_isInitialized) return;

    _remoteConfig = FirebaseRemoteConfig.instance;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );

    // 기본값 설정 (서버 연결 실패 시 사용)
    await _remoteConfig.setDefaults({
      'minimum_version': '1.0.0',
      'latest_version': '1.0.0',
      'force_update': false,
      'maintenance': false,
      'maintenance_message': '',
    });

    // 서버에서 최신 값 가져오기
    try {
      await _remoteConfig.fetchAndActivate();
      debugPrint('✅ Remote Config fetched successfully');
    } catch (e) {
      debugPrint('⚠️ Remote Config fetch failed, using defaults: $e');
    }

    _isInitialized = true;

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
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// 최소 허용 버전
  String get minimumVersion => _remoteConfig.getString('minimum_version');

  /// 최신 버전 (권고 업데이트용)
  String get latestVersion => _remoteConfig.getString('latest_version');

  /// 강제 업데이트 여부
  bool get forceUpdate => _remoteConfig.getBool('force_update');

  /// 서버 점검 모드 여부
  bool get maintenance => _remoteConfig.getBool('maintenance');

  /// 점검 안내 메시지 (시간 등, 빈 문자열이면 기본 메시지 사용)
  String get maintenanceMessage =>
      _remoteConfig.getString('maintenance_message');
}
