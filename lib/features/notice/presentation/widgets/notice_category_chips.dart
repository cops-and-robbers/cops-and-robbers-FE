import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notice_category.dart';
import '../providers/notice_provider.dart';

/// 공지사항 카테고리 필터 칩 행 (가로 스크롤)
///
/// 선택 표시는 `selectedNoticeCategoryProvider`를 직접 watch 하므로
/// 네트워크 응답을 기다리지 않고 탭 즉시 반영된다. 실제 상태 변경과
/// 로딩 팝업은 [onSelected]를 받은 페이지가 처리한다 —
/// 진행 중인 요청 가드가 페이지 쪽에 있기 때문이다.
class NoticeCategoryChips extends ConsumerWidget {
  const NoticeCategoryChips({super.key, required this.onSelected});

  final ValueChanged<NoticeCategory> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNoticeCategoryProvider);
    final l10n = AppLocalizations.of(context);
    const categories = NoticeCategory.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppPadding.horizontal16,
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            _CategoryChip(
              label: _labelOf(l10n, categories[i]),
              isSelected: categories[i] == selected,
              onTap: () => onSelected(categories[i]),
            ),
            if (i != categories.length - 1)
              SizedBox(width: AppSpacing.horizontal8),
          ],
        ],
      ),
    );
  }

  /// enum → 표시 문구.
  ///
  /// 도메인 enum이 `AppLocalizations`를 알면 안 되므로 매핑은 presentation에 둔다.
  String _labelOf(AppLocalizations l10n, NoticeCategory category) =>
      switch (category) {
        NoticeCategory.all => l10n.noticeCategoryAll,
        NoticeCategory.notice => l10n.noticeCategoryNotice,
        NoticeCategory.maintenance => l10n.noticeCategoryMaintenance,
        NoticeCategory.event => l10n.noticeCategoryEvent,
        NoticeCategory.update => l10n.noticeCategoryUpdate,
      };
}

/// 칩 1개
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        // 74는 고정 폭이 아니라 최소 폭이다. en 'Maintenance'(11자)와
        // ja 'メンテナンス'는 paragraph_14 기준 74를 넘기므로, 폭을 박으면
        // 해당 로케일에서 글자가 잘린다. 행이 가로 스크롤이라 넓어져도 안전하다.
        constraints: BoxConstraints(minWidth: 74.w),
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueVer2Strong : AppColors.black100,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          label,
          style: AppTextStyles.paragraph_14.copyWith(
            color: isSelected ? AppColors.white : AppColors.black400,
          ),
        ),
      ),
    );
  }
}
