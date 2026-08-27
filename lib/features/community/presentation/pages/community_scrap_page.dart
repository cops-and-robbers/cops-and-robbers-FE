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

  /// 상세로 이동한 뒤, 그 글이 스크랩 해제됐으면 목록에서 걷어낸다.
  ///
  /// 카드 탭과 더보기의 소유자 액션(수정·마감·삭제)이 함께 쓴다 — 이 화면은
  /// 카드가 표시 전용이라 그 액션들을 여기서 직접 처리하지 않고, 실제로 처리할
  /// 수 있는 상세 화면으로 보낸다.
  Future<void> _openDetail(int postId) async {
    await context.pushNamed(
      RoutePaths.communityDetailName,
      pathParameters: {'postId': '$postId'},
    );
    if (!context.mounted) return;
    await ref
        .read(communityScrapNotifierProvider.notifier)
        .dropIfUnscrapped(postId);
  }

  /// 더보기 메뉴.
  ///
  /// 내 글도 스크랩할 수 있어(상세 화면이 작성자 여부를 가리지 않는다) 이
  /// 목록에 내 글이 뜰 수 있고, 그러면 메뉴가 수정·마감·삭제를 정상 항목으로
  /// 보여준다. 카드가 표시 전용이라 여기서 직접 처리하지 않고 상세로 보낸다 —
  /// 조용히 무시하면 사용자가 삭제 등을 실행했다고 믿고 돌아가는 사고가 난다.
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
        unawaited(_openDetail(postId));
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
          onTap: () => unawaited(_openDetail(post.id)),
          onMenuAction: (action) => _handleCardMenu(action, post.id),
        );
      },
    );
  }
}
