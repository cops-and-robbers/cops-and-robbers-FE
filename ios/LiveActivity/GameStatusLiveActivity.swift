import ActivityKit
import SwiftUI
import WidgetKit

@main
struct LiveActivityBundle: WidgetBundle {
  var body: some Widget {
    GameStatusLiveActivity()
  }
}

struct GameStatusLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: GameStatusAttributes.self) { context in
      GameStatusCard(
        model: context.cardModel,
        appIcon: context.appIcon,
        character: context.character
      )
      .activityBackgroundTint(GameStatusTheme.of(isRobberTeam: context.attributes.isRobberTeam).background)
      .activitySystemActionForegroundColor(GameStatusTheme.of(isRobberTeam: context.attributes.isRobberTeam).primary)
    } dynamicIsland: { context in
      // 다이내믹 아일랜드 배경은 항상 검정 — 팀과 무관하게 밝은 글자, 강조색만 팀을 따른다.
      let accent = GameStatusTheme.of(isRobberTeam: context.attributes.isRobberTeam).accent
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          context.character
            .resizable()
            .scaledToFit()
            .frame(height: 44)
        }
        DynamicIslandExpandedRegion(.trailing) {
          if context.isStale {
            Text(context.attributes.gameOverLabel)
              .font(.pretendard(15))
              .foregroundColor(.white)
          } else {
            CountdownText(until: context.state.endAt)
              .font(.pretendard(24))
              .foregroundColor(accent)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          if !context.isStale {
            IslandDetail(context: context, accent: accent)
          }
        }
      } compactLeading: {
        context.character
          .resizable()
          .scaledToFit()
          .frame(width: 22, height: 22)
      } compactTrailing: {
        if context.isStale {
          Image(systemName: "flag.checkered")
            .foregroundColor(accent)
        } else {
          CountdownText(until: context.state.endAt)
            .font(.pretendard(14))
            .foregroundColor(accent)
            .frame(maxWidth: 52)
        }
      } minimal: {
        context.character
          .resizable()
          .scaledToFit()
          .frame(width: 22, height: 22)
      }
    }
  }
}

/// 다이내믹 아일랜드 펼침 아래쪽 — 남은 도둑·위치 공개와 진행 막대.
private struct IslandDetail: View {
  let context: ActivityViewContext<GameStatusAttributes>
  let accent: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 10) {
        if let alive = context.state.aliveRobbers, let total = context.state.totalRobbers {
          Text("\(context.attributes.remainingRobbersLabel) \(alive)/\(total)")
        }
        if let reveal = context.state.nextRevealAt {
          HStack(spacing: 4) {
            Text(context.attributes.locationRevealLabel)
            CountdownText(until: reveal)
          }
        }
      }
      .font(.pretendard(13))
      .foregroundColor(Color(hex: 0x93A2B3))  // AppColors.black400 — 어두운 배경의 보조 글자
      ProgressView(
        timerInterval: context.state.startAt...max(context.state.startAt, context.state.endAt),
        countsDown: false
      ) {
        EmptyView()
      } currentValueLabel: {
        EmptyView()
      }
      .tint(accent)
    }
  }
}

extension ActivityViewContext where Attributes == GameStatusAttributes {
  var cardModel: GameStatusCardModel {
    GameStatusCardModel(
      title: attributes.title,
      teamLabel: attributes.teamLabel,
      remainingTimeLabel: attributes.remainingTimeLabel,
      remainingRobbersLabel: attributes.remainingRobbersLabel,
      locationRevealLabel: attributes.locationRevealLabel,
      gameOverLabel: attributes.gameOverLabel,
      isRobberTeam: attributes.isRobberTeam,
      startAt: state.startAt,
      endAt: state.endAt,
      nextRevealAt: state.nextRevealAt,
      aliveRobbers: state.aliveRobbers,
      totalRobbers: state.totalRobbers,
      isStale: isStale
    )
  }

  /// 앱 아이콘은 언어마다 글자가 달라(경도 / Cops and Robbers) 앱 언어로 고른다.
  var appIcon: Image {
    let code = ["ko", "ja"].contains(attributes.localeCode) ? attributes.localeCode : "en"
    return Image("app_icon_\(code)")
  }

  var character: Image {
    Image(attributes.isRobberTeam ? "character_robber" : "character_police")
  }
}

// 프리뷰 전용 샘플 — 실제 문구는 Dart(ARB)가 넘긴다. stale은 previewContext(_:isStale:viewKind:)(iOS 16.2+)로 주입.
struct GameStatusLiveActivity_Previews: PreviewProvider {
  static func attributes(robber: Bool) -> GameStatusAttributes {
    GameStatusAttributes(
      title: "경찰과도둑",
      remainingTimeLabel: "남은 시간",
      remainingRobbersLabel: "남은 도둑",
      locationRevealLabel: "위치 공개",
      gameOverLabel: "게임 종료",
      isRobberTeam: robber,
      teamLabel: robber ? "도둑" : "경찰",
      localeCode: "ko"
    )
  }
  static let normal = GameStatusAttributes.ContentState(
    startAt: .now.addingTimeInterval(-10 * 60),
    endAt: .now.addingTimeInterval(20 * 60),
    nextRevealAt: .now.addingTimeInterval(3 * 60),
    aliveRobbers: 3,
    totalRobbers: 5
  )
  static let noRobbers = GameStatusAttributes.ContentState(
    startAt: normal.startAt, endAt: normal.endAt, nextRevealAt: normal.nextRevealAt,
    aliveRobbers: nil, totalRobbers: nil
  )
  static let noReveal = GameStatusAttributes.ContentState(
    startAt: normal.startAt, endAt: normal.endAt, nextRevealAt: nil, aliveRobbers: 3, totalRobbers: 5
  )

  static var previews: some View {
    Group {
      attributes(robber: false).previewContext(normal, viewKind: .content)
        .previewDisplayName("경찰")
      attributes(robber: true).previewContext(normal, viewKind: .content)
        .previewDisplayName("도둑")
      attributes(robber: false).previewContext(noRobbers, viewKind: .content)
        .previewDisplayName("도둑 줄 없음 (이벤트 모드)")
      attributes(robber: true).previewContext(noReveal, viewKind: .content)
        .previewDisplayName("공개 줄 없음")
      attributes(robber: false).previewContext(normal, isStale: true, viewKind: .content)
        .previewDisplayName("stale — 게임 종료")
      attributes(robber: true).previewContext(normal, viewKind: .dynamicIsland(.expanded))
        .previewDisplayName("다이내믹 아일랜드 펼침")
      attributes(robber: false).previewContext(normal, isStale: true, viewKind: .dynamicIsland(.compact))
        .previewDisplayName("compact stale")
    }
  }
}
