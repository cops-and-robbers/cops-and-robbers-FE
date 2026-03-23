import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';

/// 채팅 메시지 수신 DTO
///
/// STOMP 구독으로 수신되는 메시지 JSON을 파싱합니다.
///
/// ```json
/// {
///   "id": "uuid-uuid-uuid....",
///   "gameId": 1,
///   "sender": { "participantId": 5, "nickname": "창희도둑", "team": "ROBBER" },
///   "message": "경찰 떴다!",
///   "timestamp": "2026-01-26T14:30:15.123456789+09:00",
///   "scope": "TEAM"
/// }
/// ```
@freezed
class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    required String id,
    required int gameId,
    required ChatSenderDto sender,
    required String message,
    required String timestamp,
    required String scope,
  }) = _ChatMessageDto;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);
}

/// 채팅 메시지 타임스탬프 파싱 확장
///
/// 서버 타임스탬프를 KST(UTC+9)로 변환합니다.
/// 마이크로초 초과 자릿수를 정규화한 뒤 파싱합니다.
extension ChatMessageTimestamp on ChatMessageDto {
  static final _microRegex = RegExp(r'(\.\d{1,6})\d*');

  /// KST 변환된 DateTime. 파싱 실패 시 null.
  DateTime? get kstDateTime {
    try {
      final normalized = timestamp.replaceFirstMapped(
        _microRegex,
        (m) => m.group(1)!,
      );
      return DateTime.parse(normalized).toUtc().toLocal();
    } catch (_) {
      return null;
    }
  }

  /// HH:MM 형태의 KST 시간 문자열
  String get formattedTimeKst {
    final dt = kstDateTime;
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// 채팅 발신자 정보 DTO
@freezed
class ChatSenderDto with _$ChatSenderDto {
  const factory ChatSenderDto({
    required int participantId,
    required String nickname,
    required String team,
  }) = _ChatSenderDto;

  factory ChatSenderDto.fromJson(Map<String, dynamic> json) =>
      _$ChatSenderDtoFromJson(json);
}
