import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/cards/info_card.dart';

/// 제목·한 줄 설명·스위치로 된 방 설정 카드 틀 (#668 구역 축소, #723 무전)
///
/// [onChanged]가 null이면 누를 수 없는 스위치를 흐리게 보여 준다(참가자·잠금).
class SettingSwitchCard extends StatelessWidget {
  /// 누를 수 없는 스위치를 흐리게 보이는 정도 (#668 시안 2-waiting-settings-v3)
  static const double _disabledOpacity = 0.4;

  const SettingSwitchCard({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    this.titleTrailing,
    this.onChanged,
    this.muted = false,
    this.isDarkMode = false,
  });

  final String title;

  /// 제목 오른쪽에 붙는 위젯 (예: Beta 칩)
  final Widget? titleTrailing;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// 쓸 수 없는 설정임을 제목·설명 색으로 알린다 (구역 축소 잠금)
  final bool muted;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final titleColor = muted
        ? AppColors.black400
        : (isDarkMode ? AppColors.white : AppColors.black);
    final descColor = muted
        ? AppColors.black400
        : (isDarkMode ? AppColors.black400 : AppColors.black600);
    final titleText = Text(
      title,
      style: AppTextStyles.label_16.copyWith(color: titleColor),
    );
    final trailing = titleTrailing;

    return InfoCard(
      backgroundColor: isDarkMode ? AppColors.black900 : null,
      borderColor: isDarkMode ? AppColors.black800 : null,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.vertical20,
        horizontal: AppSpacing.horizontal24,
      ),
      // 스크린 리더가 스위치만 "꺼짐"으로 읽지 않고 제목과 함께 읽게 묶는다
      child: MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (trailing == null)
                    titleText
                  else
                    Row(
                      children: [
                        Flexible(child: titleText),
                        SizedBox(width: AppSpacing.horizontal8),
                        trailing,
                      ],
                    ),
                  SizedBox(height: AppSpacing.vertical8),
                  Text(
                    description,
                    style: AppTextStyles.tag_12.copyWith(color: descColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.horizontal12),
            // 누를 수 없을 때(참가자·잠금)는 토큰 색 그대로 위젯째 흐리게 한다 — 색 투명도 금지(ui-design-system)
            _dimUnlessEditable(
              editable: onChanged != null,
              Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // 팀 테마 표(ui-design-system 2.4): 켜짐 경찰 파랑 / 도둑 green, 꺼짐 black200 / black800.
                // 비활성이어도 머티리얼 회색이 아니라 이 토큰으로 그린다. 손잡이는 팀 무관 흰색(사용자 결정)
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? (isDarkMode ? AppColors.green : AppColors.blueVer2Basic)
                      : (isDarkMode ? AppColors.black800 : AppColors.black200),
                ),
                thumbColor: const WidgetStatePropertyAll(AppColors.white),
                // 빈 아이콘: 꺼짐에서도 손잡이를 줄이지 않게 하는 M3 동작용 (그림 없음)
                thumbIcon: const WidgetStatePropertyAll(Icon(null)),
                trackOutlineColor: const WidgetStatePropertyAll(
                  AppColors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dimUnlessEditable(Widget child, {required bool editable}) =>
      editable ? child : Opacity(opacity: _disabledOpacity, child: child);
}
