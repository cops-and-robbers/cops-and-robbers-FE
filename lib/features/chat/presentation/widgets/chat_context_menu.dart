import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/pages/text_submit_page.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/chat_message_dto.dart';
import '../../../report/domain/constants/report_categories.dart';

/// 채팅 메시지 롱프레스 시 표시되는 컨텍스트 메뉴 오버레이
///
/// 두 가지 모드:
/// 1. **액션 메뉴** — 복사하기, 신고하기, 차단하기
/// 2. **신고 카테고리 선택** — 신고하기 탭 시 전환
///
/// [show] 정적 메서드로 오버레이를 표시합니다.
class ChatContextMenu extends StatefulWidget {
  const ChatContextMenu._({
    required this.message,
    required this.isMe,
    required this.isDarkMode,
    required this.messageRect,
    required this.onBlock,
    required this.onReport,
    required this.callerContext,
  });

  final ChatMessageDto message;
  final bool isMe;
  final bool isDarkMode;
  final Rect messageRect;
  final void Function(int participantId) onBlock;

  /// 신고 콜백 (카테고리, 메시지 내용, 대상 participantId, 기타 사유)
  final Future<void> Function({
    required ReportCategory category,
    required String messageContent,
    required int reportedParticipantId,
    String? etcReason,
  })
  onReport;

  /// dismiss 후에도 유효한 호출자 context (Snackbar/Dialog 표시용)
  final BuildContext callerContext;

  /// 채팅 메시지 롱프레스 컨텍스트 메뉴를 표시합니다.
  static Future<void> show({
    required BuildContext context,
    required ChatMessageDto message,
    required bool isMe,
    required bool isDarkMode,
    required void Function(int participantId) onBlock,
    required Future<void> Function({
      required ReportCategory category,
      required String messageContent,
      required int reportedParticipantId,
      String? etcReason,
    })
    onReport,
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
        message: message,
        isMe: isMe,
        isDarkMode: isDarkMode,
        messageRect: messageRect,
        onBlock: onBlock,
        onReport: onReport,
        callerContext: context,
      ),
    );
  }

  @override
  State<ChatContextMenu> createState() => _ChatContextMenuState();
}

enum _MenuMode { actions, reportCategories }

class _ChatContextMenuState extends State<ChatContextMenu> {
  _MenuMode _mode = _MenuMode.actions;

  void _dismiss() => Navigator.of(context).pop();

  void _onCopy() {
    final l10n = AppLocalizations.of(widget.callerContext);
    Clipboard.setData(ClipboardData(text: widget.message.message));
    _dismiss();
    AppSnackbar.show(
      widget.callerContext,
      message: l10n.dialogchatContextMenuMessage,
      iconPath: 'assets/icons/icon_copy.svg',
      isDarkMode: widget.isDarkMode,
    );
  }

  void _onReportTap() {
    setState(() => _mode = _MenuMode.reportCategories);
  }

  void _onBlockWithSnackbar() {
    final l10n = AppLocalizations.of(widget.callerContext);
    _dismiss();
    widget.onBlock(widget.message.sender.participantId);
    AppSnackbar.show(
      widget.callerContext,
      message: l10n.messageUserBlocked,
      iconPath: 'assets/icons/icon_block.svg',
      isDarkMode: widget.isDarkMode,
    );
  }

