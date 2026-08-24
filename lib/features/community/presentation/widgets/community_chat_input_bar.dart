import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'community_message_input.dart';

/// 채팅방 입력창
///
/// 입력 바 자체는 [CommunityMessageInput]이 그리고, 여기는 채팅 쪽 값(힌트·길이
/// 상한·한 줄 입력)만 채운다.
///
/// 빈 메시지·500자 초과는 서버가 거절하는 값이라 여기서 먼저 막는다
/// (`EMPTY_MESSAGE`·`MESSAGE_TOO_LONG`이 정상 경로에서 안 나오는 이유).
/// 시안의 "+" 버튼은 뒤에 붙을 기능이 없어 뺐다.
class CommunityChatInputBar extends StatelessWidget {
  const CommunityChatInputBar({
    required this.onSend,
    this.enabled = true,
    super.key,
  });

  /// 낙관적 전송이라 즉시 반환한다 — 확정은 pending 말풍선이 대신 보여 준다.
  final void Function(String text) onSend;

  /// 연결이 끊긴 동안 false — 보내도 실패만 쌓인다.
  final bool enabled;

  static const maxLength = 500;

  @override
  Widget build(BuildContext context) {
    return CommunityMessageInput(
      hintText: AppLocalizations.of(context).communityChatInputHint,
      onSubmit: (text) async => onSend(text),
      maxLength: maxLength,
      enabled: enabled,
    );
  }
}
