import 'dart:async';

import '../../domain/entities/community_chat_event.dart';
import '../../domain/entities/community_chat_member_entity.dart';
import '../../domain/entities/community_chat_message_entity.dart';
import '../../domain/entities/community_chat_page_entity.dart';
import '../../domain/entities/community_chat_room_entity.dart';
import '../../domain/entities/community_post_status.dart';
import '../../domain/repositories/community_chat_repository.dart';

/// 모집글 채팅의 임시 구현 (메모리)
///
/// ponytail: 서버 연동(2단계) 전까지 화면과 상태 흐름을 먼저 완성하려는 대역이다.
/// 앱을 껐다 켜면 사라진다. 보낸 메시지는 [echoDelay] 뒤 서버 에코처럼 같은
/// `messageKey`로 돌아온다. 시드는 시안(`커뮤니티_내 모임.png`)의 방 둘이다.
///
/// 교체 방법: `communityChatRepositoryProvider`가 impl을 돌려주게 바꾼다.
/// 모르는 postId로 [join]하면 방을 새로 만들어 실서버 게시글에서도 상세 → 참여 →
/// 입장 흐름을 돌려볼 수 있다.
class CommunityChatRepositoryMock implements CommunityChatRepository {
  CommunityChatRepositoryMock({
    this.myUserId = 0,
    this.myNickname = '나',
    this.latency = const Duration(milliseconds: 200),
    this.echoDelay = const Duration(milliseconds: 300),
  }) {
    _seed();
  }

  static const seededPostId = 42;
  static const seededAuthorId = 7;

  final int myUserId;
  final String myNickname;

  /// 실서버 왕복처럼 보이게 하는 지연 — 로딩 UI를 눈으로 확인하기 위해.
  final Duration latency;
  final Duration echoDelay;

  final Map<int, CommunityChatRoomEntity> _rooms = {};
  final Map<int, List<CommunityChatMessageEntity>> _messages = {}; // 최신순
  final Map<int, List<CommunityChatMemberEntity>> _members = {};
  final Map<int, String> _notices = {};
  StreamController<CommunityChatEvent>? _controller;
  int? _connectedPostId;
  int _nextId = 10000;

