import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/content_filter/profanity_filter.dart';
import '../../../../core/widgets/dividers/solid_divider.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../report/domain/report_target.dart';
import '../../../report/presentation/report_flow.dart';
import '../../domain/entities/community_chat_message_entity.dart';

/// 이 말풍선을 신고할 수 있는가 — 서버가 거절할 것을 화면이 미리 막는다.
///
/// 넷 다 걸러야 한다:
/// - **내 메시지**: 서버가 400(`SELF_REPORT`)으로 막는다.
/// - **아직 전송 중**: 서버 id가 없다. 앱이 만든 `messageKey`를 대신 보내면
///   서버가 못 찾는다(404 `CHAT_MESSAGE_NOT_FOUND`).
/// - **시스템 메시지·초대 카드**: 사람이 쓴 글이 아니라 신고할 대상이 없다.
/// - **비로그인**: 내 메시지인지 가릴 수 없고 신고 자체가 401이다.
bool canReportChatMessage(
  CommunityChatMessageEntity message, {
  required int? myUserId,
}) {
  if (myUserId == null) return false;
  if (message.senderId == myUserId) return false;
  if (message.id == null) return false;
  return message.body is CommunityChatTextBody;
}

/// 모집글 채팅 말풍선을 길게 눌렀을 때 뜨는 메뉴 — 복사 · 신고
///
/// 인게임 [ChatContextMenu]를 쓰지 않는 이유: 그쪽은 게임 전용 DTO
/// (`ChatMessageDto`)와 차단 콜백에 묶여 있어 커뮤니티에서 넘길 값이 없다.
/// 공통으로 뽑는 건 실사용처를 세어 본 뒤에 한다(LSN-0001) — 지금은 둘뿐이고
/// 항목 구성부터 다르다(커뮤니티에는 차단이 없다).
class CommunityChatMessageMenu extends StatelessWidget {
  const CommunityChatMessageMenu._({
    required this.message,
    required this.canReport,
    required this.callerContext,
  });

  final CommunityChatMessageEntity message;
  final bool canReport;

  /// 메뉴가 닫힌 뒤에도 살아 있는 context — 스낵바·신고 화면이 쓴다.
  final BuildContext callerContext;

  /// 말풍선 위에 메뉴를 띄운다. 신고할 수 없는 말풍선이면 복사만 나온다.
  static Future<void> show({
    required BuildContext context,
    required CommunityChatMessageEntity message,
    required int? myUserId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CommunityChatMessageMenu._(
        message: message,
        canReport: canReportChatMessage(message, myUserId: myUserId),
        callerContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        margin: AppPadding.horizontal16,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context, l10n.buttonCopy, () => _copy(context, l10n)),
            if (canReport) ...[
              const SolidDivider(),
              _item(
                context,
                l10n.buttonReport,
                () => _report(context),
                color: AppColors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.vertical16),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.label_16.copyWith(
            color: color ?? AppColors.black,
          ),
        ),
      ),
    ),
  );

  void _copy(BuildContext context, AppLocalizations l10n) {
    final body = message.body;
    // 복사는 텍스트 말풍선에서만 뜬다 — 다른 타입은 메뉴 자체를 열지 않는다.
    if (body is! CommunityChatTextBody) return;
    // 화면에 보이는 대로 복사한다 — 필터가 가린 말을 클립보드로 흘리지 않는다.
    Clipboard.setData(ClipboardData(text: ProfanityFilter.filter(body.text)));
    Navigator.of(context).pop();
    AppSnackbar.show(callerContext, message: l10n.messageMessageCopied);
  }

  void _report(BuildContext context) {
    // 여기 오는 말풍선은 `canReport`가 참이라 id가 반드시 있다.
    final chatMessageId = message.id!;
    Navigator.of(context).pop();
    unawaited(
      runReportFlow(
        context: callerContext,
        target: CommunityChatReportTarget(chatMessageId),
      ),
    );
  }
}
