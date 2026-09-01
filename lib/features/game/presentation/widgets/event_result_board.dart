import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';

/// 이벤트 모드 — 게임 종료 결과 증거 보드.
///
/// 수집한 증거(1..arrestCount)는 선명, 미수집은 50% 흐림(Opacity 위젯) +
/// 가운데 자물쇠 아이콘으로 표시한다.
/// "운영진 N명 검거" 텍스트와 "홈으로" 버튼만 제공(이벤트 모드는 rematch 없음).
class EventResultBoard extends StatelessWidget {
  const EventResultBoard({
    required this.arrestCount,
    required this.onGoHome,
    this.title,
    this.buttonText,
    super.key,
  });

  /// 검거한 운영진 수 (0~3).
  final int arrestCount;

  /// 하단 버튼 콜백 (게임종료=홈 이동 / 인게임=오버레이 닫기).
  final VoidCallback onGoHome;

  /// 보드 제목 (null이면 게임종료 기본 문구 "수사 종료").
  final String? title;

  /// 하단 버튼 라벨 (null이면 "홈으로").
  final String? buttonText;

  /// 고정 증거 에셋 수(evidence1~3).
  static const int _total = 3;

  /// 슬롯별 핀보드 배치 — 좌/상 오프셋(dp), 회전 각도(라디안), 크기 배율.
  /// 시각 QA 시 미세조정 가능. scale은 96x80 기준 슬롯별 확대율.
  static const List<({double left, double top, double angle, double scale})>
  _slots = [
    (left: 16, top: 8, angle: -0.09, scale: 1.0),
    (left: 150, top: 16, angle: 0.09, scale: 1.25),
    (left: 70, top: 92, angle: -0.04, scale: 1.3),
  ];

  /// 다이얼로그 형태로 표시하는 헬퍼.
  ///
  /// 배리어 탭으로 닫히지 않으며, 스케일+페이드 트랜지션 사용.
  static Future<void> show({
    required BuildContext context,
    required int arrestCount,
    required VoidCallback onGoHome,
    String? title,
    String? buttonText,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (_, _, _) => PopScope(
        canPop: false,
        child: EventResultBoard(
          arrestCount: arrestCount,
          onGoHome: onGoHome,
          title: title,
          buttonText: buttonText,
        ),
      ),
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppPadding.horizontal36,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 결과 타이틀 ("수사 종료")
            Text(
              title ?? l10n.gameEventResultTitle,
              style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical16),
            // 핀보드 콜라주 영역 — Stack으로 증거 슬롯 3개를 겹쳐 배치
            SizedBox(
              width: double.infinity,
              height: 190.h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (int i = 1; i <= _total; i++)
                    _buildSlot(i, i <= arrestCount),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.vertical16),
            // 검거 수 텍스트 ("운영진 N명 검거")
            Text(
              l10n.gameEventResultArrestCount(arrestCount),
              style: AppTextStyles.heading_20.copyWith(color: AppColors.blue),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.vertical20),
            // "홈으로" 버튼 (이벤트 모드: rematch 없음)
            AppButton(
              text: buttonText ?? l10n.buttonGoHome,
              onPressed: onGoHome,
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }

  /// 증거 슬롯 하나를 빌드한다.
  ///
  /// [index] 1~3, [collected] true이면 선명 / false이면 Opacity(0.5) + 자물쇠.
  Widget _buildSlot(int index, bool collected) {
    final cfg = _slots[index - 1];
    final evidenceImage = Image.asset(
      'assets/events/evidence$index.png',
      width: 96.w * cfg.scale,
      height: 80.w * cfg.scale,
      fit: BoxFit.contain,
    );

    return Positioned(
      // 슬롯 전체(흐림+자물쇠 포함)에 key를 붙여 테스트에서 개수 검증
      key: ValueKey('event_result_slot_$index'),
      left: cfg.left.w,
      top: cfg.top.h,
      child: Transform.rotate(
        angle: cfg.angle,
        child: collected
            ? evidenceImage
            : Stack(
                alignment: Alignment.center,
                children: [
                  // 미수집: 증거 사진은 숨기고 자리(형태)만 회색 틀로 표시
                  Container(
                    width: 96.w * cfg.scale,
                    height: 80.w * cfg.scale,
                    decoration: BoxDecoration(
                      color: AppColors.black100,
                      borderRadius: AppRadius.medium,
                    ),
                  ),
                  // 자물쇠 아이콘 (key로 테스트에서 존재 여부 검증)
                  Container(
                    key: ValueKey('event_result_lock_$index'),
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 16.w,
                      color: AppColors.black400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
