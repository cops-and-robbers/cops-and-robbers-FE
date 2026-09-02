import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../constants/spacing_and_radius.dart';
import '../constants/text_styles.dart';
import 'buttons/app_button.dart';

/// 보여 줄 것이 없는 자리 — 돋보기 든 캐릭터 + 한 줄 안내
///
/// 목록이 비었을 때(모집글·스크랩·알림함·공지사항·채팅방)와 불러오지 못했을 때가
/// 같은 모양을 쓴다. [actionText]와 [onAction]을 **둘 다** 주면 아래에 버튼이
/// 붙는다 — 다시 시도·목록으로 같은 되돌릴 길이 있는 화면만 해당한다.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.iconWidth = 80,
    this.actionText,
    this.onAction,
  });

  final String message;

  /// 캐릭터 폭. 목록 안에 끼는 자리는 기본값(80), 화면 하나를 통째로 차지하는
  /// 자리(불러오기 실패·삭제된 글)는 110을 쓴다.
  final double iconWidth;

  /// 버튼 라벨. [onAction]이 없으면 무시한다 — 눌리지 않는 버튼을 그리지 않는다.
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionText;
    final action = onAction;

    return Padding(
      padding: AppPadding.horizontal24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppIcons.notFound, width: iconWidth.w),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
          ),
          if (label != null && action != null) ...[
            SizedBox(height: AppSpacing.vertical16),
            AppButton(width: double.infinity, text: label, onPressed: action),
          ],
        ],
      ),
    );
  }
}
