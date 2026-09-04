import 'package:cops_and_robbers/core/deeplink/deeplink_event.dart';
import 'package:cops_and_robbers/core/deeplink/deeplink_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 콜드 스타트 dedup 의 적용 범위 (#560).
///
/// last-handled URI 비교는 초대에만 적용된다 — join 은 참가 API 부작용이 있어
/// recents 재실행의 재참가를 막아야 하지만, 모집글 링크는 글 하나에 URI 가
/// 고정이라 같은 링크를 다시 여는 것이 정상 사용이다.
///
/// 경계 목: `coldStartDeeplinkUriProvider`(app_links 플랫폼 채널) 오버라이드와
/// SharedPreferences 인메모리 목. 그 안쪽(파싱·dedup 판단)은 실제 코드다.
void main() {
  const lastHandledKey = 'last_handled_deeplink_uri';
  final postUri = Uri.parse('https://copsandrobbers.app/g/12');
  final inviteUri = Uri.parse('https://copsandrobbers.app/join/ABC123');

  ProviderContainer containerWithInitialLink(Uri uri) {
    final container = ProviderContainer(
      overrides: [
        coldStartDeeplinkUriProvider.overrideWith((ref) async => uri),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'coldStartDeeplink_returns_post_event_when_same_post_uri_was_handled_before',
    () async {
      SharedPreferences.setMockInitialValues({
        lastHandledKey: postUri.toString(),
      });

      final event = await containerWithInitialLink(
        postUri,
      ).read(coldStartDeeplinkProvider.future);

      expect(
        event,
        const DeeplinkEvent.communityPost(postId: 12),
        reason: '같은 모집글 링크 재탭은 정상 사용이다 — dedup 으로 버리면 홈으로 떨어진다 (#560)',
      );
      // 모집글은 last-handled 를 건드리지 않는다 — 기록하면 초대 dedup 키를 덮는다
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(lastHandledKey), postUri.toString());
    },
  );

  test(
    'coldStartDeeplink_returns_null_when_same_invite_uri_was_handled_before',
    () async {
      SharedPreferences.setMockInitialValues({
        lastHandledKey: inviteUri.toString(),
      });

      final event = await containerWithInitialLink(
        inviteUri,
      ).read(coldStartDeeplinkProvider.future);

      expect(event, isNull, reason: '초대의 recents 재실행 재참가 차단은 유지된다');
    },
  );

  test(
    'coldStartDeeplink_marks_invite_uri_as_handled_when_first_seen',
    () async {
      SharedPreferences.setMockInitialValues({});

      final event = await containerWithInitialLink(
        inviteUri,
      ).read(coldStartDeeplinkProvider.future);
      final prefs = await SharedPreferences.getInstance();

      expect(event, const DeeplinkEvent.inviteJoin(inviteCode: 'ABC123'));
      expect(prefs.getString(lastHandledKey), inviteUri.toString());
    },
  );
}
