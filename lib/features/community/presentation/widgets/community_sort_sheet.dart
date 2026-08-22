import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/dividers/dashed_divider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/community_sort_option.dart';

/// 정렬 기준 선택 바텀시트
///
/// 목록 상단의 "최신순 ▾"을 누르면 아래에서 올라온다. 항목이 3개뿐이라
/// 드롭다운보다 바텀시트가 터치 영역이 넓고 한 손으로 닿는다.
///
/// 선택 결과는 [Navigator.pop]으로 돌려준다 — 시트가 상태를 들고 있지 않으므로
/// 호출부가 확정된 값만 받아 처리한다. (취소하면 null)
class CommunitySortSheet extends StatelessWidget {
  const CommunitySortSheet({super.key, required this.selected});

  final CommunitySortOption selected;

  /// 시트를 띄우고 선택된 값을 돌려준다. 바깥을 탭해 닫으면 null.
  static Future<CommunitySortOption?> show(
    BuildContext context, {
    required CommunitySortOption selected,
  }) {
    return showModalBottomSheet<CommunitySortOption>(
      context: context,
      // 바텀 네비까지 덮는다 — 이 시트를 띄우는 동안 탭 이동은 막는 게 맞고,
      // 브랜치 Navigator에 띄우면 시트가 네비 아래로 들어가 어중간하게 잘린다.
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
      builder: (_) => CommunitySortSheet(selected: selected),
    );
  }

  /// 선택 체크 아이콘 크기
  static double get _checkSize => 12.w;

  /// 텍스트 ↔ 체크 사이 간격. 왼쪽 대칭 여백도 이 값을 함께 쓴다.
  static double get _checkGap => AppSpacing.horizontal12;

  /// 표시 순서 — 인덱스 ↔ enum 변환의 단일 기준.
  ///
  /// 인기순은 뺀다. 서버가 `UNSUPPORTED_LIST_SORT`(400)를 주기 때문이다 —
  /// 좋아요·스크랩 테이블이 없어 셀 대상이 없다. enum 값은 남겨 둬야
  /// 서버가 열렸을 때 여기 한 줄만 되돌리면 된다(DEC-0020).
  static const List<CommunitySortOption> _order = [
    CommunitySortOption.latest,
    CommunitySortOption.distance,
    CommunitySortOption.deadline,
  ];

  String _label(AppLocalizations l10n, CommunitySortOption option) =>
      switch (option) {
        CommunitySortOption.latest => l10n.communitySortLatest,
        CommunitySortOption.popular => l10n.communitySortPopular,
        CommunitySortOption.distance => l10n.communitySortDistance,
        CommunitySortOption.deadline => l10n.communitySortDeadline,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 안드로이드는 제스처 인셋이 없거나 작아 시트가 화면 바닥에 붙어 마지막 항목이
    // 눌리기 어렵다. 바텀 네비와 같은 방식으로 30을 더해 그만큼 위로 올린다
    // (app_bottom_nav.dart:44와 동일 패턴, 다만 이 시트는 항목이 커서 20으로는
    // 부족해 30으로 키웠다).
    final androidExtra = Theme.of(context).platform == TargetPlatform.android
        ? 30.h
        : 0.0;

    // 높이 고정. 패딩·텍스트 줄높이만으로 셈한 값(202 안팎)은 실제 렌더링에서
    // 오버플로우가 났다 — 위젯 테스트로 실측해 항목 3개가 겹치지 않는 최소값(약
    // 265) 위에 여유를 둔 270으로 뒀다. 홈 인디케이터 자리를 겸하므로 SafeArea를
    // 두지 않는다.
    return SizedBox(
      height: 270.h + androidExtra,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSpacing.vertical14),
          _buildHandlebar(),
          SizedBox(height: AppSpacing.vertical12),
          for (int i = 0; i < _order.length; i++) ...[
            // 항목 사이에만 구분선 — 마지막 아래에는 두지 않는다.
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal26,
                ),
                child: const DashedDivider(),
              ),
            _buildOption(context, l10n, _order[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildHandlebar() {
    return Container(
      width: 50.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: AppColors.black200,
        borderRadius: AppRadius.pill,
      ),
    );
  }

  /// 항목 선택 — 터치와 스크린 리더 액션이 같은 경로를 타게 한다.
  ///
  /// 이미 선택된 항목이어도 진동은 준다. 시트는 어느 쪽이든 닫히므로 "터치가 먹혔다"는
  /// 확인이 필요하다 (AppBottomNav와 같은 판단).
  void _select(BuildContext context, CommunitySortOption option) {
    VibrationService.instance().buttonTap();
    Navigator.of(context).pop(option);
  }

  Widget _buildOption(
    BuildContext context,
    AppLocalizations l10n,
    CommunitySortOption option,
  ) {
    final isSelected = option == selected;
    final label = _label(l10n, option);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      // 자식 Text가 라벨을 중복 announce하지 않도록 제외하되, 그 때문에 탭 액션도
      // 접근성 트리에서 빠지므로 여기서 직접 노출한다 (SegmentedToggle과 동일).
      excludeSemantics: true,
      onTap: () => _select(context, option),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _select(context, option),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 오른쪽 체크 자리와 같은 폭을 왼쪽에도 비워 둔다. 체크만 붙이면
              // Row 중앙 정렬이 텍스트를 왼쪽으로 밀어, 선택된 항목만 글자 위치가
              // 어긋난다. 양쪽을 대칭으로 두면 세 항목의 글자가 같은 x에 선다.
              SizedBox(width: _checkGap + _checkSize),
              Text(
                label,
                style: AppTextStyles.label_16.copyWith(color: AppColors.black),
              ),
              SizedBox(width: _checkGap),
              SizedBox(
                width: _checkSize,
                // 색이 SVG에 박혀 있어 colorFilter를 주지 않는다.
                child: isSelected
                    ? SvgPicture.asset(
                        'assets/icons/icon_check.svg',
                        width: _checkSize,
                        height: _checkSize,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
