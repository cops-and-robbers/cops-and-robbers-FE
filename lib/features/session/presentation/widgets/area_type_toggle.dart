import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/toggles/segmented_toggle.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../game/data/models/game_area_model.dart';

/// 구역 설정 방식 토글 (거리로 설정 = 원형 / 핀으로 설정 = 폴리곤)
///
/// 트랙·애니메이션·햅틱·접근성은 공용 [SegmentedToggle]이 담당하고, 이 위젯은
/// `GameAreaType` ↔ 세그먼트 인덱스 변환만 한다.
///
/// 폭 350은 이 화면 전용 디자인 스펙이라 여기서 준다. 대기방에서 도둑 팀이
/// 다크 배경 위에서 보게 되므로 [isDarkMode]를 그대로 넘긴다.
class AreaTypeToggle extends StatelessWidget {
  const AreaTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.isDarkMode = false,
  });

  final GameAreaType selected;
  final ValueChanged<GameAreaType> onChanged;

  /// 다크(도둑) 테마 여부
  final bool isDarkMode;

  /// 세그먼트 표시 순서 — 인덱스 ↔ enum 변환의 단일 기준
  static const List<GameAreaType> _order = [
    GameAreaType.circle,
    GameAreaType.polygon,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedToggle(
      labels: [l10n.areaTypeSetByDistance, l10n.areaTypeSetByPin],
      selectedIndex: _order.indexOf(selected),
      onChanged: (index) => onChanged(_order[index]),
      width: 350.w,
      isDarkMode: isDarkMode,
    );
  }
}
