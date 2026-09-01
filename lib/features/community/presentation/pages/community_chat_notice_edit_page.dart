import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/i18n/error_message_mapper.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/community_chat_notice_provider.dart';

/// 공지글 작성 — 등록과 수정이 같은 화면이다
///
/// [initialContent]가 있으면 수정, 없으면 등록이다. 방마다 공지가 하나뿐이라
/// (DEC-0054) 두 화면을 따로 둘 이유가 없다 — 보이는 것도 부르는 API만 다르다.
class CommunityChatNoticeEditPage extends ConsumerStatefulWidget {
  const CommunityChatNoticeEditPage({
    required this.postId,
    this.initialContent,
    super.key,
  });

  final int postId;
  final String? initialContent;

  @override
  ConsumerState<CommunityChatNoticeEditPage> createState() =>
      _CommunityChatNoticeEditPageState();
}

class _CommunityChatNoticeEditPageState
    extends ConsumerState<CommunityChatNoticeEditPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialContent ?? '',
  );

  /// 저장 요청이 날아가 있는 동안 — 완료를 두 번 눌러 공지가 두 번 저장되는 걸 막는다.
  bool _submitting = false;

  bool get _isEdit => widget.initialContent != null;

  bool get _canSubmit => !_submitting && _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: l10n.communityChatNoticeWriteTitle,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: l10n.buttonCancel,
          icon: SvgPicture.asset(AppIcons.delete, width: 24.w, height: 24.w),
        ),
        actions: [_buildDoneAction(l10n)],
      ),
      body: SafeArea(
        // 키보드가 올라오면 입력칸 아래가 가려지므로 본문 전체가 스크롤한다.
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontal16,
            vertical: AppSpacing.vertical20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.vertical10),
                child: Text(
                  l10n.communityChatNoticeLabelContent,
                  style: AppTextStyles.paragraph14Semibold.copyWith(
                    color: AppColors.black600,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.large,
                  boxShadow: AppShadows.ver2,
                ),
                child: SizedBox(
                  height: 400.h,
                  child: AppTextField(
                    controller: _controller,
                    hintText: l10n.communityChatNoticeHint,
                    width: double.infinity,
                    // 서버 스키마의 상한과 같은 값이다(api-docs v2.31.0).
                    // 넘겨 보내면 400이라 입력에서 먼저 막는다.
                    maxLength: 500,
                    // 장소·시간·준비물을 줄로 나눠 적는 칸이라 엔터는 줄바꿈이다.
                    maxLines: 100,
                    textAlignVertical: TextAlignVertical.top,
                    borderRadius: AppRadius.large,
                    showBorder: false,
                    hintColor: AppColors.black200,
                    // 글자 수가 아니라 "비었나"만 보므로 매 타이핑 리빌드가 필요없다 —
                    // 비었다 ↔ 찼다가 바뀌는 순간만 완료 버튼이 달라진다.
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneAction(AppLocalizations l10n) {
    final enabled = _canSubmit;

    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.buttonDone,
      excludeSemantics: true,
      onTap: enabled ? _submit : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? _submit : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal16),
          child: Center(
            child: Text(
              l10n.buttonDone,
              style: AppTextStyles.label_16.copyWith(
                color: enabled ? AppColors.logo : AppColors.black200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    final notifier = ref.read(
      communityChatNoticeProvider(widget.postId).notifier,
    );
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 등록과 수정은 서버 엔드포인트가 갈린다 — 없는 공지에 PUT을 보내면
      // 404 `CHAT_PIN_NOT_FOUND`다.
      _isEdit ? await notifier.edit(content) : await notifier.register(content);
    } on AppException catch (e) {
      // `await` 뒤라 화면이 이미 사라졌을 수 있다(LSN-0021) — 미리 잡아둔
      // messenger만 쓴다.
      if (mounted) setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorByException(e))));
      return;
    }
    // 저장이 도는 동안 취소를 눌렀으면 이 화면은 이미 사라졌다 — 그때 pop하면
    // 그 아래 공지 화면까지 닫혀 채팅방으로 튕긴다.
    if (mounted) navigator.pop();
  }
}
