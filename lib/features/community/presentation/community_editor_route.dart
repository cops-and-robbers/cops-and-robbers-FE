import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/route_paths.dart';
import '../domain/entities/community_post_entity.dart';
import 'providers/community_detail_provider.dart';

/// 모집글 수정 화면을 연다 — 상세 위로 솟아오르고, 닫으면 상세가 드러난다.
///
/// 목록 카드와 상세가 함께 쓴다. [fromList]면 상세를 **전환 없이** 먼저 깔아
/// 준다 (`CommunityDetailEntry.silent`): 목록에서 바로 수정을 골랐어도 완료든
/// 취소든 닫았을 때 목록이 아니라 방금 고친 글이 보여야 하기 때문이다.
///
/// 상세를 깔지 않고 수정만 push하면 안 된다 — GoRouter는 중첩 경로를 push해도
/// 부모 페이지를 스택에 만들지 않아서, 닫으면 목록으로 튕긴다 (실측 확인).
///
/// 저장 결과는 상세 Notifier에 그대로 밀어넣는다. 재조회하지 않으므로 닫힌
/// 직후의 상세에 스피너가 끼지 않는다.
Future<void> openCommunityEditor(
  BuildContext context,
  WidgetRef ref,
  CommunityPostEntity post, {
  bool fromList = false,
}) async {
  final postId = {'postId': '${post.id}'};

  if (fromList) {
    context.pushNamed(
      RoutePaths.communityDetailName,
      pathParameters: postId,
      extra: CommunityDetailEntry.silent,
    );
  }

  final updated = await context.pushNamed<CommunityPostEntity>(
    RoutePaths.communityEditName,
    pathParameters: postId,
    extra: post,
  );
  if (updated == null) return;

  ref
      .read(communityDetailNotifierProvider(post.id).notifier)
      .applyUpdatedPost(updated);
}
