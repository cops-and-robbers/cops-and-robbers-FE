import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading/app_refresh_control.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/route_paths.dart';
import '../providers/community_notification_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/community_notification_card.dart';

/// 알림함 화면
///
/// `community_scrap_page.dart`의 목록 본문(무한 스크롤 리스너 + 로딩·에러·빈
/// 상태)을 따른다. 화면을 나갈 때(`PopScope`) 읽음 처리를 한 번 호출한다 —
/// 개별 알림 클릭 시점에 불러도 서버 커서가 전역이라 결과가 같고(DEC-0038),
/// 이탈 시 한 번이 내비게이션 도중 취소 같은 엣지케이스가 없어 더 단순하다.
///
/// `dispose()`가 아니라 `PopScope`를 쓰는 이유: `dispose()`에서 불렀을 때는
/// 읽음 POST가 전혀 나가지 않았다(실측, 원인은 특정하지 못함). `PopScope`는
/// pop이 실제로 일어나는 시점에 위젯이 아직 살아 있고, 취소된 pop(`didPop`
/// false)을 걸러낼 수 있어 어느 쪽이든 더 낫다.
class CommunityNotificationPage extends ConsumerStatefulWidget {
  const CommunityNotificationPage({super.key});

  @override
  ConsumerState<CommunityNotificationPage> createState() =>
      _CommunityNotificationPageState();
}

class _CommunityNotificationPageState
    extends ConsumerState<CommunityNotificationPage> {
  final ScrollController _scrollController = ScrollController();

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

  /// 읽음 커서를 지금 시각으로 옮긴다. 실패해도 조용히 넘어간다 — 다음에
  /// 알림함을 열 때 다시 시도되고, 화면을 이미 나간 뒤라 재시도 UI가 없다.
  ///
  /// `ref`가 아니라 [ProviderContainer]를 직접 잡아 쓴다 — pop 직후 이
  /// 위젯은 곧 disposed되는데, `await` 너머(POST 응답을 기다리는 동안)에서
  /// `ref`를 다시 쓰면 "Cannot use ref after the widget was disposed"로
  /// 죽는다(안드로이드 실기기 실측). `ProviderContainer`는 이 위젯의 생명주기와
  /// 무관하므로 pop이 끝난 뒤에도 안전하게 쓸 수 있다.
  Future<void> _markRead() async {
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(communityRepositoryProvider).readNotifications();
    } catch (e) {
      // 화면이 이미 사라진 뒤라 보여줄 곳이 없다. 로그만 남긴다 — "읽음이
      // 안 된다"를 다시 겪을 때 여기서 실패했는지 알 수 있어야 한다.
      debugPrint('[알림함] ⚠️ 읽음 처리 실패 — 다음 진입 시 재시도: $e');
      return;
    }
    container.invalidate(communityNotificationUnreadCountProvider);
  }

  /// 당겨서 새로고침 — 첫 페이지부터 다시 받는다.
  ///
  /// 실패는 스낵바로 알린다. 알림함은 소켓이 없어 이 당김이 새 알림을 확인할
  /// 유일한 수단이라, 조용히 삼키면 "당겼는데 아무 일도 없다"가 된다.
  Future<void> _refresh() async {
    try {
      await ref.read(communityNotificationNotifierProvider.notifier).refresh();
    } on AppException catch (e) {
      if (!mounted) return;
      if (e is AuthException) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - _loadMoreThreshold) return;
    unawaited(_loadMore());
  }

  Future<void> _loadMore() async {
    try {
      await ref.read(communityNotificationNotifierProvider.notifier).loadMore();
    } on AppException catch (e) {
      if (!mounted) return;
      if (e is AuthException) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
        backgroundColor: AppColors.red,
      );
    }
  }

  void _openPost(int postId) {
    VibrationService.instance().buttonTap();
    context.pushNamed(
      RoutePaths.communityDetailName,
      pathParameters: {'postId': '$postId'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      // pop이 실제로 일어나는 이 시점에서 부른다(dispose()에서는 POST가 나가지
      // 않았다 — 클래스 문서 참고). didPop이 true일 때만이다(뒤로가기 확인
      // 다이얼로그 등으로 취소되면 didPop=false).
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        unawaited(_markRead());
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(
          title: l10n.pageCommunityNotificationTitle,
          onBack: () => context.pop(),
        ),
        body: ref
            .watch(communityNotificationNotifierProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => e is AuthException
                  ? const SizedBox.shrink()
                  : _buildRefreshablePlaceholder(
                      e is AppException
                          ? l10n.errorByException(e)
                          : l10n.errorCommunityNotificationsLoadGeneric,
                    ),
              data: (state) => state.items.isEmpty
                  ? _buildRefreshablePlaceholder(
                      l10n.communityNotificationEmpty,
                    )
                  : _buildList(state),
            ),
      ),
    );
  }

  /// 당겨서 새로고침이 가능한 플레이스홀더 (빈 목록 / 첫 로드 에러).
  ///
  /// 컨텐츠가 뷰포트를 다 채우지 않아도 당길 수 있어야 하므로
  /// `SliverFillRemaining`으로 남는 높이를 채운다(`community_feed_list.dart`와 같다).
  Widget _buildRefreshablePlaceholder(String message) {
    return AppRefreshControl(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: EmptyState(message: message)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(CommunityNotificationState state) {
    return AppRefreshControl(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppSpacing.horizontal16,
          right: AppSpacing.horizontal16,
          // AppBar와 첫 카드 사이만 16 더 준다(시안) — 나머지는 기본 16.
          top: AppSpacing.vertical16 + AppSpacing.vertical16,
          bottom: AppSpacing.vertical16,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vertical14),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final notification = state.items[index];
          return CommunityNotificationCard(
            notification: notification,
            onTap: () => _openPost(notification.communityPostId),
          );
        },
      ),
    );
  }
}
