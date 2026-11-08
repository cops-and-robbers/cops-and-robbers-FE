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
    /// 구역 축소를 켠 게임의 다음 축소 시각 (#668). 없으면 줄을 숨긴다. 이전 Activity도 디코딩되게 optional.
    var nextShrinkAt: Date? = nil
    /// 축소 카운트다운 앞 라벨. 게임 중에 앱을 업데이트해 이전 Activity를 이어받아도 보이도록
    /// attributes(처음 만들 때 고정)가 아니라 state에 둔다.
    var shrinkLabel: String? = nil
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
  /// 재실행 시 같은 게임을 찾는다. 이전 버전의 Activity도 디코딩할 수 있게 optional.
  var gameId: Int? = nil
}
