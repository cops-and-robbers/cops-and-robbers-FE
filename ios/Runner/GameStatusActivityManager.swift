import ActivityKit
import UIKit

/// 게임 현황 Live Activity의 생성·갱신·종료.
///
/// - 시작은 포그라운드에서만 된다(ActivityAuthorizationError.visibility). 위치 백그라운드 모드로
///   앱이 살아 있어도 마찬가지라, 실패하면 "생성 대기"로 두고 앱이 앞으로 올 때 최신 값으로 다시 만든다.
/// - 앱 밖에서 닫힌 표시는 같은 라운드에서 다시 만들지 않는다. ActivityKit은 사용자·시스템 제거를 구분하지 않는다.
@available(iOS 16.2, *)
@MainActor
final class GameStatusActivityManager {
  static let shared = GameStatusActivityManager()

  private var latest: (attributes: GameStatusAttributes, state: GameStatusAttributes.ContentState)?
  private var currentActivityID: String?
  private var endedExternally = false
  private var foregroundObserver: NSObjectProtocol?
  private var stateTask: Task<Void, Never>?

  func update(attributes: GameStatusAttributes, state: GameStatusAttributes.ContentState) {
    if latest?.attributes.gameId != attributes.gameId || latest?.state.startAt != state.startAt {
      currentActivityID = nil
      endedExternally = false
      stateTask?.cancel()
    }
    latest = (attributes, state)
    guard state.endAt > Date() else {
      stop()
      return
    }
    guard !endedExternally else { return }

    let activities = Activity<GameStatusAttributes>.activities
    // gameId만 같아도 같은 방의 새 라운드일 수 있으므로 시작 시각까지 대조한다.
    let activity = activities.first {
      $0.attributes.gameId == attributes.gameId && $0.content.state.startAt == state.startAt
    }
    end(activities.filter { $0.id != activity?.id })
    if let activity {
      guard activity.activityState == .active || activity.activityState == .stale else {
        endedExternally = true
        return
      }
      if currentActivityID != activity.id {
        currentActivityID = activity.id
        removeForegroundObserver()
        watchDismissal(of: activity)
      }
      Task { await activity.update(ActivityContent(state: state, staleDate: state.endAt)) }
    } else {
      // 이미 추적하던 표시가 사라졌으면 사용자 닫기를 되돌리지 않는다.
      guard currentActivityID == nil else { return }
      requestLatest()
    }
  }

  func stop() {
    latest = nil
    currentActivityID = nil  // 먼저 비워야 아래 종료가 "사용자 닫힘"으로 기록되지 않는다
    endedExternally = false
    removeForegroundObserver()
    stateTask?.cancel()
    stateTask = nil
    end(Activity<GameStatusAttributes>.activities)
  }

  /// 앱 재실행은 게임 종료가 아니다. 종료 시각이 지난 표시만 정리한다.
  @discardableResult
  func restore() -> Task<Void, Never>? {
    let now = Date()
    return end(Activity<GameStatusAttributes>.activities.filter { $0.content.state.endAt <= now })
  }

  @discardableResult
  private func end(_ activities: [Activity<GameStatusAttributes>]) -> Task<Void, Never>? {
    guard !activities.isEmpty else { return nil }
    return Task {
      for activity in activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
    }
  }

  private func requestLatest() {
    guard let latest, !endedExternally, currentActivityID == nil else { return }
    guard latest.state.endAt > Date() else { return }
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
      print("[LiveActivity] request failed: \(error)")
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
          self.endedExternally = true
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
