import 'package:flutter/foundation.dart';

/// 잠금 화면(Android 알림 · iOS Live Activity)에 보낼 게임 현황.
///
/// 문구는 전부 Dart(ARB)에서 만들어 넘긴다 — 네이티브에 3개 언어 문자열을 따로 두지 않기 위해서.
/// Android는 [robbersText]·[revealText]를, iOS는 숫자·시각과 라벨을 쓴다.
@immutable
class LockScreenStatus {
  const LockScreenStatus({
    required this.startAt,
    required this.endAt,
    required this.nextRevealAt,
    required this.aliveRobbers,
    required this.totalRobbers,
    required this.title,
    required this.robbersText,
    required this.revealText,
    required this.remainingTimeLabel,
    required this.remainingRobbersLabel,
    required this.locationRevealLabel,
    required this.gameOverLabel,
    required this.isRobberTeam,
    required this.teamLabel,
    required this.localeCode,
  });

  /// 게임 시작 시각 — iOS 진행 막대(시작~종료)를 OS가 채운다.
  final DateTime startAt;
  final DateTime endAt;

  /// 없으면 공개 줄을 숨긴다.
  final DateTime? nextRevealAt;

  /// 둘 다 null이면 도둑 줄을 숨긴다(이벤트 모드이거나 아직 모름).
  final int? aliveRobbers;
  final int? totalRobbers;

  final String title;
  final String? robbersText;
  final String? revealText;
  final String remainingTimeLabel;
  final String remainingRobbersLabel;
  final String locationRevealLabel;
  final String gameOverLabel;

  /// 내 팀이 도둑인지 — 카드 테마(경찰 밝음·파랑 / 도둑 어두움·초록)와 캐릭터를 고른다.
  final bool isRobberTeam;

  /// 카드 오른쪽 위 팀 표시 ("경찰"/"도둑", 앱 언어)
  final String teamLabel;

  /// 앱 언어 코드(ko/en/ja) — iOS 카드가 언어별 앱 아이콘을 고른다.
  final String localeCode;

  /// 채널 인자. 키 이름은 MainActivity.kt·AppDelegate.swift와 맞춘다.
  Map<String, Object?> toMap() => {
    'startAtMs': startAt.millisecondsSinceEpoch,
    'endAtMs': endAt.millisecondsSinceEpoch,
    'nextRevealAtMs': nextRevealAt?.millisecondsSinceEpoch,
    'aliveRobbers': aliveRobbers,
    'totalRobbers': totalRobbers,
    'title': title,
    'robbersText': robbersText,
    'revealText': revealText,
    'remainingTimeLabel': remainingTimeLabel,
    'remainingRobbersLabel': remainingRobbersLabel,
    'locationRevealLabel': locationRevealLabel,
    'gameOverLabel': gameOverLabel,
    'isRobberTeam': isRobberTeam,
    'teamLabel': teamLabel,
    'localeCode': localeCode,
  };

  @override
  bool operator ==(Object other) =>
      other is LockScreenStatus && mapEquals(toMap(), other.toMap());

  @override
  int get hashCode => Object.hashAll(toMap().values);

  @override
  String toString() => 'LockScreenStatus${toMap()}';
}
