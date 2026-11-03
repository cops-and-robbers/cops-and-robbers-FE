import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../domain/event_evidence.dart';
import '../../domain/event_evidence_layout.dart';
import 'event_evidence_image.dart';

/// 이벤트 모드 — 게임 종료 결과 증거 보드.
///
/// 수집한 증거는 선명하게, 미수집 증거는 회색 틀과 자물쇠로 표시한다.
/// 사진 수와 비율에 따라 배치가 달라진다([EventEvidenceLayout]).
/// "운영진 N명 검거" 텍스트와 "홈으로" 버튼만 제공(이벤트 모드는 rematch 없음).
class EventResultBoard extends StatelessWidget {
  /// 사진 영역의 높이 제한. 작은 폰에서 팝업이 화면을 넘지 않게 한다.
  static const double _maxPhotoHeightRatio = 0.45;

  const EventResultBoard({
    required this.arrestCount,
    required this.onGoHome,
    this.title,
    this.buttonText,
    this.evidence = EventEvidence.bundled,
    super.key,
  });

  /// 검거한 운영진 수. 증거는 사진 수까지 공개한다.
  final int arrestCount;

  /// 하단 버튼 콜백 (게임종료=홈 이동 / 인게임=오버레이 닫기).
  final VoidCallback onGoHome;

  /// 보드 제목 (null이면 게임종료 기본 문구 "수사 종료").
  final String? title;

  /// 하단 버튼 라벨 (null이면 "홈으로").
  final String? buttonText;

  /// 이번 판의 증거 사진.
  final EventEvidence evidence;

  /// 다이얼로그 형태로 표시하는 헬퍼.
  ///
  /// 배리어 탭으로 닫히지 않으며, 스케일+페이드 트랜지션 사용.
  static Future<void> show({
    required BuildContext context,
    required int arrestCount,
    required VoidCallback onGoHome,
    String? title,
    String? buttonText,
    EventEvidence evidence = EventEvidence.bundled,
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
          evidence: evidence,
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
            _buildPhotos(context),
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

  /// 사진 수와 비율로 배치를 정해 증거 칸을 놓는다.
  Widget _buildPhotos(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * _maxPhotoHeightRatio;
    return LayoutBuilder(
      builder: (_, constraints) {
        final layout = EventEvidenceLayout.resolve(
          aspectRatio: evidence.aspectRatio,
          count: evidence.count,
          maxWidth: constraints.maxWidth,
          maxHeight: maxHeight,
          horizontalGap: AppSpacing.horizontal16,
          verticalGap: AppSpacing.vertical16,
        );
        final slots = [
          for (var i = 1; i <= evidence.count; i++) _buildSlot(i, layout),
        ];
        if (layout.arrangement == EventEvidenceArrangement.twoOverOne) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _withGaps(
                  slots.take(2).toList(),
                  SizedBox(width: AppSpacing.horizontal16),
                ),
              ),
              SizedBox(height: AppSpacing.vertical16),
              slots.last,
            ],
          );
        }
        if (layout.arrangement == EventEvidenceArrangement.stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: _withGaps(slots, SizedBox(height: AppSpacing.vertical16)),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _withGaps(slots, SizedBox(width: AppSpacing.horizontal16)),
        );
      },
    );
  }

  List<Widget> _withGaps(List<Widget> slots, Widget gap) => [
    for (var i = 0; i < slots.length; i++) ...[if (i > 0) gap, slots[i]],
  ];

  /// 증거 칸 하나를 빌드한다.
  ///
  /// [index]는 1부터. 아직 못 모은 칸은 사진 대신 회색 틀과 자물쇠를 표시한다.
  Widget _buildSlot(int index, EventEvidenceLayout layout) {
    final collected = arrestCount >= index;
    return SizedBox(
      key: ValueKey('event_result_slot_$index'),
      width: layout.slotWidth,
      height: layout.slotHeight,
      child: Transform.rotate(
        angle: layout.tiltFor(index, evidence.count),
        child: collected
            ? ClipRRect(
                borderRadius: AppRadius.medium,
                child: EventEvidenceImage(photo: evidence.photoFor(index)),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  // 미수집: 증거 사진은 숨기고 자리(형태)만 회색 틀로 표시
                  Container(
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