  void _seed() {
    final now = DateTime.now();
    DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));

    _members[seededPostId] = [
      const CommunityChatMemberEntity(
        userId: 7,
        nickname: '경도매우러버',
        isAuthor: true,
      ),
      const CommunityChatMemberEntity(
        userId: 2,
        nickname: '홍길동그라미',
        isAuthor: false,
      ),
      const CommunityChatMemberEntity(
        userId: 3,
        nickname: '경도광',
        isAuthor: false,
      ),
      const CommunityChatMemberEntity(
        userId: 4,
        nickname: '도토리수집가',
        isAuthor: false,
      ),
      const CommunityChatMemberEntity(
        userId: 5,
        nickname: '포근포근백설기',
        isAuthor: false,
      ),
      const CommunityChatMemberEntity(
        userId: 6,
        nickname: '오동통너구리',
        isAuthor: false,
      ),
      const CommunityChatMemberEntity(
        userId: 8,
        nickname: '가을여치',
        isAuthor: false,
      ),
      const CommunityChatMemberEntity(
        userId: 9,
        nickname: '노곤한노루',
        isAuthor: false,
      ),
    ];

    // 두 페이지가 나오도록 40건 — 위로 올려 이전 대화를 이어 받는 흐름을 본다.
    final filler = [
      for (var i = 1; i <= 40; i++)
        CommunityChatMessageEntity(
          id: i,
          messageKey: 'seed-$i',
          senderId: i.isEven ? 7 : 2,
          senderNickname: i.isEven ? '경도매우러버' : '홍길동그라미',
          body: CommunityChatMessageBody.text('이전 대화 $i'),
          createdAt: ago(300 - i * 5),
        ),
    ];
    final recent = [
      CommunityChatMessageEntity(
        id: 41,
        messageKey: 'seed-41',
        senderId: 3,
        senderNickname: '도둑쥐',
        body: const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.join,
        ),
        createdAt: ago(40),
      ),
      CommunityChatMessageEntity(
        id: 42,
        messageKey: 'seed-42',
        senderId: 7,
        senderNickname: '경도매우러버',
        body: const CommunityChatMessageBody.text('안녕하세요~ 공지 확인해주세요!'),
        createdAt: ago(30),
      ),
      CommunityChatMessageEntity(
        id: 43,
        messageKey: 'seed-43',
        senderId: 7,
        senderNickname: '경도매우러버',
        body: const CommunityChatMessageBody.text(
          '저희 20시에 정문에서 볼 예정이고 만나서 게임방 생성할게요',
        ),
        createdAt: ago(30),
      ),
      CommunityChatMessageEntity(
        id: 44,
        messageKey: 'seed-44',
        senderId: myUserId,
        senderNickname: myNickname,
        body: const CommunityChatMessageBody.text('넵 알겠습니다! 곧 봬요ㅎㅎㅎ'),
        createdAt: ago(28),
      ),
      CommunityChatMessageEntity(
        id: 45,
        messageKey: 'seed-45',
        senderId: 9,
        senderNickname: '경도처음',
        body: const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.leave,
        ),
        createdAt: ago(20),
      ),
      CommunityChatMessageEntity(
        id: 46,
        messageKey: 'seed-46',
        senderId: 2,
        senderNickname: '홍길동그라미',
        body: const CommunityChatMessageBody.gameInvite('ABC123'),
        createdAt: ago(10),
      ),
    ];
    _messages[seededPostId] = [...recent.reversed, ...filler.reversed];

    _messages[43] = [
      CommunityChatMessageEntity(
        id: 100,
        messageKey: 'seed-100',
        senderId: 5,
        senderNickname: '포근포근백설기',
        body: const CommunityChatMessageBody.text('그럼 다들 후문보단 정문이 나을까요?'),
        createdAt: ago(320),
      ),
    ];
    _members[43] = [
      const CommunityChatMemberEntity(
        userId: 5,
        nickname: '포근포근백설기',
        isAuthor: true,
      ),
    ];

    _notices[seededPostId] =
        '준비물: 편한 신발, 물, 보조배터리\n시간: 20시 정문 집합\n늦으시는 분은 채팅으로 미리 알려주세요!';

    _rooms[seededPostId] = CommunityChatRoomEntity(
      postId: seededPostId,
      title: '나랑 경도하자!!!!!',
      status: CommunityPostStatus.recruiting,
      meetingAt: now.add(const Duration(days: 2)),
      memberCount: 10,
      lastMessage: _lastOf(seededPostId),
    );
    _rooms[43] = CommunityChatRoomEntity(
      postId: 43,
      title: '얼렁뚱땅초보자들의 경도 모임',
      status: CommunityPostStatus.recruiting,
      meetingAt: now.add(const Duration(days: 5)),
      memberCount: 4,
      lastMessage: _lastOf(43),
    );
  }

  CommunityChatLastMessageEntity? _lastOf(int postId) {
    final list = _messages[postId];
    if (list == null || list.isEmpty) return null;
    final m = list.first;
    return CommunityChatLastMessageEntity(
      id: m.id!,
      body: m.body,
      createdAt: m.createdAt,
      senderNickname: m.senderNickname,
    );
  }

  @override
  Future<List<CommunityChatRoomEntity>> getRooms() async {
    await Future<void>.delayed(latency);
    final rooms = _rooms.values
        .map((r) => r.copyWith(lastMessage: _lastOf(r.postId)))
        .toList();
    // 서버 규칙: 마지막 대화가 최근인 방부터, 대화 없는 방은 맨 뒤.
    rooms.sort((a, b) {
      final ta = a.lastMessage?.createdAt;
      final tb = b.lastMessage?.createdAt;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });
    return rooms;
  }

  @override
  Future<List<CommunityChatMemberEntity>> getMembers(int postId) async {
    await Future<void>.delayed(latency);
    return List.unmodifiable(_members[postId] ?? const []);
  }

  @override
  Future<String?> getNotice(int postId) async {
    await Future<void>.delayed(latency);
    return _notices[postId];
  }

  @override
  Future<void> setNotice(int postId, String notice) async {
    await Future<void>.delayed(latency);
    _notices[postId] = notice;
  }

  @override
  Future<void> join(int postId) async {
    await Future<void>.delayed(latency);
    final existing = _rooms[postId];
    if (existing != null) {
      if (_members[postId]!.any((m) => m.userId == myUserId)) return;
      _rooms[postId] = existing.copyWith(memberCount: existing.memberCount + 1);
    } else {
      // 실서버 게시글(모르는 postId)도 흐름을 돌려볼 수 있게 방을 만든다.
      _rooms[postId] = CommunityChatRoomEntity(
        postId: postId,
        title: '모집글 $postId',
        status: CommunityPostStatus.recruiting,
        meetingAt: DateTime.now().add(const Duration(days: 1)),
        memberCount: 2,
      );
      _messages[postId] = [];
      _members[postId] = [
        const CommunityChatMemberEntity(
          userId: seededAuthorId,
          nickname: '경도매우러버',
          isAuthor: true,
        ),
      ];
    }
    _members[postId] = [
      ..._members[postId]!,
      CommunityChatMemberEntity(
        userId: myUserId,
        nickname: myNickname,
        isAuthor: false,
      ),
    ];
    _store(
      postId,
      CommunityChatMessageEntity(
        id: _nextId++,
        messageKey: 'sys-$_nextId',
        senderId: myUserId,
        senderNickname: myNickname,
        body: const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.join,
        ),
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> leave(int postId) async {
    await Future<void>.delayed(latency);
    _rooms.remove(postId);
    _members[postId]?.removeWhere((m) => m.userId == myUserId);
  }

  @override
  Future<CommunityChatPageEntity> getMessages(
    int postId, {
    int? cursor,
    int size = 30,
  }) async {
    await Future<void>.delayed(latency);
    final all = _messages[postId] ?? const [];
    final from = cursor == null
        ? all
        : all.where((m) => m.id! < cursor).toList();
    final page = from.take(size).toList();
    final hasNext = from.length > size;
    return CommunityChatPageEntity(
      messages: page,
      nextCursor: hasNext ? page.last.id : null,
      hasNext: hasNext,
    );
  }

  @override
  Stream<CommunityChatEvent> connect(int postId) {
    _controller?.close();
    final controller = StreamController<CommunityChatEvent>.broadcast();
    _controller = controller;
    _connectedPostId = postId;
    // 구독이 붙은 뒤에 상태가 가도록 한 틱 미룬다.
    scheduleMicrotask(() {
      if (!controller.isClosed) {
        controller.add(
          const CommunityChatEvent.connection(
            CommunityChatConnectionState.connected,
          ),
        );
      }
    });
    return controller.stream;
  }

  @override
  Future<void> send(
    int postId, {
    required String messageKey,
    required String text,
  }) async {
    final controller = _controller;
    if (controller == null || _connectedPostId != postId) return;
    // 서버는 저장을 끝낸 뒤 브로드캐스트한다 — id가 항상 실려 온다.
    Future<void>.delayed(echoDelay, () {
      if (controller.isClosed) return;
      final stored = CommunityChatMessageEntity(
        id: _nextId++,
        messageKey: messageKey,
        senderId: myUserId,
        senderNickname: myNickname,
        body: CommunityChatMessageBody.text(text),
        createdAt: DateTime.now(),
      );
      _store(postId, stored);
      controller.add(CommunityChatEvent.message(stored));
    });
  }

  @override
  Future<void> disconnect() async {
    await _controller?.close();
    _controller = null;
    _connectedPostId = null;
  }

  void _store(int postId, CommunityChatMessageEntity m) {
    _messages[postId] = [m, ...(_messages[postId] ?? const [])];
  }
}
