import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../community_chat_author.dart';
import '../providers/community_chat_room_provider.dart';
import '../providers/community_chat_rooms_provider.dart';
import '../providers/community_detail_provider.dart';

/// 채팅방 공지사항 — 상단 모임 카드를 누르면 전체 화면으로 연다
///
/// 방장이 붙여 둔 텍스트 하나뿐이다(준비물·시간 등 자유 형식). 방장만 수정할 수
/// 있고, 다른 멤버는 읽기 전용이다(isAuthor 판정은 사이드바와 같은 규칙).
class CommunityChatNoticePage extends ConsumerStatefulWidget {
  const CommunityChatNoticePage({required this.postId, super.key});

  final int postId;

  @override
  ConsumerState<CommunityChatNoticePage> createState() =>
      _CommunityChatNoticePageState();
}

class _CommunityChatNoticePageState
    extends ConsumerState<CommunityChatNoticePage> {
  final _controller = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final post = ref
        .watch(communityDetailNotifierProvider(widget.postId))
        .valueOrNull
        ?.post;
    final members = ref
        .watch(communityChatMembersProvider(widget.postId))
        .valueOrNull;
    final myId = ref.watch(currentUserIdProvider);
    final isAuthor = isChatRoomAuthor(post: post, members: members, myId: myId);

    final room = ref.watch(communityChatRoomNotifierProvider(widget.postId));
    final notice = room.valueOrNull?.notice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: l10n.communityChatNoticeTitle,
        onBack: () =>
            _editing ? setState(() => _editing = false) : context.pop(),
        actions: [
          if (isAuthor && !_editing)
            GestureDetector(
              onTap: () {
                _controller.text = notice ?? '';
                setState(() => _editing = true);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal16,
                ),
                child: SvgPicture.asset(
                  'assets/icons/icon_write.svg',
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPadding.horizontal16,
          child: _editing
              ? _buildEditor(l10n)
              : _buildViewer(l10n, notice, isAuthor),
        ),
      ),
    );
  }

  Widget _buildViewer(AppLocalizations l10n, String? notice, bool isAuthor) {
    if (notice == null || notice.isEmpty) {
      return Center(
        child: Text(
          isAuthor
              ? l10n.communityChatNoticeEmptyAuthor
              : l10n.communityChatNoticeEmpty,
          textAlign: TextAlign.center,
          style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black600),
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
      child: Text(
        notice,
        style: AppTextStyles.paragraph_14.copyWith(color: AppColors.black),
      ),
    );
  }

  Widget _buildEditor(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.vertical16),
        Expanded(
          child: AppTextField(
            controller: _controller,
            hintText: l10n.communityChatNoticeHint,
            width: double.infinity,
            maxLength: 500,
            maxLines: 100,
            textAlignVertical: TextAlignVertical.top,
            borderRadius: AppRadius.large,
            showBorder: false,
            backgroundColor: AppColors.white,
          ),
        ),
        SizedBox(height: AppSpacing.vertical16),
        AppButton(
          width: double.infinity,
          text: l10n.communityChatNoticeSave,
          isLoading: _saving,
          onPressed: _save,
        ),
        SizedBox(height: AppSpacing.vertical16),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(communityChatRoomNotifierProvider(widget.postId).notifier)
          .updateNotice(_controller.text);
    } on AppException catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: AppLocalizations.of(context).errorByException(e),
      );
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    setState(() => _editing = false);
  }
}
