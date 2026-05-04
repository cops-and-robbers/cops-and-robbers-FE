import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_settings.freezed.dart';

/// 게임 설정 정보 엔티티
///
/// 참여 인원, 라운드 시간, 위치 공유 간격 등 게임 설정을 표현합니다.
@freezed
class SessionSettings with _$SessionSettings {
  const factory SessionSettings({
    required int maxPlayers,
    required int roundTimeMinutes,
    required int locationShareMinutes,
    required int policeStartDelayMinutes,
  }) = _SessionSettings;

  const SessionSettings._();

  /// 화면 표시용 최대 참여 인원
  ///
  /// 예: "50명"
  String get maxPlayersDisplay => '$maxPlayers명';

  /// 화면 표시용 라운드 시간
  ///
  /// 예: "30분"
  String get roundTimeDisplay => '$roundTimeMinutes분';

  /// 화면 표시용 위치 공유 간격
  ///
  /// 예: "5분"
  String get locationShareDisplay => '$locationShareMinutes분';

  /// 화면 표시용 경찰 출동 시간
  ///
  /// 예: "도둑 도망 후 5분 뒤"
  String get policeStartDisplay => '도둑 도망 후 $policeStartDelayMinutes분 뒤';
}
