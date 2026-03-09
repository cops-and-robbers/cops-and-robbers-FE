import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 게임 규칙 다이얼로그 내용 위젯
///
/// AppDialog.show의 customContent로 사용됩니다.
class GameRulesContent extends StatelessWidget {
  const GameRulesContent({this.locationRevealIntervalMinutes, super.key});

  /// 위치 공개 주기 (분). null이면 기본값 5 사용.
  final int? locationRevealIntervalMinutes;

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black600),
        ),
        SizedBox(width: AppSpacing.horizontal4),
        Expanded(
          child: Text.rich(
            TextSpan(children: [content]),
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
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
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppColors.blue800.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2.r),
        ),
        child: Text(
          text,
          style: AppTextStyles.paragraph14Semibold.copyWith(
            color: AppColors.black800,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
