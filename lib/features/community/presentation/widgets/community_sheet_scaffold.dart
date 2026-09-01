import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../l10n/app_localizations.dart';

/// 모집글 작성 화면에서 올라오는 바텀시트의 공통 껍데기
/// (상단 타이틀 + 우측 완료, 핸들바 없음)
///
/// `CommunitySortSheet`는 탭 즉시 값이 확정돼 핸들바만 있으면 됐지만, 날짜·인원은
/// 휠을 굴려 고른 뒤 확정하는 흐름이라 "완료"가 필요하다. 그래서 시트 셋업
/// (배경·barrier·상단 라운드·안드로이드 여백)만 같은 값을 쓰고 내용은 나눈다.
class CommunitySheetScaffold extends StatelessWidget {
  const CommunitySheetScaffold({
    super.key,
    required this.title,
    required this.onDone,
    required this.children,
    this.height,
    this.showDivider = false,
  });

  final String title;

  /// 완료 탭 — 보통 확정된 값을 들고 `Navigator.pop`한다.
  final VoidCallback onDone;

  /// 타이틀 아래에 세로로 쌓일 내용.
  final List<Widget> children;

  /// 시트 높이. null이면 내용에 맞춘다. 내용이 상태에 따라 늘었다 줄었다 하는
  /// 시트(휠 펼침)는 고정해야 열고 닫을 때마다 시트가 튀지 않는다.
  final double? height;

  /// 타이틀 아래 실선 구분선 여부. 시트 좌우 끝까지 이어진다.
  final bool showDivider;

  /// 시트를 띄운다. 셋업 값은 `CommunitySortSheet`와 동일하게 맞춘다.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      // 바텀 네비까지 덮는다 — 시트를 띄운 동안 탭 이동은 막는 게 맞다.
      useRootNavigator: true,
      backgroundColor: AppColors.white,
      // Material 기본값(black54)은 이 앱의 연하늘 배경 위에서 과하게 어둡다.
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      // 상단만 둥글게 — 아래는 화면 끝에 붙는다.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.xl18.topLeft,
          topRight: AppRadius.xl18.topRight,
        ),
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 안드로이드는 제스처 인셋이 없거나 작아 시트가 화면 바닥에 붙는다.
    // 바텀 네비와 같은 방식으로 그만큼 위로 올린다 (community_sort_sheet.dart:79).
    final androidExtra = Theme.of(context).platform == TargetPlatform.android
        ? AppSpacing.vertical20
        : 0.0;

    // 구분선만 시트 좌우 끝까지 이어져야 해서 좌우 여백을 시트 전체가 아니라
    // 헤더와 내용에 각각 준다.
    final horizontal = EdgeInsets.symmetric(
      horizontal: AppSpacing.horizontal21,
    );

    return SizedBox(
      height: height == null ? null : height! + androidExtra,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.vertical24),
          Padding(padding: horizontal, child: _buildHeader(context, l10n)),
          if (showDivider) ...[
            SizedBox(height: AppSpacing.vertical12),
            const SolidDivider(),
          ],
          SizedBox(height: AppSpacing.vertical20),
          Padding(
            padding: horizontal,
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
          SizedBox(height: AppSpacing.vertical20 + androidExtra),
        ],
      ),
    );
  }

  /// 타이틀은 시트 정중앙, 완료는 오른쪽 끝.
  ///
  /// `Row`로 나란히 놓으면 완료 폭만큼 타이틀이 왼쪽으로 밀려, 로케일마다
  /// 타이틀 위치가 달라진다. `Stack`으로 겹쳐 두 위치를 서로 독립시킨다.
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Stack은 positioned가 아닌 자식 크기로 줄어든다 — 이 줄이 없으면
        // 폭이 타이틀 글자 폭이 되어 완료가 타이틀 위에 겹쳐 그려진다.
        const SizedBox(width: double.infinity),
        Text(
          title,
          style: AppTextStyles.label_16.copyWith(color: AppColors.black),
        ),
        Positioned(
          right: 0,
          child: Semantics(
            button: true,
            label: l10n.buttonDone,
            excludeSemantics: true,
            onTap: _handleDone,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleDone,
              child: Text(
                l10n.buttonDone,
                style: AppTextStyles.label_16.copyWith(color: AppColors.logo),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleDone() {
    VibrationService.instance().buttonTap();
    onDone();
  }
}
