import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/community_interaction_repository_mock.dart';
import '../../domain/entities/community_interaction_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/community_comment_tree.dart';
import '../../domain/entities/community_post_status.dart';
import '../../domain/repositories/community_interaction_repository.dart';
import 'community_provider.dart';

part 'community_detail_provider.g.dart';

/// 상호작용 Repository Provider — 목데이터 교체 지점
///
/// ponytail: 좋아요·스크랩은 응답에 카운트·내 반응 필드가 없어 메모리 목을
/// 돌려준다. 댓글은 실서버로 옮겨 갔다(`communityCommentRepositoryProvider`).
/// API가 열리면 여기서 돌려주는 구현체만 실제 구현으로 바꾼다. 화면·Notifier는
/// 인터페이스만 알고 있어 손댈 곳이 없다.
///
/// `keepAlive`인 이유: 목이 상태를 메모리에 들고 있어서, 상세를 나갔다 들어올
/// 때마다 새로 만들면 방금 누른 좋아요가 풀린다. 실제 구현으로 바꾸면
/// 서버가 상태를 갖게 되므로 이 옵션은 떼도 된다.
@Riverpod(keepAlive: true)
CommunityInteractionRepository communityInteractionRepository(Ref ref) {
  return CommunityInteractionRepositoryMock();
}

/// 상세 화면이 그리는 데 필요한 것 전부
///
/// 게시글 본문과 상호작용·댓글을 한 상태로 묶는다 — 셋을 따로 watch 하면
/// 화면이 부분 로딩 조합(본문만 온 상태, 댓글만 온 상태)을 전부 그려야 한다.
class CommunityDetailState {
  const CommunityDetailState({
    required this.post,
    required this.interaction,
    required this.comments,
  });

  final CommunityPostEntity post;
  final CommunityInteractionEntity interaction;
  final List<CommunityCommentEntity> comments;

  CommunityDetailState copyWith({
    CommunityPostEntity? post,
    CommunityInteractionEntity? interaction,
    List<CommunityCommentEntity>? comments,
  }) => CommunityDetailState(
    post: post ?? this.post,
    interaction: interaction ?? this.interaction,
    comments: comments ?? this.comments,
  );
}

/// 모집글 상세 상태 관리 Notifier
///
/// 게시글 본문은 실서버, 상호작용·댓글은 목이다. 둘의 출처가 달라도 화면은
/// 이 Notifier 하나만 본다 — 목이 실서버로 바뀌어도 화면은 그대로다.
@riverpod
class CommunityDetailNotifier extends _$CommunityDetailNotifier {
  @override
  FutureOr<CommunityDetailState> build(int postId) async {
    final postFuture = ref.watch(communityRepositoryProvider).getPost(postId);
    final interactionRepo = ref.watch(communityInteractionRepositoryProvider);

    // 셋은 서로를 기다릴 이유가 없다. 순차로 await 하면 왕복이 그대로 쌓인다.
    //
    // ponytail: 셋 중 하나만 실패해도 화면 전체가 에러(재시도 버튼)로 간다.
    // 댓글만 실패했는데 글 본문까지 못 읽는 게 이 선택의 대가다. 대신 빈 목록으로
    // 넘기면 "첫 댓글을 남겨보세요"가 떠서 댓글이 없는 글처럼 보인다 — 에러 없이
    // 틀린 화면이 더 나쁘다. 부분 실패를 구분해 보여줄 자리가 생기면 그때 나눈다.
    final results = await Future.wait([
      postFuture,
      interactionRepo.getInteraction(postId),
      ref.watch(communityCommentRepositoryProvider).getComments(postId),
    ]);

    return CommunityDetailState(
      post: results[0] as CommunityPostEntity,
      interaction: results[1] as CommunityInteractionEntity,
      comments: results[2] as List<CommunityCommentEntity>,
    );
  }

  /// 좋아요 토글 — 응답을 기다리지 않고 먼저 뒤집는다(낙관적 갱신).
  ///
  /// 실패하면 이전 값으로 되돌리고 예외를 다시 던진다 — 화면이 스낵바로만
  /// 알리게 하기 위함이다.
  Future<void> toggleLike() => _optimistic(
    apply: (i) => i.copyWith(
      isLiked: !i.isLiked,
      likeCount: i.likeCount + (i.isLiked ? -1 : 1),
    ),
    call: (repo, postId) => repo.toggleLike(postId),
  );

