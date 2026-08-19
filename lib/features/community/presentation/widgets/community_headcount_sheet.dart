import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'community_sheet_scaffold.dart';

/// 모집 인원 선택 바텀시트 (휠 + 빠른 증가 칩)
///
/// 범위는 백엔드 `CommunityPostCreateRequest`의 제약을 그대로 따른다
/// (`maxParticipants`: min 2 / max 50). 시안은 1부터 그려져 있지만 1은
/// 서버가 거부하므로 휠에 올리지 않는다.
///
/// 선택 결과는 [Navigator.pop]으로 돌려준다 — 확정 전 값은 시트 안에만
/// 머무르고, 바깥을 탭해 닫으면 null이라 호출부 상태가 변하지 않는다
/// (`CommunitySortSheet`와 같은 계약).
class CommunityHeadcountSheet extends StatefulWidget {
  const CommunityHeadcountSheet({super.key, required this.selected});

  final int selected;

  /// 모집 인원 하한 — 혼자 하는 모임은 없다 (백엔드 제약과 동일).
  static const int min = 2;

  /// 모집 인원 상한 (백엔드 제약과 동일).
  static const int max = 50;

  /// 시트를 띄우고 확정된 인원을 돌려준다. 바깥을 탭해 닫으면 null.
  static Future<int?> show(BuildContext context, {required int selected}) {
    return CommunitySheetScaffold.show<int>(
      context,
      builder: (_) => CommunityHeadcountSheet(selected: selected),
    );
  }

  @override
  State<CommunityHeadcountSheet> createState() =>
      _CommunityHeadcountSheetState();
}

class _CommunityHeadcountSheetState extends State<CommunityHeadcountSheet> {
  late final FixedExtentScrollController _wheelController;
  late int _current;

  /// 한 번에 더할 수 있는 인원 — 칩 3개의 단일 기준.
  static const List<int> _quickAdds = [5, 10, 20];

  /// 휠 한 칸 높이. 시안의 숫자 간격에서 역산했다.
  static double get _itemExtent => 40.h;

  /// 휠에 보이는 줄 수 — 가운데 1 + 위아래 3씩.
  static const int _visibleRows = 7;

  @override
  void initState() {
    super.initState();
    _current = widget.selected.clamp(
      CommunityHeadcountSheet.min,
      CommunityHeadcountSheet.max,
    );
    _wheelController = FixedExtentScrollController(
      initialItem: _current - CommunityHeadcountSheet.min,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  /// 칩 탭 — 현재 값에 더하고 휠을 그 자리로 굴린다.
  ///
  /// 휠을 움직이면 `onSelectedItemChanged`가 따라 울리므로 `_current`는
  /// 여기서 직접 바꾸지 않는다. 두 곳에서 쓰면 애니메이션 중간값과 어긋난다.
  void _quickAdd(int amount) {
    VibrationService.instance().buttonTap();
    final next = (_current + amount).clamp(
      CommunityHeadcountSheet.min,
      CommunityHeadcountSheet.max,
    );
    if (next == _current) return;
    _wheelController.animateToItem(
      next - CommunityHeadcountSheet.min,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CommunitySheetScaffold(
      title: l10n.communityCreateLabelHeadcount,
      onDone: () => Navigator.of(context).pop(_current),
      children: [
        Row(
          children: [
            for (int i = 0; i < _quickAdds.length; i++) ...[
              if (i > 0) SizedBox(width: AppSpacing.horizontal6),
              Expanded(child: _buildQuickAddChip(l10n, _quickAdds[i])),
            ],
          ],
        ),
        SizedBox(height: AppSpacing.vertical20),
        SizedBox(height: _itemExtent * _visibleRows, child: _buildWheel()),
      ],
    );
  }

  Widget _buildQuickAddChip(AppLocalizations l10n, int amount) {
    final label = l10n.communityHeadcountQuickAdd(amount);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: () => _quickAdd(amount),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _quickAdd(amount),
        child: Container(
          height: 34.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.black100,
            borderRadius: AppRadius.medium,
          ),
          child: Text(
            label,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black700,
            ),
          ),
        ),
      ),
    );
  }

  /// 휠은 시안대로 단위 없는 숫자만 굴린다 — 단위("명")는 시트를 닫은 뒤
  /// 작성 화면의 인원 표시가 붙인다.
  Widget _buildWheel() {
    // 기본 selectionOverlay는 선택 줄에 회색 밴드를 깐다. 시안은 밴드 없이
    // 글자 색만으로 선택을 나타내므로 끈다.
    return CupertinoPicker(
      scrollController: _wheelController,
      itemExtent: _itemExtent,
      selectionOverlay: null,
      onSelectedItemChanged: (index) =>
          setState(() => _current = index + CommunityHeadcountSheet.min),
      children: [
        for (
          int count = CommunityHeadcountSheet.min;
          count <= CommunityHeadcountSheet.max;
          count++
        )
          Center(
            child: Text(
              '$count',
              style: AppTextStyles.heading_24.copyWith(
                color: count == _current
                    ? AppColors.black700
                    : AppColors.black200,
              ),
            ),
          ),
      ],
    );
  }
}
