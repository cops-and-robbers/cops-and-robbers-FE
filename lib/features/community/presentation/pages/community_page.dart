import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_scope.dart';
import '../providers/community_feed_state.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_scope_toggle.dart';

/// 커뮤니티 탭 — 모집글 목록
///
/// `MainScaffold`가 body와 바텀네비만 소유하므로 AppBar는 이 페이지가 갖는다.
/// 탭 루트라 돌아갈 곳이 없어 leading(뒤로가기)은 두지 않는다.
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
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
      await ref.read(communityFeedNotifierProvider.notifier).loadMore();
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

  /// pull-to-refresh — 0페이지부터 다시 조회한다.
  ///
  /// 실패해도 provider의 error 상태가 placeholder로 이미 반영되므로, 여기서는
  /// RefreshIndicator에 완료 신호만 주기 위해 예외를 흡수한다(별도 스낵바 불필요).
  Future<void> _refresh() async {
    try {
      await ref.read(communityFeedNotifierProvider.notifier).refresh();
    } on AppException catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = ref.watch(selectedCommunityScopeProvider);

    return Scaffold(
      // AppBar만 흰색이고 그 아래 본문은 홈과 같은 연하늘 배경.
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          l10n.pageCommunityTitle,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        actions: [
          // 검색은 백엔드에 keyword 쿼리가 없고 알림은 기능 자체가 없다.
          // 시안의 앱바 균형을 위해 자리만 두고 탭은 받지 않는다 (#475 범위 제외).
          _buildAppBarIcon('assets/icons/icon_search.svg'),
          _buildAppBarIcon('assets/icons/icon_bell_off.svg'),
          SizedBox(width: AppSpacing.horizontal16),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.vertical16),
          Padding(
            padding: AppPadding.horizontal20,
            child: CommunityScopeToggle(
              selected: scope,
              onChanged: (next) => ref
                  .read(selectedCommunityScopeProvider.notifier)
                  .select(next),
            ),
          ),
          SizedBox(height: AppSpacing.vertical26),
          Padding(
            padding: AppPadding.horizontal20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 정렬 옵션은 백엔드 sort 쿼리가 생기면 드롭다운으로 연다.
                Text(
                  l10n.communitySortLatest,
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),
                SizedBox(width: AppSpacing.horizontal4),
                SvgPicture.asset(
                  'assets/icons/icon_down.svg',
                  width: 12.w,
                  height: 12.h,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.vertical12),
          Expanded(child: _buildBody(l10n, scope)),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(String assetPath) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.horizontal8),
      child: SvgPicture.asset(assetPath, width: 24.w, height: 24.h),
    );
  }

  Widget _buildBody(AppLocalizations l10n, CommunityScope scope) {
    // 우리 동네 / 내 모임은 백엔드 scope 쿼리가 없어 Notifier가 호출을 건너뛴다.
    // 작성 버튼은 새 글을 쓰는 진입점 자체라 어느 탭이든 동일하게 떠 있어야 한다.
    if (scope != CommunityScope.all) {
      return _wrapWithCreateButton(
        l10n,
        _buildPlaceholder(l10n.comingSoonMessage),
      );
    }

    return ref
        .watch(communityFeedNotifierProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // AuthInterceptor가 강제 로그아웃(→ 화면 전환)을 처리하므로 UI는 무반응.
          // 첫 로드라 화면에 아직 아무 데이터가 없어 무반응 = 빈 화면(_loadMore()와 동일 원칙).
          // 이 분기만 작성 버튼도 함께 감춘다 — 화면이 곧 사라질 텐데 누를 거리를
          // 잠깐 보여줄 이유가 없다.
          error: (e, _) => e is AuthException
              ? const SizedBox.shrink()
              : _wrapWithCreateButton(
                  l10n,
                  _buildRefreshablePlaceholder(
                    e is AppException
                        ? l10n.errorByException(e)
                        : l10n.errorCommunityPostsLoadFailed,
                  ),
                ),
          data: (feed) => feed.items.isEmpty
              ? _wrapWithCreateButton(
                  l10n,
                  _buildRefreshablePlaceholder(l10n.pageCommunityEmpty),
                )
              : _wrapWithCreateButton(l10n, _buildList(feed)),
        );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/icons/icon_not_found.svg', width: 110.w),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            message,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
          ),
          // 위쪽 토글·정렬 라벨만큼 아래를 채워 화면 기준 가운데로 보이게 한다.
          SizedBox(height: AppSpacing.vertical64),
        ],
      ),
    );
  }

  /// 당겨서 새로고침이 가능한 플레이스홀더 (빈 목록 / 첫 로드 에러).
  ///
  /// `RefreshIndicator`는 컨텐츠가 뷰포트를 다 채우지 않아도 당길 수 있어야
  /// 하므로, `SliverFillRemaining`으로 남는 높이를 채우고
  /// `AlwaysScrollableScrollPhysics`로 항상 스크롤 가능하게 한다.
  Widget _buildRefreshablePlaceholder(String message) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildPlaceholder(message),
          ),
        ],
      ),
    );
  }

  Widget _buildList(CommunityFeedState feed) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal20,
          right: AppSpacing.horizontal20,
          // 하단 작성 버튼과 겹치지 않도록 여백 추가
          bottom: _buttonBottomOffset + 72.h,
        ),
        // AppShadows.ver2가 blur 10이라 기본 클립에 그림자가 잘린다.
        clipBehavior: Clip.none,
        itemCount: feed.items.length + (feed.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vertical12),
        itemBuilder: (context, index) {
          if (index >= feed.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          // 카드 탭은 상세 화면이 생기면 연결한다 (#475 범위 제외).
          return CommunityPostCard(post: feed.items[index]);
        },
      ),
    );
  }

  double get _buttonBottomOffset =>
      AppSpacing.vertical16 + MediaQuery.paddingOf(context).bottom;

  /// 목록 / 빈 상태 / 에러 상태 위에 공통으로 뜨는 플로팅 모집글 작성 버튼.
  ///
  /// 준비 중 상태(우리 동네·내 모임)에도 띄운다 — 글쓰기 화면은 아직 없어 눌러도
  /// "준비 중이에요" 안내로 끝나는 건 다른 탭과 동일하니, 탭을 옮길 때마다
  /// 버튼이 사라졌다 나타나는 것보다 항상 같은 자리에 있는 편이 낫다.
  Widget _wrapWithCreateButton(AppLocalizations l10n, Widget content) {
    return Stack(
      children: [
        content,
        Positioned(
          bottom: _buttonBottomOffset,
          left: 0,
          right: 0,
          child: Center(
            child: AppButton(
              text: l10n.communityCreatePost,
              // 작성 화면은 후속 작업이다. 죽은 버튼으로 두지 않고 안내만 띄운다.
              onPressed: () =>
                  AppSnackbar.show(context, message: l10n.comingSoonMessage),
              backgroundColor: AppColors.logo,
              foregroundColor: AppColors.white,
              showBorder: false,
              borderRadius: AppRadius.pill,
              width: 196.w,
              height: 56.h,
              icon: SvgPicture.asset(
                'assets/icons/icon_write.svg',
                width: 20.w,
                height: 20.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
