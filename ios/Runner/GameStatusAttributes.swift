import ActivityKit
import Foundation

/// 게임 현황 Live Activity의 데이터. 앱(Runner)과 확장 기능(LiveActivity)이 같이 컴파일한다.
///
/// 라벨은 Dart(ARB)가 만든 문구를 그대로 받는다 — 확장 기능에 문자열 리소스를 두지 않는다.
struct GameStatusAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var startAt: Date
    var endAt: Date
    var nextRevealAt: Date?
    var aliveRobbers: Int?
    var totalRobbers: Int?
  }

  var title: String
  var remainingTimeLabel: String
  var remainingRobbersLabel: String
  var locationRevealLabel: String
  var gameOverLabel: String
  /// 게임 동안 바뀌지 않는 팀·언어 — 카드 테마·캐릭터·언어별 앱 아이콘을 고른다.
  var isRobberTeam: Bool
  var teamLabel: String
  var localeCode: String
}
