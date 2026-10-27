import 'package:cops_and_robbers/features/notice/domain/entities/notice_entity.dart';
import 'package:cops_and_robbers/features/notice/domain/new_notice.dart';
import 'package:flutter_test/flutter_test.dart';

NoticeEntity _notice(int id, {bool pinned = false}) => NoticeEntity(
  id: id,
  title: '공지 $id',
  content: '본문',
  pinned: pinned,
  createdAt: DateTime(2026, 10, 27),
);

void main() {
  group('newestNoticeId', () {
    // 서버는 고정 공지를 먼저 보낸다 — 오래된 "이용 수칙" 고정 공지가 맨 위에 있고
    // 그 아래 새 행사 공지가 붙는 게 실제 첫 페이지 모양이다.
    test(
      'newestNoticeId_returns_new_regular_notice_when_old_pinned_notice_is_on_top',
      () {
        final items = [_notice(3, pinned: true), _notice(12), _notice(11)];

        expect(newestNoticeId(items), 12);
      },
    );

    test('newestNoticeId_returns_null_when_no_notices_exist', () {
      expect(newestNoticeId([]), isNull);
    });
  });

  group('isNewerNotice', () {
    test('isNewerNotice_is_true_when_admin_posted_notice_after_last_visit', () {
      expect(isNewerNotice(newestId: 12, lastSeenId: 11), isTrue);
    });

    test('isNewerNotice_is_false_when_user_already_saw_newest_notice', () {
      expect(isNewerNotice(newestId: 12, lastSeenId: 12), isFalse);
    });

    // 처음 설치하면 저장값이 없다 — 이미 있는 공지도 아직 안 본 것으로 친다(DEC-0038 감수).
    test('isNewerNotice_is_true_when_fresh_install_and_notices_exist', () {
      expect(isNewerNotice(newestId: 12, lastSeenId: null), isTrue);
    });

    // 운영자가 잘못 올린 최신 공지를 지우면 최대 id가 본 것보다 작아진다.
    test(
      'isNewerNotice_is_false_when_newest_notice_was_deleted_after_seen',
      () {
        expect(isNewerNotice(newestId: 11, lastSeenId: 12), isFalse);
      },
    );

    test('isNewerNotice_is_false_when_server_has_no_notices', () {
      expect(isNewerNotice(newestId: null, lastSeenId: null), isFalse);
    });
  });
}
