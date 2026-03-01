import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/previous_button.dart';
import '../../../../core/widgets/pagination_bar.dart';

/// 공지사항 페이지
///
/// 공지사항 목록을 아코디언(펼침/접기) 형태로 표시하며,
/// 하단에 페이지네이션 바를 제공합니다.
/// 현재는 더미 데이터를 사용하며, API 엔드포인트 완성 후 연동 예정입니다.
class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  /// 스크롤 위치 제어 (페이지 변경 시 상단 복귀)
  final ScrollController _scrollController = ScrollController();

  /// 현재 펼쳐진 공지사항 인덱스 (-1이면 모두 접힌 상태)
  int _expandedIndex = -1;

  /// 현재 페이지 (0-based)
  int _currentPage = 0;

  /// 페이지당 표시할 공지사항 수
  static const int _pageSize = 10;

  /// 더미 공지사항 데이터
  static final List<_NoticeItem> _allNotices = List.generate(
    100,
    (_) => _NoticeItem(
      title: '옷 장착 오류 등 기타 오류 수정',
      content: '오류 수정했습니다~',
      date: DateTime(2026, 2, 10),
    ),
  );

  /// 현재 페이지에 해당하는 공지사항 목록
  List<_NoticeItem> get _currentNotices {
    final start = (_currentPage * _pageSize).clamp(0, _allNotices.length);
    final end = (start + _pageSize).clamp(start, _allNotices.length);
    return _allNotices.sublist(start, end);
  }

  /// 전체 페이지 수
  int get _totalPages => (_allNotices.length / _pageSize).ceil();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notices = _currentNotices;

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
      body: Builder(
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
                        _buildNoticeItem(notice: notices[i], index: i),
                      // 하단 페이지네이션 바와 겹치지 않도록 여백 추가
                      SizedBox(height: paginationBottomOffset + 60.h),
                    ],
                  ),
                ),
              ),

              // ── 플로팅 페이지네이션 바 ──
              if (_totalPages > 1)
                Positioned(
                  bottom: paginationBottomOffset,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: PaginationBar(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                          _expandedIndex = -1;
                        });
                        _scrollController.jumpTo(0);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 공지사항 아이템 (아코디언)
  Widget _buildNoticeItem({required _NoticeItem notice, required int index}) {
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
                // ── 제목 + 드롭다운 아이콘 ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                  _formatDate(notice.date),
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

        const Divider(color: AppColors.black100, height: 1),
      ],
    );
  }

  /// DateTime -> yyyy.MM.dd 형식 문자열 변환
  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

/// 공지사항 더미 데이터 모델
///
/// API 연동 시 NoticeEntity로 대체 예정
class _NoticeItem {
  final String title;
  final String content;
  final DateTime date;

  const _NoticeItem({
    required this.title,
    required this.content,
    required this.date,
  });
}
