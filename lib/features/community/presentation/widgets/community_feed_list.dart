import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' show LocationPermission;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading/app_refresh_control.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';
import '../community_editor_route.dart';
import '../providers/community_feed_state.dart';
import '../providers/community_provider.dart';
import 'community_post_card.dart';
import 'community_post_menu.dart';
import 'community_sort_sheet.dart';

/// 커뮤니티 모집글 무한 스크롤 목록
///
/// 정렬 라벨 + 카드 목록 + 당겨서 새로고침 + 카드 더보기 동작을 함께 소유한다.
/// 목록 화면과 검색 화면이 같은 동작을 필요로 해 하나로 둔다 — 스크롤 리스너,
/// `loadMore` 중복 요청 가드, 에러 스낵바, 새로고침이 묶여 있어 복제하면
/// 한쪽만 고치는 사고가 난다.
///
/// [keyword]가 null이면 목록, 값이 있으면 검색 결과다. 그 구분은 이 위젯이
/// 쓰지 않고 provider의 family 키로 그대로 넘어간다.
class CommunityFeedList extends ConsumerStatefulWidget {
  const CommunityFeedList({
    super.key,
    required this.scope,
    required this.sort,
    required this.emptyMessage,
    this.keyword,
    this.bottomPadding = 0,
  });

  final CommunityScope scope;
  final CommunitySortOption sort;

  /// null = 목록, 값 있음 = 검색 결과.
  final String? keyword;

  /// 조회 결과가 비었을 때 보여줄 문구. 목록과 검색이 다른 말을 쓴다.
  final String emptyMessage;

  /// 목록 하단에 비워 둘 높이. 목록 화면은 떠 있는 작성 버튼에 마지막 카드가
  /// 가리지 않도록 버튼 높이만큼 넘긴다. 검색 화면은 버튼이 없어 0이다.
  final double bottomPadding;

  @override
  ConsumerState<CommunityFeedList> createState() => _CommunityFeedListState();
}

class _CommunityFeedListState extends ConsumerState<CommunityFeedList> {
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

