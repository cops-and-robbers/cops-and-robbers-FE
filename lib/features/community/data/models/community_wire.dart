import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../../domain/entities/community_chat_message_entity.dart';
import '../../domain/entities/community_post_status.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';

/// 모집 상태의 서버 와이어 문자열.
///
/// `@JsonValue`를 쓰지 않는 이유: 그 어노테이션은 json_serializable이
/// `fromJson`/`toJson`을 만들 때만 읽히고 결과가 `.g.dart`의 private
/// `_$...EnumMap`에 들어간다. DTO는 `status`를 `String`으로 받아 Repository
/// 경계에서 도메인 enum으로 바꾸므로 그 맵에 닿지 못한다.
extension CommunityPostStatusWire on CommunityPostStatus {
  /// [CommunityPostStatus.ended]까지 매핑해 switch를 total로 둔다. 요청 스키마
  /// (`CommunityPostStatusRequest`)에도 `ENDED`가 있어 유효한 값이지만, 상태 변경은
  /// 모집중 ↔ 마감 이진 전환이라 이 값이 실려 나가지는 않는다.
  String get wireValue => switch (this) {
    CommunityPostStatus.recruiting => 'RECRUITING',
    CommunityPostStatus.completed => 'COMPLETED',
    CommunityPostStatus.ended => 'ENDED',
  };
}

/// 와이어 문자열 → 도메인 enum.
///
/// 모르는 값은 '종료'로 본다. '마감'(completed)으로 보면
/// `community_post_menu.dart`의 `!= ended` 가드를 통과해 작성자에게 "다시
/// 모집하기"가 뜨고 누르면 서버로 RECRUITING이 나간다 — 미지 상태에 표시와
/// 변경 둘 다 열리는 셈이다. `ended`로 보면 참여 표시와 상태 변경이 모두
/// 막혀 둘 다 보수적으로 잡힌다. 예외를 던지면 그 글 하나 때문에 목록 한 장이
/// 통째로 에러 화면이 된다 — `ENDED`가 추가됐을 때 실제로 그랬다.
CommunityPostStatus communityPostStatusFromWire(String wire) {
  switch (wire) {
    case 'RECRUITING':
      return CommunityPostStatus.recruiting;
    case 'COMPLETED':
      return CommunityPostStatus.completed;
    case 'ENDED':
      return CommunityPostStatus.ended;
    default:
      // 조용히 묻히면 다음 미지 값이 언제 들어왔는지 알 길이 없다.
      debugPrint('[커뮤니티] ⚠️ 알 수 없는 모집 상태: $wire → 종료로 처리');
      return CommunityPostStatus.ended;
  }
}

/// `GET /api/community-posts`의 `scope` 쿼리 값.
extension CommunityScopeQuery on CommunityScope {
  /// `null`이면 Retrofit이 생성한 `removeWhere((k, v) => v == null)`가
  /// 파라미터 자체를 제외하므로 "전체 = 파라미터 생략"이 그대로 표현된다.
  ///
  /// 주의: 백엔드가 `scope` 파라미터는 받지만 `NEARBY`·`MINE`은 아직
  /// 400(`UNSUPPORTED_LIST_SCOPE`)이다 — 지원 전까지 호출자가
  /// [CommunityScope.all]만 넘겨야 한다.
  String? get queryValue => switch (this) {
    CommunityScope.all => null,
    CommunityScope.nearby => 'NEARBY',
    CommunityScope.mine => 'MINE',
  };
}

/// `GET /api/community-posts`의 `sort` 쿼리 값.
///
/// [CommunitySortOption.popular]까지 매핑해 switch를 total로 둔다 — 서버가
/// `UNSUPPORTED_LIST_SORT`(400)를 주는 값이라 정렬 시트가 노출하지 않으므로
/// 실제로 전송되지는 않는다.
extension CommunitySortOptionWire on CommunitySortOption {
  String get wireValue => switch (this) {
    CommunitySortOption.latest => 'LATEST',
    CommunitySortOption.popular => 'POPULAR',
    CommunitySortOption.distance => 'DISTANCE',
    CommunitySortOption.deadline => 'DEADLINE',
  };
}

/// 채팅 메시지의 `messageType` + `message` → 도메인 본문.
///
/// 서버는 본문 하나에 세 가지를 실어 보낸다 — `TEXT`는 문자열 그대로,
/// `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다. `SYSTEM`에 사람 이름이 들어 있지
/// 않은 것은 의도다: 닉네임을 바꾸면 지난 메시지의 이름도 따라 바뀌어야 하고
/// 문구 수정·다국어도 앱에서 끝나야 하기 때문이다(DOC-0037).
///
/// 읽을 수 없는 것은 전부 [CommunityChatUnknownBody]로 접는다. 던지면 새 타입
/// 하나가 채팅방 한 장을 통째로 에러 화면으로 만든다 — 목록에서 `ENDED`가
/// 추가됐을 때 실제로 그랬다.
CommunityChatMessageBody communityChatMessageBodyFromWire(
  String messageType,
  String message,
) {
  switch (messageType) {
    case 'TEXT':
      return CommunityChatMessageBody.text(message);
    case 'SYSTEM':
      final event = _decode(message)?['event'];
      return switch (event) {
        'JOIN' => const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.join,
        ),
        'LEAVE' => const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.leave,
        ),
        'KICK' => const CommunityChatMessageBody.system(
          CommunityChatSystemEvent.kick,
        ),
        _ => _unknown('시스템 이벤트', event ?? message),
      };
    case 'GAME_INVITE':
      final code = _decode(message)?['inviteCode'];
      // 코드가 없으면 눌러도 들어갈 방이 없다 — 카드를 그리지 않는다.
      if (code is String && code.isNotEmpty) {
        return CommunityChatMessageBody.gameInvite(code);
      }
      return _unknown('게임 초대', message);
    default:
      return _unknown('메시지 타입', messageType);
  }
}

/// JSON 본문 파싱. 형태가 다르면 null — 호출부가 unknown으로 접는다.
Map<String, dynamic>? _decode(String message) {
  try {
    final decoded = jsonDecode(message);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

/// 조용히 묻히면 다음 미지 값이 언제 들어왔는지 알 길이 없다.
CommunityChatMessageBody _unknown(String what, Object value) {
  debugPrint('[커뮤니티 채팅] ⚠️ 알 수 없는 $what: $value → 숨김 처리');
  return const CommunityChatMessageBody.unknown();
}
