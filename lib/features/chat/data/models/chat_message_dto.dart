import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/services/content_filter/profanity_filter.dart';
import '../../../../core/utils/iso_timestamp_parser.dart';

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
/// 서버 타임스탬프(`+09:00` suffix 포함 ISO 8601)를 **단말 local DateTime**으로
/// 변환합니다. 채팅은 실시간 대화 맥락이라 사용자 시계 기준 시각이 자연스럽습니다
/// (예: 미국 동부 사용자에게는 한국 14:30 메시지가 00:30으로 표시).
///
/// 파싱은 [IsoTimestampParser]에 위임 — 나노초 절단·timezone 누락 시 KST 보정·
/// `.toLocal()` 적용을 게임 이벤트/세션/공지 처리와 동일하게 일관 적용한다.
extension ChatMessageTimestamp on ChatMessageDto {
  /// 단말 local로 변환된 DateTime. 파싱 실패 시 null.
  DateTime? get localDateTime => IsoTimestampParser.parse(timestamp);

  /// HH:MM 형태의 단말 local 시간 문자열 (24시간제 고정)
  String get formattedTimeLocal {
    final dt = localDateTime;
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// 채팅 메시지 비속어 필터링 확장
///
/// [ProfanityFilter]를 통해 마스킹된 메시지 텍스트를 제공합니다.
/// 원본 [message] 필드는 보존됩니다.
extension ChatMessageFiltered on ChatMessageDto {
  /// 욕설/금칙어가 마스킹된 메시지 텍스트
  String get filteredMessage => ProfanityFilter.filter(message);
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
