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
    const allowedHosts = {'copsnro66ers.site'};
    if (!allowedHosts.contains(uri.host)) {
      return DeeplinkEvent.unknown(uri: uri);
    }
    final segments = uri.pathSegments;
    if (segments.length >= 2 &&
        segments[0] == 'join' &&
        segments[1].isNotEmpty) {
      return DeeplinkEvent.inviteJoin(inviteCode: segments[1]);
    }
    return DeeplinkEvent.unknown(uri: uri);
  }
}
