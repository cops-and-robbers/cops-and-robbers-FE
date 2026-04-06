import 'dart:io';

/// 앱 외부 링크 URL 상수
///
/// 스토어 다운로드, 개인정보 처리방침, 이용약관 등 외부 웹 링크를 관리합니다.
class AppUrls {
  AppUrls._();

  /// 스토어 다운로드 URL (플랫폼별 분기)
  static String get storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.elipair.copsandrobbers';
    }
    return 'https://apps.apple.com/us/app/id6756843948';
  }

  /// 개인정보 처리방침
  static const String privacyPolicy =
      'https://sites.google.com/view/copsandrobbers-pp/%ED%99%88';

  /// 이용약관
  static const String termsOfService =
      'https://sites.google.com/view/copsandrobbers-tos/%ED%99%88';
}
