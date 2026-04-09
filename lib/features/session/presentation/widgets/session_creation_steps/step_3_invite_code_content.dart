import 'package:flutter/material.dart';

import '../../../../../core/constants/spacing_and_radius.dart';
import '../../../domain/entities/session_settings.dart';
import '../../../domain/entities/zone_info.dart';
import '../setting_list_card.dart';
import '../zone_list_card.dart';

/// 세션 생성 Step 3: 최종 설정 확인 컨텐츠
///
/// 세션 생성 전 마지막으로 설정한 구역과 게임 설정을 확인합니다.
/// 사용자가 "방 생성하기" 버튼을 클릭하면 API 호출 후 대기실로 이동합니다.
class Step3InviteCodeContent extends StatelessWidget {
  const Step3InviteCodeContent({
    super.key,
    required this.zones,
    required this.settings,
    this.settingSummaryKey,
  });

  // ============================================
  // Properties
  // ============================================

  /// 구역 정보 리스트
  final List<ZoneInfo> zones;

  /// 게임 설정 정보
  final SessionSettings settings;

  /// 튜토리얼 하이라이트용 — 설정 요약 영역 전체
  final GlobalKey? settingSummaryKey;

  // ============================================
  // Build Methods
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      key: settingSummaryKey,
      children: [
        ZoneListCard(zones: zones),
        SizedBox(height: AppSpacing.vertical8),
        SettingListCard(settings: settings),
      ],
    );
  }
}
