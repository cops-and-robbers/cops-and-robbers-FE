import '../../domain/entities/community_interaction_entity.dart';
import '../../domain/repositories/community_interaction_repository.dart';

/// 좋아요·스크랩의 임시 구현 (메모리)
///
/// ponytail: 토글 API는 열렸지만 목록·상세 응답에 카운트와 내가 눌렀는지가
/// 없어 버튼의 처음 상태를 그릴 수 없다. 그 필드가 내려올 때까지의 대역이다 —
/// 앱을 껐다 켜면 사라진다.
///
/// 교체 방법: 실제 구현체를 만들고 `communityInteractionRepositoryProvider`가
/// 그것을 돌려주게 바꾼다. 화면 코드는 이 인터페이스만 알고 있어 손댈 곳이 없다.
class CommunityInteractionRepositoryMock
    implements CommunityInteractionRepository {
  /// postId → 상호작용 상태
  final Map<int, CommunityInteractionEntity> _interactions = {};

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
}
