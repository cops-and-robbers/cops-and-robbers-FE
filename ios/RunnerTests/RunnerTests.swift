import ActivityKit
import XCTest
@testable import Runner

@available(iOS 16.2, *)
@MainActor
class RunnerTests: XCTestCase {
  private func attributes() -> GameStatusAttributes {
    GameStatusAttributes(
      title: "Game", remainingTimeLabel: "Time", remainingRobbersLabel: "Robbers",
      locationRevealLabel: "Reveal", gameOverLabel: "Over", isRobberTeam: false,
      teamLabel: "Police", localeCode: "en", gameId: 42
    )
  }

  private func state() -> GameStatusAttributes.ContentState {
    let now = Date()
    return .init(startAt: now, endAt: now.addingTimeInterval(1800),
                 nextRevealAt: nil, aliveRobbers: 1, totalRobbers: 1)
  }

  override func tearDown() async throws {
    for activity in Activity<GameStatusAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
  }

  func test_activity_keeps_identifier_when_manager_restarts() async throws {
    let attributes = attributes()
    let state = state()
    let existing = try Activity.request(
      attributes: attributes, content: ActivityContent(state: state, staleDate: state.endAt),
      pushType: nil
    )

    // 새 매니저에는 이전 프로세스의 currentActivityID가 없다.
    let manager = GameStatusActivityManager()
    await manager.restore()?.value
    XCTAssertEqual(Activity<GameStatusAttributes>.activities.map(\.id), [existing.id])
    manager.update(attributes: attributes, state: state)

    XCTAssertEqual(Activity<GameStatusAttributes>.activities.map(\.id), [existing.id])
  }

  func test_activity_stays_absent_when_round_has_expired() {
    var expired = state()
    expired.startAt = Date().addingTimeInterval(-1800)
    expired.endAt = Date().addingTimeInterval(-1)

    GameStatusActivityManager().update(attributes: attributes(), state: expired)

    XCTAssertTrue(Activity<GameStatusAttributes>.activities.isEmpty)
  }

  func test_activity_is_replaced_when_same_game_starts_another_round() async throws {
    let attributes = attributes()
    let previous = state()
    let existing = try Activity.request(
      attributes: attributes, content: ActivityContent(state: previous, staleDate: previous.endAt),
      pushType: nil
    )
    var next = previous
    next.startAt = previous.startAt.addingTimeInterval(1)
    let manager = GameStatusActivityManager()

    manager.update(attributes: attributes, state: next)
    await assertEnded(existing)

    XCTAssertEqual(Activity<GameStatusAttributes>.activities.map { $0.content.state.startAt }, [next.startAt])
  }

  func test_activity_is_removed_when_game_stops_after_restart() async throws {
    let state = state()
    let existing = try Activity.request(
      attributes: attributes(), content: ActivityContent(state: state, staleDate: state.endAt),
      pushType: nil
    )

    GameStatusActivityManager().stop()
    await assertEnded(existing)

    XCTAssertTrue(Activity<GameStatusAttributes>.activities.isEmpty)
  }

  func test_activity_stays_absent_when_closed_outside_the_app() async throws {
    let manager = GameStatusActivityManager()
    let attributes = attributes()
    let state = state()
    manager.update(attributes: attributes, state: state)
    let activity = try XCTUnwrap(Activity<GameStatusAttributes>.activities.first)

    await activity.end(nil, dismissalPolicy: .immediate)
    manager.update(attributes: attributes, state: state)

    XCTAssertTrue(Activity<GameStatusAttributes>.activities.isEmpty)
  }

  private func assertEnded(_ activity: Activity<GameStatusAttributes>) async {
    let ended = expectation(description: "Activity ended")
    let observer = Task {
      for await state in activity.activityStateUpdates {
        if state == .ended || state == .dismissed {
          ended.fulfill()
          return
        }
      }
    }
    await fulfillment(of: [ended], timeout: 5)
    observer.cancel()
  }
}
