import 'package:flutter/material.dart';

import '../../../../core/constants/spacing_and_radius.dart';
import '../../../game/domain/entities/area_shape.dart';
import '../../domain/entities/session_settings.dart';
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
///   area: gameArea,
///   settings: SessionSettings(...),
///   onCodeCopy: () => showCopyMessage(),
/// )
/// ```
class SessionInfoView extends StatelessWidget {
  const SessionInfoView({
    super.key,
    required this.sessionCode,
    required this.area,
    required this.settings,
    this.onCodeCopy,
  });

  /// 세션 코드
  final String sessionCode;

  /// 게임 구역 (플레이그라운드 + 감옥)
  final GameAreaEntity area;

  /// 게임 설정
  final SessionSettings settings;

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
        ZoneListCard(area: area),
        SizedBox(height: AppSpacing.vertical8),
        SettingListCard(settings: settings),
      ],
    );
  }
}
