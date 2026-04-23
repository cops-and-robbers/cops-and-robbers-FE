import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../domain/entities/game_result_entity.dart';
import '../providers/game_result_provider.dart';

// ============================================================
// 순수 함수
// ============================================================

/// `durationSeconds`(초)를 "분:초" 포맷 문자열로 변환.
///
/// - 초는 2자리 0 패딩 (`"5:07"`)
/// - 분은 60분 이상도 cap 없이 누적 (`3661 → "61:01"`)
String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 캐릭터 SVG 경로 반환.
String resolveResultCharacterAsset({
  required String myTeam,
  required String winnerTeam,
}) {
  final teamSlug = myTeam.toLowerCase();
  final isWin = myTeam == winnerTeam;
  final resultSlug = isWin ? 'win' : 'lose';
  return 'assets/characters/$teamSlug/result/$resultSlug.svg';
}

// ============================================================
// 위젯
// ============================================================

/// 위젯 레이아웃 상수
///
/// 실제 에셋 크기에 따라 미세조정 필요.
///
/// 불변 조건: `characterHeight == characterOverflow + characterReveal`
/// (캐릭터가 잘리지 않고 다이얼로그에 정확히 걸치기 위해 세 값을 함께 조정해야 함)
class _Dimens {
  static double get characterHeight => 140.h;
  static double get characterOverflow => 80.h; // 다이얼로그 상단 위쪽으로 노출되는 높이
  static double get characterReveal => 60.h; // 다이얼로그 본체 상단 여백 (캐릭터가 걸치는 부분)
}

/// 게임 종료 결과 다이얼로그
///
/// - 캐릭터 SVG가 다이얼로그 상단에 걸쳐 있는 입체 구도
/// - 승/패 타이틀 + 통계 3행 + 액션 버튼 2개
/// - `gameResultProvider(gameResultId)` 구독 → AsyncValue로 통계 분기
///
/// 호출 예:
/// ```dart
/// await GameOverResultDialog.show(
///   context: context,
///   isDarkMode: true,
///   myTeam: 'ROBBER',
///   winnerTeam: 'ROBBER',
///   gameResultId: 42,
///   onGoHome: () { /* ... */ },
///   onRematch: () { /* ... */ },
/// );
/// ```
class GameOverResultDialog extends ConsumerWidget {
  const GameOverResultDialog({
    super.key,
    required this.isDarkMode,
    required this.myTeam,
    required this.winnerTeam,
    required this.gameResultId,
    required this.onGoHome,
    required this.onRematch,
  });

  /// 팀 테마 (도둑=true, 경찰=false)
  final bool isDarkMode;

  /// 본인 팀 ('POLICE' | 'ROBBER')
  final String myTeam;

  /// 승리 팀 ('POLICE' | 'ROBBER')
  final String winnerTeam;

  /// 결과 조회 대상 ID
  final int gameResultId;

  /// "홈으로" 버튼 콜백
  final VoidCallback onGoHome;

  /// "한 번 더" 버튼 콜백
  final VoidCallback onRematch;

