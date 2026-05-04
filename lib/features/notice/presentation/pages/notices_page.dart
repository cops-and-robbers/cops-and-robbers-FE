import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/dialogs/app_popup.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../domain/entities/notice_entity.dart';
import '../providers/notice_provider.dart';

/// 공지사항 페이지
///
/// 공지사항 목록을 아코디언(펼침/접기) 형태로 표시하며,
/// 하단에 페이지네이션 바를 제공한다. 백엔드는 고정 공지(pinned=true)를
/// 우선 정렬해 응답하며, UI에서는 제목 앞에 아이콘으로 시각적 구분한다.
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

  /// 로딩 팝업 노출 중인지 추적 (이중 close 방지)
  bool _isLoadingPopupShown = false;

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
    _scrollController.dispose();
    super.dispose();
  }

  void _showLoadingPopup() {
    if (_isLoadingPopupShown) return;
    _isLoadingPopupShown = true;
    AppPopup.showLoading(context: context, message: '공지사항을 불러오는 중...');
  }

  void _closeLoadingPopupIfShown() {
    if (!_isLoadingPopupShown) return;
    _isLoadingPopupShown = false;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
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
        final msg = e is AppException
            ? e.message
            : '공지사항을 불러오지 못했어요';
        AppSnackbar.show(
          context,
          message: msg,
          backgroundColor: AppColors.red,
        );
      },
    );
  }

  void _onPageChanged(int newPage) {
    // 이전 fetch가 진행 중이면 무시 (중복 요청 + 팝업 노이즈 방지).
    if (ref.read(noticesNotifierProvider).isLoading) return;
    _showLoadingPopup();
    ref.read(noticesNotifierProvider.notifier).fetchPage(newPage);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<NoticePageEntity>>(
      noticesNotifierProvider,
      _handleStateChange,
    );

    final asyncState = ref.watch(noticesNotifierProvider);
    final pageData = asyncState.value;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: Text(
          '공지사항',
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
      ),
      body: _buildBody(pageData),
    );
  }

  Widget _buildBody(NoticePageEntity? pageData) {
    // 첫 진입 시: state.value가 null. 팝업이 화면을 가린 상태로 빈 Scaffold.
    if (pageData == null) {
      return const SizedBox.shrink();
    }

    final notices = pageData.items;
    final totalPages = pageData.totalPages;
    final currentPage = pageData.currentPage;

    if (notices.isEmpty) {
      return Center(
        child: Text(
          '등록된 공지사항이 없습니다',
          style: AppTextStyles.paragraph_14.copyWith(
            color: AppColors.black600,
          ),
        ),
      );
    }

    return Builder(
      builder: (context) {
        final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
        final paginationBottomOffset = AppSpacing.vertical16 + bottomSafeArea;

        return Stack(
          children: [
            // ── 공지사항 목록 ──
            SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: AppPadding.horizontal20,
                child: Column(
                  children: [
                    for (int i = 0; i < notices.length; i++)
                      _buildNoticeItem(
                        notice: notices[i],
                        index: i,
                        isLast: i == notices.length - 1,
                      ),
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

  /// 공지사항 아이템 (아코디언)
  Widget _buildNoticeItem({
    required NoticeEntity notice,
    required int index,
    bool isLast = false,
  }) {
    final isExpanded = _expandedIndex == index;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? -1 : index;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.vertical16,
              horizontal: AppSpacing.horizontal4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 제목 + (pinned 아이콘) + 드롭다운 아이콘 ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 고정 공지면 제목 앞에 핀 아이콘 (임시 — 디자인 시안 확정 시 조정).
                    if (notice.pinned) ...[
                      SvgPicture.asset(
                        'assets/icons/icon_pin.svg',
                        width: 16.w,
                        height: 16.w,
                      ),
                      SizedBox(width: AppSpacing.horizontal8),
                    ],
                    Expanded(
                      child: Text(
                        notice.title,
                        style: AppTextStyles.label_16.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20.w,
                      color: AppColors.black300,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.vertical4),

                // ── 날짜 ──
                Text(
                  _formatDate(notice.createdAt),
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.black600,
                  ),
                ),

                // ── 내용 (펼침 시) ──
                if (isExpanded) ...[
                  SizedBox(height: AppSpacing.vertical16),
                  Text(
                    notice.content,
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (!isLast) const Divider(color: AppColors.black100, height: 1),
      ],
    );
  }

  /// DateTime -> yyyy.MM.dd 형식 문자열 변환
  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}
