import 'package:freezed_annotation/freezed_annotation.dart';

part 'deeplink_event.freezed.dart';

/// 딥링크 URI 를 의미 있는 sealed event 로 normalize.
///
/// 새 시나리오 추가 시 case 만 추가하면 됨 (예: friendAdd, gameResultShare).
@freezed
sealed class DeeplinkEvent with _$DeeplinkEvent {
  const factory DeeplinkEvent.inviteJoin({required String inviteCode}) =
      InviteJoinEvent;
  const factory DeeplinkEvent.unknown({required Uri uri}) = UnknownEvent;

  /// 화이트리스트된 host 의 URI 만 의미 있는 event 로 변환.
  /// 그 외는 unknown 으로 분류 (호출자가 무시).
  static DeeplinkEvent fromUri(Uri uri) {
    // 커스텀 스킴: copsandrobbers://join/{inviteCode}
    // 인앱 브라우저(카톡 등)/QR 에서 웹 브릿지 페이지가 앱을 깨울 때 사용한다.
    // OS 가 https 를 가로채지 못하는 환경의 폴백 경로이며, host=join / pathSegments=[code] 로 파싱된다.
    if (uri.scheme == 'copsandrobbers') {
      if (uri.host == 'join' &&
          uri.pathSegments.length == 1 &&
          uri.pathSegments.first.isNotEmpty) {
        return DeeplinkEvent.inviteJoin(inviteCode: uri.pathSegments.first);
      }
      return DeeplinkEvent.unknown(uri: uri);
    }

    // https App Links / Universal Links: https://copsnro66ers.site/join/{inviteCode}
    const allowedHosts = {'copsnro66ers.site'};
    if (!allowedHosts.contains(uri.host)) {
      return DeeplinkEvent.unknown(uri: uri);
    }
    final segments = uri.pathSegments;
    // /join/{inviteCode} 형태만 통과시킨다.
    // pathPrefix="/join/"로 가로챈 그 외 경로(/join/ABC/extra 등)는 unknown으로 분류.
    if (segments.length == 2 &&
        segments[0] == 'join' &&
        segments[1].isNotEmpty) {
      return DeeplinkEvent.inviteJoin(inviteCode: segments[1]);
    }
    return DeeplinkEvent.unknown(uri: uri);
  }
}
