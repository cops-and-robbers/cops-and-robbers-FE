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
import 'game_setting_values_editor.dart';

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
    this.onTapField,
    this.isDarkMode = false,
  });

  /// 게임 설정 정보
  final SessionSettings settings;

  /// 설정 카드 탭 콜백 (호스트 전용 — 설정 수정 페이지 이동)
  final VoidCallback? onTap;

  /// 행 탭 콜백 (최종 확인 화면 — 해당 항목을 고치러 이동)
  final ValueChanged<GameSettingField>? onTapField;

  /// 다크 모드 여부 (도둑팀)
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: InfoCard(
        title: l10n.sectionTitleSettings,
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
              label: l10n.labelParticipantCount,
              onTap: onTapField == null
                  ? null
                  : () => onTapField!(GameSettingField.participants),
              value: l10n.gameSettingMaxPlayers(settings.maxPlayers.toString()),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _SettingRow(
              label: l10n.fieldRoundTimeLimit,
              onTap: onTapField == null
                  ? null
                  : () => onTapField!(GameSettingField.roundDuration),
              value: l10n.gameSettingRoundMinutes(settings.roundTimeMinutes),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _SettingRow(
              label: l10n.fieldLocationShareInterval,
              onTap: onTapField == null
                  ? null
                  : () => onTapField!(GameSettingField.locationShare),
              value: l10n.gameSettingLocationShareMinutes(
                settings.locationShareMinutes,
              ),
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: AppSpacing.vertical12),
            _SettingRow(
              label: l10n.fieldPoliceDispatchTime,
              onTap: onTapField == null
                  ? null
                  : () => onTapField!(GameSettingField.policeWait),
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
    this.onTap,
  });

  final String label;
  final String value;
  final bool isDarkMode;

  /// 행 탭 콜백. 주어지면 값 옆에 이동 표시가 붙는다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.paragraph_14_100.copyWith(
              color: isDarkMode ? AppColors.black200 : AppColors.black800,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.paragraph14Semibold.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: AppSpacing.horizontal8),
                Transform.rotate(
                  angle: math.pi,
                  child: SvgPicture.asset(
                    'assets/icons/icon_previous.svg',
                    width: 14.w,
                    height: 14.w,
                    colorFilter: ColorFilter.mode(
                      isDarkMode ? AppColors.black400 : AppColors.black300,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
