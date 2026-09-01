import 'dart:math' as math;

import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import 'agreement_checkbox.dart';

/// 약관 동의 화면의 개별 약관 1행
///
/// 체크박스를 탭하면 [onToggle]이 호출되고, 제목 영역을 탭하면 [onDetailTap]이
/// 호출됩니다 (상세보기 페이지로 이동).
///
/// [readOnly]가 true이면 체크박스 탭이 무시되고 시각적으로 흐리게 표시됩니다.
/// 설정 화면에서 필수 약관을 해제 불가능함을 전달할 때 사용합니다.
class AgreementItem extends StatelessWidget {
  const AgreementItem({
    super.key,
    required this.checked,
    required this.required,
    required this.title,
    required this.onToggle,
    this.onDetailTap,
    this.readOnly = false,
  });

  final bool checked;
  final bool required;
  final String title;
  final VoidCallback onToggle;
  final VoidCallback? onDetailTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tagText = required
        ? l10n.agreementItemRequiredTag
        : l10n.agreementItemOptionalTag;
    final tagColor = required ? AppColors.black600 : AppColors.black400;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          AgreementCheckbox(
            checked: checked,
            onTap: onToggle,
            readOnly: readOnly,
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Expanded(
            child: GestureDetector(
              onTap: readOnly ? null : onToggle,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    tagText,
                    style: AppTextStyles.paragraph14Semibold.copyWith(
                      color: tagColor,
                    ),
                  ),
                  SizedBox(width: AppSpacing.horizontal4),
                  Flexible(
                    child: Text(
                      title,
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onDetailTap != null)
            GestureDetector(
              onTap: onDetailTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(left: AppSpacing.horizontal8),
                child: Transform.rotate(
                  angle: math.pi,
                  child: SvgPicture.asset(
                    AppIcons.previous,
                    width: 20.w,
                    height: 20.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.black300,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
