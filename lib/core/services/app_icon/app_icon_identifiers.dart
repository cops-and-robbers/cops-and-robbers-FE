/// iOS `Info.plist`의 `CFBundleAlternateIcons` 키와 **정확히 일치**해야 하는
/// alternate 아이콘 식별자.
///
/// 매퍼·서비스·네이티브 등록이 이 상수를 단일 출처로 공유한다(매직스트링 방지).
/// en은 Primary 아이콘이므로 alternate 식별자가 없다(null).
/// Android `AndroidManifest.xml`의 `<activity-alias android:name>` 접미사도
/// 이 상수와 동일한 값을 사용한다 — 플랫폼별 매직스트링 분산을 방지한다.
class AppIconIdentifiers {
  AppIconIdentifiers._();

  /// 한국어 대체 아이콘
  static const String ko = 'app_icon_ko';

  /// 일본어 대체 아이콘
  static const String ja = 'app_icon_ja';

  /// 영어 아이콘.
  ///
  /// iOS에서는 Primary(=null)라 alternate 식별자가 없지만, Android는 alias 토글
  /// 방식이라 명시적 식별자가 필요하다. Android 네이티브 진입 직전에 `null → en`으로
  /// 변환한다(Dart 도메인은 iOS 기준 null=Primary 유지).
  static const String en = 'app_icon_en';
}
