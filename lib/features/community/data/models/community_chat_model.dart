import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_chat_model.freezed.dart';
part 'community_chat_model.g.dart';

/// 내 채팅방 목록의 마지막 메시지 DTO
///
/// 백엔드 스키마: api-docs.json#LastMessageResponse (v2.25.0)
///
/// 발신자 정보는 v2.25.0(BE #173)에 붙었다. 없으면 미리보기가 "OO님이 참여했어요"
/// 대신 이름 없는 일반 문구로 물러선다.
@freezed
class CommunityChatLastMessageResponseModel
    with _$CommunityChatLastMessageResponseModel {
  const factory CommunityChatLastMessageResponseModel({
    required int id,

    /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다 —
    /// 해석은 `communityChatMessageBodyFromWire`가 한다.
    String? message,
    String? messageType,
    DateTime? createdAt,
    String? senderNickname,

    /// 프로필 아이콘 번호. 탈퇴자는 기본값이 채워져 온다 (DEC-0041).
    int? senderProfileIcon,
  }) = _CommunityChatLastMessageResponseModel;

  factory CommunityChatLastMessageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityChatLastMessageResponseModelFromJson(json);
}

/// 내가 참여 중인 채팅방 한 칸 DTO
///
/// 백엔드 스키마: api-docs.json#ChatRoomResponse (v2.25.0)
///
/// [status]를 도메인 enum이 아니라 문자열로 받는 이유는 목록과 같다 — 변환은
/// Repository 경계에서 하고, 모르는 값이 와도 방 목록 한 장이 통째로 날아가지
/// 않는다. `ENDED`가 추가됐을 때 실제로 그랬다.
@freezed
class CommunityChatRoomResponseModel with _$CommunityChatRoomResponseModel {
  const factory CommunityChatRoomResponseModel({
    required int postId,

    /// 게시글 제목. 스키마에 required가 없어 nullable로 받는다 — 제목 한 줄이
    /// 비는 편이 목록 전체가 파싱 실패로 날아가는 것보다 낫다 (LSN-0009).
    String? title,
    String? status,
    DateTime? meetingAt,
    int? memberCount,

    /// 아직 대화가 없는 방은 null이다. 목록에서 맨 뒤로 밀린다.
    CommunityChatLastMessageResponseModel? lastMessage,
  }) = _CommunityChatRoomResponseModel;

  factory CommunityChatRoomResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityChatRoomResponseModelFromJson(json);
}

/// 내 채팅방 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityChatRoomListResponse (v2.25.0)
/// 참여 방 수에 상한(100)이 있어 페이징하지 않는다.
@freezed
class CommunityChatRoomListResponseModel
    with _$CommunityChatRoomListResponseModel {
  const factory CommunityChatRoomListResponseModel({
    @Default(<CommunityChatRoomResponseModel>[])
    List<CommunityChatRoomResponseModel> chatRooms,
  }) = _CommunityChatRoomListResponseModel;

  factory CommunityChatRoomListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityChatRoomListResponseModelFromJson(json);
}

/// 채팅 메시지 한 건 DTO
///
/// 백엔드 스키마: api-docs.json#MessageResponse (v2.25.0)
///
/// [senderNickname]은 **조회 시점의 현재 닉네임**이다 — 탈퇴한 사람만 발신 당시
/// 이름이 남는다. 서버가 본문에 이름을 넣지 않는 것도 같은 이유다: 이름을 저장하면
/// 개명해도 지난 메시지가 옛 이름으로 굳는다 (DOC-0037).
@freezed
class CommunityChatMessageResponseModel
    with _$CommunityChatMessageResponseModel {
  const factory CommunityChatMessageResponseModel({
    required int id,

    /// 앱이 만든 UUID. 낙관적 말풍선을 에코와 맞추는 열쇠다.
    String? messageKey,
    int? senderId,
    String? senderNickname,

    /// 프로필 아이콘 번호. REST 내역과 소켓 브로드캐스트가 같은 이름으로 실어
    /// 보내므로(소켓은 BE #178에서 붙었다) 이 DTO 하나로 둘 다 읽는다.
    /// 값이 없으면 화면이 기본 아이콘으로 물러선다.
    int? senderProfileIcon,

    /// 본문. `SYSTEM`·`GAME_INVITE`는 JSON 문자열이다.
    String? message,
    String? messageType,
    DateTime? createdAt,
  }) = _CommunityChatMessageResponseModel;

  factory CommunityChatMessageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityChatMessageResponseModelFromJson(json);
}

/// 대화 내역 한 페이지 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityChatHistoryResponse (v2.25.0)
///
/// [messages]는 최신순이다. [hasNext]가 true일 때만 [nextCursor]가 실려 온다.
@freezed
class CommunityChatHistoryResponseModel
    with _$CommunityChatHistoryResponseModel {
  const factory CommunityChatHistoryResponseModel({
    @Default(<CommunityChatMessageResponseModel>[])
    List<CommunityChatMessageResponseModel> messages,
    int? nextCursor,
    @Default(false) bool hasNext,
  }) = _CommunityChatHistoryResponseModel;

  factory CommunityChatHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityChatHistoryResponseModelFromJson(json);
}

/// 채팅방 멤버 한 명 DTO
///
/// 백엔드 스키마: api-docs.json#MemberResponse (v2.25.0)
///
/// [isAuthor]가 방장 표시다. 값이 없으면 일반 멤버로 본다 — 나가기 버튼 노출이
/// 여기서 갈리므로, 모를 때 권한을 여는 쪽으로 물러서지 않는다.
@freezed
class CommunityChatMemberResponseModel with _$CommunityChatMemberResponseModel {
  const factory CommunityChatMemberResponseModel({
    required int userId,

    /// 탈퇴한 유저면 `"알수없음"`이 채워져 온다 (DEC-0041 — 자리를 비우지 않는다).
    String? nickname,
    int? profileIcon,
    @Default(false) bool isAuthor,
  }) = _CommunityChatMemberResponseModel;

  factory CommunityChatMemberResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityChatMemberResponseModelFromJson(json);
}

/// 채팅방 멤버 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityChatMemberListResponse (v2.25.0)
/// 방 멤버만 부를 수 있다(403 `NOT_A_CHAT_MEMBER`). 페이징 없음 — 정원 상한이 있다.
@freezed
class CommunityChatMemberListResponseModel
    with _$CommunityChatMemberListResponseModel {
  const factory CommunityChatMemberListResponseModel({
    @Default(<CommunityChatMemberResponseModel>[])
    List<CommunityChatMemberResponseModel> members,
  }) = _CommunityChatMemberListResponseModel;

  factory CommunityChatMemberListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CommunityChatMemberListResponseModelFromJson(json);
}
