import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/cards/info_card.dart';
import '../../domain/entities/session_settings.dart';

/// 게임 설정 목록 카드
///
/// 참여 인원, 라운드 시간, 위치 공유 간격, 경찰 시작 시간 등
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
  const SettingListCard({super.key, required this.settings});

  /// 게임 설정 정보
  final SessionSettings settings;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: '설정',
      titleStyle: AppTextStyles.label_16.copyWith(color: AppColors.black),
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.vertical20,
        horizontal: AppSpacing.horizontal24,
      ),
      child: Column(
        children: [
          _SettingRow(label: '참여 인원', value: settings.maxPlayersDisplay),
          SizedBox(height: AppSpacing.vertical12),
          _SettingRow(label: '라운드 제한 시간', value: settings.roundTimeDisplay),
          SizedBox(height: AppSpacing.vertical12),
          _SettingRow(label: '위치 공유 간격', value: settings.locationShareDisplay),
          SizedBox(height: AppSpacing.vertical12),
          _SettingRow(label: '경찰 시작 시간', value: settings.policeStartDisplay),
        ],
      ),
    );
  }
}

/// 설정 행 (내부 위젯)
class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.paragraph_14_100.copyWith(
            color: AppColors.black800,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.paragraph14Semibold.copyWith(
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
