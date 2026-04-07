import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../network/websocket/stomp_connection.dart';
import '../buttons/app_button.dart';
import 'dialog_animation.dart';

/// WebSocket 연결 끊김 시 표시되는 재연결 모달
///
/// - 경찰(light mode): 흰 배경, 파란 버튼
/// - 도둑(dark mode): 검은 배경, 초록 버튼
/// - [stateNotifier]를 통해 연결 상태 변화를 모달 내부에서 실시간 반영
///   (connecting → 스피너 표시 / disconnected·error → 재연결 버튼 활성화)
class ReconnectModal extends StatelessWidget {
  const ReconnectModal({
    required this.isDarkMode,
    required this.onReconnect,
    required this.stateNotifier,
    super.key,
  });

  /// 도둑팀: true (dark), 경찰팀: false (light)
  final bool isDarkMode;

  /// 재연결 버튼 탭 콜백
  final VoidCallback onReconnect;

  /// 현재 연결 상태 — 외부에서 값을 갱신하면 모달 UI가 즉시 반응
  final ValueNotifier<StompConnectionState> stateNotifier;

  // ============================================================
  // 정적 표시 메서드
  // ============================================================

  /// 재연결 모달 표시
  ///
  /// [barrierDismissible: false] — 사용자가 배리어 탭으로 닫을 수 없음.
  /// 재연결 성공 시 호출 측에서 [Navigator.pop]으로 직접 닫아야 합니다.
  static Future<void> show({
    required BuildContext context,
    required bool isDarkMode,
    required VoidCallback onReconnect,
    required ValueNotifier<StompConnectionState> stateNotifier,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ReconnectModal',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (ctx, anim, secondaryAnim) => ReconnectModal(
        isDarkMode: isDarkMode,
        onReconnect: onReconnect,
        stateNotifier: stateNotifier,
      ),
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  // ============================================================
  // 색상 헬퍼
  // ============================================================

  Color get _cardColor => isDarkMode ? AppColors.black : AppColors.white;
  Color get _indicatorColor => isDarkMode ? AppColors.white : AppColors.black;
  Color get _textColor => isDarkMode ? AppColors.black400 : AppColors.black600;
  Color get _buttonBg => isDarkMode ? AppColors.green : AppColors.blue;
  Color get _buttonFg => isDarkMode ? AppColors.black : AppColors.white;
  Color get _buttonDisabledBg =>
      isDarkMode ? AppColors.green500 : AppColors.blue500;
  Color get _buttonDisabledFg => _buttonFg;

  // ============================================================
  // 빌드
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<StompConnectionState>(
        valueListenable: stateNotifier,
        builder: (context, connState, _) {
          // connecting 중에만 버튼 비활성 / 그 외엔 항상 재연결 가능
          final isConnecting = connState == StompConnectionState.connecting;

          return Container(
            width: 320.w,
            height: 182.h,
            padding: EdgeInsets.only(
              top: 24.h,
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
            ),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: AppRadius.xxlarge,
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SizedBox(
                    width: 44.w,
                    height: 44.w,
                    child: CircularProgressIndicator(color: _indicatorColor),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    '연결이 끊어졌어요. 재연결이 필요해요',
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: _textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // connecting 중에만 "연결 중..." 비활성, 나머지는 "재연결" 활성
                  AppButton(
                    text: isConnecting ? '연결 중...' : '재연결',
                    onPressed: isConnecting ? null : onReconnect,
                    backgroundColor: _buttonBg,
                    foregroundColor: _buttonFg,
                    disabledBackgroundColor: _buttonDisabledBg,
                    disabledForegroundColor: _buttonDisabledFg,
                    borderRadius: AppRadius.medium,
                    showBorder: false,
                    width: double.infinity,
                    height: 48.h,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
