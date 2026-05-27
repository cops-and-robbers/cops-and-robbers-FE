import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_join_result.freezed.dart';

/// 게임 방 참여 결과 엔티티
///
/// 초대 코드로 게임 방에 참여했을 때 반환되는 핵심 식별자입니다.
/// 이후 로비 화면 진입 및 WebSocket 구독에 [gameId]와 [participantId]를 사용합니다.
@freezed
class GameJoinResult with _$GameJoinResult {
  const factory GameJoinResult({
    /// 참여한 게임의 고유 ID
    required int gameId,

    /// 해당 게임에서 부여받은 참여자 고유 ID
    required int participantId,
  }) = _GameJoinResult;
}
