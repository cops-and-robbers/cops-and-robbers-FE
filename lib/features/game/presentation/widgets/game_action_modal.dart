import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';

/// 체포 / 탈옥 확인 공통 모달
///
/// AppDialog를 래핑한 정적 유틸리티 클래스.
///
/// 사용 예시:
/// ```dart
/// // 체포 (아바타 다이얼로그)
/// GameActionModal.show(
///   context: context,
///   title: '해당 플레이어를 체포하셨나요?',
///   message: '',
///   confirmLabel: '체포',
///   nickname: robber.nickname,
///   onConfirm: () => ref.read(gameEventNotifierProvider.notifier)
///       .arrestRobber(gameId, robber.participantId),
/// );
///
/// // 탈옥 (다크모드)
/// GameActionModal.show(
///   context: context,
///   title: '탈옥',
///   message: '탈옥을 시도하시겠습니까?',
///   confirmLabel: '탈옥',
///   isDarkMode: true,
///   onConfirm: () => ref.read(gameEventNotifierProvider.notifier).escape(gameId),
/// );
/// ```
class GameActionModal {
  GameActionModal._();

  /// 체포 / 탈옥 확인 모달 표시
  ///
  /// [nickname]이 제공되면 아바타(icon_person.png)와 닉네임이 함께 표시됩니다.
  /// [isDarkMode]가 true이면 다크모드 스타일이 적용됩니다.
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String? nickname,
    bool isDarkMode = false,
  }) {
    final bool useAvatar = nickname != null;
    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      isDarkMode: isDarkMode,
      backgroundColor: isDarkMode ? AppColors.black : null,
      title: title,
      titleStyle: isDarkMode
          ? AppTextStyles.robberHeading.copyWith(color: AppColors.white)
          : null,
      message: useAvatar ? null : message,
      confirmText: confirmLabel,
      cancelText: useAvatar ? l10n.buttonNo : l10n.buttonCancel,
      onConfirm: onConfirm,
      showAvatar: useAvatar,
      avatarWidget: useAvatar
          ? ClipRRect(
              borderRadius: AppRadius.large,
              child: Container(
                width: 92.w,
                height: 108.w,
                color: AppColors.black300,
              ),
            )
          : null,
      nickname: nickname,
    );
  }
}
