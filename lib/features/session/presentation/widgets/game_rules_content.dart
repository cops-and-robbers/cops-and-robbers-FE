import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 게임 규칙 다이얼로그 내용 위젯
///
/// AppDialog.show의 customContent로 사용됩니다.
class GameRulesContent extends StatelessWidget {
  const GameRulesContent({
    this.locationRevealIntervalMinutes,
    this.isDarkMode = false,
    super.key,
  });

  /// 위치 공개 주기 (분). null이면 기본값 5 사용.
  final int? locationRevealIntervalMinutes;

  /// 다크 모드 여부
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRule(number: '1.', content: _rule1()),
        SizedBox(height: AppSpacing.vertical12),
        _buildRule(number: '2.', content: _rule2()),
        SizedBox(height: AppSpacing.vertical12),
        _buildRule(number: '3.', content: _rule3()),
      ],
    );
  }

  Widget _buildRule({required String number, required InlineSpan content}) {
    final textColor = isDarkMode ? AppColors.black400 : AppColors.black600;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: AppTextStyles.paragraph_14.copyWith(color: textColor),
        ),
        SizedBox(width: AppSpacing.horizontal4),
        Expanded(
          child: Text.rich(
            TextSpan(children: [content]),
            style: AppTextStyles.paragraph_14.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  InlineSpan _rule1() {
    return TextSpan(
      children: [
        const TextSpan(text: '경찰은 모든 도둑을 잡아서 '),
        _highlight('체포하면,'),
        const TextSpan(text: '\n도둑은 '),
        _highlight('제한 시간이 끝날 때까지 버티면'),
        const TextSpan(text: ' 승리해요'),
      ],
    );
  }

  InlineSpan _rule2() {
    final minutes = locationRevealIntervalMinutes ?? 5;
    return TextSpan(
      children: [
        const TextSpan(text: '도둑팀의 위치는 '),
        _highlight('$minutes분마다'),
        const TextSpan(text: ' 경찰팀에게 공유돼요'),
      ],
    );
  }

  InlineSpan _rule3() {
    return TextSpan(
      children: [
        _highlight('지정된 게임 구역에서 벗어나면 안 돼요'),
        const TextSpan(text: '\n→ 구역 안으로 돌아갈 때까지 위치가 드러나요'),
      ],
    );
  }

  InlineSpan _highlight(String text) {
    final highlightColor = isDarkMode
        ? AppColors.green800.withValues(alpha: 0.3)
        : AppColors.blue800.withValues(alpha: 0.3);
    final textStyle = AppTextStyles.paragraph14Semibold.copyWith(
      color: isDarkMode ? AppColors.black100 : AppColors.black800,
      height: 1.4,
    );

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 하이라이트 배경 (3px 아래로)
          Positioned(
            left: 0,
            right: 0,
            top: 7.h,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          // 텍스트 (위치 고정)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(text, style: textStyle),
          ),
        ],
      ),
    );
  }
}
