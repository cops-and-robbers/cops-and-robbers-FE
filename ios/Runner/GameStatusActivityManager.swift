import ActivityKit
import UIKit

/// 게임 현황 Live Activity의 생성·갱신·종료.
///
/// - 시작은 포그라운드에서만 된다(ActivityAuthorizationError.visibility). 위치 백그라운드 모드로
///   앱이 살아 있어도 마찬가지라, 실패하면 "생성 대기"로 두고 앱이 앞으로 올 때 최신 값으로 다시 만든다.
/// - 사용자가 닫으면 이번 게임 동안 다시 만들지 않는다(닫힌 뒤 update가 새로 만들어 버리는 것을 막음).
@available(iOS 16.2, *)
@MainActor
final class GameStatusActivityManager {
  static let shared = GameStatusActivityManager()

  private var latest: (attributes: GameStatusAttributes, state: GameStatusAttributes.ContentState)?
  private var currentActivityID: String?
  private var dismissedByUser = false
  private var foregroundObserver: NSObjectProtocol?
  private var stateTask: Task<Void, Never>?

  func update(attributes: GameStatusAttributes, state: GameStatusAttributes.ContentState) {
    latest = (attributes, state)
    guard !dismissedByUser else { return }
    if let activity = Activity<GameStatusAttributes>.activities.first(where: { $0.id == currentActivityID }) {
      Task { await activity.update(ActivityContent(state: state, staleDate: state.endAt)) }
    } else {
      requestLatest()
    }
  }

  func stop() {
    latest = nil
    currentActivityID = nil  // 먼저 비워야 아래 종료가 "사용자 닫힘"으로 기록되지 않는다
    dismissedByUser = false
    removeForegroundObserver()
    stateTask?.cancel()
    stateTask = nil
    endAll()
  }

  /// 앱 실행 시 호출 — 게임 중 강제 종료되면 stop이 오지 않아 이전 Activity가 남는다.
  func endAll() {
    let activities = Activity<GameStatusAttributes>.activities
    Task {
      for activity in activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }

  private func requestLatest() {
    guard let latest, !dismissedByUser, currentActivityID == nil else { return }
    guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
    do {
      let activity = try Activity.request(
        attributes: latest.attributes,
        content: ActivityContent(state: latest.state, staleDate: latest.state.endAt),
        pushType: nil
      )
      currentActivityID = activity.id
      removeForegroundObserver()
      watchDismissal(of: activity)
    } catch {
      // 백그라운드에서 시작이 막힘 → 앱이 앞으로 오면 보관한 최신 값으로 다시 시도한다.
      addForegroundObserver()
    }
  }

  private func watchDismissal(of activity: Activity<GameStatusAttributes>) {
    stateTask?.cancel()
    stateTask = Task { [weak self] in
      for await state in activity.activityStateUpdates {
        guard let self else { return }
        // 앱이 끝낸 경우는 stop()이 currentActivityID를 먼저 비워 여기서 걸러진다.
        if (state == .dismissed || state == .ended) && self.currentActivityID == activity.id {
          self.dismissedByUser = true
          self.currentActivityID = nil
        }
      }
    }
  }

  private func addForegroundObserver() {
    guard foregroundObserver == nil else { return }
    foregroundObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in self?.requestLatest() }
    }
  }

  private func removeForegroundObserver() {
    if let observer = foregroundObserver {
      NotificationCenter.default.removeObserver(observer)
      foregroundObserver = nil
    }
  }
}
