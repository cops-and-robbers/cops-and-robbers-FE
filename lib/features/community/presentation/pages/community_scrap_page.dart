import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../community_report_action.dart';
import '../providers/community_scrap_provider.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_post_menu.dart';

/// 내 스크랩 목록 화면
///
/// `community_page.dart`의 목록 본문(무한 스크롤 리스너 + 카드 + 로딩·에러·빈
/// 상태)을 따르되, 스코프 토글·정렬 행·작성 버튼은 없다 — 스크랩 목록은 서버
/// 정렬이 고정이고 검색·필터가 없다.
///
/// 카드는 표시 전용이다(시안). 스크랩 해제는 상세에서만 일어나므로, 상세를
/// 갔다 돌아오는 시점에 그 글만 다시 조회해 해제 여부를 판정한다.
class CommunityScrapPage extends ConsumerStatefulWidget {
  const CommunityScrapPage({super.key});

  @override
  ConsumerState<CommunityScrapPage> createState() => _CommunityScrapPageState();
}

class _CommunityScrapPageState extends ConsumerState<CommunityScrapPage> {
  final ScrollController _scrollController = ScrollController();

  /// 바닥에서 이만큼 남았을 때 다음 페이지를 당긴다 — 스크롤이 멈추지 않을 최소 여유.
  static const double _loadMoreThreshold = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;
    // 프레임마다 호출되지만 Notifier의 isLoadingMore/hasMore 가드가 즉시 걸러낸다.
    unawaited(_loadMore());
  }

  Future<void> _loadMore() async {
    try {
      await ref.read(communityScrapNotifierProvider.notifier).loadMore();
    } on AppException catch (e) {
      if (!mounted) return;
      // AuthInterceptor가 강제 로그아웃을 처리하므로 UI는 무반응.
      if (e is AuthException) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    }
  }

  /// 더보기 메뉴 — 카드가 표시 전용이라 소유자 액션(수정·마감·삭제)은 배선하지
  /// 않는다. 내 글을 스크랩해 보는 드문 경우 그 항목을 눌러도 반응이 없을 뿐이다.
  void _handleCardMenu(CommunityPostMenuAction action, int postId) {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case CommunityPostMenuAction.login:
        AppSnackbar.show(context, message: l10n.communityLoginRequiredMessage);
        context.push(RoutePaths.login);
      case CommunityPostMenuAction.report:
        unawaited(reportCommunityPost(context, postId));
      case CommunityPostMenuAction.edit:
      case CommunityPostMenuAction.toggleStatus:
      case CommunityPostMenuAction.delete:
      // ponytail: 표시 전용 카드라 소유자 액션은 만들지 않는다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: l10n.pageCommunityScrapTitle,
        onBack: () => context.pop(),
      ),
      body: ref
          .watch(communityScrapNotifierProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            // AuthInterceptor가 강제 로그아웃(→ 화면 전환)을 처리하므로 UI는 무반응.
            error: (e, _) => e is AuthException
                ? const SizedBox.shrink()
                : Center(
                    child: EmptyState(
                      message: e is AppException
                          ? l10n.errorByException(e)
                          : l10n.errorCommunityScrapsLoadGeneric,
                    ),
                  ),
            data: (state) => state.items.isEmpty
                ? Center(child: EmptyState(message: l10n.communityScrapEmpty))
                : _buildList(state),
          ),
    );
  }

  Widget _buildList(CommunityScrapState state) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: AppSpacing.vertical16,
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vertical12),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final post = state.items[index];
        return CommunityPostCard(
          post: post,
          onTap: () async {
            await context.pushNamed(
              RoutePaths.communityDetailName,
              pathParameters: {'postId': '${post.id}'},
            );
            if (!context.mounted) return;
            await ref
                .read(communityScrapNotifierProvider.notifier)
                .dropIfUnscrapped(post.id);
          },
          onMenuAction: (action) => _handleCardMenu(action, post.id),
        );
      },
    );
  }
}
