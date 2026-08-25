import '../entities/community_chat_event.dart';
import '../entities/community_chat_member_entity.dart';
import '../entities/community_chat_page_entity.dart';
import '../entities/community_chat_room_entity.dart';

/// 모집글 채팅 저장소 — REST 4종 + 소켓을 하나로 감싼다
///
/// 게임 채팅은 Notifier가 STOMP datasource를 직접 잡지만 여기서는 이 인터페이스가
/// "서버"를 대표한다. UI를 먼저 만들려면 목이 소켓까지 흉내 내야 하고, Notifier
/// 테스트가 가짜 하나로 끝나기 때문이다(경계만 모킹). 2단계에서 Retrofit + STOMP
/// datasource를 합친 impl로 교체한다.
abstract class CommunityChatRepository {
  /// 내 채팅방 목록. 페이징 없음(참여 상한 100). 대화 없는 방은 맨 뒤.
  Future<List<CommunityChatRoomEntity>> getRooms();

  /// 채팅방 멤버 목록 (BE 이슈 가정). 서버 미구현이면 구현체가 빈 목록을 돌려준다.
  Future<List<CommunityChatMemberEntity>> getMembers(int postId);

  /// 방장이 채팅방에 붙여 둔 공지사항. 없으면 null. (백엔드 추가 예정 — mock)
  Future<String?> getNotice(int postId);

  /// 공지사항 등록/수정. 방장만 부른다(화면이 막는다). (백엔드 추가 예정 — mock)
  Future<void> setNotice(int postId, String notice);

  /// 참여. 이미 멤버(409 `ALREADY_JOINED`)면 성공으로 삼킨다 — 화면은 "입장"만 알면 된다.
  Future<void> join(int postId);

  Future<void> leave(int postId);

  /// 이전 대화. [cursor]가 null이면 최신부터, 아니면 그보다 이전부터. 최신순.
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  });

  /// 소켓 연결 + 이 방 구독. 메시지·연결 상태·소켓 에러가 한 스트림으로 온다.
  /// 다시 부르면 이전 연결을 정리하고 새로 연결한다(재연결).
  Stream<CommunityChatEvent> connect(int postId);

  /// [messageKey]는 앱이 만든 UUID — 에코가 같은 키로 돌아와 pending을 확정한다.
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  });

  /// UNSUBSCRIBE → 연결 종료. 나가기 성공 뒤와 화면 이탈 때 부른다.
  Future<void> disconnect();
}
