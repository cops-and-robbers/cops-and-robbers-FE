/// 딥링크 설정 상수
///
/// 도메인 변경 시 [host]만 수정하면 앱 전체 딥링크가 연동된다.
/// Android/iOS 네이티브 설정도 함께 변경 필요:
/// - android/app/src/main/AndroidManifest.xml (android:host)
/// - ios/Runner/Runner.entitlements (applinks:도메인)
class DeepLinkConfig {
  DeepLinkConfig._();

  // TODO: 백엔드 도메인 확정 시 변경
  static const String host = 'example.com';
  static const String scheme = 'https';

  /// 방 초대 딥링크 URL 생성
  static String roomInviteUrl(String inviteCode) =>
      '$scheme://$host/room?code=$inviteCode';

  /// 이 앱의 딥링크인지 scheme + 호스트로 판별
  static bool isDeepLink(Uri uri) => uri.scheme == scheme && uri.host == host;

  /// 방 초대 딥링크인지 경로로 판별
  static bool isRoomInvite(Uri uri) => uri.path == '/room';

  /// 방 초대코드 추출 (없으면 null)
  static String? extractRoomCode(Uri uri) => uri.queryParameters['code'];
}
