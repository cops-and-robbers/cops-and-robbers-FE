import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';
import '../providers/community_feed_state.dart';
import '../providers/community_provider.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_scope_toggle.dart';
import '../widgets/community_sort_sheet.dart';

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

  // ponytail: 목데이터 모드의 가짜 페이지네이션 상태.
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

    // 작성 버튼은 어떤 provider에도 의존하지 않는다. 여기서 한 번만 만들어
    // 아래 Consumer들이 다시 그려도 이 서브트리는 재생성되지 않게 한다.
    final createButton = _buildCreateButton(l10n);

    // build()는 provider를 watch하지 않는다 — 여기서 watch하면 스코프 전환이나
    // 무한 스크롤의 isLoadingMore 토글마다 AppBar·정렬행·작성 버튼까지 전부
    // 다시 그려진다. 실제로 바뀌는 곳만 Consumer로 감싼다.
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
          // 후속 기능 연결 전까지 탭 여부만 로그로 확인한다.
          _buildAppBarIcon('assets/icons/icon_search.svg'),
          _buildAppBarIcon('assets/icons/icon_bell_off.svg'),
          SizedBox(width: AppSpacing.horizontal16),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.vertical16),
          Padding(
            padding: AppPadding.horizontal16,
            child: Consumer(
              builder: (context, ref, _) => CommunityScopeToggle(
                selected: ref.watch(selectedCommunityScopeProvider),
                onChanged: (next) => ref
                    .read(selectedCommunityScopeProvider.notifier)
                    .select(next),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vertical26),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) => _buildBody(
                l10n,
                ref,
                ref.watch(selectedCommunityScopeProvider),
                ref.watch(selectedCommunitySortProvider),
                createButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정렬 라벨 — 탭하면 정렬 선택 바텀시트를 연다.
  Widget _buildSortLabel(AppLocalizations l10n, CommunitySortOption sort) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 시트가 올라오기 전에 터치가 먹혔음을 알린다 (AppButton과 동일한 탭 햅틱).
        VibrationService.instance().buttonTap();
        _openSortSheet(sort);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _sortLabel(l10n, sort),
            style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
          ),
          SizedBox(width: AppSpacing.horizontal4),
          SvgPicture.asset(
            'assets/icons/icon_sort.svg',
            width: 10.w,
            height: 6.h,
          ),
        ],
      ),
    );
  }

  String _sortLabel(AppLocalizations l10n, CommunitySortOption sort) =>
      switch (sort) {
        CommunitySortOption.latest => l10n.communitySortLatest,
        CommunitySortOption.popular => l10n.communitySortPopular,
        CommunitySortOption.distance => l10n.communitySortDistance,
        CommunitySortOption.deadline => l10n.communitySortDeadline,
      };

  Future<void> _openSortSheet(CommunitySortOption current) async {
    final picked = await CommunitySortSheet.show(context, selected: current);
    if (picked == null || picked == current || !mounted) return;

    // 백엔드가 sort=LATEST 외에는 400을 준다. 선택을 반영하면 라벨만 "인기순"으로
    // 바뀌고 목록은 최신순 그대로라, 에러 없이 틀린 화면이 된다 — scope의
    // NEARBY/MINE과 같은 함정이다. 다른 값이 열리면 이 분기를 지우고 select()만 남긴다.
    if (picked != CommunitySortOption.latest) {
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).comingSoonMessage,
      );
      return;
    }
    ref.read(selectedCommunitySortProvider.notifier).select(picked);
  }

  Widget _buildAppBarIcon(String assetPath) {
    return IconButton(
      onPressed: () => debugPrint('🔍 앱바 아이콘 탭'),
      padding: EdgeInsets.only(left: AppSpacing.horizontal20),
      icon: SvgPicture.asset(assetPath, width: 22.w, height: 22.h),
    );
  }

  /// [ref]는 호출한 `Consumer`의 것을 받는다 — State의 `ref`로 watch하면 구독이
  /// 페이지 전체에 걸려 이 함수만 다시 그리려던 목적이 사라진다.
  Widget _buildBody(
    AppLocalizations l10n,
    WidgetRef ref,
    CommunityScope scope,
    CommunitySortOption sort,
    Widget createButton,
  ) {
    // 우리 동네 / 내 모임은 백엔드가 아직 400을 주므로 Notifier가 호출을 건너뛴다.
    // 작성 버튼은 새 글을 쓰는 진입점 자체라 어느 탭이든 동일하게 떠 있어야 한다.
    if (scope != CommunityScope.all) {
      return _wrapWithCreateButton(
        createButton,
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
                  createButton,
                  _buildRefreshablePlaceholder(
                    e is AppException
                        ? l10n.errorByException(e)
                        : l10n.errorCommunityPostsLoadFailed,
                  ),
                ),
          data: (feed) => feed.items.isEmpty
              ? _wrapWithCreateButton(
                  createButton,
                  _buildRefreshablePlaceholder(l10n.pageCommunityEmpty),
                )
              : _wrapWithCreateButton(
                  createButton,
                  _buildList(l10n, sort, feed),
                ),
        );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyState(message: message),
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

  /// 정렬 라벨을 목록 맨 위 아이템으로 넣어 카드와 함께 스크롤되게 한다
  /// (예전엔 Column 밖에 고정돼 있어 스크롤해도 안 내려갔다).
  Widget _buildList(
    AppLocalizations l10n,
    CommunitySortOption sort,
    CommunityFeedState feed,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal16,
          right: AppSpacing.horizontal16,
          // 마지막 카드가 작성 버튼에 가리지 않도록 버튼이 차지하는 높이만큼 비운다.
          // 버튼 높이에서 파생시켜야 버튼 크기를 바꿔도 같이 따라온다.
          bottom:
              _buttonBottomOffset + _createButtonHeight + AppSpacing.vertical16,
        ),
        itemCount: 1 + feed.items.length + (feed.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vertical12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal8),
              child: _buildSortLabel(l10n, sort),
            );
          }
          final itemIndex = index - 1;
          if (itemIndex >= feed.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final post = feed.items[itemIndex];
          return CommunityPostCard(
            post: post,
            onTap: () => _openDetail(post.id),
            // 목록에서는 어느 항목이든 상세로 보낸다 — 수정·삭제·상태 변경은
            // 대상 글을 보면서 하는 편이 안전하고, 처리 코드도 상세 한 곳에만 둔다.
            onMenuAction: (_) => _openDetail(post.id),
          );
        },
      ),
    );
  }

  /// 모집글 상세로 이동.
  void _openDetail(int postId) {
    VibrationService.instance().buttonTap();
    context.pushNamed(
      RoutePaths.communityDetailName,
      pathParameters: {'postId': '$postId'},
    );
  }

  double get _buttonBottomOffset =>
      AppSpacing.vertical20 + MediaQuery.paddingOf(context).bottom;

  /// 플로팅 작성 버튼 높이 — 버튼 자신과 목록 하단 여백이 함께 참조한다.
  double get _createButtonHeight => 42.h;

  /// 플로팅 모집글 작성 버튼 — `build()`에서 한 번만 만든다.
  ///
  /// 스코프나 목록 상태와 무관한 위젯이라, 여기서 만든 인스턴스를 각 분기가
  /// 그대로 재사용한다. 분기 안에서 새로 만들면 탭을 옮기거나 다음 페이지를
  /// 불러올 때마다 이 서브트리(SvgPicture 포함)가 통째로 다시 생성된다.
  Widget _buildCreateButton(AppLocalizations l10n) {
    // AppButton은 elevation 0 / shadowColor transparent로 그림자를 끄므로
    // 파라미터로 넘길 수 없다. 목록 위에 떠 있는 버튼이라 배경과 분리돼 보이도록
    // 카드와 같은 ver2 쉐도우를 밖에서 씌운다 (home_page.dart:589와 같은 방식).
    // 버튼과 같은 pill 반경을 줘야 그림자가 모양을 따라간다.
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.pill,
        boxShadow: AppShadows.ver2,
      ),
      child: AppButton(
        text: l10n.communityCreatePost,
        textStyle: AppTextStyles.paragraph14bold,
        onPressed: () => context.pushNamed(RoutePaths.communityCreateName),
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        showBorder: false,
        borderRadius: AppRadius.pill,
        width: 134.w,
        height: _createButtonHeight,
        // pill 가장자리와 아이콘·텍스트 사이 여백
        icon: SvgPicture.asset(
          'assets/icons/icon_write.svg',
          width: 14.w,
          height: 14.h,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// 목록 / 빈 상태 / 에러 상태 위에 공통으로 뜨는 작성 버튼을 얹는다.
  ///
  /// 준비 중 상태(우리 동네·내 모임)에도 띄운다 — 글쓰기 화면은 아직 없어 눌러도
  /// "준비 중이에요" 안내로 끝나는 건 다른 탭과 동일하니, 탭을 옮길 때마다
  /// 버튼이 사라졌다 나타나는 것보다 항상 같은 자리에 있는 편이 낫다.
  Widget _wrapWithCreateButton(Widget createButton, Widget content) {
    return Stack(
      children: [
        content,
        Positioned(
          bottom: _buttonBottomOffset,
          left: 0,
          right: 0,
          child: Center(child: createButton),
        ),
      ],
    );
  }
}
