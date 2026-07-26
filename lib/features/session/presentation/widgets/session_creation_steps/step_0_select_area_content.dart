import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/widgets/buttons/zone_setting_button.dart';
import '../../../../../features/game/domain/entities/area_shape.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../router/route_paths.dart';

/// 세션 생성 Step 0: 구역 선택 컨텐츠
///
/// 플레이그라운드와 감옥 구역 설정을 위한 UI를 제공합니다.
/// ZoneSettingButton을 통해 각 구역 설정 페이지로 이동하며,
/// 설정 완료 시 콜백으로 데이터를 전달합니다.
///
/// 플레이그라운드 설정이 완료된 후에만 감옥 구역 설정 버튼이 노출됩니다.
class Step0SelectAreaContent extends StatelessWidget {
  const Step0SelectAreaContent({
    super.key,
    required this.playgroundShape,
    required this.prisonShape,
    required this.onPlaygroundResult,
    required this.onPrisonResult,
    this.playgroundKey,
    this.prisonKey,
  });

  // ============================================
  // Properties
  // ============================================

  /// 설정된 플레이그라운드 도형 (미설정이면 null)
  final AreaShape? playgroundShape;

  /// 설정된 감옥 도형 (미설정이면 null)
  final AreaShape? prisonShape;

  /// 플레이그라운드 설정 결과 콜백
  final ValueChanged<AreaShape> onPlaygroundResult;

  /// 감옥 설정 결과 콜백
  final ValueChanged<AreaShape> onPrisonResult;

  /// 튜토리얼 하이라이트용 — 플레이그라운드 버튼
  final GlobalKey? playgroundKey;

  /// 튜토리얼 하이라이트용 — 감옥 버튼
  final GlobalKey? prisonKey;

  // ============================================
  // Event Handlers
  // ============================================

  /// 플레이그라운드 설정 버튼 클릭 시
  ///
  /// 최초 생성(감옥 미설정) 흐름에서는 플레이그라운드 완료 직후 감옥 설정으로
  /// 자동 연결해 이탈을 줄인다. 감옥이 이미 설정된 뒤(재설정)에는 허브로 돌아온다.
  Future<void> _onPlaygroundPressed(BuildContext context) async {
    final wasPrisonSet = prisonShape != null;
    final result = await context.pushNamed<AreaShape>(
      RoutePaths.setupPlaygroundFromFlowName,
    );
    if (result == null) return;
    onPlaygroundResult(result);

    if (!wasPrisonSet && context.mounted) {
      await _onPrisonPressed(context);
    }
  }

  /// 감옥 설정 버튼 클릭 시
  Future<void> _onPrisonPressed(BuildContext context) async {
    final result = await context.pushNamed<AreaShape>(
      RoutePaths.setupPrisonFromFlowName,
    );
    if (result != null) onPrisonResult(result);
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // 플레이그라운드 버튼 (항상 노출)
        ZoneSettingButton(
          key: playgroundKey,
          zoneType: ZoneType.playground,
          title: l10n.dialogstep0SelectAreaContentTitle,
          shape: playgroundShape,
          onPressed: () => _onPlaygroundPressed(context),
        ),

        // 감옥 버튼 (플레이그라운드 설정 완료 후에만 노출)
        if (playgroundShape != null) ...[
          SizedBox(height: AppSpacing.vertical8),
          ZoneSettingButton(
            key: prisonKey,
            zoneType: ZoneType.prison,
            title: l10n.dialogstep0SelectAreaContentTitle5bc0,
            shape: prisonShape,
            onPressed: () => _onPrisonPressed(context),
          ),
        ],
      ],
    );
  }
}
