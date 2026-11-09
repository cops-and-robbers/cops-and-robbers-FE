import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/radio_session_provider.dart';

/// 누르고 있는 동안만 말하는 무전 버튼 (#697)
///
/// 게임 화면 좌우 버튼(SvgIconButton)과 같은 56·모서리 16. 경찰(라이트) 화면에서만 쓴다.
/// 탭이 아니라 누름/뗌을 받아야 해서 GestureDetector 대신 [Listener]를 쓴다 —
/// 손가락이 밖으로 미끄러지거나 전화가 와서 포인터가 취소돼도 반드시 [onRelease]가 불린다.
class RadioPttButton extends StatelessWidget {
  const RadioPttButton({
    super.key,
    required this.state,
    required this.onPress,
    required this.onRelease,
    required this.onBlockedTap,
  });

  final RadioSessionState state;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  /// 대기 시간·마이크 거부·다른 경찰 송신 중에 눌렀을 때 — 왜 안 되는지 알려 준다
  final VoidCallback onBlockedTap;

  bool get _canTalk =>
      state.status == RadioStatus.ready && state.speakerIdentity == null;

  @override
  Widget build(BuildContext context) {
    final talking = state.talking;
    final iconColor = talking
        ? AppColors.white
        : _canTalk
        ? AppColors.blue
        : AppColors.black200;

    return Semantics(
      button: true,
      enabled: _canTalk,
      label: AppLocalizations.of(context).radioPttLabel,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (!_canTalk) return onBlockedTap();
          VibrationService.instance().buttonTap();
          onPress();
        },
        onPointerUp: (_) => onRelease(),
        onPointerCancel: (_) => onRelease(),
        child: AnimatedScale(
          scale: talking ? 1.08 : 1,
          duration: const Duration(milliseconds: 80),
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: talking ? AppColors.blue : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: AppShadows.softThemed(false),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              AppIcons.mic,
              width: 32.w,
              height: 32.w,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
