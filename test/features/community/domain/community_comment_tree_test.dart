import 'package:cops_and_robbers/features/community/domain/community_comment_tree.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_interaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

CommunityCommentEntity _comment(
  int id, {
  int? parentId,
  List<CommunityCommentEntity> replies = const [],
}) => CommunityCommentEntity(
  id: id,
  parentId: parentId,
  writerId: 7,
  writerNickname: '날쌘도둑',
  writerProfileIconId: 1,
  content: '댓글 $id',
  createdAt: DateTime.utc(2026, 8, 27, 1, id),
  replies: replies,
);

void main() {
  group('withNewComment', () {
    test('appends_top_level_comment_to_the_end', () {
      final result = withNewComment([_comment(1), _comment(2)], _comment(3));

      expect(result.map((c) => c.id), [1, 2, 3]);
    });

    test('appends_reply_under_its_parent', () {
      final result = withNewComment([
        _comment(1, replies: [_comment(10, parentId: 1)]),
        _comment(2),
      ], _comment(11, parentId: 1));

      expect(result.map((c) => c.id), [1, 2], reason: '답글은 최상위로 올라오지 않는다');
      expect(result.first.replies.map((c) => c.id), [10, 11]);
    });

    test('leaves_other_comments_untouched_when_reply_is_added', () {
      final result = withNewComment([
        _comment(1),
        _comment(2),
      ], _comment(11, parentId: 2));

      expect(result.first.replies, isEmpty);
      expect(result.last.replies.map((c) => c.id), [11]);
    });

    // 서버가 받아준 댓글이므로 부모는 서버에 있다. 목록이 낡아 못 찾는 경우에
    // 조용히 버리면 사용자가 방금 쓴 글이 사라진 것처럼 보인다.
    test('falls_back_to_top_level_when_parent_is_missing', () {
      final result = withNewComment([_comment(1)], _comment(11, parentId: 99));

      expect(result.map((c) => c.id), [1, 11]);
    });
  });

  // 삭제 후 재조회가 실패했을 때만 쓰는 최소 반영이다. 지운 한 건만 빠져야 한다.
  group('withoutComment', () {
    test('removes_top_level_comment', () {
      final result = withoutComment([_comment(1), _comment(2)], 1);

      expect(result.map((c) => c.id), [2]);
    });

    test('removes_reply_and_keeps_its_parent', () {
      final result = withoutComment([
        _comment(
          1,
          replies: [_comment(10, parentId: 1), _comment(11, parentId: 1)],
        ),
      ], 10);

      expect(result.single.id, 1);
      expect(result.single.replies.map((c) => c.id), [11]);
    });

    test('leaves_list_untouched_when_id_is_absent', () {
      final source = [
        _comment(1, replies: [_comment(10, parentId: 1)]),
      ];

      final result = withoutComment(source, 99);

      expect(result.map((c) => c.id), [1]);
      expect(result.single.replies.map((c) => c.id), [10]);
    });
  });
}
