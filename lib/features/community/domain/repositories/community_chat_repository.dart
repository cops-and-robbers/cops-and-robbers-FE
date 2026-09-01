import '../entities/community_chat_event.dart';
import '../entities/community_chat_member_entity.dart';
import '../entities/community_chat_page_entity.dart';
import '../entities/community_chat_room_entity.dart';

/// 모집글 채팅 저장소 — REST 7종 + 소켓을 하나로 감싼다
///
/// 게임 채팅은 Notifier가 STOMP datasource를 직접 잡지만 여기서는 이 인터페이스가
/// "서버"를 대표한다. Notifier 테스트가 가짜 하나로 끝나기 때문이다(경계만 모킹).
///
/// 소켓은 **열고 닫는 것**과 **방을 드나드는 것**이 갈린다. 소켓은 로그인~로그아웃
/// 동안 하나로 살아 있고(유저당 알림 채널을 계속 받아야 한다 — DEC-0045), 방 구독만
/// 화면을 따라 붙었다 떨어진다.
abstract class CommunityChatRepository {
  /// 내 채팅방 목록. 페이징 없음(참여 상한 100). 대화 없는 방은 맨 뒤.
  /// 각 방의 `unreadCount`가 안 읽은 개수의 기준선이다(DEC-0044).
  Future<List<CommunityChatRoomEntity>> getRooms();

  /// 채팅방 멤버 목록 + 내 알림 수신 여부. 방 멤버만 부를 수 있다(403 `NOT_A_CHAT_MEMBER`).
  Future<CommunityChatMembersEntity> getMembers(int postId);

  /// 멤버 강퇴. 방장만 부를 수 있고 강퇴된 유저는 재입장 제한이 없다(DEC-0043).
  /// 서버는 소켓 세션을 끊지 않고 `KICK` 시스템 메시지를 브로드캐스트한다.
  Future<void> kickMember(int postId, int userId);

  /// 참여. 이미 멤버(409 `ALREADY_JOINED`)면 성공으로 삼킨다 — 화면은 "입장"만 알면 된다.
  Future<void> join(int postId);

  Future<void> leave(int postId);

  /// 이전 대화. [cursor]가 null이면 최신부터, 아니면 그보다 이전부터. 최신순.
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  });

  /// 읽음 커서를 [lastReadMessageId]까지 옮긴다. 앞으로만 간다 — 과거 id는 무시된다.
  Future<void> markRead(int postId, int lastReadMessageId);

  /// 이 방의 푸시 알림 수신 여부. 끄면 푸시만 막고 안 읽은 개수는 그대로 오른다.
  Future<void> setNotification(int postId, {required bool enabled});

  /// 소켓 연결. 연결될 때마다 [userId]의 알림 채널을 다시 구독한다.
  /// 메시지(방 채널·개인 채널 모두)·연결 상태·소켓 에러가 한 스트림으로 온다.
  /// 다시 부르면 이전 연결을 정리하고 새로 연결한다(재연결).
  Stream<CommunityChatEvent> connect(int userId);

  /// 소켓 종료. 로그아웃·계정 전환 때 부른다. 개인 채널 UNSUBSCRIBE는 보내지
  /// 않는다 — 소켓이 닫히면 서버가 세션과 함께 정리한다(DEC-0045).
  Future<void> disconnect();

  /// 방 구독. 연결돼 있으면 즉시, 아니면 연결될 때 자동으로 건다.
  void subscribeRoom(int postId);

  /// 방 구독만 해제. 소켓은 그대로다.
  ///
  /// [postId]를 받는 이유: 방 A에서 B로 옮기면 A의 provider가 B보다 늦게 정리될 수
  /// 있다. 방 번호를 확인하지 않으면 그때 막 건 B의 구독이 풀린다.
  void unsubscribeRoom(int postId);

  /// [messageKey]는 앱이 만든 UUID — 에코가 같은 키로 돌아와 pending을 확정한다.
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  });

  /// 게임 초대 전송(GAME_INVITE, #516). 낙관적 갱신이 없는 단발 발신이라
  /// 연결이 없으면 false를 돌려 호출부가 사용자에게 알린다.
  bool sendGameInvite(
    int postId, {
    required String messageKey,
    required String inviteCode,
  });
}