  void _onCategorySelected(ReportCategory category) {
    final l10n = AppLocalizations.of(widget.callerContext);
    _dismiss();

    final isDark = widget.isDarkMode;

    // 기타(직접 작성): 신고 작성 페이지로 이동
    if (category == ReportCategory.other) {
      Navigator.of(widget.callerContext).push(
        MaterialPageRoute<void>(
          builder: (_) => TextSubmitPage(
            title: l10n.dialogchatContextMenuTitle,
            label: l10n.fieldchatContextMenuLabel,
            hintText: l10n.fieldchatContextMenuHint,
            submitText: l10n.buttonReport,
            isDestructive: true,
            isDarkMode: isDark,
            onSubmit: (text) async {
              try {
                await widget.onReport(
                  category: ReportCategory.other,
                  messageContent: widget.message.message,
                  reportedParticipantId: widget.message.sender.participantId,
                  etcReason: text,
                );
                if (!widget.callerContext.mounted) return;
                Navigator.of(widget.callerContext).pop();
                AppSnackbar.show(
                  widget.callerContext,
                  message: l10n.dialogchatContextMenuMessageDf78,
                  isDarkMode: isDark,
                );
              } catch (e) {
                if (!widget.callerContext.mounted) return;
                Navigator.of(widget.callerContext).pop();
                AppSnackbar.show(
                  widget.callerContext,
                  message: e is AppException
                      ? e.message
                      : l10n.errorReportFailed,
                  backgroundColor: AppColors.red,
                  isDarkMode: isDark,
                );
              }
            },
          ),
        ),
      );
      return;
    }

    // 나머지 카테고리: 확인 다이얼로그
    AppDialog.show(
      context: widget.callerContext,
      title: l10n.dialogReportConfirmTitle,
      cancelText: l10n.dialogchatContextMenuCancel,
      confirmText: l10n.dialogchatContextMenuConfirm,
      isDestructive: true,
      isDarkMode: isDark,
      cancelTextColor: isDark ? AppColors.black400 : AppColors.black600,
      confirmTextColor: isDark ? AppColors.white : null,
      customContent: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '${l10n.chatReportSelectedCategoryLabel} ',
              style: AppTextStyles.paragraph_14.copyWith(
                color: isDark ? AppColors.black400 : AppColors.black600,
              ),
            ),
            TextSpan(
              text: category.localizedLabel(l10n),
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.red,
              ),
            ),
            TextSpan(
              text: l10n.chatReportSubmitNotice,
              style: AppTextStyles.paragraph_14.copyWith(
                color: isDark ? AppColors.black400 : AppColors.black600,
              ),
            ),
          ],
        ),
      ),
      onConfirm: () async {
        try {
          await widget.onReport(
            category: category,
            messageContent: widget.message.message,
            reportedParticipantId: widget.message.sender.participantId,
          );
          if (!widget.callerContext.mounted) return;
          AppSnackbar.show(
            widget.callerContext,
            message: l10n.dialogchatContextMenuMessageDf78,
            isDarkMode: isDark,
          );
        } catch (e) {
          if (!widget.callerContext.mounted) return;
          AppSnackbar.show(
            widget.callerContext,
            message: e is AppException
                ? e.message
                : l10n.errorReportFailed,
            backgroundColor: AppColors.red,
            isDarkMode: isDark,
          );
        }
      },
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

  /// 버블 Container를 직접 빌드 (ChatMessageBubble의 Padding 없이)
  Widget _buildBubble() {
    final filteredMessage = widget.message.filteredMessage;
    final borderRadius = widget.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(12.r),
            bottomRight: Radius.circular(4.r),
          )
        : BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(12.r),
          );

    return Container(
      constraints: BoxConstraints(maxWidth: 240.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.black : AppColors.white,
        borderRadius: borderRadius,
      ),
      child: Text(
        filteredMessage,
        style: AppTextStyles.paragraph_14.copyWith(
          color: widget.isDarkMode ? AppColors.white : AppColors.black900,
        ),
      ),
    );
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
            child: _buildBubble(),
          ),

          // 메뉴 (크기 측정 후 위치 결정)
          _MenuPositioner(
            key: ValueKey(_mode),
            screenSize: screenSize,
            calculatePosition: _calculateMenuPosition,
            child: _mode == _MenuMode.actions
                ? _ActionMenu(
                    isMe: widget.isMe,
                    isDarkMode: widget.isDarkMode,
                    onCopy: _onCopy,
                    onReport: _onReportTap,
                    onBlock: _onBlockWithSnackbar,
                  )
                : _ReportCategoryMenu(
                    isDarkMode: widget.isDarkMode,
                    onCategorySelected: _onCategorySelected,
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
    super.key,
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
    required this.isMe,
    required this.isDarkMode,
    required this.onCopy,
    required this.onReport,
    required this.onBlock,
  });

  final bool isMe;
  final bool isDarkMode;
  final VoidCallback onCopy;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _MenuContainer(
      isDarkMode: isDarkMode,
      children: [
        _MenuItem(
          iconPath: 'assets/icons/icon_copy.svg',
          label: l10n.fieldchatContextMenuLabelA83e,
          textColor: isDarkMode ? AppColors.white : AppColors.black,
          iconColor: isDarkMode ? AppColors.black200 : AppColors.black800,
          isDarkMode: isDarkMode,
          onTap: onCopy,
        ),
        if (!isMe) ...[
          _MenuDivider(isDarkMode: isDarkMode),
          _MenuItem(
            iconPath: 'assets/icons/icon_siren.svg',
            label: l10n.buttonReport,
            textColor: AppColors.red,
            iconColor: AppColors.red900,
            isDarkMode: isDarkMode,
            onTap: onReport,
          ),
          _MenuDivider(isDarkMode: isDarkMode),
          _MenuItem(
            iconPath: 'assets/icons/icon_block.svg',
            label: l10n.buttonBlock,
            textColor: isDarkMode ? AppColors.white : AppColors.black,
            iconColor: isDarkMode ? AppColors.black200 : AppColors.black800,
            isDarkMode: isDarkMode,
            onTap: onBlock,
          ),
        ],
      ],
    );
  }
}

/// 신고 카테고리 선택 메뉴
class _ReportCategoryMenu extends StatelessWidget {
  const _ReportCategoryMenu({
    required this.isDarkMode,
    required this.onCategorySelected,
  });

  final bool isDarkMode;
  final void Function(ReportCategory category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ReportCategory.values;

    return _MenuContainer(
      isDarkMode: isDarkMode,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontal20,
            AppSpacing.vertical16,
            AppSpacing.horizontal20,
            AppSpacing.vertical4,
          ),
          child: Text(
            l10n.chatReportCategoryTitle,
            style:
                (isDarkMode
                        ? AppTextStyles.robberParagraph
                        : AppTextStyles.paragraph14Semibold)
                    .copyWith(
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
          ),
        ),
        ...List.generate(categories.length * 2 - 1, (index) {
          if (index.isOdd) return _MenuDivider(isDarkMode: isDarkMode);
          final category = categories[index ~/ 2];
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              color: isDarkMode ? AppColors.black : AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal20,
                vertical: AppSpacing.vertical16,
              ),
              child: Text(
                category.localizedLabel(l10n),
                style: AppTextStyles.label16Medium.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// 메뉴 컨테이너 — 흰 배경, 라운드 코너
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
    return Divider(
      height: 1,
      color: isDarkMode ? AppColors.black800 : AppColors.black100,
      indent: 20.w,
      endIndent: 20.w,
    );
  }
}
