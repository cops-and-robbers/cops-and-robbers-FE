import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── 이전 페이지 버튼 (첫 페이지에서는 완전 숨김) ──
        if (currentPage > 0)
          _buildArrowButton(
            icon: Icons.chevron_left,
            onTap: () => onPageChanged(currentPage - 1),
          ),

        // ── 페이지 번호 목록 ──
        ...pageNumbers.map((page) {
          if (page == -1) {
            // 생략 부호 (...)
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal4),
              child: Text(
                '···',
                style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
              ),
            );
          }
          return _buildPageButton(page);
        }),

        // ── 다음 페이지 버튼 (마지막 페이지에서는 완전 숨김) ──
        if (currentPage < totalPages - 1)
          _buildArrowButton(
            icon: Icons.chevron_right,
            onTap: () => onPageChanged(currentPage + 1),
          ),
      ],
    );
  }

  /// 표시할 페이지 번호 목록 계산
  ///
  /// -1은 생략 부호(...)를 의미.
  /// - 첫 페이지: `1 2 3 ... n`
  /// - 마지막 페이지: `1 ... n-2 n-1 n`
  /// - 그 외 전부: `... prev curr next ...` (슬라이딩 윈도우)
  List<int> _buildPageNumbers() {
    if (totalPages <= 4) {
      return List.generate(totalPages, (i) => i);
    }

    // 첫 페이지: 첫 3개 + ... + 마지막
    if (currentPage == 0) {
      return [0, 1, 2, -1, totalPages - 1];
    }

    // 마지막 페이지: 첫 + ... + 마지막 3개
    if (currentPage == totalPages - 1) {
      return [0, -1, totalPages - 3, totalPages - 2, totalPages - 1];
    }

    // 그 외: 슬라이딩 윈도우 (현재 ± 1)
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
      onTap: isSelected ? null : () => onPageChanged(page),
      child: Container(
        width: 24.w,
        height: 24.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.black100 : null,
        ),
        child: Center(
          child: Text(
            '${page + 1}',
            style: AppTextStyles.tag_12.copyWith(
              color: isSelected ? AppColors.black : AppColors.black600,
            ),
          ),
        ),
      ),
    );
  }

  /// 이전/다음 화살표 버튼
  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Icon(icon, size: 20.w, color: AppColors.black),
      ),
    );
  }
}
