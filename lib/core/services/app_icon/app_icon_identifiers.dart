/// iOS `Info.plist`의 `CFBundleAlternateIcons` 키와 **정확히 일치**해야 하는
/// alternate 아이콘 식별자.
///
/// 매퍼·서비스·네이티브 등록이 이 상수를 단일 출처로 공유한다(매직스트링 방지).
/// en은 Primary 아이콘이므로 alternate 식별자가 없다(null).
class AppIconIdentifiers {
  AppIconIdentifiers._();

  /// 한국어 대체 아이콘
  static const String ko = 'app_icon_ko';

  /// 일본어 대체 아이콘
  static const String ja = 'app_icon_ja';
}
