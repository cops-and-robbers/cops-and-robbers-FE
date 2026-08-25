/// 딥링크 / App Links / Universal Links 관련 상수.
///
/// 초대 링크 생성(`share_util`)과 수신 파싱(`deeplink_event`, 홈 QR 스캐너)이
/// 동일한 host 를 공유하도록 단일 소스로 둔다.
///
/// ⚠️ 네이티브 설정과 반드시 함께 변경해야 한다 — 아래 두 파일은 빌드타임
/// 설정이라 이 Dart 상수를 참조할 수 없으므로, host 변경 시 수동 동기화 필수:
///   - android/app/src/main/AndroidManifest.xml  (App Links intent-filter: android:host)
///   - ios/Runner/Runner.entitlements             (Universal Links: applinks:)
class DeeplinkConstants {
  DeeplinkConstants._();

  /// App Links(Android) / Universal Links(iOS) 공개 host.
  static const String host = 'copsandrobbers.app';
}
