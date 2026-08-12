import 'dart:async'; // unawaited

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/loading/app_loading.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notice_category.dart';
import '../../domain/entities/notice_entity.dart';
import '../providers/notice_provider.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_category_chips.dart';

/// 공지사항 페이지
///
/// 상단 고정 카테고리 칩으로 필터링하고, 그 아래 카드 목록을 아코디언
/// (펼침/접기) 형태로 표시하며 하단에 페이지네이션 바를 제공한다.
/// 백엔드는 고정 공지(pinned=true)를 우선 정렬해 응답하며,
/// UI에서는 제목 앞 핀 아이콘으로 시각적 구분한다.
class NoticesPage extends ConsumerStatefulWidget {
  const NoticesPage({super.key});

  @override
  ConsumerState<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends ConsumerState<NoticesPage> {
  /// 스크롤 위치 제어 (페이지 변경 시 상단 복귀)
  final ScrollController _scrollController = ScrollController();

  /// 현재 펼쳐진 공지사항 인덱스 (-1이면 모두 접힌 상태)
  int _expandedIndex = -1;

  /// 로딩 오버레이 핸들 (null이면 미표시)
  LoadingHandle? _loadingHandle;

  @override
  void initState() {
    super.initState();
    // 첫 진입 시 자동 fetch 동안 로딩 팝업 표시.
    // build() 시점에 띄우면 매 rebuild마다 호출되므로 post-frame에서 1회만.
    // 또한 post-frame 도달 전 응답이 이미 도착했을 수 있으므로 state를 한 번 더 체크
    // (race 방지 — 캐시/매우 빠른 응답 케이스).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final asyncState = ref.read(noticesNotifierProvider);
      if (!asyncState.isLoading) return;
      _showLoadingPopup();
    });
  }

  @override
  void dispose() {
    // 화면이 먼저 사라져도 로딩 라우트가 남지 않도록 정리
    final handle = _loadingHandle;
    _loadingHandle = null;
    if (handle != null) unawaited(handle.close());
    _scrollController.dispose();
    super.dispose();
  }

  void _showLoadingPopup() {
    if (_loadingHandle != null) return;
    _loadingHandle = AppLoading.showMessage(
      context,
      message: AppLocalizations.of(context).messageLoadingNotices,
    );
  }

  void _closeLoadingPopupIfShown() {
    final handle = _loadingHandle;
    if (handle == null) return;
    _loadingHandle = null;
    // 리스너 콜백이라 await할 수 없다. 최소 표시 시간은 핸들이 알아서 지킨다.
    unawaited(handle.close());
  }

  void _handleStateChange(
    AsyncValue<NoticePageEntity>? prev,
    AsyncValue<NoticePageEntity> next,
  ) {
    // mounted 가드는 첫 context 사용 직전에. dispose 후 stale context 방지.
    next.when(
      data: (page) {
        if (!mounted) return;
        _closeLoadingPopupIfShown();
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        // 페이지 전환 후 펼친 항목 자동 접기 (사용자 혼선 방지).
        if (_expandedIndex != -1) {
          setState(() => _expandedIndex = -1);
        }
      },
      loading: () {
        // 로딩 팝업은 액션 시점(initState/페이지 클릭)에 띄우므로 여기서는 no-op.
      },
      error: (e, _) {
        if (!mounted) return;
        _closeLoadingPopupIfShown();
        // AuthInterceptor가 강제 로그아웃을 처리하므로 UI는 무반응.
        if (e is AuthException) return;
        final l10n = AppLocalizations.of(context);
        final msg = e is AppException
            ? l10n.errorByException(e)
            : l10n.errorNoticeLoadFailed;
        AppSnackbar.show(context, message: msg, backgroundColor: AppColors.red);
      },
    );
  }

  void _onPageChanged(int newPage) {
    // 이전 fetch가 진행 중이면 무시 (중복 요청 + 팝업 노이즈 방지).
    if (ref.read(noticesNotifierProvider).isLoading) return;
    _showLoadingPopup();
    ref.read(noticesNotifierProvider.notifier).fetchPage(newPage);
  }

  /// 카테고리 필터 전환.
  ///
  /// 페이지 이동과 달리 로딩 팝업을 띄우지 않는다 — 칩 색이 탭 즉시 바뀌는 것이
  /// 이미 피드백이고, 응답이 올 때까지 이전 목록이 그대로 보여 화면을 가릴 이유가 없다.
  void _onCategorySelected(NoticeCategory category) {
    final state = ref.read(noticesNotifierProvider);
    // 이전 fetch가 진행 중이면 무시 (중복 요청 방지).
    if (state.isLoading) return;

    if (ref.read(selectedNoticeCategoryProvider) == category) {
      // 같은 칩 재탭은 직전 조회가 실패했을 때만 재시도로 받는다.
      // 이때 select()를 쓰면 안 된다 — updateShouldNotify가 identical() 비교라
      // 같은 enum 값은 알림이 나가지 않아 NoticesNotifier가 재빌드되지 않는다.
      // provider를 직접 무효화해 재조회를 강제한다.
      if (!state.hasError) return;
      ref.invalidate(noticesNotifierProvider);
      return;
    }

    // NoticesNotifier.build()가 이 provider를 watch 하므로
    // 상태만 바꾸면 0페이지부터 자동 재조회된다.
    ref.read(selectedNoticeCategoryProvider.notifier).select(category);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<NoticePageEntity>>(
      noticesNotifierProvider,
      _handleStateChange,
    );

    final asyncState = ref.watch(noticesNotifierProvider);
    // valueOrNull을 쓰는 이유: 첫 로드 실패처럼 이전 값이 없는 AsyncError에서
    // .value는 예외를 rethrow해 화면이 ErrorWidget으로 깨진다.
    // 여기서는 "데이터 없음"으로 받아 _buildBody의 null 분기가 처리하게 한다.
    final pageData = asyncState.valueOrNull;

    return Scaffold(
      // AppBar만 흰색이고 그 아래 본문은 홈과 같은 연하늘 배경.
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).pageNoticesTitle,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: Column(
        children: [
          // ── [고정] 카테고리 필터 ──
          // 목록 스크롤 밖에 두어, 아래로 내려도 필터가 남아 있게 한다.
          SizedBox(height: AppSpacing.vertical16),
          NoticeCategoryChips(onSelected: _onCategorySelected),
          SizedBox(height: AppSpacing.vertical24),

          Expanded(child: _buildBody(pageData)),
        ],
      ),
    );
  }

  Widget _buildBody(NoticePageEntity? pageData) {
    // 첫 진입 시: state.value가 null. 팝업이 화면을 가린 상태로 빈 영역.
    if (pageData == null) {
      return const SizedBox.shrink();
    }

    final notices = pageData.items;
    final totalPages = pageData.totalPages;
    final currentPage = pageData.currentPage;

    if (notices.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).pageNoticesEmpty,
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black600),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
        final paginationBottomOffset = AppSpacing.vertical16 + bottomSafeArea;

        return Stack(
          children: [
            // ── 공지사항 카드 목록 ──
            SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: AppPadding.horizontal16,
                child: Column(
                  children: [
                    for (int i = 0; i < notices.length; i++) ...[
                      NoticeCard(
                        notice: notices[i],
                        isExpanded: _expandedIndex == i,
                        onTap: () => setState(() {
                          _expandedIndex = _expandedIndex == i ? -1 : i;
                        }),
                      ),
                      if (i != notices.length - 1)
                        SizedBox(height: AppSpacing.vertical18),
                    ],
                    // 하단 페이지네이션 바와 겹치지 않도록 여백 추가
                    SizedBox(height: paginationBottomOffset + 60.h),
                  ],
                ),
              ),
            ),

            // ── 플로팅 페이지네이션 바 ──
            if (totalPages > 1)
              Positioned(
                bottom: paginationBottomOffset,
                left: 0,
                right: 0,
                child: Center(
                  child: PaginationBar(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: _onPageChanged,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
