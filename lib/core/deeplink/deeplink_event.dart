import 'package:freezed_annotation/freezed_annotation.dart';

import 'deeplink_constants.dart';

part 'deeplink_event.freezed.dart';

/// 딥링크 URI 를 의미 있는 sealed event 로 normalize.
///
/// 새 시나리오 추가 시 case 만 추가하면 됨 (예: friendAdd, gameResultShare).
@freezed
sealed class DeeplinkEvent with _$DeeplinkEvent {
  const factory DeeplinkEvent.inviteJoin({required String inviteCode}) =
      InviteJoinEvent;
  const factory DeeplinkEvent.communityPost({required int postId}) =
      CommunityPostEvent;
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
      // copsandrobbers://open/community/{postId} — 웹 상세의 "앱에서 열기" 폴백.
      // host 를 open 으로 두고 뒤에 라우터 경로를 그대로 싣는 규약이다. 엔진이
      // warm 인텐트의 경로를 라우터로 전달할 때 실제 라우트에 안착해 404 가
      // 뜨지 않는다 (host 가 community 면 경로가 /{id} 로 잘려 라우트가 없다).
      if (uri.host == 'open' &&
          uri.pathSegments.length == 2 &&
          uri.pathSegments[0] == 'community') {
        final postId = int.tryParse(uri.pathSegments[1]);
        if (postId != null && postId > 0) {
          return DeeplinkEvent.communityPost(postId: postId);
        }
      }
      return DeeplinkEvent.unknown(uri: uri);
    }

    // https App Links / Universal Links: https://{host}/join/{inviteCode}
    const allowedHosts = {DeeplinkConstants.host};
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
    // 모집글: /g/{id}, /ja/g/{id}, /en/g/{id}
    final postId = _communityPostId(segments);
    if (postId != null) {
      return DeeplinkEvent.communityPost(postId: postId);
    }
    return DeeplinkEvent.unknown(uri: uri);
  }

  /// 모집글 경로에서 글 id 를 뽑는다. 모양이 다르거나 숫자가 아니면 null.
  ///
  /// 언어별 경로는 웹의 정본 주소 규칙과 같다. 지원 언어가 늘면 여기와
  /// AndroidManifest 의 pathPrefix, 웹 AASA 세 곳을 함께 넓혀야 한다
  /// (docs/DEEPLINK.md 의 언어 추가 체크리스트 참조).
  static int? _communityPostId(List<String> segments) {
    final shaped =
        (segments.length == 2 && segments[0] == 'g') ||
        (segments.length == 3 &&
            (segments[0] == 'ja' || segments[0] == 'en') &&
            segments[1] == 'g');
    if (!shaped) return null;
    final id = int.tryParse(segments.last);
    return (id != null && id > 0) ? id : null;
  }
}
