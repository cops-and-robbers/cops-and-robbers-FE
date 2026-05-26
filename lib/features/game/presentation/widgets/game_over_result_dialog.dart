import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
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

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 캐릭터 **몸통** SVG 경로 반환.
///
/// 몸통은 다이얼로그 **뒤**에 배치되어 상단 튀어나온 부분만 보임.
String resolveBodyAsset({required String myTeam, required String winnerTeam}) {
  final teamSlug = myTeam.toLowerCase();
  final resultSlug = myTeam == winnerTeam ? 'win' : 'lose';
  return 'assets/characters/$teamSlug/result/default/${resultSlug}_body.svg';
}

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 **왼쪽 팔** SVG 경로 반환.
///
/// 팔은 다이얼로그 **앞**에 배치되어 다이얼로그를 잡고 있는 입체감을 준다.
String resolveLeftArmAsset({
  required String myTeam,
  required String winnerTeam,
}) {
  final teamSlug = myTeam.toLowerCase();
  final resultSlug = myTeam == winnerTeam ? 'win' : 'lose';
  return 'assets/characters/$teamSlug/result/default/${resultSlug}_arm_left.svg';
}

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 **오른쪽 팔** SVG 경로 반환.
String resolveRightArmAsset({
  required String myTeam,
  required String winnerTeam,
}) {
  final teamSlug = myTeam.toLowerCase();
  final resultSlug = myTeam == winnerTeam ? 'win' : 'lose';
  return 'assets/characters/$teamSlug/result/default/${resultSlug}_arm_right.svg';
}

// ============================================================
// 위젯
// ============================================================

