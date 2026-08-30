import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/community_comment_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/community_comment_tree.dart';
import '../../domain/entities/community_post_status.dart';
import 'community_provider.dart';

part 'community_detail_provider.g.dart';

/// 상세 화면이 그리는 데 필요한 것 전부
///
/// 게시글 본문과 댓글을 한 상태로 묶는다 — 둘을 따로 watch 하면 화면이 부분
/// 로딩 조합(본문만 온 상태, 댓글만 온 상태)을 전부 그려야 한다.
class CommunityDetailState {
  const CommunityDetailState({required this.post, required this.comments});

  final CommunityPostEntity post;
  final List<CommunityCommentEntity> comments;

  CommunityDetailState copyWith({
    CommunityPostEntity? post,
    List<CommunityCommentEntity>? comments,
  }) => CommunityDetailState(
    post: post ?? this.post,
    comments: comments ?? this.comments,
  );
}

/// 모집글 상세 상태 관리 Notifier
@riverpod
class CommunityDetailNotifier extends _$CommunityDetailNotifier {
  @override
  FutureOr<CommunityDetailState> build(int postId) async {
    // 둘은 서로를 기다릴 이유가 없다. 순차로 await 하면 왕복이 그대로 쌓인다.
    //
    // ponytail: 하나만 실패해도 화면 전체가 에러(재시도 버튼)로 간다. 댓글만
    // 실패했는데 글 본문까지 못 읽는 게 이 선택의 대가다. 대신 빈 목록으로
    // 넘기면 "첫 댓글을 남겨보세요"가 떠서 댓글이 없는 글처럼 보인다 — 에러 없이
    // 틀린 화면이 더 나쁘다. 부분 실패를 구분해 보여줄 자리가 생기면 그때 나눈다.
    final results = await Future.wait([
      ref.watch(communityRepositoryProvider).getPost(postId),
      ref.watch(communityCommentRepositoryProvider).getComments(postId),
    ]);

    return CommunityDetailState(
      post: results[0] as CommunityPostEntity,
      comments: results[1] as List<CommunityCommentEntity>,
    );
  }

  /// 좋아요 토글 — 응답을 기다리지 않고 먼저 뒤집는다(낙관적 갱신).
  ///
  /// 실패하면 이전 값으로 되돌리고 예외를 다시 던진다 — 화면이 스낵바로만
  /// 알리게 하기 위함이다. 카운트를 앱이 ±1로 계산하는 이유는 토글 응답에
  /// 본문이 없어서다. 경합이 나면 다음 조회에서 맞춰진다.
  Future<void> toggleLike() => _optimistic(
    apply: (p) => p.copyWith(
      isLiked: !p.isLiked,
      likeCount: p.likeCount + (p.isLiked ? -1 : 1),
    ),
    call: (p) {
      final repo = ref.read(communityReactionRepositoryProvider);
      return p.isLiked ? repo.unlike(p.id) : repo.like(p.id);
    },
  );

  /// 스크랩 토글 — 좋아요와 같은 낙관적 갱신.
  Future<void> toggleScrap() => _optimistic(
    apply: (p) => p.copyWith(
      isScrapped: !p.isScrapped,
      scrapCount: p.scrapCount + (p.isScrapped ? -1 : 1),
    ),
    call: (p) {
      final repo = ref.read(communityReactionRepositoryProvider);
      return p.isScrapped ? repo.unscrap(p.id) : repo.scrap(p.id);
    },
  );

  /// 이 글 알림 토글 — 서버 값 둘(댓글·답글)을 한꺼번에 뒤집는다.
  ///
  /// 요청이 두 필드를 모두 요구해 하나만 보낼 수 없다. 표시 상태는 "둘 중 하나라도
  /// 켜짐"([CommunityPostNotificationSetting.enabled])이고, 끄면 둘 다 false,
  /// 켜면 둘 다 true다. 내 글 기본값(댓글 on·답글 off)은 껐다 켜면 (on·on)이
  /// 된다 — 답글 알림까지 받게 되는, 손해 없는 방향이다.
  ///
  /// 설정이 null이면(비로그인·목록 경유) 메뉴가 항목을 안 그리므로 여기 오지
  /// 않는다. 그래도 오면 켜는 쪽으로 보낸다.
  Future<void> toggleNotification() => _optimistic(
    apply: (p) => p.copyWith(notificationSetting: _flippedSetting(p)),
    call: (p) {
      final next = _flippedSetting(p);
      return ref
          .read(communityRepositoryProvider)
          .updateNotificationSetting(
            postId: p.id,
            commentNotificationsEnabled: next.commentNotificationsEnabled,
            replyNotificationsEnabled: next.replyNotificationsEnabled,
          );
    },
  );

