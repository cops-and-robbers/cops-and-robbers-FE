import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../buttons/app_button.dart';
import 'dialog_animation.dart';

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
/// // 아바타 포함 다이얼로그 (체포 로직 - 파란 확인 버튼)
/// AppDialog.show(
///   context: context,
///   title: '체포 성공!',
///   message: '도둑을 체포했습니다',
///   showAvatar: true,
///   avatarWidget: CircleAvatar(backgroundImage: NetworkImage(url)),
///   nickname: '도둑닉네임',
///   confirmColor: AppColors.blue,
/// );
///
/// // 버튼 없는 다이얼로그 (타이머/공지)
/// AppDialog.show(
///   context: context,
///   title: '게임 종료',
///   showButtons: false,
///   customContent: TimerWidget(),
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
class AppDialog extends StatelessWidget {
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

  // ============================================
  // 정적 메서드
  // ============================================

  /// 다이얼로그 표시
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
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
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
          onConfirm: onConfirm != null
              ? () {
                  Navigator.of(dialogContext).pop();
                  onConfirm.call();
                }
              : () => Navigator.of(dialogContext).pop(),
          onCancel: onCancel != null
              ? () {
                  Navigator.of(dialogContext).pop();
                  onCancel.call();
                }
              : () => Navigator.of(dialogContext).pop(),
        );
      },
      transitionBuilder: DialogAnimation.buildTransition,
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
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: DialogAnimation.barrierColor,
      transitionDuration: DialogAnimation.duration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AppDialog(
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
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        );
      },
      transitionBuilder: DialogAnimation.buildTransition,
    );
  }

  // ============================================
  // UI 빌드
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: AppPadding.horizontal36,
        padding: EdgeInsets.only(
          top: 24.w,
          left: 16.w,
          right: 16.w,
          bottom: 16.w,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아바타 + 닉네임 (선택)
              if (showAvatar) ...[
                _buildAvatarSection(),
                SizedBox(height: AppSpacing.vertical16),
              ],

              // 제목
              if (title != null)
                Text(
                  title!,
                  style:
                      titleStyle ??
                      AppTextStyles.heading_20.copyWith(color: AppColors.black),
                  textAlign: TextAlign.center,
                ),

              // 메시지
              if (message != null) ...[
                SizedBox(height: AppSpacing.vertical16),
                Text(
                  message!,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // 커스텀 콘텐츠
              if (customContent != null) ...[
                SizedBox(height: AppSpacing.vertical12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: customContent!,
                  ),
                ),
              ],

              // 버튼들
              if (showButtons) ...[
                SizedBox(height: AppSpacing.vertical20),
                _buildButtons(),
              ],
            ],
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
          child: avatarWidget ?? const SizedBox.shrink(),
        ),
        // 닉네임
        if (nickname != null) ...[
          SizedBox(height: AppSpacing.vertical4),
          Text(
            nickname!,
            style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// 확인 버튼 배경색 (기본값 적용)
  Color get _resolvedConfirmColor =>
      confirmColor ?? (isDestructive ? AppColors.red : AppColors.black);

  /// 확인 버튼 텍스트색 (기본값 적용)
  Color get _resolvedConfirmTextColor => confirmTextColor ?? AppColors.white;

  /// 취소 버튼 배경색 (기본값 적용)
  Color get _resolvedCancelColor => cancelColor ?? AppColors.black100;

  /// 취소 버튼 텍스트색 (기본값 적용)
  Color get _resolvedCancelTextColor => cancelTextColor ?? AppColors.black600;

  /// 버튼 영역
  Widget _buildButtons() {
    final hasCancel = cancelText != null;

    if (hasCancel) {
      // 2버튼: 취소 + 확인
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: cancelText!,
              onPressed: onCancel,
              backgroundColor: _resolvedCancelColor,
              foregroundColor: _resolvedCancelTextColor,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ),
          SizedBox(width: AppSpacing.horizontal8),
          Expanded(
            child: AppButton(
              text: confirmText,
              onPressed: onConfirm,
              backgroundColor: _resolvedConfirmColor,
              foregroundColor: _resolvedConfirmTextColor,
              borderRadius: AppRadius.medium,
              showBorder: false,
              height: 48.h,
            ),
          ),
        ],
      );
    }

    // 1버튼: 확인만
    return AppButton(
      text: confirmText,
      onPressed: onConfirm,
      backgroundColor: _resolvedConfirmColor,
      foregroundColor: _resolvedConfirmTextColor,
      borderRadius: AppRadius.medium,
      showBorder: false,
      width: double.infinity,
      height: 48.h,
    );
  }
}
