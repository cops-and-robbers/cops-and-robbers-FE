import 'package:flutter/material.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../domain/entities/session_settings.dart';
import '../../domain/entities/zone_info.dart';
import 'session_code_card.dart';
import 'setting_list_card.dart';
import 'zone_list_card.dart';

/// 세션 정보 전체 뷰
///
/// 세션 코드, 구역 목록, 게임 설정을 조합하여 표시합니다.
///
/// 사용 예시:
/// ```dart
/// SessionInfoView(
///   sessionCode: 'A1B2C3',
///   zones: [ZoneInfo(...)],
///   settings: SessionSettings(...),
///   onZoneTap: (zoneId) => navigateToZone(zoneId),
///   onCodeCopy: () => showCopyMessage(),
/// )
/// ```
class SessionInfoView extends StatelessWidget {
  const SessionInfoView({
    super.key,
    required this.sessionCode,
    required this.zones,
    required this.settings,
    this.onZoneTap,
    this.onCodeCopy,
  });

  /// 세션 코드
  final String sessionCode;

  /// 구역 정보 리스트
  final List<ZoneInfo> zones;

  /// 게임 설정
  final SessionSettings settings;

  /// 구역 클릭 콜백
  final void Function(String zoneId)? onZoneTap;

  /// 코드 복사 콜백
  final VoidCallback? onCodeCopy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Column → ListView
      shrinkWrap: true, // 부모 크기에 맞춤
      physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
      children: [
        SessionCodeCard(code: sessionCode, onCopy: onCodeCopy),
        SizedBox(height: AppSpacing.vertical16),
        ZoneListCard(zones: zones, onZoneTap: onZoneTap),
        SizedBox(height: AppSpacing.vertical8),
        SettingListCard(settings: settings),
      ],
    );
  }
}