  /// 스크랩 토글 — 좋아요와 같은 낙관적 갱신.
  Future<void> toggleBookmark() => _optimistic(
    apply: (i) => i.copyWith(
      isBookmarked: !i.isBookmarked,
      bookmarkCount: i.bookmarkCount + (i.isBookmarked ? -1 : 1),
    ),
    call: (repo, postId) => repo.toggleBookmark(postId),
  );

  Future<void> _optimistic({
    required CommunityInteractionEntity Function(CommunityInteractionEntity)
    apply,
    required Future<CommunityInteractionEntity> Function(
      CommunityInteractionRepository,
      int,
    )
    call,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(interaction: apply(current.interaction)),
    );
    try {
      final updated = await call(
        ref.read(communityInteractionRepositoryProvider),
        postId,
      );
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(interaction: updated),
      );
    } catch (_) {
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          interaction: current.interaction,
        ),
      );
      rethrow;
    }
  }

  /// 댓글 또는 답글 작성.
  ///
  /// 서버는 만들어진 댓글 한 건만 주므로 목록에 합쳐 넣는다 — 다시 받아오면
  /// 커서가 처음으로 되감긴다.
  Future<void> addComment(String content, {int? parentId}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final created = await ref
        .read(communityCommentRepositoryProvider)
        .addComment(postId: postId, content: content, parentId: parentId);

    final latest = state.valueOrNull ?? current;
    state = AsyncData(
      latest.copyWith(comments: withNewComment(latest.comments, created)),
    );
  }

  /// 댓글 삭제.
  ///
  /// 삭제 결과를 앱이 계산하지 않고 다시 받는다. 답글이 남았으면 자리만 남기고
  /// 마스킹하지만, 마지막 답글이 지워지면 껍데기 부모까지 함께 정리되기
  /// 때문이다(DEC-0034) — 그 연쇄 규칙을 앱에 복제하면 서버가 바꿀 때 조용히
  /// 어긋난다.
  Future<void> deleteComment(int commentId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final repo = ref.read(communityCommentRepositoryProvider);
    await repo.deleteComment(commentId);

    // 여기부터는 삭제가 이미 끝났다. 재조회가 실패해도 실패로 되돌리면 안 된다 —
    // 사용자는 삭제가 안 된 줄 알고 다시 누르고, 서버는 없는 댓글이라 거절한다.
    // 그래서 재조회 실패는 삼키고, 지운 댓글만 목록에서 걷어낸 채로 둔다.
    List<CommunityCommentEntity> comments;
    try {
      comments = await repo.getComments(postId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 댓글 삭제 후 재조회 실패 — 지운 댓글만 걷어낸다: $e');
      }
      comments = withoutComment(
        (state.valueOrNull ?? current).comments,
        commentId,
      );
    }

    state = AsyncData(
      (state.valueOrNull ?? current).copyWith(comments: comments),
    );
  }

  /// 모집 상태 전환 (모집중 ↔ 마감).
  ///
  /// 서버가 변경된 글을 돌려주므로 그대로 갈아끼운다. 목록도 낡은 상태를 들고
  /// 있으므로 함께 무효화한다.
  Future<void> toggleStatus() async {
    final current = state.valueOrNull;
    if (current == null) return;
    // 종료 글은 서버가 조회 시 다시 ENDED로 판정한다 — 왕복만 낭비다.
    if (current.post.status == CommunityPostStatus.ended) return;

    final next = current.post.status == CommunityPostStatus.recruiting
        ? CommunityPostStatus.completed
        : CommunityPostStatus.recruiting;

    final updated = await ref
        .read(communityRepositoryProvider)
        .updateStatus(postId: postId, status: next);

    state = AsyncData((state.valueOrNull ?? current).copyWith(post: updated));
    ref.invalidate(communityFeedNotifierProvider);
  }

  /// 게시글 삭제. 성공하면 목록을 무효화한다 — 화면 이동은 호출자 몫이다.
  Future<void> deletePost() async {
    await ref.read(communityRepositoryProvider).deletePost(postId);
    ref.invalidate(communityFeedNotifierProvider);
  }

  /// 수정 화면이 돌려준 글로 갈아끼운다 (네트워크 없음).
  ///
  /// 서버가 수정 결과를 그대로 돌려주므로 다시 조회할 이유가 없다 — 재조회하면
  /// 값은 같은데 스피너만 한 번 깜빡인다 ([toggleStatus]와 같은 판단).
  void applyUpdatedPost(CommunityPostEntity updated) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(post: updated));
    ref.invalidate(communityFeedNotifierProvider);
  }
}
