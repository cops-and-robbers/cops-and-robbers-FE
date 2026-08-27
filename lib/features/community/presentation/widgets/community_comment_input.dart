import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'community_message_input.dart';

/// 댓글 입력창 (답글 모드 겸용)
///
/// 입력 바 자체는 [CommunityMessageInput]이 그리고, 여기는 답글 모드만 얹는다.
/// 입력 필드는 하나뿐이다 — 답글용을 따로 두면 어느 쪽에 쓰는 중인지 화면에서
/// 갈리지 않는다.
///
/// 답글 모드는 힌트 문구로만 알린다. 예전에는 위에 "○○님에게 답글 남기는 중"
/// 안내 줄이 붙었는데, 늘 한 줄을 차지해 정작 읽어야 할 댓글을 밀어냈다. 대상
/// 댓글은 목록 쪽에서 배경으로 강조되므로(`replyTargetId`) 어디에 다는 중인지는
/// 그쪽이 더 정확히 보여 준다. 모드를 끄는 건 본문 아무 곳이나 탭하는 것이다
/// (상세 화면이 처리).
class CommunityCommentInput extends StatefulWidget {
  const CommunityCommentInput({
    super.key,
    required this.onSubmit,
    this.replyToNickname,
  });

  /// 전송. 부모가 성공 시 답글 모드를 끈다.
  final Future<void> Function(String content) onSubmit;

  /// 답글 대상 닉네임. null이면 최상위 댓글 모드.
  final String? replyToNickname;

  /// 서버 검증값과 같은 값이다(api-docs `CommunityCommentCreateRequest.content`).
  ///
  /// 목데이터 시절에는 맞출 값이 없어 모집글 설명과 같은 1000으로 뒀는데, 실서버는
  /// 500에서 400을 준다 — 앱이 더 관대하면 다 쓰고 등록을 누른 뒤에야 막힌다.
  static const maxLength = 500;

  @override
  State<CommunityCommentInput> createState() => _CommunityCommentInputState();
}

class _CommunityCommentInputState extends State<CommunityCommentInput> {
  final _focusNode = FocusNode();

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
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CommunityMessageInput(
      hintText: widget.replyToNickname == null
          ? l10n.communityCommentHint
          : l10n.communityCommentReplyHint,
      onSubmit: widget.onSubmit,
      maxLength: CommunityCommentInput.maxLength,
      focusNode: _focusNode,
    );
  }
}