  /// 다이얼로그 호출 헬퍼
  static Future<void> show({
    required BuildContext context,
    required bool isDarkMode,
    required String myTeam,
    required String winnerTeam,
    required int gameResultId,
    required VoidCallback onGoHome,
    required VoidCallback onRematch,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverResultDialog(
        isDarkMode: isDarkMode,
        myTeam: myTeam,
        winnerTeam: winnerTeam,
        gameResultId: gameResultId,
        onGoHome: onGoHome,
        onRematch: onRematch,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(gameResultProvider(gameResultId));
    final isWin = myTeam == winnerTeam;
    final characterAsset = resolveResultCharacterAsset(
      myTeam: myTeam,
      winnerTeam: winnerTeam,
    );

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: AppPadding.horizontal24,
        elevation: 0,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 1) 다이얼로그 본체 — margin top으로 캐릭터 공간 확보
            Container(
              margin: EdgeInsets.only(top: _Dimens.characterReveal),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 24.h,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.black : AppColors.white,
                borderRadius: AppRadius.xl20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: _Dimens.characterReveal),
                  _ResultTitle(isDarkMode: isDarkMode, isWin: isWin),
                  SizedBox(height: AppSpacing.vertical24),
                  _StatsSection(
                    isDarkMode: isDarkMode,
                    resultAsync: resultAsync,
                  ),
                  SizedBox(height: AppSpacing.vertical24),
                  _ActionButtons(
                    isDarkMode: isDarkMode,
                    onGoHome: onGoHome,
                    onRematch: onRematch,
                  ),
                ],
              ),
            ),

            // 2) 캐릭터 오버레이 — Stack의 앞쪽에 배치되어 다이얼로그보다 위에 그려짐
            Positioned(
              top: -_Dimens.characterOverflow,
              child: SvgPicture.asset(
                characterAsset,
                height: _Dimens.characterHeight,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 내부 위젯
// ============================================================

class _ResultTitle extends StatelessWidget {
  const _ResultTitle({required this.isDarkMode, required this.isWin});

  final bool isDarkMode;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    // 경찰 승리: 파랑 / 경찰 패배: 빨강
    // 도둑 승리: 초록 / 도둑 패배: 빨강
    final color = isDarkMode
        ? (isWin ? AppColors.green : AppColors.red)
        : (isWin ? AppColors.blue : AppColors.red);

    final baseStyle = isDarkMode
        ? AppTextStyles.robberHeading24
        : AppTextStyles.heading_20;

    return Text(
      isWin ? '승리' : '패배',
      style: baseStyle.copyWith(color: color),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.isDarkMode,
    required this.resultAsync,
  });

  final bool isDarkMode;
  final AsyncValue<GameResultEntity> resultAsync;

  @override
  Widget build(BuildContext context) {
    return resultAsync.when(
      data: (entity) => Column(
        children: [
          _StatRow(
            isDarkMode: isDarkMode,
            label: '체포 횟수',
            value: '${entity.totalArrestCount}회',
          ),
          SizedBox(height: AppSpacing.vertical12),
          _StatRow(
            isDarkMode: isDarkMode,
            label: '남은 도둑',
            value: '${entity.remainingRobberCount}명',
          ),
          SizedBox(height: AppSpacing.vertical12),
          _StatRow(
            isDarkMode: isDarkMode,
            label: '게임 진행 시간',
            value: formatDuration(entity.durationSeconds),
          ),
        ],
      ),
      loading: () => _placeholderRows(),
      error: (_, _) => _placeholderRows(),
    );
  }

  Widget _placeholderRows() {
    return Column(
      children: [
        _StatRow(isDarkMode: isDarkMode, label: '체포 횟수', value: '-'),
        SizedBox(height: AppSpacing.vertical12),
        _StatRow(isDarkMode: isDarkMode, label: '남은 도둑', value: '-'),
        SizedBox(height: AppSpacing.vertical12),
        _StatRow(isDarkMode: isDarkMode, label: '게임 진행 시간', value: '-'),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.isDarkMode,
    required this.label,
    required this.value,
  });

  final bool isDarkMode;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.label16Medium.copyWith(
      color: isDarkMode ? AppColors.black400 : AppColors.black800,
    );
    final valueStyle = isDarkMode
        ? AppTextStyles.robberLabel.copyWith(color: AppColors.white)
        : AppTextStyles.label_16.copyWith(color: AppColors.black);

    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isDarkMode,
    required this.onGoHome,
    required this.onRematch,
  });

  final bool isDarkMode;
  final VoidCallback onGoHome;
  final VoidCallback onRematch;

  @override
  Widget build(BuildContext context) {
    // "한 번 더" 버튼 색: 도둑=green, 경찰=blue
    final rematchColor = isDarkMode ? AppColors.green : AppColors.blue;

    // "홈으로" 버튼 색: 테마별 회색 계열 (AppDialog secondary 스타일 준용)
    final goHomeBg = isDarkMode ? AppColors.black800 : AppColors.black100;
    final goHomeFg = isDarkMode ? AppColors.white : AppColors.black;

    return Row(
      children: [
        Expanded(
          child: AppButton(
            key: const ValueKey('game_over_go_home_button'),
            text: '홈으로',
            onPressed: onGoHome,
            backgroundColor: goHomeBg,
            foregroundColor: goHomeFg,
            showBorder: false,
            height: 48.h,
          ),
        ),
        SizedBox(width: AppSpacing.horizontal12),
        Expanded(
          child: AppButton(
            key: const ValueKey('game_over_rematch_button'),
            text: '한 번 더',
            onPressed: onRematch,
            backgroundColor: rematchColor,
            foregroundColor: isDarkMode ? AppColors.black : AppColors.white,
            showBorder: false,
            height: 48.h,
          ),
        ),
      ],
    );
  }
}
