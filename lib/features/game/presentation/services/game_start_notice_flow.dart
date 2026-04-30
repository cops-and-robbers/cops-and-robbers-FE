import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/services/background/background_service.dart';
import '../../../../core/services/tutorial/tutorial_keys.dart';
import '../../../../core/services/tutorial/tutorial_service.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';

/// 게임 시작 시 1회성 안내 다이얼로그 플로우
///
/// 표시 순서 (각각 1회만):
/// 1. 배터리 최적화 안내 (Android 전용) — 절전 모드 제외 방법 안내
/// 2. 배터리 영향 안내 (iOS/Android 공통) — GPS·통신 소모 사전 고지
///
/// 표시 여부는 [TutorialService]가 SharedPreferences로 관리.
/// 설정의 "튜토리얼 초기화" 시 같이 리셋되어 다시 노출됨.
/// 첫 번째 다이얼로그를 [확인]으로 닫아야 두 번째가 나타남 (await 순차 처리).
class GameStartNoticeFlow {
  // 유틸 클래스 — 인스턴스화 금지
  GameStartNoticeFlow._();

  /// 아직 보여주지 않은 안내 다이얼로그를 순서대로 표시
  ///
  /// [context]는 유효한 BuildContext여야 함. 비동기 사이마다 mounted를 검사하므로
  /// context가 무효화되면 즉시 반환.
  /// [backgroundService]는 [설정 열기] 버튼 클릭 시 native 설정 화면을 여는 데 사용.
  /// [isDarkMode]는 팀 테마. 도둑(ROBBER)이면 true, 경찰(POLICE)이면 false.
  ///
  /// 호출 위치: GamePage initState의 addPostFrameCallback 내부.
  static Future<void> showOnceIfNeeded(
    BuildContext context, {
    required BackgroundService backgroundService,
    required bool isDarkMode,
  }) async {
    // 1. 배터리 최적화 안내 (Android만, 1회)
    if (Platform.isAndroid) {
      final shown = await TutorialService.isCompleted(
        TutorialKeys.batteryOptNotice,
      );
      if (!shown) {
        // 저장을 먼저 해서 다이얼로그 중 앱이 종료돼도 재표시되지 않게 함
        await TutorialService.markCompleted(TutorialKeys.batteryOptNotice);
        if (!context.mounted) return;
        await AppDialog.show<void>(
          context: context,
          title: '끊김 없는 게임을 위해',
          message:
              '일부 단말은 절전 모드에서 게임을 멈출 수 있습니다.\n\n'
              '"앱 설정 → 배터리"에서 "제한 없음" 또는\n'
              '"배터리 사용 제한 안 함"을 선택해주세요.',
          cancelText: '나중에',
          confirmText: '설정 열기',
          isDarkMode: isDarkMode,
          // 사용자 명시적 [설정 열기] 탭 → App Store Guideline 5.1.1(iv) 준수
          onConfirm: () => backgroundService.openAppSettings(),
        );
      }
    }

    // 2. 배터리 영향 안내 (양 플랫폼, 1회)
    if (!context.mounted) return;
    final noticeShown = await TutorialService.isCompleted(
      TutorialKeys.batteryImpactNotice,
    );
    if (!noticeShown) {
      await TutorialService.markCompleted(TutorialKeys.batteryImpactNotice);
      if (!context.mounted) return;
      await AppDialog.show<void>(
        context: context,
        title: '게임 중 배터리 사용',
        message:
            '게임 중에는 GPS와 통신을 계속 사용해서\n'
            '평소보다 배터리가 빠르게 소모됩니다.\n\n'
            '게임이 끝나면 자동으로 중단됩니다.',
        isDarkMode: isDarkMode,
      );
    }
  }
}
