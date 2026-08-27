import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../features/report/domain/report_target.dart';
import '../../../features/report/presentation/report_flow.dart';
import '../../../l10n/app_localizations.dart';
import '../../constants/app_colors.dart';
import '../../constants/spacing_and_radius.dart';
import '../../constants/text_styles.dart';
import '../dividers/solid_divider.dart';
import '../snackbars/app_snackbar.dart';

/// 메뉴 뒤에 원래 자리로 다시 그리는 말풍선 — 닉네임·시각·아바타 없이 본문만
///
/// 실제 말풍선을 그대로 쓰지 않는 이유: 원래 위치에 겹쳐 그리는 용도라 주변
/// 여백까지 따라오면 자리가 어긋난다. 색과 모서리는 화면마다 달라서 받는다.
class ChatContextMenuBubble extends StatelessWidget {
  const ChatContextMenuBubble({
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
    required this.borderRadius,
    super.key,
  });

  final String text;
  final Color backgroundColor;
  final TextStyle textStyle;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 240.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Text(text, style: textStyle),
    );
  }
}

/// 채팅 메시지 롱프레스 시 표시되는 컨텍스트 메뉴 오버레이
///
/// 인게임 채팅과 모집글 채팅이 함께 쓴다 — 신고 진입 UI를 두 벌 만들지 않는다.
/// 말풍선 자체는 [bubble]로 호출자가 그려 넘긴다: 두 화면의 말풍선 모양과
/// 데이터 타입이 달라서, 여기서 그리려면 DTO 하나에 묶여 버린다.
///
/// 항목은 있는 것만 뜬다 — [reportTarget]이 null이면 신고가, [onBlock]이
/// null이면 차단이 빠진다(모집글 채팅에는 차단이 없다).
///
/// 신고하기를 누르면 이 오버레이는 닫히고 유형 선택은 `ReportCategoryPage`가
/// 받는다 — 모집글 신고와 같은 화면이다.
class ChatContextMenu extends StatefulWidget {
  const ChatContextMenu._({
    required this.bubble,
    required this.copyText,
    required this.isDarkMode,
    required this.messageRect,
    required this.onBlock,
    required this.reportTarget,
    required this.callerContext,
  });

  /// 원래 자리에 다시 그릴 말풍선. 호출자가 자기 화면의 것을 그대로 넘긴다.
  final Widget bubble;

  /// 복사하기가 클립보드에 담을 문자열. 화면에 보이는 대로(필터 적용 후) 넘긴다.
  final String copyText;

  final bool isDarkMode;
  final Rect messageRect;

  /// null이면 차단 항목을 그리지 않는다.
  final VoidCallback? onBlock;

  /// 무엇을 신고하는가 — 신고 화면이 이 대상으로 접수한다.
  /// null이면 신고 항목을 그리지 않는다(내 메시지·아직 전송 중 등).
  final ReportTarget? reportTarget;

  /// dismiss 후에도 유효한 호출자 context (Snackbar/Dialog 표시용)
  final BuildContext callerContext;

  /// 채팅 메시지 롱프레스 컨텍스트 메뉴를 표시합니다.
  static Future<void> show({
    required BuildContext context,
    required Widget bubble,
    required String copyText,
    bool isDarkMode = false,
    ReportTarget? reportTarget,
    VoidCallback? onBlock,
  }) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Future.value();

    final offset = renderBox.localToGlobal(Offset.zero);
    final messageRect = offset & renderBox.size;

    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.white.withValues(alpha: 0),
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) => ChatContextMenu._(
        bubble: bubble,
        copyText: copyText,
        isDarkMode: isDarkMode,
        messageRect: messageRect,
        onBlock: onBlock,
        reportTarget: reportTarget,
        callerContext: context,
      ),
    );
  }

  @override
  State<ChatContextMenu> createState() => _ChatContextMenuState();
}

class _ChatContextMenuState extends State<ChatContextMenu> {
  void _dismiss() => Navigator.of(context).pop();

  void _onCopy() {
    final l10n = AppLocalizations.of(widget.callerContext);
    Clipboard.setData(ClipboardData(text: widget.copyText));
    _dismiss();
    AppSnackbar.show(
      widget.callerContext,
      message: l10n.messageMessageCopied,
      iconPath: 'assets/icons/icon_copy.svg',
      isDarkMode: widget.isDarkMode,
    );
  }

  /// 신고하기 — 유형 선택은 커뮤니티와 같은 화면에서 한다.
  ///
  /// 예전에는 이 오버레이 안에서 유형까지 골랐다. 화면으로 옮기면서 "고른 즉시
  /// 접수"가 아니라 아래 신고하기 버튼이 확인을 겸하게 됐다.
  void _onReportTap() {
    _dismiss();
    unawaited(_pickCategoryAndReport());
  }

  Future<void> _pickCategoryAndReport() => runReportFlow(
    context: widget.callerContext,
    target: widget.reportTarget!,
    isDarkMode: widget.isDarkMode,
  );

  void _onBlockWithSnackbar() {
    final l10n = AppLocalizations.of(widget.callerContext);
    _dismiss();
    widget.onBlock!();
    AppSnackbar.show(
      widget.callerContext,
      message: l10n.messageUserBlocked,
      iconPath: 'assets/icons/icon_block.svg',
      isDarkMode: widget.isDarkMode,
    );
  }

