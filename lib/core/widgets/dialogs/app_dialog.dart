import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../services/vibration_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/app_button.dart';
import 'dialog_animation.dart';
import 'dialog_spacing.dart';

/// 앱 전역에서 사용하는 공용 다이얼로그 컴포넌트
///
/// **기본 스펙**:
/// - 배경: white, 모서리: 24px 라운드
/// - 양옆 마진: 36px (화면 너비에 맞게 확장)
/// - 애니메이션: 스케일 + 페이드 (250ms, easeOutBack)
///
/// **버튼 모드 3가지**:
/// 1. 2버튼 (취소+확인): `cancelText`를 지정하면 취소 버튼 표시
/// 2. 1버튼 (확인만): `cancelText` 미지정 (기본값)
/// 3. 무버튼: `showButtons: false` (타이머, 공지, 게임종료용)
///
/// **유효성 검증 + shake 애니메이션**:
/// `validator`를 지정하면 확인 버튼 탭 시 validator 실행.
/// false 반환 시 다이얼로그를 닫지 않고 흔들림 애니메이션으로 피드백.
///
/// **사용 예시**:
/// ```dart
/// // 기본 확인 다이얼로그 (1버튼)
/// AppDialog.show(
///   context: context,
///   title: '게임 규칙',
///   message: '30분 안에 모든 도둑을 체포하세요',
/// );
///
/// // 확인/취소 다이얼로그 (2버튼)
/// AppDialog.show(
///   context: context,
///   title: '체포할까요?',
///   message: '이 플레이어를 체포합니다',
///   cancelText: '취소',
///   onConfirm: () => capture(),
/// );
///
/// // validator + shake (6자리 코드 검증)
/// AppDialog.show(
///   context: context,
///   title: '방 참여하기',
///   customContent: AppTextField(controller: ctrl, maxLength: 6),
///   cancelText: '취소',
///   confirmText: '참여',
///   validator: () => ctrl.text.trim().length == 6,
///   onConfirm: () => joinRoom(ctrl.text.trim()),
/// );
///
/// // spacing 커스터마이징 (특정 다이얼로그만 간격 조절)
/// AppDialog.show(
///   context: context,
///   title: '게임 규칙',
///   spacing: DialogSpacing(toContent: AppSpacing.vertical12),
///   customContent: Column(...),
/// );
///
/// // 간편 확인 (bool 반환)
/// final result = await AppDialog.confirm(
///   context: context,
///   title: '삭제할까요?',
///   message: '삭제하면 되돌릴 수 없어요',
///   isDestructive: true,
/// );
/// if (result == true) { /* 삭제 */ }
/// ```
class AppDialog extends StatefulWidget {
  const AppDialog({
    super.key,
    this.title,
    this.message,
    this.confirmText = '확인',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showButtons = true,
    this.customContent,
    this.showAvatar = false,
    this.avatarWidget,
    this.nickname,
    this.confirmColor,
    this.confirmTextColor,
    this.cancelColor,
    this.cancelTextColor,
    this.titleStyle,
    this.spacing,
    this.backgroundColor,
    this.isDarkMode = false,
  });

  /// 제목 (선택) - heading_20, black. null이면 제목 영역 숨김
  final String? title;

  /// 메시지 (선택) - paragraph_14, black600
  final String? message;

  /// 확인 버튼 텍스트 (기본: '확인')
  final String confirmText;

  /// 취소 버튼 텍스트 (null이면 취소 버튼 없음)
  final String? cancelText;

  /// 확인 콜백
  final VoidCallback? onConfirm;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 위험 액션 여부 (true면 확인 버튼 빨간색)
  final bool isDestructive;

  /// 버튼 표시 여부 (false면 버튼 영역 전체 숨김)
  final bool showButtons;

  /// 커스텀 콘텐츠 (message 대신 또는 추가로 사용)
  final Widget? customContent;

  /// 아바타 표시 여부 (기본: false, 체포 로직 등 특정 상황에서만 사용)
  final bool showAvatar;

  /// 아바타 위젯 (showAvatar가 true일 때 표시)
  final Widget? avatarWidget;

  /// 닉네임 (showAvatar가 true일 때 아바타 아래 표시)
  final String? nickname;

  /// 확인 버튼 배경색 (미지정 시 isDestructive ? red : black)
  final Color? confirmColor;

  /// 확인 버튼 텍스트색 (미지정 시 white)
  final Color? confirmTextColor;

  /// 취소 버튼 배경색 (미지정 시 black100)
  final Color? cancelColor;

  /// 취소 버튼 텍스트색 (미지정 시 black600)
  final Color? cancelTextColor;

