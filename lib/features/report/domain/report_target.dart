/// 무엇을 신고하는가
///
/// 신고 화면은 라우트로 열리므로 콜백을 넘길 수 없다. 대신 대상만 `extra`로
/// 넘기고, 화면이 대상에 맞는 접수 메서드를 고른다.
///
/// 새 신고 대상이 생기면 여기에 한 종류를 더한다.
sealed class ReportTarget {
  const ReportTarget();
}

/// 커뮤니티 모집글
class CommunityPostReportTarget extends ReportTarget {
  const CommunityPostReportTarget(this.postId);

  final int postId;
}

/// 커뮤니티 모집글 채팅 메시지
///
/// [chatMessageId]는 **서버가 발급한 메시지 id**다 — 앱이 만든 `messageKey`를
/// 보내면 서버가 못 찾는다(404). 아직 전송 중인 말풍선은 그 id가 없어서
/// 화면이 신고 진입 자체를 막는다(`canReportChatMessage`).
class CommunityChatReportTarget extends ReportTarget {
  const CommunityChatReportTarget(this.chatMessageId);

  final int chatMessageId;
}

/// 인게임 채팅 메시지
class GameChatReportTarget extends ReportTarget {
  const GameChatReportTarget({
    required this.gameId,
    required this.reportedParticipantId,
    required this.messageContent,
  });

  final int gameId;
  final int reportedParticipantId;
  final String messageContent;
}

/// 신고 화면에 넘기는 것 전부
///
/// 라우트의 `extra`는 하나뿐이라 대상과 화면 테마를 함께 담는다. 인게임 채팅은
/// 도둑 테마(어두운 화면) 위에서 열리는데, 그 판단은 채팅 화면이 이미 갖고 있어
/// 여기로 실어 보낸다.
class ReportArgs {
  const ReportArgs({required this.target, this.isDarkMode = false});

  final ReportTarget target;
  final bool isDarkMode;
}

/// 기타 사유 작성 화면에 넘기는 것
///
/// `extra`에 맨 bool을 넘기면 다른 라우트의 `extra`와 구분이 안 된다. 타입을
/// 두면 잘못 들어온 값을 라우터가 걸러 낼 수 있다.
class ReportReasonArgs {
  const ReportReasonArgs({required this.target, this.isDarkMode = false});

  /// 작성 화면이 직접 접수하므로 대상도 함께 받는다 — 다 쓰고 닫힌 뒤에 보내면
  /// 서버 왕복 동안 신고 메뉴가 도로 보인다.
  final ReportTarget target;
  final bool isDarkMode;
}
