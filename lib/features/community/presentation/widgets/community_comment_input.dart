import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';

/// 댓글 입력창 (답글 모드 겸용)
///
/// [replyToNickname]이 있으면 "○○님에게 답글 남기는 중" 안내 줄이 위에 붙고,
/// 그 줄의 × 로 답글 모드를 끈다. 입력 필드는 하나뿐이다 — 답글용을 따로 두면
/// 어느 쪽에 쓰는 중인지 화면에서 갈리지 않는다.
class CommunityCommentInput extends StatefulWidget {
  const CommunityCommentInput({
    super.key,
    required this.onSubmit,
    this.replyToNickname,
    this.onCancelReply,
  });

  /// 전송. 부모가 성공 시 답글 모드를 끈다.
  final Future<void> Function(String content) onSubmit;

  /// 답글 대상 닉네임. null이면 최상위 댓글 모드.
  final String? replyToNickname;

  final VoidCallback? onCancelReply;

  @override
  State<CommunityCommentInput> createState() => _CommunityCommentInputState();
}

class _CommunityCommentInputState extends State<CommunityCommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// 전송 중 중복 탭 방지. 두 번 누르면 같은 댓글이 두 개 달린다.
  bool _isSubmitting = false;

  @override
  void didUpdateWidget(CommunityCommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 답글 달기를 누른 순간 키보드가 올라와야 한다 — 안 그러면 화면 아래
    // 입력창을 사용자가 다시 찾아 눌러야 한다.
    if (widget.replyToNickname != null && oldWidget.replyToNickname == null) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    VibrationService.instance().buttonTap();
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(content);
      // 실패했으면 사용자가 다시 보낼 수 있게 입력 내용을 남겨둔다.
      if (mounted) _controller.clear();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final replyTo = widget.replyToNickname;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.black100)),
      ),
      // 키보드가 올라오면 그 위로, 내려가면 홈 인디케이터 위로 붙는다.
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyTo != null) _buildReplyBanner(l10n, replyTo),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontal16,
                vertical: AppSpacing.vertical8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        // 긴 댓글도 쓰지만 입력창이 화면을 다 먹으면 안 된다.
                        maxLines: 4,
                        minLines: 1,
                        // 댓글 API가 아직 없어 맞출 서버 검증값이 없다. 상한 없이
                        // 두면 댓글 하나가 목록을 통째로 밀어내므로 모집글 설명과
                        // 같은 값으로 1차 방어만 걸어 둔다 — API가 생기면 서버 값을
                        // 정본으로 삼아 맞춘다 (LSN-0008).
                        maxLength: 1000,
                        textInputAction: TextInputAction.newline,
                        style: AppTextStyles.paragraph_14.copyWith(
                          color: AppColors.black,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          // maxLength 기본 카운터는 입력창 아래 한 줄을 더 먹어
                          // 높이(42)를 넘긴다. 제한은 걸되 표시는 하지 않는다
                          // (AppTextField도 같은 처리).
                          counterText: '',
                          hintText: replyTo == null
                              ? l10n.communityCommentHint
                              : l10n.communityCommentReplyHint,
                          hintStyle: AppTextStyles.paragraph_14.copyWith(
                            color: AppColors.black400,
                          ),
                          filled: true,
                          fillColor: AppColors.black100,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.horizontal16,
                            vertical: AppSpacing.vertical12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.large,
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.horizontal14),
                  _buildSendButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBanner(AppLocalizations l10n, String nickname) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal16,
        vertical: AppSpacing.vertical8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.communityCommentReplyingTo(nickname),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tag_12.copyWith(color: AppColors.black600),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onCancelReply,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.horizontal4),
              child: Icon(Icons.close, size: 16.w, color: AppColors.black500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isSubmitting ? null : _submit,
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        child: _isSubmitting
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : SvgPicture.asset(
                'assets/icons/icon_sending.svg',
                width: 24.w,
                height: 24.h,
                colorFilter: ColorFilter.mode(
                  AppColors.blueVer2Basic,
                  BlendMode.srcIn,
                ),
              ),
      ),
    );
  }
}
