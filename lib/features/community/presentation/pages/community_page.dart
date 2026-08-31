import 'dart:async';

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
import '../../../../core/services/lifecycle/lifecycle_provider.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router/current_branch_index_provider.dart';
import '../../../../router/route_paths.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';
import '../providers/community_chat_socket_provider.dart';
import '../providers/community_notification_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/community_chat_room_list.dart';
import '../widgets/community_feed_list.dart';
import '../widgets/community_scope_toggle.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';

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
  @override
  void initState() {
    super.initState();
    // 생명주기 감지는 이 서비스가 observer를 등록해야 시작된다. 등록 지점이
    // activate() 하나뿐이라, 부르지 않으면 아래 lifecycleStateProvider 구독이
    // 영원히 값을 받지 못한다. 멱등이고, provider가 폐기될 때 대칭적으로
    // deactivate()된다.
    ref.read(appLifecycleServiceProvider).activate();
  }

  @override
  Widget build(BuildContext context) {
    // 다른 탭이나 게임에 갔다가 돌아왔을 때. 상세·검색은 셸 위에 떠서 이 값을
    // 바꾸지 않으므로, 글을 오래 읽고 나와도 목록이 초기화되지 않는다.
    ref.listen(currentBranchIndexProvider, (previous, next) {
      if (previous == next) return;
      if (next != RoutePaths.communityBranchIndex) return;
      unawaited(_refreshIfStale());
      // 알림함은 소켓이 없어 이 탭으로 돌아오는 시점이 배지를 다시 볼 유일한
      // 기회다 — 알림함을 거치지 않고 나갔다 왔어도(다른 탭에서 댓글이
      // 달렸을 수 있으니) 매번 다시 받는다.
      ref.invalidate(communityNotificationUnreadCountProvider);
    });

    // 앱이 백그라운드에서 돌아왔을 때.
    ref.listen(lifecycleStateProvider, (previous, next) {
      if (next.valueOrNull != AppLifecycleState.resumed) return;
      // 커뮤니티 탭이 아니면 보이지 않는 화면이다. 안 보이는 것을 위해
      // 네트워크를 쓰지 않는다.
      if (ref.read(currentBranchIndexProvider) !=
          RoutePaths.communityBranchIndex) {
        return;
      }
      unawaited(_refreshIfStale());
      ref.invalidate(communityNotificationUnreadCountProvider);
    });

    // 이전에 봤던 정렬로 돌아가면 그 인스턴스는 keepAlive로 살아 있고 낡은
    // 채다. 정렬 전환은 브랜치 인덱스를 바꾸지 않아 위 트리거가 울리지 않는다.
    ref.listen(selectedCommunitySortProvider, (previous, next) {
      if (previous == next) return;
      unawaited(_refreshIfStale());
    });

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
      appBar: AppTopBar(
        title: l10n.pageCommunityTitle,
        actions: [
          _buildAppBarIcon(
            'assets/icons/icon_search.svg',
            onTap: () {
              VibrationService.instance().buttonTap();
              context.pushNamed(RoutePaths.communitySearchName);
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref
                  .watch(communityNotificationUnreadCountProvider)
                  .valueOrNull;
              final hasUnread = unreadCount != null && unreadCount > 0;
              // 종 모양이 그대로인 icon_noti.svg 하나만 쓰고 배지는 직접
              // 그린다 — 예전엔 icon_noti_on.svg로 통째로 바꿨는데, 그 svg가
              // 종 모양을 캔버스 안 다른 위치에 그려놔서(배지 자리만큼 내부
              // 여백이 다름) 전환할 때 종 모양이 미세하게 움직여 보였다(실측).
              return _buildAppBarIcon(
                'assets/icons/icon_noti.svg',
                showBadge: hasUnread,
                onTap: () {
                  VibrationService.instance().buttonTap();
                  context.pushNamed(RoutePaths.communityNotificationName);
                },
              );
            },
          ),
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

  /// 지금 보고 있는 목록이 낡았으면 조용히 다시 받는다.
  ///
  /// 검색어 자리에 항상 `null`을 넘기는 이유: 검색 결과는 화면을 나가면
  /// 폐기되므로 유효 시간을 따질 대상이 아니다.
  Future<void> _refreshIfStale() async {
    // 내 모임은 소켓이 갱신한다(유저당 알림 채널, DEC-0045). 돌아오는 순간에
    // 할 일은 재조회가 아니라 "혹시 끊겼으면 다시 붙이기"다 — 붙어 있으면 무동작.
    // 재연결이 소진된 뒤에도 사용자가 돌아오는 것으로 다시 시도가 풀린다.
    if (ref.read(selectedCommunityScopeProvider) == CommunityScope.mine) {
      ref.read(communityChatSocketProvider.notifier).reconnectNow();
      return;
    }

    try {
      await ref
          .read(
            communityFeedNotifierProvider(
              ref.read(selectedCommunityScopeProvider),
              ref.read(selectedCommunitySortProvider),
              null,
            ).notifier,
          )
          .refreshIfStale();
    } on AppException catch (_) {
      // 사용자가 부른 동작이 아니다. 실패는 provider의 에러 상태로 이미 화면에
      // 반영되므로 여기서 스낵바를 띄우지 않는다.
      debugPrint('[커뮤니티] ⚠️ 배경 갱신 실패 — 목록이 낡을 수 있음');
    }
  }

  Widget _buildAppBarIcon(
    String assetPath, {
    VoidCallback? onTap,
    bool showBadge = false,
  }) {
    return IconButton(
      onPressed: onTap ?? () => debugPrint('🔍 앱바 아이콘 탭'),
      padding: EdgeInsets.only(left: AppSpacing.horizontal20),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(assetPath, width: 24.w, height: 24.h),
          // 아이콘 자체를 바꾸지 않고 배지만 얹는다 — icon_noti_on.svg로
          // 통째로 바꾸면 두 svg의 내부 여백이 달라 전환할 때 종 모양이
          // 미세하게 움직여 보였다(실측).
          if (showBadge)
            Positioned(
              right: -3.w,
              top: -3.h,
              child: Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.w),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    WidgetRef ref,
    CommunityScope scope,
    CommunitySortOption sort,
    Widget createButton,
  ) {
    // 우리 동네는 백엔드가 아직 400을 주므로 provider를 부르지 않는다.
    // 작성 버튼은 새 글을 쓰는 진입점 자체라 어느 탭이든 동일하게 떠 있어야 한다.
    if (scope == CommunityScope.nearby) {
      return _wrapWithCreateButton(
        createButton,
        _buildPlaceholder(l10n.comingSoonMessage),
      );
    }
    // 내 모임 = 참여 중인 채팅방 목록 (시안 `커뮤니티_내 모임`)
    if (scope == CommunityScope.mine) {
      return _wrapWithCreateButton(
        createButton,
        CommunityChatRoomList(
          bottomPadding: _buttonBottomOffset + _createButtonHeight,
        ),
      );
    }

    final feedList = CommunityFeedList(
      scope: scope,
      sort: sort,
      emptyMessage: l10n.pageCommunityEmpty,
      // 마지막 카드가 떠 있는 작성 버튼에 가리지 않도록 비운다.
      bottomPadding: _buttonBottomOffset + _createButtonHeight,
      // 이 화면은 위에 스코프 토글·정렬 라벨이 있어 빈 상태 문구가 그만큼
      // 위로 치우친다 — 그 높이만큼 아래를 채워 화면 기준 가운데로 보정한다.
      emptyStateCenterOffset: AppSpacing.vertical64,
    );

    // 로딩 중이거나 AuthInterceptor가 강제 로그아웃(→ 화면 전환)을 처리할
    // AuthException 상태에서는 화면이 곧 사라지거나 아직 아무것도 없으므로
    // 누를 거리를 잠깐 보여줄 이유가 없다 — 작성 버튼도 함께 감춘다.
    // CommunityFeedList가 그 상태에서 무반응(SizedBox.shrink)으로 그리는 것과
    // 짝을 이루는 판단이라 같은 provider 상태를 여기서 한 번 더 살핀다.
    final showCreateButton = ref
        .watch(communityFeedNotifierProvider(scope, sort, null))
        .maybeWhen(
          data: (_) => true,
          error: (e, _) => e is! AuthException,
          orElse: () => false,
        );

    return showCreateButton
        ? _wrapWithCreateButton(createButton, feedList)
        : feedList;
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
