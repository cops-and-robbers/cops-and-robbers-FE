import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../domain/entities/notice_entity.dart';

/// 공지사항 카드 (아코디언 항목)
///
/// 펼침 상태를 부모가 소유하는 이유: 한 번에 하나만 펼쳐야 하는데,
/// 카드가 자체 상태를 들면 형제 카드를 접을 수단이 없다.
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.notice,
    required this.isExpanded,
    required this.onTap,
  });

  final NoticeEntity notice;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        // 폭은 하드코딩하지 않고 가용 폭을 채운다 — designSize 393에서
        // 좌우 패딩 16을 빼면 361로, 시안의 362와 사실상 같다.
        width: double.infinity,
        // 76은 고정 높이가 아니라 최소 높이다. 펼치면 본문만큼 늘어나야 하고,
        // 시스템 글자 크기를 키우면 접힘 상태에서도 76을 넘긴다.
        // 높이를 박으면 그때 글자가 경고 없이 잘린다.
        constraints: BoxConstraints(minHeight: 76.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal20,
          vertical: AppSpacing.vertical16,
        ),
        // 쉐도우를 주지 않는다 — 연하늘 배경(#F4FAFF) 위의 흰 카드라
        // 색 차이만으로 경계가 충분히 드러난다.
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 제목 + (고정 핀) + 펼침 화살표 ──
            Row(
              children: [
                if (notice.pinned) ...[
                  // viewBox가 10x15라 정사각으로 그리면 가로로 늘어난다.
                  // 색상(#F64C4F)은 SVG에 박혀 있어 colorFilter를 주지 않는다.
                  SvgPicture.asset(
                    'assets/icons/icon_pin.svg',
                    width: 10.w,
                    height: 15.h,
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
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
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
    );
  }

  /// DateTime -> yyyy.MM.dd 형식 문자열 변환
  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}
