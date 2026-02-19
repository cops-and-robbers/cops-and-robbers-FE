import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../../../core/widgets/buttons/zone_setting_button.dart';

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
    required this.playgroundCenter,
    required this.playgroundRadiusMeters,
    required this.prisonCenter,
    required this.prisonRadiusMeters,
    required this.onPlaygroundSet,
    required this.onPrisonSet,
  });

  // ============================================
  // Properties
  // ============================================

  /// 플레이그라운드 중심 좌표
  final LatLng? playgroundCenter;

  /// 플레이그라운드 반경 (미터)
  final double? playgroundRadiusMeters;

  /// 감옥 중심 좌표
  final LatLng? prisonCenter;

  /// 감옥 반경 (미터)
  final double? prisonRadiusMeters;

  /// 플레이그라운드 설정 완료 콜백
  final Function(LatLng center, double radius) onPlaygroundSet;

  /// 감옥 설정 완료 콜백
  final Function(LatLng center, double radius) onPrisonSet;

  // ============================================
  // Event Handlers
  // ============================================

  /// 플레이그라운드 설정 버튼 클릭 시
  Future<void> _onPlaygroundPressed(BuildContext context) async {
    final result = await context.pushNamed('setupPlaygroundFromFlow');

    if (result is Map<String, dynamic>) {
      final center = result['center'] as LatLng;
      final radius = result['radius'] as double;
      onPlaygroundSet(center, radius);
    }
  }

  /// 감옥 설정 버튼 클릭 시
  Future<void> _onPrisonPressed(BuildContext context) async {
    final result = await context.pushNamed('setupPrisonFromFlow');

    if (result is Map<String, dynamic>) {
      final center = result['center'] as LatLng;
      final radius = result['radius'] as double;
      onPrisonSet(center, radius);
    }
  }

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    final isPlaygroundSet =
        playgroundCenter != null && playgroundRadiusMeters != null;

    return Column(
      children: [
        // 플레이그라운드 버튼 (항상 노출)
        ZoneSettingButton(
          zoneType: ZoneType.playground,
          title: '플레이그라운드',
          radiusMeters: playgroundRadiusMeters,
          onPressed: () => _onPlaygroundPressed(context),
        ),

        // 감옥 버튼 (플레이그라운드 설정 완료 후에만 노출)
        if (isPlaygroundSet) ...[
          SizedBox(height: AppSpacing.vertical8),
          ZoneSettingButton(
            zoneType: ZoneType.prison,
            title: '감옥',
            radiusMeters: prisonRadiusMeters,
            onPressed: () => _onPrisonPressed(context),
          ),
        ],
      ],
    );
  }
}
