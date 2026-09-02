import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/vibration_service.dart';

/// 화면 하단에 고정하는 숫자 키패드
///
/// 시스템 키보드 대신 쓴다. 항목별 빠른 추가 칩과 숫자 3x4 그리드로 구성되며,
/// 값의 해석(교체·상한 처리)은 호출부가 담당하고 이 위젯은 입력 이벤트만 올린다.
///
/// ```dart
/// NumberPad(
///   quickAmounts: const [5, 10, 20],
///   unit: '명',
///   onDigit: (d) => ...,
///   onQuickAdd: (amount) => ...,
///   onBackspace: () => ...,
/// )
/// ```
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.quickAmounts,
    required this.unit,
    required this.onDigit,
    required this.onQuickAdd,
    required this.onBackspace,
    this.isDarkMode = false,
  });

  /// 빠른 추가 칩의 증가량 3개 (예: [5, 10, 20] → "+ 5명" "+ 10명" "+ 20명")
  final List<int> quickAmounts;

  /// 칩 라벨에 붙는 단위 (예: '명', '분')
  final String unit;

  /// 숫자 키 입력 (0~9)
  final ValueChanged<int> onDigit;

  /// 빠른 추가 칩 입력 (증가량 전달)
  final ValueChanged<int> onQuickAdd;

  /// 한 자리 지우기
  final VoidCallback onBackspace;

  /// 다크 모드 여부 (대기실 설정 수정 화면용)
  final bool isDarkMode;

  // 다크는 라이트와 같은 역할 구조를 따른다:
  // 존 배경은 페이지(black900)와 구분되는 틴트, 칩은 연한 브랜드색 + 진한 텍스트.
  Color get _backgroundColor =>
      isDarkMode ? AppColors.black800 : AppColors.background;

  Color get _digitColor => isDarkMode ? AppColors.black200 : AppColors.black700;

  // 다크 칩은 앱의 다크 문법(어두운 면 + 초록 액센트, 슬라이더와 동일)을 따른다.
  // 밝은 초록 면은 주 CTA 하나만 쓴다.
  Color get _chipBackgroundColor =>
      isDarkMode ? AppColors.black700 : AppColors.blueVer2_70;

  Color get _chipTextColor =>
      isDarkMode ? AppColors.green800 : AppColors.black700;

  void _tap(VoidCallback action) {
    VibrationService.instance().buttonTap();
    action();
  }

  @override
  Widget build(BuildContext context) {
    // 하단 세이프 에어리어(홈 인디케이터)까지 키패드 배경색으로 채운다 (#539).
    // 화면 쪽 SafeArea는 bottom: false여야 인셋이 이중 적용되지 않는다.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    // 시안 실측: 키패드 영역 전체 높이 361 (상단 여백 20 + 칩 34 + 키 4줄)
    return Container(
      width: double.infinity,
      height: 361.h + bottomInset,
      color: _backgroundColor,
      padding: EdgeInsets.only(top: AppSpacing.vertical20, bottom: bottomInset),
      child: Column(
        children: [
          _buildQuickChips(),
          SizedBox(height: AppSpacing.vertical12),
          Expanded(child: _buildDigitRow(const [1, 2, 3])),
          Expanded(child: _buildDigitRow(const [4, 5, 6])),
          Expanded(child: _buildDigitRow(const [7, 8, 9])),
          Expanded(child: _buildLastRow()),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal20),
      child: Row(
        children: [
          for (final (i, amount) in quickAmounts.indexed) ...[
            if (i > 0) SizedBox(width: 5.w),
            Expanded(
              child: GestureDetector(
                onTap: () => _tap(() => onQuickAdd(amount)),
                child: Container(
                  height: 34.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _chipBackgroundColor,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  // 시안: + 와 값 사이 간격 5
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+',
                        style: AppTextStyles.paragraph14Semibold.copyWith(
                          color: _chipTextColor,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '$amount$unit',
                        style: AppTextStyles.paragraph14Semibold.copyWith(
                          color: _chipTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDigitRow(List<int> digits) {
    return Row(
      children: [
        for (final digit in digits) Expanded(child: _buildDigitKey(digit)),
      ],
    );
  }

  /// 마지막 줄: 왼쪽 빈칸, 0, 지우기
  Widget _buildLastRow() {
    return Row(
      children: [
        const Expanded(child: SizedBox.shrink()),
        Expanded(child: _buildDigitKey(0)),
        Expanded(
          child: _buildKey(
            onTap: onBackspace,
            child: Icon(
              Icons.backspace_outlined,
              size: 24.w,
              color: _digitColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitKey(int digit) {
    return _buildKey(
      onTap: () => onDigit(digit),
      child: Text(
        '$digit',
        style: AppTextStyles.semibold_28.copyWith(color: _digitColor),
      ),
    );
  }

  Widget _buildKey({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: () => _tap(onTap),
      // 키 사이 빈 영역도 탭에 반응하도록 배경까지 히트 영역에 포함한다.
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(child: Center(child: child)),
    );
  }
}
