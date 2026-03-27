import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
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
    required this.messageWidget,
    required this.isMe,
    required this.messageRect,
    required this.onBlock,
    required this.callerContext,
  });

  final ChatMessageDto message;
  final Widget messageWidget;
  final bool isMe;
  final Rect messageRect;
  final void Function(int participantId) onBlock;

  /// dismiss 후에도 유효한 호출자 context (Snackbar/Dialog 표시용)
  final BuildContext callerContext;

  /// 채팅 메시지 롱프레스 컨텍스트 메뉴를 표시합니다.
  ///
  /// [message] 대상 채팅 메시지 DTO
  /// [messageWidget] 오버레이 위에 표시할 메시지 버블 위젯
  /// [isMe] 내 메시지 여부 (true면 복사하기만 표시)
  /// [onBlock] 차단 콜백 — `participantId`를 전달합니다
  static Future<void> show({
    required BuildContext context,
    required ChatMessageDto message,
    required Widget messageWidget,
    required bool isMe,
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
        messageWidget: messageWidget,
        isMe: isMe,
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final margin = 16.w;

    // 메뉴 왼쪽 위치: 메시지 좌측 정렬, 화면 밖으로 나가지 않게 clamp
    final menuLeft = widget.messageRect.left.clamp(
      margin,
      screenSize.width - 204.w - margin,
    );

    // 메뉴 bottom = 메시지 위쪽 AppSpacing.vertical8 간격
    // bottom은 화면 하단으로부터의 거리
    final menuBottom =
        screenSize.height - widget.messageRect.top + AppSpacing.vertical8;

    // 메뉴 최대 높이: 메시지 위 공간 - 상단 마진
    final maxMenuHeight =
        widget.messageRect.top - AppSpacing.vertical8 - 16.h;

    return Material(
      color: AppColors.white.withValues(alpha: 0),
      child: Stack(
        children: [
          // 어두운 배경 오버레이
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(color: AppColors.black.withValues(alpha: 0.4)),
            ),
          ),

          // 원래 위치에 메시지 버블 표시
          Positioned(
            left: widget.messageRect.left,
            top: widget.messageRect.top,
            width: widget.messageRect.width,
            height: widget.messageRect.height,
            child: widget.messageWidget,
          ),

          // 메뉴 (bottom 기준으로 위로 자연스럽게 확장)
          Positioned(
            left: menuLeft,
            bottom: menuBottom,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxMenuHeight),
              child: _mode == _MenuMode.actions
                  ? _ActionMenu(
                      isMe: widget.isMe,
                      onCopy: _onCopy,
                      onReport: _onReportTap,
                      onBlock: _onBlockWithSnackbar,
                    )
                  : _ReportCategoryMenu(
                      onCategorySelected: _onCategorySelected,
                    ),
            ),
          ),
        ],
      ),
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
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
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
              color: AppColors.white.withValues(alpha: 0),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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

/// 메뉴 컨테이너 — 흰 배경, 라운드 코너, 그림자
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
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
        color: AppColors.white.withValues(alpha: 0),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}
