import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import 'dialog_animation.dart';

/// 버튼 없이 콘텐츠만 표시하는 팝업
///
/// 타이머, 게임 종료, 카운트다운 등 인터랙션 없이
/// 정보만 보여주는 용도로 사용합니다.
/// AppDialog와 동일한 컨테이너 스타일(white, 24r, 36 마진)과
/// 애니메이션(스케일 + 페이드)을 공유합니다.
///
/// **사용 예시**:
/// ```dart
/// // 기본 팝업 (배경 터치로 닫기 가능)
/// AppPopup.show(
///   context: context,
///   content: TimerWidget(),
/// );
///
/// // 자동 닫힘 팝업 (barrierDismissible 자동 비활성화)
/// await AppPopup.show(
///   context: context,
///   content: GameOverWidget(),
///   autoCloseDuration: Duration(seconds: 5),
/// );
/// context.go('/game/result'); // 닫힌 후 이동
/// ```
class AppPopup extends StatefulWidget {
  const AppPopup({super.key, required this.content, this.autoCloseDuration});

  /// 팝업 콘텐츠 위젯
  final Widget content;

  /// 자동 닫힘 시간 (null이면 자동 닫힘 없음)
  final Duration? autoCloseDuration;

  /// 팝업 표시
  ///
  /// [autoCloseDuration]을 지정하면 해당 시간 후 자동으로 닫히며,
  /// [barrierDismissible]은 자동으로 false가 됩니다 (배경 터치 닫기 차단).
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,
    bool barrierDismissible = true,
    Duration? autoCloseDuration,
  }) {
    // autoCloseDuration 설정 시 배경 터치 닫기 자동 비활성화
    final effectiveBarrierDismissible = autoCloseDuration != null
        ? false
        : barrierDismissible;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: effectiveBarrierDismissible,
      barrierLabel: 'Popup',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppPopup(content: content, autoCloseDuration: autoCloseDuration);
      },
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  @override
  State<AppPopup> createState() => _AppPopupState();
}

class _AppPopupState extends State<AppPopup> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    if (widget.autoCloseDuration != null) {
      _autoCloseTimer = Timer(widget.autoCloseDuration!, () {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget popup = Center(
      child: Container(
        width: double.infinity,
        margin: AppPadding.horizontal36,
        padding: EdgeInsets.symmetric(vertical: 42.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Material(color: Colors.transparent, child: widget.content),
      ),
    );

    if (widget.autoCloseDuration != null) {
      popup = PopScope(canPop: false, child: popup);
    }

    return popup;
  }
}
