import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_shadows.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';

/// 숫자 기반 페이지네이션 바
///
/// 하단에 페이지 번호와 이전/다음 버튼을 표시합니다.
/// `< 1 2 3 ... 10 >` 형태.
///
/// **사용 예시**:
/// ```dart
/// PaginationBar(
///   currentPage: 0,
///   totalPages: 10,
///   onPageChanged: (page) => notifier.fetchNotices(page: page),
/// )
/// ```
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  /// 현재 페이지 (0-based)
  final int currentPage;

  /// 전체 페이지 수
  final int totalPages;

  /// 페이지 변경 콜백 (0-based page index)
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final pageNumbers = _buildPageNumbers();

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.vertical12,
        horizontal: AppSpacing.horizontal16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.pill,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── 이전 페이지 버튼 ──
          _buildArrowButton(
            isFlipped: false,
            enabled: currentPage > 0,
            onTap: () => onPageChanged(currentPage - 1),
          ),

          // ── 페이지 번호 목록 ──
          ...pageNumbers.map((page) {
            if (page == -1) {
              // 생략 부호 (...)
              return Container(
                width: 28.w,
                height: 28.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Center(
                  child: Text(
                    '···',
                    style: AppTextStyles.paragraph14Semibold.copyWith(
                      color: AppColors.black600,
                    ),
                  ),
                ),
              );
            }
            return _buildPageButton(page);
          }),

          // ── 다음 페이지 버튼 ──
          _buildArrowButton(
            isFlipped: true,
            enabled: currentPage < totalPages - 1,
            onTap: () => onPageChanged(currentPage + 1),
          ),
        ],
      ),
    );
  }

  /// 표시할 페이지 번호 목록 계산
  ///
  /// -1은 생략 부호(...)를 의미.
  /// - 첫 페이지: `1 2 3 ... n`
  /// - 마지막 페이지: `1 ... n-2 n-1 n`
  /// - 그 외 전부: `... prev curr next ...` (슬라이딩 윈도우)
  List<int> _buildPageNumbers() {
    if (totalPages <= 5) {
      return List.generate(totalPages, (i) => i);
    }

    // 첫 2페이지: 첫 3개 + ... + 마지막
    if (currentPage <= 1) {
      return [0, 1, 2, -1, totalPages - 1];
    }

    // 마지막 2페이지: 첫 + ... + 마지막 3개
    if (currentPage >= totalPages - 2) {
      return [0, -1, totalPages - 3, totalPages - 2, totalPages - 1];
    }

    // 그 외: 슬라이딩 윈도우 (... prev curr next ...)
    final result = <int>[];

    if (currentPage - 1 > 0) result.add(-1);

    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i >= 0 && i < totalPages) result.add(i);
    }

    if (currentPage + 1 < totalPages - 1) result.add(-1);

    return result;
  }

  /// 페이지 번호 버튼
  Widget _buildPageButton(int page) {
    final isSelected = page == currentPage;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isSelected ? null : () => onPageChanged(page),
      child: Container(
        width: 28.w,
        height: 28.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.black100 : null,
        ),
        child: Center(
          child: Text(
            '${page + 1}',
            style: isSelected
                ? AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.black,
                  )
                : AppTextStyles.tag_12.copyWith(color: AppColors.black600),
          ),
        ),
      ),
    );
  }

  /// 이전/다음 화살표 버튼
  ///
  /// [isFlipped]가 true이면 SVG를 수평 반전하여 "다음" 화살표로 사용.
  Widget _buildArrowButton({
    required bool isFlipped,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? AppColors.black600 : AppColors.black200;
    final icon = SvgPicture.asset(
      'assets/icons/icon_previous.svg',
      width: 16.w,
      height: 16.w,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 28.w,
        height: 28.w,
        child: Center(
          child: isFlipped ? Transform.flip(flipX: true, child: icon) : icon,
        ),
      ),
    );
  }
}
