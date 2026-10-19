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
        // 펼침 위쪽은 아일랜드 모서리가 둥글어 붙여 두면 잘린다 — 좌우·위로 띄운다.
        DynamicIslandExpandedRegion(.leading) {
          context.islandCharacter
            .frame(height: 44)
            .padding(.leading, 8)
            .padding(.top, 8)
        }
        DynamicIslandExpandedRegion(.trailing) {
          if context.isStale {
            Text(context.attributes.gameOverLabel)
              .font(.cardFont(15))
              .foregroundColor(.white)
          } else {
            // 타이머는 최대 폭을 잡고 왼쪽 정렬돼 가운데에 떠 보이므로, 오른쪽 끝에 붙이고 무엇의 숫자인지 라벨을 위에 단다.
            VStack(alignment: .trailing, spacing: 2) {
              Text(context.attributes.remainingTimeLabel)
                .font(.cardFont(12))
                .foregroundColor(Color(hex: 0x93A2B3))  // AppColors.black400
              CountdownText(until: context.state.endAt)
                .font(.cardFont(24))
                .foregroundColor(accent)
                .multilineTextAlignment(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 8)
            .padding(.top, 8)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          if !context.isStale {
            IslandDetail(context: context, accent: accent)
          }
        }
      } compactLeading: {
        context.islandCharacter
          .frame(width: 22, height: 22)
      } compactTrailing: {
        if context.isStale {
          Image(systemName: "flag.checkered")
            .foregroundColor(accent)
        } else {
          // 타이머 Text는 폭을 주지 않으면 가능한 최대 폭을 잡아 아일랜드가 화면 끝까지 늘어난다.
          // 52 = 최대 게임 시간(180분)의 "2:59:59"가 들어가는 폭. 카드가 사라지던 원인은 frame이 아니었다(archiveTooLarge).
          CountdownText(until: context.state.endAt)
            .font(.cardFont(14))
            .foregroundColor(accent)
            .multilineTextAlignment(.trailing)
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
      .font(.cardFont(13))
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

  /// 아일랜드 왼쪽에 두는 캐릭터 — 그림이 왼쪽을 보고 있어 좌우를 뒤집어 아일랜드 안쪽을 보게 한다.
  /// 잠금 화면 카드는 캐릭터가 오른쪽 끝이라 원본 방향이 이미 안쪽이다.
  var islandCharacter: some View {
    character
      .resizable()
      .scaledToFit()
      .scaleEffect(x: -1, y: 1)
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
