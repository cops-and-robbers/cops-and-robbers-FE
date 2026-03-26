import 'dart:io';

/// 앱 전역 설정 상수
class AppConfig {
  AppConfig._();

  // TODO(release): 실제 스토어 다운로드 URL로 변경
  /// 스토어 URL (플랫폼별 분기)
  static String get storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/console';
    }
    return 'https://appstoreconnect.apple.com';
  }
}