  CommunityPostNotificationSetting _flippedSetting(CommunityPostEntity p) {
    final next = !(p.notificationSetting?.enabled ?? false);
    return CommunityPostNotificationSetting(
      commentNotificationsEnabled: next,
      replyNotificationsEnabled: next,
    );
  }

  /// 글 한 건의 낙관적 갱신 골격 — [apply]로 먼저 뒤집고 [call]이 실패하면 되돌린다.
  ///
  /// [call]은 뒤집기 **전** 글을 받는다 — 서버에 보낼 판단(좋아요를 누를지 취소할지)은
  /// 그 값으로 해야 방향이 맞다. 어느 Repository를 부를지는 클로저가 정한다 —
  /// 반응(좋아요·스크랩)과 알림 설정이 다른 Repository에 있어서다.
  Future<void> _optimistic({
    required CommunityPostEntity Function(CommunityPostEntity) apply,
    required Future<void> Function(CommunityPostEntity before) call,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final before = current.post;
    state = AsyncData(current.copyWith(post: apply(before)));
    try {
      await call(before);
    } catch (_) {
      state = AsyncData((state.valueOrNull ?? current).copyWith(post: before));
      rethrow;
    }
    // try 밖: 서버는 이미 반응을 받았다. 여기서 던지면 catch가 그 성공을
    // 롤백해 "서버는 됐는데 화면은 실패"로 어긋난다 — 이 태스크가 흡수하려는
    // 것과 같은 종류의 불일치라 catch 안에 두지 않는다.
    _syncFeedCard();
  }

  /// 바뀐 글을 목록의 그 카드에만 반영한다.
  ///
  /// `ref.invalidate`를 쓰지 않는 이유: 커서 페이지네이션이라 무효화는 0페이지
  /// 부터 다시 당긴다 — 3페이지까지 내려온 사용자가 하트 한 번에 맨 위로 튕긴다
  /// (`CommunityFeedNotifier.toggleStatus`가 같은 이유로 피한 함정이다).
  ///
  /// 검색으로 들어온 인스턴스(keyword != null)는 잡지 못하지만, 검색 결과는
  /// 화면을 나가면 폐기되므로(keepAlive 없음) 무해하다. `replacePost`는 목록에
  /// 없는 글이면 아무 일도 하지 않는다.
  void _syncFeedCard() {
    final post = state.valueOrNull?.post;
    if (post == null) return;

    final feedProvider = communityFeedNotifierProvider(
      ref.read(selectedCommunityScopeProvider),
      ref.read(selectedCommunitySortProvider),
      null,
    );
    // 상세는 피드를 거치지 않고도 도달한다(채팅방에서 바로 push). 그 경로에서
    // .notifier를 가드 없이 읽으면 죽어 있던 인스턴스를 그 자리에서 빌드해
    // getPosts()를 실제로 조회한다 — invalidate의 커서 되감김을 피하려던 게
    // 무색해진다. ref.exists로 이미 살아있을 때만 반영한다.
    if (!ref.exists(feedProvider)) return;
    ref.read(feedProvider.notifier).replacePost(post);
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

  /// 내 댓글의 답글 알림 토글 — 낙관적 갱신, 실패 시 그 댓글만 되돌리고 다시 던진다.
  ///
  /// 목록 전체를 이전 스냅샷으로 되돌리지 않는 이유는, 그 사이 달린 댓글까지
  /// 같이 지워지기 때문이다. 1depth에만 있는 id를 받는다 — 답글엔 메뉴 항목이
  /// 없고, 낡은 목록이라 못 찾으면 서버를 부르지 않는다.
  Future<void> toggleReplyNotification(int commentId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final targets = current.comments.where((c) => c.id == commentId);
    if (targets.isEmpty) return;
    final next = !targets.first.replyNotificationsEnabled;

    state = AsyncData(
      current.copyWith(
        comments: withReplyNotification(current.comments, commentId, next),
      ),
    );
    try {
      await ref
          .read(communityCommentRepositoryProvider)
          .updateReplyNotification(commentId: commentId, enabled: next);
    } catch (_) {
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(
          comments: withReplyNotification(latest.comments, commentId, !next),
        ),
      );
      rethrow;
    }
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
