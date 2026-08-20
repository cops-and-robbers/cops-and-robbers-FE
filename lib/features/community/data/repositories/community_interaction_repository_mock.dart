import '../../domain/entities/community_interaction_entity.dart';
import '../../domain/repositories/community_interaction_repository.dart';

/// 좋아요·스크랩·댓글의 임시 구현 (메모리)
///
/// ponytail: 백엔드 API가 열릴 때까지의 대역이다. 앱을 껐다 켜면 사라진다 —
/// 영속이 필요한 값이 아니라 화면과 상태 흐름을 먼저 완성하려는 목적이다.
///
/// 교체 방법: 실제 구현체를 만들고 `communityInteractionRepositoryProvider`가
/// 그것을 돌려주게 바꾼다. 화면 코드는 이 인터페이스만 알고 있어 손댈 곳이 없다.
/// 메서드별로 API가 따로 열리면 이 클래스를 상속해 열린 것만 override 해도 된다.
class CommunityInteractionRepositoryMock
    implements CommunityInteractionRepository {
  /// postId → 상호작용 상태
  final Map<int, CommunityInteractionEntity> _interactions = {};

  /// postId → 댓글 목록
  final Map<int, List<CommunityCommentEntity>> _comments = {};

  /// 목 댓글 id 채번기. 실제 API가 붙으면 서버가 발급한다.
  int _nextCommentId = 1000;

  /// 실서버 왕복처럼 보이게 하는 지연. 로딩 인디케이터가 한 프레임도 안 보이면
  /// 로딩 UI가 제대로 그려지는지 확인할 수 없다.
  static const _latency = Duration(milliseconds: 200);

  @override
  Future<CommunityInteractionEntity> getInteraction(int postId) async {
    await Future.delayed(_latency);
    return _interactions[postId] ?? _seed(postId);
  }

  @override
  Future<CommunityInteractionEntity> toggleLike(int postId) async {
    await Future.delayed(_latency);
    final current = _interactions[postId] ?? _seed(postId);
    final next = current.copyWith(
      isLiked: !current.isLiked,
      likeCount: current.likeCount + (current.isLiked ? -1 : 1),
    );
    _interactions[postId] = next;
    return next;
  }

  @override
  Future<CommunityInteractionEntity> toggleBookmark(int postId) async {
    await Future.delayed(_latency);
    final current = _interactions[postId] ?? _seed(postId);
    final next = current.copyWith(
      isBookmarked: !current.isBookmarked,
      bookmarkCount: current.bookmarkCount + (current.isBookmarked ? -1 : 1),
    );
    _interactions[postId] = next;
    return next;
  }

  @override
  Future<List<CommunityCommentEntity>> getComments(int postId) async {
    await Future.delayed(_latency);
    return _comments[postId] ?? _seedComments(postId);
  }

  @override
  Future<List<CommunityCommentEntity>> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    await Future.delayed(_latency);
    final list = [...(_comments[postId] ?? _seedComments(postId))];
    final created = CommunityCommentEntity(
      id: _nextCommentId++,
      // 작성자 정보는 서버가 토큰에서 뽑아 내려주는 값이다. 목에서는 화면 확인용
      // 고정값을 쓴다 — 실제 연동 시 이 블록 전체가 서버 응답으로 대체된다.
      writerId: 0,
      writerNickname: '나',
      writerProfileIconId: 1,
      content: content,
      createdAt: DateTime.now(),
    );

    if (parentId == null) {
      list.add(created);
    } else {
      final index = list.indexWhere((c) => c.id == parentId);
      // 답글 대상이 그 사이 지워졌으면 최상위 댓글로 떨어뜨린다 — 조용히 버리면
      // 사용자가 쓴 글이 사라진 것처럼 보인다.
      if (index == -1) {
        list.add(created);
      } else {
        final parent = list[index];
        list[index] = parent.copyWith(replies: [...parent.replies, created]);
      }
    }

    _comments[postId] = list;
    return list;
  }

  @override
  Future<List<CommunityCommentEntity>> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    await Future.delayed(_latency);
    final list = _comments[postId] ?? _seedComments(postId);
    final next = [
      for (final c in list)
        if (c.id != commentId)
          c.copyWith(
            replies: c.replies.where((r) => r.id != commentId).toList(),
          ),
    ];
    _comments[postId] = next;
    return next;
  }

  /// 첫 조회 시 채우는 초기값. 글마다 달라 보이도록 id로 값을 흔든다.
  CommunityInteractionEntity _seed(int postId) {
    final seeded = CommunityInteractionEntity(
      isLiked: false,
      likeCount: postId * 3 % 47,
      isBookmarked: false,
      bookmarkCount: postId * 7 % 23,
      currentParticipants: postId * 2 % 8 + 1,
    );
    _interactions[postId] = seeded;
    return seeded;
  }

  List<CommunityCommentEntity> _seedComments(int postId) {
    final seeded = [
      CommunityCommentEntity(
        id: postId * 100 + 1,
        writerId: 101,
        writerNickname: '날쌘도둑',
        writerProfileIconId: 2,
        content: '저 참여하고 싶어요! 초보도 괜찮나요?',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        replies: [
          CommunityCommentEntity(
            id: postId * 100 + 2,
            writerId: 7,
            writerNickname: '무서운경찰관',
            writerProfileIconId: 1,
            content: '그럼요, 규칙은 현장에서 알려드려요',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      CommunityCommentEntity(
        id: postId * 100 + 3,
        writerId: 102,
        writerNickname: '숨은고수',
        writerProfileIconId: 2,
        content: '몇 시까지 하나요?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
    ];
    _comments[postId] = seeded;
    return seeded;
  }
}
