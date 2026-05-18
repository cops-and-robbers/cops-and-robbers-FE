import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../../services/loading_message_service.dart';
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
  const AppPopup({
    super.key,
    required this.content,
    this.autoCloseDuration,
    this.backgroundColor,
  });

  /// 팝업 콘텐츠 위젯
  final Widget content;

  /// 자동 닫힘 시간 (null이면 자동 닫힘 없음)
  final Duration? autoCloseDuration;

  /// 팝업 배경색 (미지정 시 AppColors.white)
  final Color? backgroundColor;

  /// 팝업 표시
  ///
  /// [autoCloseDuration]을 지정하면 해당 시간 후 자동으로 닫히며,
  /// [barrierDismissible]은 자동으로 false가 됩니다 (배경 터치 닫기 차단).
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,
    bool barrierDismissible = true,
    Duration? autoCloseDuration,
    Color? backgroundColor,
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
        return AppPopup(
          content: content,
          autoCloseDuration: autoCloseDuration,
          backgroundColor: backgroundColor,
        );
      },
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  /// 로딩 팝업 표시 (터치 차단)
  ///
  /// [CircularProgressIndicator] + 메시지 텍스트를 표시하는 간편 메서드입니다.
  /// API 호출 등 비동기 작업 중 사용자에게 진행 상태를 알립니다.
  /// 닫기: `Navigator.of(context).pop()`
  ///
  /// ```dart
  /// AppPopup.showLoading(context: context, message: '로그아웃 중...');
  /// await someAsyncWork();
  /// if (navigator.canPop()) navigator.pop();
  /// ```
  static Future<T?> showLoading<T>({
    required BuildContext context,
    required String message,
  }) {
    return show<T>(
      context: context,
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.black),
          SizedBox(height: AppSpacing.vertical16),
          Text(
            message,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.black600,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 기반 랜덤 로딩 팝업 표시
  ///
  /// `assets/messages/loading_messages.json`에서 카테고리에 해당하는
  /// 메시지를 랜덤으로 선택하여 표시합니다.
  ///
  /// **주의**: 이 메서드의 Future는 메시지 로드 완료 시 resolve됩니다.
  /// [showLoading]의 Future(팝업 닫힘 시 resolve)는 의도적으로
  /// await하지 않습니다 (fire-and-forget). 팝업은 호출부에서
  /// `Navigator.of(context).pop()`으로 직접 닫아야 합니다.
  ///
  /// ```dart
  /// await AppPopup.showRandomLoading(
  ///   context: context,
  ///   category: LoadingCategory.joinRoom,
  /// );
  /// await someApiCall();
  /// if (navigator.canPop()) navigator.pop(); // 로딩 팝업 닫기
  /// ```
  static Future<void> showRandomLoading({
    required BuildContext context,
    required LoadingCategory category,
  }) async {
    final message = LoadingMessageService.getMessage(context, category);
    if (!context.mounted) return;
    // showLoading의 Future는 팝업이 닫힐 때 complete되므로 await하지 않음
    showLoading(context: context, message: message);
  }

  @override
  State<AppPopup> createState() => _AppPopupState();
}

class _AppPopupState extends State<AppPopup> with WidgetsBindingObserver {
  Timer? _autoCloseTimer;
  DateTime? _closeTime;

  @override
  void initState() {
    super.initState();
    if (widget.autoCloseDuration != null) {
      WidgetsBinding.instance.addObserver(this);
      _closeTime = DateTime.now().add(widget.autoCloseDuration!);
      _scheduleClose();
    }
  }

  @override
  void dispose() {
    if (widget.autoCloseDuration != null) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleClose();
    }
  }

  void _scheduleClose() {
    _autoCloseTimer?.cancel();
    final remaining = _closeTime!.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _popIfCurrent();
    } else {
      _autoCloseTimer = Timer(remaining, _popIfCurrent);
    }
  }

  void _popIfCurrent() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget popup = Center(
      child: Container(
        width: double.infinity,
        margin: AppPadding.horizontal36,
        padding: EdgeInsets.symmetric(vertical: 42.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.white,
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