  /// 지금 보고 있는 목록. 스코프·정렬·검색어마다 인스턴스가 따로라 동작마다 짚어 줘야 한다.
  CommunityFeedNotifier get _feed => ref.read(
    communityFeedNotifierProvider(
      widget.scope,
      widget.sort,
      widget.keyword,
    ).notifier,
  );

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;
    // 프레임마다 호출되지만 Notifier의 isLoadingMore/hasMore 가드가 즉시 걸러낸다.
    unawaited(_loadMore());
  }

  Future<void> _loadMore() async {
    try {
      await _feed.loadMore();
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

  // ==========================================================================
  // 카드 더보기 메뉴
  //
  // 제자리 동작(마감·삭제)은 여기서 끝낸다 — 그 카드만 갈아끼우거나 빼면 되고,
  // 목록을 무효화하면 커서가 0으로 돌아가 스크롤 위치가 통째로 날아간다.
  // 화면을 떠나는 동작(수정)만 상세를 경유한다.
  // ==========================================================================

  void _handleCardMenu(
    CommunityPostEntity post,
    CommunityPostMenuAction action,
  ) {
    final l10n = AppLocalizations.of(context);

    switch (action) {
      case CommunityPostMenuAction.login:
        AppSnackbar.show(context, message: l10n.communityLoginRequiredMessage);
        context.push(RoutePaths.login);
      case CommunityPostMenuAction.report:
        // ponytail: 게시글 신고 API가 아직 없다 (상세와 같은 상태).
        AppSnackbar.show(context, message: l10n.comingSoonMessage);
      case CommunityPostMenuAction.edit:
        VibrationService.instance().buttonTap();
        // 상세를 먼저 깔고 그 위로 연다 — 완료든 취소든 닫았을 때 목록이 아니라
        // 방금 보던 글이 나와야 한다.
        unawaited(openCommunityEditor(context, ref, post, fromList: true));
      case CommunityPostMenuAction.toggleStatus:
        unawaited(_runCardAction(() => _feed.toggleStatus(post)));
      case CommunityPostMenuAction.delete:
        unawaited(_confirmDelete(l10n, post.id));
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n, int postId) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: l10n.communityDeleteConfirmTitle,
      message: l10n.communityDeleteConfirmMessage,
      confirmText: l10n.communityMenuDelete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    await _runCardAction(() => _feed.deletePost(postId));
  }

  /// 카드 하나에 대한 서버 동작을 감싼다 — 실패는 스낵바로만 알린다.
  ///
  /// 이미 사라진 글이면 Notifier가 카드를 먼저 걷어낸 뒤 예외를 올린다. 화면은
  /// 여기서 이동하지 않는다 — 사용자는 이미 목록에 있고, 유령 카드가 사라지는
  /// 것으로 결과가 보인다.
  Future<void> _runCardAction(Future<void> Function() action) async {
    VibrationService.instance().buttonTap();
    try {
      await action();
    } on AppException catch (e) {
      if (!mounted) return;
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
      await _feed.refresh();
    } on AppException catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ref
        .watch(
          communityFeedNotifierProvider(
            widget.scope,
            widget.sort,
            widget.keyword,
          ),
        )
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // AuthInterceptor가 강제 로그아웃(→ 화면 전환)을 처리하므로 UI는 무반응.
          // 첫 로드라 화면에 아직 아무 데이터가 없어 무반응 = 빈 화면.
          error: (e, _) => e is AuthException
              ? const SizedBox.shrink()
              : _buildRefreshablePlaceholder(
                  e is AppException
                      ? l10n.errorByException(e)
                      : l10n.errorCommunityPostsLoadFailed,
                ),
          data: (feed) => feed.items.isEmpty
              ? _buildRefreshablePlaceholder(widget.emptyMessage)
              : _buildList(l10n, feed),
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

  /// 정렬 시트를 띄우고 고른 값을 반영한다.
  ///
  /// 거리순만 위치 좌표가 있어야 성립하므로, 그때만 권한을 확보한 뒤에 정렬을
  /// 바꾼다. 목록 자체는 권한 없이 계속 보이고 거부해도 이전 정렬로 쓰므로
  /// 진입을 막는 게이트가 아니다.
  Future<void> _openSortSheet(CommunitySortOption current) async {
    final picked = await CommunitySortSheet.show(context, selected: current);
    if (picked == null || picked == current || !mounted) return;

    if (picked == CommunitySortOption.distance &&
        !await _ensureLocationForDistance()) {
      return;
    }
    if (!mounted) return;

    ref.read(selectedCommunitySortProvider.notifier).select(picked);
  }

  /// 거리순에 쓸 위치 권한을 확보한다. 실패하면 안내만 하고 false.
  ///
  /// 영구 거부를 따로 가르는 이유: 안드로이드는 두 번 거부하면 시스템 팝업을
  /// 더 띄우지 않는다. 같은 문구를 반복해 봐야 아무 일도 일어나지 않으므로
  /// 설정으로 안내한다.
  Future<bool> _ensureLocationForDistance() async {
    final granted = await ref.read(ensureLocationPermissionProvider)();
    if (!mounted) return false;

    if (granted) {
      // 권한이 없던 동안 국가는 기기 로케일 폴백이었다. 좌표가 생겼으니 다시
      // 판정한다 — 아니면 해외에 있는 한국 로케일 사용자가 한국 목록을 현지
      // 좌표로 거리순 정렬하게 된다(DEC-0021).
      ref.invalidate(communityCountryCodeProvider);
      return true;
    }

    final deniedForever =
        await ref.read(checkLocationPermissionProvider)() ==
        LocationPermission.deniedForever;
    if (!mounted) return false;

    final l10n = AppLocalizations.of(context);
    AppSnackbar.show(
      context,
      message: deniedForever
          ? l10n.communitySortLocationDenied
          : l10n.communitySortNeedsLocation,
    );
    return false;
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
  /// 컨텐츠가 뷰포트를 다 채우지 않아도 당길 수 있어야 하므로,
  /// `SliverFillRemaining`으로 남는 높이를 채우고
  /// `AlwaysScrollableScrollPhysics`로 항상 스크롤 가능하게 한다.
  Widget _buildRefreshablePlaceholder(String message) {
    return AppRefreshControl(
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
  Widget _buildList(AppLocalizations l10n, CommunityFeedState feed) {
    return AppRefreshControl(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal16,
          right: AppSpacing.horizontal16,
          bottom: widget.bottomPadding + AppSpacing.vertical16,
        ),
        itemCount: 1 + feed.items.length + (feed.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vertical12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal8),
              child: _buildSortLabel(l10n, widget.sort),
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
            onMenuAction: (action) => _handleCardMenu(post, action),
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
}
