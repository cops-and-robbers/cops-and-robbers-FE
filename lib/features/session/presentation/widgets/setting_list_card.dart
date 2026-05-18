import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/session_settings.dart';

/// 게임 설정 목록 카드
///
/// 참여 인원, 라운드 시간, 위치 공유 간격, 경찰 출동 시간 등
/// 게임 설정 정보를 표시합니다.
///
/// 사용 예시:
/// ```dart
/// SettingListCard(
///   settings: SessionSettings(
///     maxPlayers: 50,
///     roundTimeMinutes: 30,
///     locationShareMinutes: 5,
///     policeStartDelayMinutes: 5,
///   ),
/// )
/// ```
class SettingListCard extends StatelessWidget {
  const SettingListCard({
    super.key,
    required this.settings,
    this.onTap,
    this.isDarkMode = false,
  });

  /// 게임 설정 정보
  final SessionSettings settings;

  /// 설정 카드 탭 콜백 (호스트 전용 — 설정 수정 페이지 이동)
  final VoidCallback? onTap;

  /// 다크 모드 여부 (도둑팀)
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: InfoCard(
        title: l10n.dialogsettingListCardTitle,
        titleStyle: AppTextStyles.label_16.copyWith(
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
        titleTrailing: onTap != null
            ? Transform.rotate(
                angle: math.pi,
                child: SvgPicture.asset(
                  'assets/icons/icon_previous.svg',
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    isDarkMode ? AppColors.black400 : AppColors.black300,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
        backgroundColor: isDarkMode ? AppColors.black900 : null,
        borderColor: isDarkMode ? AppColors.black800 : null,
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.vertical20,
          horizontal: AppSpacing.horizontal24,
        ),
        child: Column(
          children: [
            _SettingRow(
              label: l10n.fieldsettingListCardLabel,
              value: l10n.gameSettingMaxPlayers(
                settings.maxPlayers.toString(),
              ),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _SettingRow(
              label: l10n.fieldsettingListCardLabelEc5e,
              value: l10n.gameSettingRoundMinutes(
                settings.roundTimeMinutes,
              ),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _SettingRow(
              label: l10n.fieldsettingListCardLabelA1b3,
              value: l10n.gameSettingLocationShareMinutes(
                settings.locationShareMinutes,
              ),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _SettingRow(
              label: l10n.fieldsettingListCardLabelCe3b,
              value: l10n.gameSettingPoliceStartDelay(
                settings.policeStartDelayMinutes,
              ),
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }
}

/// 설정 행 (내부 위젯)
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    this.isDarkMode = false,
  });

  final String label;
  final String value;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.paragraph_14_100.copyWith(
            color: isDarkMode ? AppColors.black200 : AppColors.black800,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.paragraph14Semibold.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
      ],
    );
  }
}