  /// 제목 스타일 오버라이드 (미지정 시 heading_20, black)
  final TextStyle? titleStyle;

  /// 다이얼로그 내부 섹션 간 간격 오버라이드 (미지정 시 기본값 적용)
  final DialogSpacing? spacing;

  /// 다이얼로그 배경색 (미지정 시 AppColors.white)
  final Color? backgroundColor;

  /// 다크 모드 버튼 기본값 활성화
  ///
  /// true일 때 명시적 색상 미지정 시:
  /// - confirm: green 배경, robberLabel + black 텍스트
  /// - cancel: black900 배경, robberLabel + black400 텍스트
  final bool isDarkMode;

  // ============================================
  // 정적 메서드
  // ============================================

  /// showGeneralDialog 공용 래퍼
  ///
  /// [show]와 [confirm]이 공유하는 다이얼로그 표시 보일러플레이트를 추출합니다.
  static Future<T?> _buildAndShow<T>({
    required BuildContext context,
    required bool barrierDismissible,
    required Widget Function(BuildContext dialogContext) builder,
  }) {
    // 다이얼로그 열기 전 포커스 해제 — 다이얼로그 닫힘(pop) 시
    // 이전 route의 TextField로 포커스가 자동 복원되는 것을 방지
    FocusScope.of(context).unfocus();
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, _, _) => builder(dialogContext),
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  /// 다이얼로그 표시
  ///
  /// [validator]를 지정하면 확인 버튼 탭 시 먼저 호출됩니다.
  /// false를 반환하면 다이얼로그를 닫지 않고 흔들림 애니메이션을 실행합니다.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    String confirmText = '확인',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
    bool showButtons = true,
    Widget? customContent,
    bool showAvatar = false,
    Widget? avatarWidget,
    String? nickname,
    bool barrierDismissible = true,
    Color? confirmColor,
    Color? confirmTextColor,
    Color? cancelColor,
    Color? cancelTextColor,
    TextStyle? titleStyle,
    bool Function()? validator,
    DialogSpacing? spacing,
    Color? backgroundColor,
    bool isDarkMode = false,
  }) {
    final dialogKey = GlobalKey<_AppDialogState>();

    return _buildAndShow<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AppDialog(
        key: dialogKey,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        showButtons: showButtons,
        customContent: customContent,
        showAvatar: showAvatar,
        avatarWidget: avatarWidget,
        nickname: nickname,
        confirmColor: confirmColor,
        confirmTextColor: confirmTextColor,
        cancelColor: cancelColor,
        cancelTextColor: cancelTextColor,
        titleStyle: titleStyle,
        spacing: spacing,
        backgroundColor: backgroundColor,
        isDarkMode: isDarkMode,
        onConfirm: () {
          if (validator != null && !validator()) {
            dialogKey.currentState?.shake();
            return;
          }
          Navigator.of(dialogContext).pop();
          onConfirm?.call();
        },
        onCancel: onCancel != null
            ? () {
                Navigator.of(dialogContext).pop();
                onCancel.call();
              }
            : () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  /// 간편 확인 다이얼로그 (bool 반환)
  static Future<bool?> confirm({
    required BuildContext context,
    String? title,
    String? message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
    bool showAvatar = false,
    Widget? avatarWidget,
    String? nickname,
    bool barrierDismissible = true,
    Color? confirmColor,
    Color? confirmTextColor,
    Color? cancelColor,
    Color? cancelTextColor,
    TextStyle? titleStyle,
    DialogSpacing? spacing,
    Color? backgroundColor,
    bool isDarkMode = false,
  }) {
    return _buildAndShow<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        showAvatar: showAvatar,
        avatarWidget: avatarWidget,
        nickname: nickname,
        confirmColor: confirmColor,
        confirmTextColor: confirmTextColor,
        cancelColor: cancelColor,
        cancelTextColor: cancelTextColor,
        titleStyle: titleStyle,
        spacing: spacing,
        backgroundColor: backgroundColor,
        isDarkMode: isDarkMode,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );
  }

  // ============================================
  // State
  // ============================================

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -8.w), weight: 1),
          TweenSequenceItem(
            tween: Tween(begin: -8.w, end: 8.w),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween(begin: 8.w, end: -6.w),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween(begin: -6.w, end: 4.w),
            weight: 2,
          ),
          TweenSequenceItem(tween: Tween(begin: 4.w, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  /// 흔들림 애니메이션 실행
  void shake() {
    _shakeController.forward(from: 0);
  }

  /// 확인 버튼 배경색 (기본값 적용)
  Color get _resolvedConfirmColor =>
      widget.confirmColor ??
      (widget.isDestructive
          ? AppColors.red
          : widget.isDarkMode
          ? AppColors.green
          : AppColors.black);

  /// 확인 버튼 텍스트색 (기본값 적용)
  Color get _resolvedConfirmTextColor =>
      widget.confirmTextColor ??
      (widget.isDarkMode ? AppColors.black : AppColors.white);

  /// 취소 버튼 배경색 (기본값 적용)
  Color get _resolvedCancelColor =>
      widget.cancelColor ??
      (widget.isDarkMode ? AppColors.black900 : AppColors.black100);

  /// 취소 버튼 텍스트색 (기본값 적용)
  Color get _resolvedCancelTextColor =>
      widget.cancelTextColor ??
      (widget.isDarkMode ? AppColors.black400 : AppColors.black600);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset * 0.4),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Center(
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              margin: AppPadding.horizontal36,
              padding: EdgeInsets.only(
                top: AppSpacing.vertical24,
                left: AppSpacing.horizontal12,
                right: AppSpacing.horizontal12,
                bottom: AppSpacing.vertical16,
              ),
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    (widget.isDarkMode ? AppColors.black : AppColors.white),
                borderRadius: AppRadius.xxlarge,
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아바타 + 닉네임 (선택)
                    if (widget.showAvatar) ...[
                      _buildAvatarSection(),
                      SizedBox(
                        height:
                            widget.spacing?.avatarToTitle ??
                            AppSpacing.vertical16,
                      ),
                    ],

                    // 제목
                    if (widget.title != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontal4,
                        ),
                        child: Text(
                          widget.title!,
                          style:
                              widget.titleStyle ??
                              (widget.isDarkMode
                                  ? AppTextStyles.robberHeading.copyWith(
                                      color: AppColors.white,
                                    )
                                  : AppTextStyles.heading_20.copyWith(
                                      color: AppColors.black,
                                    )),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // 메시지
                    if (widget.message != null) ...[
                      SizedBox(
                        height:
                            widget.spacing?.titleToMessage ??
                            AppSpacing.vertical12,
                      ),
                      Text(
                        widget.message!,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: widget.isDarkMode
                              ? AppColors.black400
                              : AppColors.black600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // 커스텀 콘텐츠
                    if (widget.customContent != null) ...[
                      SizedBox(
                        height:
                            widget.spacing?.toContent ??
                            (widget.message != null
                                ? AppSpacing.vertical12
                                : AppSpacing.vertical20),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontal6,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: widget.customContent!,
                        ),
                      ),
                    ],

                    // 버튼들
                    if (widget.showButtons) ...[
                      SizedBox(
                        height:
                            widget.spacing?.toButtons ?? AppSpacing.vertical20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.horizontal4,
                        ),
                        child: _buildButtons(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 아바타 + 닉네임 섹션
  Widget _buildAvatarSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아바타 이미지
        SizedBox(
          width: 92.w,
          height: 108.w,
          child: widget.avatarWidget ?? const SizedBox.shrink(),
        ),
        // 닉네임
        if (widget.nickname != null) ...[
          SizedBox(height: AppSpacing.vertical4),
          Text(
            widget.nickname!,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// 버튼 영역
  Widget _buildButtons() {
    final hasCancel = widget.cancelText != null;

    if (hasCancel) {
      // 2버튼: 취소 + 확인
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: widget.cancelText!,
              onPressed: widget.onCancel,
              backgroundColor: _resolvedCancelColor,
              foregroundColor: _resolvedCancelTextColor,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
              textStyle: widget.isDarkMode ? AppTextStyles.robberLabel : null,
            ),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Expanded(
            child: AppButton(
              text: widget.confirmText,
              onPressed: () {
                VibrationService.instance().buttonTap();
                widget.onConfirm?.call();
              },
              backgroundColor: _resolvedConfirmColor,
              foregroundColor: _resolvedConfirmTextColor,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
              textStyle: widget.isDarkMode ? AppTextStyles.robberLabel : null,
            ),
          ),
        ],
      );
    }

    // 1버튼: 확인만
    return AppButton(
      text: widget.confirmText,
      onPressed: () {
        VibrationService.instance().buttonTap();
        widget.onConfirm?.call();
      },
      backgroundColor: _resolvedConfirmColor,
      foregroundColor: _resolvedConfirmTextColor,
      borderRadius: AppRadius.medium,
      showBorder: false,
      width: double.infinity,
      height: 48.h,
      textStyle: widget.isDarkMode ? AppTextStyles.robberLabel : null,
    );
  }
}
