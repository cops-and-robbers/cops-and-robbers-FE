import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'remote_config_service.dart';

/// 앱 버전 체크 결과
enum VersionCheckResult {
  /// 서버 점검 중
  maintenance,

  /// 강제 업데이트 필요 (앱 사용 차단)
  forceUpdate,

  /// 선택 업데이트 가능 — minimum_version 미만 (사용자가 "나중에" 선택 가능)
  optionalUpdate,

  /// 권고 업데이트 — latest_version 미만 (최신은 아니지만 사용 가능)
  recommendUpdate,

  /// 최신 버전 (업데이트 불필요)
  upToDate,
}

/// 앱 버전 체크 유틸리티
///
/// Remote Config의 파라미터와 현재 앱 버전을 비교하여
/// 점검 모드, 강제/선택 업데이트 여부를 판단한다.
///
/// 체크 순서:
/// 1. maintenance == true → [VersionCheckResult.maintenance]
/// 2. 현재 버전 < minimum_version → force_update에 따라 forceUpdate 또는 optionalUpdate
/// 3. 현재 버전 < latest_version → [VersionCheckResult.recommendUpdate]
/// 4. 그 외 → [VersionCheckResult.upToDate]
class AppVersionChecker {
  AppVersionChecker._();

  /// 버전 체크 실행
  ///
  /// Remote Config 값과 현재 앱 버전을 비교하여 결과를 반환한다.
  /// 예외 발생 시 호출자가 처리해야 한다 (SplashPage에서 catch 후 fail-open).
  static Future<VersionCheckResult> check() async {
    // 디버그 빌드에서는 점검/업데이트 게이트를 무시한다.
    // 개발 중 Remote Config 설정이 실수로 maintenance/forceUpdate 상태여도
    // 앱 흐름이 막히지 않도록 강제로 upToDate 처리.
    if (kDebugMode) {
      debugPrint('🛠️ [AppVersionChecker] 디버그 모드: 버전 체크 건너뜀');
      return VersionCheckResult.upToDate;
    }

    final config = RemoteConfigService.instance;

    // 1. 점검 모드 체크
    if (config.maintenance) {
      return VersionCheckResult.maintenance;
    }

    // 2. 버전 비교
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final minimumVersion = config.minimumVersion;

    if (_isVersionLower(currentVersion, minimumVersion)) {
      // 3. 업데이트 방식 결정
      return config.forceUpdate
          ? VersionCheckResult.forceUpdate
          : VersionCheckResult.optionalUpdate;
    }

    // 4. 권고 업데이트 체크 (최신 버전보다 낮은 경우)
    final latestVersion = config.latestVersion;
    if (_isVersionLower(currentVersion, latestVersion)) {
      return VersionCheckResult.recommendUpdate;
    }

    return VersionCheckResult.upToDate;
  }

  /// 버전 A가 버전 B보다 낮은지 비교 (semantic versioning)
  ///
  /// 예: _isVersionLower('1.2.3', '1.3.0') → true
  ///     _isVersionLower('2.0.0', '1.9.9') → false
  static bool _isVersionLower(String versionA, String versionB) {
    final partsA = versionA.split('.').map(int.tryParse).toList();
    final partsB = versionB.split('.').map(int.tryParse).toList();

    if (partsA.any((e) => e == null) || partsB.any((e) => e == null)) {
      debugPrint('⚠️ 비정상 버전 문자열 감지: current=$versionA, minimum=$versionB');
    }

    for (var i = 0; i < 3; i++) {
      final a = i < partsA.length ? (partsA[i] ?? 0) : 0;
      final b = i < partsB.length ? (partsB[i] ?? 0) : 0;

      if (a < b) return true;
      if (a > b) return false;
    }

    return false; // 동일 버전
  }
}
