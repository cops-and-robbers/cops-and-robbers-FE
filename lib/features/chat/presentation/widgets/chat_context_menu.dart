import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/content_filter/profanity_filter.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../data/models/chat_message_dto.dart';
import '../../domain/constants/report_categories.dart';

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
    required this.callerContext,
  });

  final ChatMessageDto message;
  final bool isMe;
  final bool isDarkMode;
  final Rect messageRect;
  final void Function(int participantId) onBlock;

  /// dismiss 후에도 유효한 호출자 context (Snackbar/Dialog 표시용)
  final BuildContext callerContext;

  /// 채팅 메시지 롱프레스 컨텍스트 메뉴를 표시합니다.
  static Future<void> show({
    required BuildContext context,
    required ChatMessageDto message,
    required bool isMe,
    required bool isDarkMode,
    required void Function(int participantId) onBlock,
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
    Clipboard.setData(ClipboardData(text: widget.message.message));
    _dismiss();
    AppSnackbar.show(
      widget.callerContext,
      message: '메시지가 복사되었어요',
      iconPath: 'assets/icons/icon_copy.svg',
    );
  }

  void _onReportTap() {
    setState(() => _mode = _MenuMode.reportCategories);
  }

  void _onBlockWithSnackbar() {
    _dismiss();
    widget.onBlock(widget.message.sender.participantId);
    AppSnackbar.show(
      widget.callerContext,
      message: '해당 유저를 차단했어요',
      iconPath: 'assets/icons/icon_block.svg',
    );
  }

  void _onCategorySelected(ReportCategory category) {
    _dismiss();

    AppDialog.show(
      context: widget.callerContext,
      title: '해당 유저를 신고할까요?',
      cancelText: '취소',
      confirmText: '신고하기',
      isDestructive: true,
      customContent: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: '선택한 신고 사유: ',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
            ),
            TextSpan(
              text: category.label,
              style: AppTextStyles.paragraph14Semibold.copyWith(
                color: AppColors.red,
              ),
            ),
            TextSpan(
              text: '\n신고된 내용은 검토 후 조치할게요',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.black600,
              ),
            ),
          ],
        ),
      ),
      onConfirm: () {
        // TODO: 신고 API 호출
        AppSnackbar.show(widget.callerContext, message: '신고가 접수되었어요');
      },
    );
  }

  /// 메뉴 위치 계산: 항상 메시지 위, AppSpacing.vertical8 간격
  Offset _calculateMenuPosition({
    required Size menuSize,
    required Size screenSize,
  }) {
    final marginW = 16.w;
    final marginH = 16.h;

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
    final filteredMessage = ProfanityFilter.filter(widget.message.message);
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
                    onCopy: _onCopy,
                    onReport: _onReportTap,
                    onBlock: _onBlockWithSnackbar,
                  )
                : _ReportCategoryMenu(onCategorySelected: _onCategorySelected),
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
    required this.onCopy,
    required this.onReport,
    required this.onBlock,
  });

  final bool isMe;
  final VoidCallback onCopy;
  final VoidCallback onReport;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    return _MenuContainer(
      children: [
        _MenuItem(
          iconPath: 'assets/icons/icon_copy.svg',
          label: '복사하기',
          textColor: AppColors.black,
          iconColor: AppColors.black800,
          onTap: onCopy,
        ),
        if (!isMe) ...[
          _MenuDivider(),
          _MenuItem(
            iconPath: 'assets/icons/icon_siren.svg',
            label: '신고하기',
            textColor: AppColors.red,
            iconColor: AppColors.red900,
            onTap: onReport,
          ),
          _MenuDivider(),
          _MenuItem(
            iconPath: 'assets/icons/icon_block.svg',
            label: '차단하기',
            textColor: AppColors.black,
            iconColor: AppColors.black800,
            onTap: onBlock,
          ),
        ],
      ],
    );
  }
}

/// 신고 카테고리 선택 메뉴
class _ReportCategoryMenu extends StatelessWidget {
  const _ReportCategoryMenu({required this.onCategorySelected});

  final void Function(ReportCategory category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final categories = ReportCategory.values;

    return _MenuContainer(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Text(
            '신고 유형 선택',
            style: AppTextStyles.paragraph14Semibold.copyWith(
              color: AppColors.black,
            ),
          ),
        ),
        ...List.generate(categories.length * 2 - 1, (index) {
          if (index.isOdd) return _MenuDivider();
          final category = categories[index ~/ 2];
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                category.label,
                style: AppTextStyles.label16Medium.copyWith(
                  color: AppColors.black,
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
  const _MenuContainer({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 204.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
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
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final Color textColor;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
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
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTextStyles.label_16.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// 메뉴 구분선
class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.black100,
      indent: 0,
      endIndent: 0,
    );
  }
}