  /// 메뉴 위치 계산: 항상 메시지 위, AppSpacing.vertical8 간격
  Offset _calculateMenuPosition({
    required Size menuSize,
    required Size screenSize,
  }) {
    final marginW = AppSpacing.horizontal16;
    final marginH = AppSpacing.vertical16;

    double left = widget.messageRect.left;
    if (left + menuSize.width > screenSize.width - marginW) {
      left = screenSize.width - marginW - menuSize.width;
    }
    if (left < marginW) left = marginW;

    double top =
        widget.messageRect.top - menuSize.height - AppSpacing.vertical8;
    if (top < marginH) top = marginH;

    return Offset(left, top);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Material(
      color: AppColors.white.withValues(alpha: 0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 어두운 배경 오버레이
          GestureDetector(
            onTap: _dismiss,
            child: Container(color: AppColors.black.withValues(alpha: 0.4)),
          ),

          // 원래 위치에 버블 표시 (Padding 없이 Container만)
          Positioned(
            left: widget.messageRect.left,
            top: widget.messageRect.top,
            child: widget.bubble,
          ),

          // 메뉴 (크기 측정 후 위치 결정)
          _MenuPositioner(
            screenSize: screenSize,
            calculatePosition: _calculateMenuPosition,
            child: _ActionMenu(
              isDarkMode: widget.isDarkMode,
              onCopy: _onCopy,
              onReport: widget.reportTarget == null ? null : _onReportTap,
              onBlock: widget.onBlock == null ? null : _onBlockWithSnackbar,
            ),
          ),
        ],
      ),
    );
  }
}

/// 메뉴 위젯의 크기를 측정한 뒤 올바른 위치에 배치하는 헬퍼 위젯
class _MenuPositioner extends StatefulWidget {
  const _MenuPositioner({
    required this.screenSize,
    required this.calculatePosition,
    required this.child,
  });

  final Size screenSize;
  final Offset Function({required Size menuSize, required Size screenSize})
  calculatePosition;
  final Widget child;

  @override
  State<_MenuPositioner> createState() => _MenuPositionerState();
}

class _MenuPositionerState extends State<_MenuPositioner> {
  Size? _menuSize;
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() => _menuSize = renderBox.size);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuSize = _menuSize;

    if (menuSize == null) {
      // 첫 프레임: 투명하게 숨겨서 크기 측정
      return Positioned(
        left: 0,
        top: 0,
        child: Opacity(
          opacity: 0,
          child: Container(key: _key, child: widget.child),
        ),
      );
    }

    final position = widget.calculatePosition(
      menuSize: menuSize,
      screenSize: widget.screenSize,
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(key: _key, child: widget.child),
    );
  }
}

/// 액션 메뉴 (복사하기 / 신고하기 / 차단하기)
class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.isDarkMode,
    required this.onCopy,
    required this.onReport,
    required this.onBlock,
  });

  final bool isDarkMode;
  final VoidCallback onCopy;

  /// null이면 그 항목을 그리지 않는다.
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _MenuContainer(
      isDarkMode: isDarkMode,
      children: [
        _MenuItem(
          iconPath: 'assets/icons/icon_copy.svg',
          label: l10n.buttonCopy,
          textColor: isDarkMode ? AppColors.white : AppColors.black,
          iconColor: isDarkMode ? AppColors.black200 : AppColors.black800,
          isDarkMode: isDarkMode,
          onTap: onCopy,
        ),
        if (onReport != null) ...[
          _MenuDivider(isDarkMode: isDarkMode),
          _MenuItem(
            iconPath: 'assets/icons/icon_siren.svg',
            label: l10n.buttonReport,
            textColor: AppColors.red,
            iconColor: AppColors.red900,
            isDarkMode: isDarkMode,
            onTap: onReport!,
          ),
        ],
        if (onBlock != null) ...[
          _MenuDivider(isDarkMode: isDarkMode),
          _MenuItem(
            iconPath: 'assets/icons/icon_block.svg',
            label: l10n.buttonBlock,
            textColor: isDarkMode ? AppColors.white : AppColors.black,
            iconColor: isDarkMode ? AppColors.black200 : AppColors.black800,
            isDarkMode: isDarkMode,
            onTap: onBlock!,
          ),
        ],
      ],
    );
  }
}

class _MenuContainer extends StatelessWidget {
  const _MenuContainer({required this.children, this.isDarkMode = false});

  final List<Widget> children;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 204.w,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.black : AppColors.white,
        borderRadius: AppRadius.xlarge,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// 메뉴 아이템 (아이콘 + 텍스트)
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.iconPath,
    required this.label,
    required this.textColor,
    this.iconColor,
    this.isDarkMode = false,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final Color textColor;
  final Color? iconColor;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isDarkMode ? AppColors.black : AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontal20,
          vertical: AppSpacing.vertical16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(
                iconColor ?? textColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Text(
              label,
              style:
                  (isDarkMode
                          ? AppTextStyles.robberLabel
                          : AppTextStyles.label_16)
                      .copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// 메뉴 구분선
class _MenuDivider extends StatelessWidget {
  const _MenuDivider({this.isDarkMode = false});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return SolidDivider(
      color: isDarkMode ? AppColors.black800 : AppColors.black100,
      indent: 20.w,
      endIndent: 20.w,
    );
  }
}