/// 게임 종료 결과 다이얼로그
///
/// 프로젝트 표준 `AppDialog` 레이아웃(margin/padding/radius/버튼 스타일/애니메이션)을
/// 그대로 따르며, 다이얼로그 상단 위에 팀/결과에 맞는 캐릭터 SVG를 오버레이로 얹는다.
///
/// - 승/패 타이틀 + 통계 3행 + 액션 버튼 2개
/// - `gameResultProvider(gameResultId)` 구독 → AsyncValue로 통계 분기
/// - 캐릭터 오버레이는 Stack + Positioned + Clip.none으로 다이얼로그 위로 튀어나옴
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

  // ============================================================
  // 캐릭터 레이어 상수 — 실제 SVG 크기에 맞춰 시각 QA 후 미세조정 필요
  // ============================================================

  // --- 경찰 몸통 ---
  /// 경찰 몸통 렌더 높이.
  static const double _policeBodyHeight = 136;

  /// 경찰 몸통 하단이 다이얼로그 상단에 겹쳐지는 깊이.
  /// 다이얼로그 radius와 비슷하게 두어 경계가 자연스럽게 보이도록.
  static const double _policeBodyOverlapIntoDialog = 40;

  /// 경찰 몸통 가로 오프셋. 양수 = 우측으로 이동.
  static const double _policeBodyHorizontalShift = 0;

  // --- 도둑 몸통 ---
  /// 도둑 몸통 렌더 높이 (경찰과 별개로 조절 가능).
  static const double _robberBodyHeight = 120;

  /// 도둑 몸통 하단이 다이얼로그 상단에 겹쳐지는 깊이.
  static const double _robberBodyOverlapIntoDialog = 36;

  /// 도둑 몸통 가로 오프셋 — SVG 비대칭(두건 매듭 등) 시각 보정.
  /// 양수 = 우측으로 이동.
  static const double _robberBodyHorizontalShift = 8;

  /// 팔 공통 top 오프셋 (다이얼로그 상단 기준).
  /// 음수 = 다이얼로그 위로, 양수 = 다이얼로그 안쪽으로.
  static const double _armTopOffset = -10;

  // --- 경찰 팔 ---
  /// 경찰 팔 렌더 크기 (원본 viewBox 47 × 26).
  static const double _policeArmWidth = 47;
  static const double _policeArmHeight = 26;

  /// 경찰 팔 좌/우 여백 (다이얼로그 가장자리 기준 안쪽).
  /// 값 ↑ = 팔 사이 좁아짐, 값 ↓ = 다이얼로그 모서리 가까이.
  static const double _policeArmLeftInset = 100;
  static const double _policeArmRightInset = 100;

  // --- 도둑 팔 ---
  /// 도둑 팔 렌더 크기 (경찰과 별개로 조절 가능).
  static const double _robberArmWidth = 47;
  static const double _robberArmHeight = 26;

  /// 도둑 팔 좌/우 여백 (경찰과 별개로 조절 가능).
  static const double _robberArmLeftInset = 100;
  static const double _robberArmRightInset = 100;

  /// 다이얼로그 호출 헬퍼 — `AppDialog`의 barrier 스타일을 따르되,
  /// 테스트 호환성 유지를 위해 `showDialog`의 기본 라우트를 사용한다.
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
      barrierColor: DialogAnimation.barrierColor,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: GameOverResultDialog(
          isDarkMode: isDarkMode,
          myTeam: myTeam,
          winnerTeam: winnerTeam,
          gameResultId: gameResultId,
          onGoHome: onGoHome,
          onRematch: onRematch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(gameResultProvider(gameResultId));
    final isWin = myTeam == winnerTeam;
    final isRobber = myTeam == 'ROBBER';
    final bodyAsset = resolveBodyAsset(myTeam: myTeam, winnerTeam: winnerTeam);
    final leftArmAsset = resolveLeftArmAsset(
      myTeam: myTeam,
      winnerTeam: winnerTeam,
    );
    final rightArmAsset = resolveRightArmAsset(
      myTeam: myTeam,
      winnerTeam: winnerTeam,
    );

    // 팀별 몸통 크기 / 겹침 깊이 / 가로 오프셋 선택
    final bodyHeight = isRobber ? _robberBodyHeight : _policeBodyHeight;
    final bodyOverlap = isRobber
        ? _robberBodyOverlapIntoDialog
        : _policeBodyOverlapIntoDialog;
    final bodyHorizontalShift = isRobber
        ? _robberBodyHorizontalShift
        : _policeBodyHorizontalShift;

    // 팀별 팔 크기 / 여백 선택 (사이즈·위치 팀 독립 조절)
    final armWidth = isRobber ? _robberArmWidth : _policeArmWidth;
    final armHeight = isRobber ? _robberArmHeight : _policeArmHeight;
    final armLeftInset = isRobber ? _robberArmLeftInset : _policeArmLeftInset;
    final armRightInset = isRobber
        ? _robberArmRightInset
        : _policeArmRightInset;

    // `Dialog(backgroundColor: transparent)`로 감싸서 showDialog의 기본 레이아웃
    // (중앙정렬 + 최대 폭 제한)을 활용하고, Stack 4-레이어 구조로
    // [몸통(뒤) → 다이얼로그(중간) → 왼쪽 팔 → 오른쪽 팔] 순서로 그려 입체감을 준다.
    // 팔은 좌/우 SVG를 분리해 각각 `left`/`right` 기준으로 독립 배치한다.
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 1) 몸통 — 맨 뒤, 다이얼로그에 가려져 상단(머리) 부분만 보임.
          //    크기·겹침·가로 오프셋 모두 팀별 상수에서 선택된 지역 변수 사용.
          Positioned(
            top: -(bodyHeight - bodyOverlap).h,
            child: Transform.translate(
              offset: Offset(bodyHorizontalShift.w, 0),
              child: SvgPicture.asset(
                bodyAsset,
                height: bodyHeight.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2) 다이얼로그 본체 — 몸통을 가리고 팔 아래에 깔림
          //    (AppDialog와 동일한 Container 구조)
          Container(
            width: double.infinity,
            margin: AppPadding.horizontal36,
            padding: EdgeInsets.only(
              top: AppSpacing.vertical24,
              left: AppSpacing.horizontal12,
              right: AppSpacing.horizontal12,
              bottom: AppSpacing.vertical16,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.black : AppColors.white,
              borderRadius: AppRadius.xxlarge,
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ResultTitle(isDarkMode: isDarkMode, isWin: isWin),
                  SizedBox(height: AppSpacing.vertical20),
                  _StatsSection(
                    isDarkMode: isDarkMode,
                    resultAsync: resultAsync,
                  ),
                  SizedBox(height: AppSpacing.vertical20),
                  _ActionButtons(
                    isDarkMode: isDarkMode,
                    onGoHome: onGoHome,
                    onRematch: onRematch,
                  ),
                ],
              ),
            ),
          ),

          // 3) 왼쪽 팔 — 맨 앞. SizedBox로 크기를 고정해 inset에 영향 받지 않게.
          //    크기/위치는 팀별 상수에서 선택된 지역 변수 사용.
          Positioned(
            top: _armTopOffset.h,
            left: armLeftInset.w,
            child: SizedBox(
              width: armWidth.w,
              height: armHeight.h,
              child: SvgPicture.asset(leftArmAsset),
            ),
          ),

          // 4) 오른쪽 팔 — 왼쪽 팔과 동일 구조, `right` 기준 배치.
          Positioned(
            top: _armTopOffset.h,
            right: armRightInset.w,
            child: SizedBox(
              width: armWidth.w,
              height: armHeight.h,
              child: SvgPicture.asset(rightArmAsset),
            ),
          ),
        ],
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
        : AppTextStyles.heading_24;

    final l10n = AppLocalizations.of(context);
    return Text(
      isWin ? l10n.gameResultWin : l10n.gameResultLose,
      style: baseStyle.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.isDarkMode, required this.resultAsync});

  final bool isDarkMode;
  final AsyncValue<GameResultEntity> resultAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return resultAsync.when(
      data: (entity) => Column(
        children: [
          _StatRow(
            isDarkMode: isDarkMode,
            label: l10n.labelArrestCount,
            value: l10n.gameResultArrestCount(entity.totalArrestCount),
          ),
          SizedBox(height: AppSpacing.vertical12),
          _StatRow(
            isDarkMode: isDarkMode,
            label: l10n.fieldRemainingRobbers,
            value: l10n.gameResultRemainingRobberCount(
              entity.remainingRobberCount,
            ),
          ),
          SizedBox(height: AppSpacing.vertical12),
          _StatRow(
            isDarkMode: isDarkMode,
            label: l10n.fieldGamePlaytime,
            value: formatDuration(entity.durationSeconds),
          ),
        ],
      ),
      loading: () => _placeholderRows(context),
      error: (_, _) => _placeholderRows(context),
    );
  }

  Widget _placeholderRows(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _StatRow(
          isDarkMode: isDarkMode,
          label: l10n.labelArrestCount,
          value: '-',
        ),
        SizedBox(height: AppSpacing.vertical12),
        _StatRow(
          isDarkMode: isDarkMode,
          label: l10n.fieldRemainingRobbers,
          value: '-',
        ),
        SizedBox(height: AppSpacing.vertical12),
        _StatRow(
          isDarkMode: isDarkMode,
          label: l10n.fieldGamePlaytime,
          value: '-',
        ),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal8),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          const Spacer(),
          Text(value, style: valueStyle),
        ],
      ),
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
    // AppDialog의 cancel/confirm 버튼 색상 규칙을 그대로 따름.
    // "한 번 더"는 feature 테마 유지를 위해 경찰 승리 시 blue 사용
    // (AppDialog 기본 confirm black 대신).
    final cancelBg = isDarkMode ? AppColors.black900 : AppColors.black100;
    final cancelFg = isDarkMode ? AppColors.black400 : AppColors.black600;
    final confirmBg = isDarkMode ? AppColors.green : AppColors.blue;
    final confirmFg = isDarkMode ? AppColors.black : AppColors.white;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: AppButton(
            key: const ValueKey('game_over_go_home_button'),
            text: l10n.buttonGoHome,
            onPressed: onGoHome,
            backgroundColor: cancelBg,
            foregroundColor: cancelFg,
            borderRadius: AppRadius.medium,
            showBorder: false,
            height: 48.h,
            textStyle: isDarkMode ? AppTextStyles.robberLabel : null,
          ),
        ),
        SizedBox(width: AppSpacing.horizontal8),
        Expanded(
          child: AppButton(
            key: const ValueKey('game_over_rematch_button'),
            text: l10n.buttonPlayAgain,
            onPressed: onRematch,
            backgroundColor: confirmBg,
            foregroundColor: confirmFg,
            borderRadius: AppRadius.medium,
            showBorder: false,
            height: 48.h,
            textStyle: isDarkMode ? AppTextStyles.robberLabel : null,
          ),
        ),
      ],
    );
  }
}
