import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';

/// 게임 설정 항목 카드
///
/// 기본 정보 화면에서 한 항목이 카드 한 장이다. 지금 입력 중인 항목은 진한
/// 텍스트로, 답을 마친 항목은 연한 텍스트로 그린다. 배경과 테두리는 상태와
/// 무관하게 같다.
///
/// 값이 제안값(기본값을 채워 둔 상태)이면 [isValueDimmed] 로 더 연하게 그려
/// 아직 사용자의 입력이 아님을 나타낸다.
class SettingFieldCard extends StatelessWidget {
  const SettingFieldCard({
    super.key,
    required this.label,
    required this.value,
    this.valuePrefix,
    this.valueSuffix,
    this.hint,
    this.isHintWarning = false,
    this.isActive = true,
    this.isValueDimmed = false,
    this.onTap,
    this.isDarkMode = false,
  });

  /// 항목 이름 (예: '참여 인원')
  final String label;

  /// 값 텍스트, 단위 포함 (예: '50명')
  final String value;

  /// 값 앞 설명 (예: '도둑 시작 후')
  final String? valuePrefix;

  /// 값 뒤 설명 (예: '뒤')
  final String? valueSuffix;

  /// 값 아래 안내 문구 (예: '최소 인원은 2명입니다')
  final String? hint;

  /// 안내 문구를 경고(빨강)로 그릴지 여부
  final bool isHintWarning;

  /// 지금 입력 중인 항목인지 여부
  final bool isActive;

  /// 값이 아직 사용자의 입력이 아닌 제안값인지 여부
  final bool isValueDimmed;

  /// 카드 탭 (답을 마친 항목을 다시 수정할 때)
  final VoidCallback? onTap;

  /// 다크 모드 여부 (대기실 설정 수정 화면용)
  final bool isDarkMode;

  // 다크 카드는 기존 관례(확인 카드와 동일)를 따른다: 페이지와 같은 바탕 + 헤어라인
  Color get _backgroundColor =>
      isDarkMode ? AppColors.black900 : AppColors.white;

  Color get _borderColor =>
      isDarkMode ? AppColors.black800 : AppColors.black100;

  Color get _labelColor {
    if (!isActive) return AppColors.black400;
    return isDarkMode ? AppColors.white : AppColors.black;
  }

  Color get _valueColor {
    if (!isActive) return AppColors.black400;
    if (isValueDimmed) return AppColors.black300;
    return isDarkMode ? AppColors.white : AppColors.black;
  }

  Color get _hintColor => isHintWarning ? AppColors.red : AppColors.black400;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal24,
          vertical: AppSpacing.vertical16,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시안 실측: 카드 높이 56 (본문 행 24 + 상하 16), 힌트 있으면 78
            SizedBox(
              height: 24.h,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.label_16.copyWith(
                        color: _labelColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (valuePrefix != null) ...[
                    Text(
                      valuePrefix!,
                      style: AppTextStyles.paragraph_14_100.copyWith(
                        color: _valueColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    value,
                    // 다크(도둑 테마)의 값 표기는 Moneygraphy 를 쓴다
                    style:
                        (isDarkMode
                                ? AppTextStyles.robberLabel
                                : AppTextStyles.paragraph14bold.copyWith(
                                    fontSize: 16.sp,
                                  ))
                            .copyWith(color: _valueColor),
                  ),
                  if (valueSuffix != null) ...[
                    SizedBox(width: 4.w),
                    Text(
                      valueSuffix!,
                      style: AppTextStyles.paragraph_14_100.copyWith(
                        color: _valueColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hint != null) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.info,
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(_hintColor, BlendMode.srcIn),
                  ),
                  SizedBox(width: AppSpacing.horizontal8),
                  Expanded(
                    child: Text(
                      hint!,
                      style: AppTextStyles.tag_12.copyWith(color: _hintColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
