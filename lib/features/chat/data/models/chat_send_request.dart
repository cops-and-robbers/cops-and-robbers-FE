import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_send_request.freezed.dart';
part 'chat_send_request.g.dart';

/// 채팅 메시지 발행 요청 DTO
///
/// STOMP `/pub/game/{gameId}/chat`으로 전송하는 메시지 본문입니다.
///
/// ```json
/// {
///   "message": "1층으로 와주세요!",
///   "scope": "TEAM"
/// }
/// ```
@freezed
class ChatSendRequest with _$ChatSendRequest {
  const factory ChatSendRequest({
    required String message,

    /// "TEAM" 또는 "ALL"
    required String scope,
  }) = _ChatSendRequest;

  factory ChatSendRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatSendRequestFromJson(json);
}
