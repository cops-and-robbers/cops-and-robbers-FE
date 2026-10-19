import SwiftUI

/// 잠금 화면 카드에 필요한 값. ActivityKit 타입에 기대지 않아 맥에서도 렌더링해 볼 수 있다.
struct GameStatusCardModel {
  var title: String
  var teamLabel: String
  var remainingTimeLabel: String
  var remainingRobbersLabel: String
  var locationRevealLabel: String
  var gameOverLabel: String
  var isRobberTeam: Bool
  var startAt: Date
  var endAt: Date
  var nextRevealAt: Date?
  var aliveRobbers: Int?
  var totalRobbers: Int?
  var isStale: Bool
}

/// 경찰과도둑 디자인 시스템(AppColors·AppTextStyles)의 팀 테마를 옮긴 값.
/// 경찰 = 라이트(white·black·blue), 도둑 = 다크(black·white·green). 서체는 양 팀 모두 시스템 서체.
struct GameStatusTheme {
  let background: Color
  let primary: Color
  let secondary: Color
  let accent: Color
  let onAccent: Color
  /// 숫자 값(도둑 수·공개 카운트다운) 색 — 경찰은 본문색, 도둑은 강조 초록(앱의 도둑 강조 규칙)
  let value: Color
  let timerFont: Font

  static func of(isRobberTeam: Bool) -> GameStatusTheme {
    isRobberTeam
      ? GameStatusTheme(
        background: Color(hex: 0x080A0C),  // AppColors.black
        primary: Color(hex: 0xFFFFFF),  // AppColors.white
        secondary: Color(hex: 0x93A2B3),  // AppColors.black400
        accent: Color(hex: 0x38F55B),  // AppColors.green
        onAccent: Color(hex: 0x080A0C),  // 도둑 CTA 글자 = black
        value: Color(hex: 0x38F55B),
        timerFont: .cardFont(36)
      )
      : GameStatusTheme(
        background: Color(hex: 0xFFFFFF),  // AppColors.white
        primary: Color(hex: 0x080A0C),  // AppColors.black
        secondary: Color(hex: 0x5D6F83),  // AppColors.black600
        accent: Color(hex: 0x0088FF),  // AppColors.blue
        onAccent: Color(hex: 0xFFFFFF),  // 경찰 CTA 글자 = white
        value: Color(hex: 0x080A0C),
        timerFont: .cardFont(36)
      )
  }
}

extension Color {
  init(hex: UInt32) {
    self.init(
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}

extension Font {
  /// 시스템 서체 SemiBold. 커스텀 폰트(Pretendard 2.6MB)를 쓰면 렌더링 결과에 폰트가 함께 실려
  /// 시스템이 archiveTooLarge(약 2.9MB)로 거절하고, 세 번 실패하면 Activity를 끝내 버린다.
  static func cardFont(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
}

/// 남은 시간 카운트다운(OS가 초를 줄인다). 끝나면 0:00에 멈추고 앱이 종료를 알린다.
struct CountdownText: View {
  let until: Date

  var body: some View {
    Text(timerInterval: Date.now...max(Date.now, until), countsDown: true)
      .monospacedDigit()
  }
}

/// 잠금 화면 카드 — 배민식 구성: 앱 표시·팀 배지 / 큰 남은 시간 / 도둑·위치 공개 / 캐릭터 / 진행 막대.
struct GameStatusCard: View {
  let model: GameStatusCardModel
  let appIcon: Image
  let character: Image

  private var theme: GameStatusTheme { .of(isRobberTeam: model.isRobberTeam) }

  var body: some View {
    // 잠금 화면 카드 높이 상한은 160pt — 36pt 타이머가 들어가도록 세로 간격을 8·4로 줄였다.
    VStack(alignment: .leading, spacing: 8) {
      header
      HStack(alignment: .center, spacing: 12) {
        VStack(alignment: .leading, spacing: 4) {
          headline
          if !model.isStale { detail }
        }
        Spacer(minLength: 0)
        character
          .resizable()
          .scaledToFit()
          .frame(height: 64)
      }
      if !model.isStale {
        ProgressView(timerInterval: model.startAt...max(model.startAt, model.endAt), countsDown: false) {
          EmptyView()
        } currentValueLabel: {
          EmptyView()
        }
        .tint(theme.accent)
      }
    }
    .padding(16)
  }

  private var header: some View {
    HStack(spacing: 6) {
      appIcon
        .resizable()
        .frame(width: 20, height: 20)
        .clipShape(RoundedRectangle(cornerRadius: 5))
      Text(model.title)
        .font(.cardFont(13))
        .foregroundColor(theme.secondary)
      Spacer()
      Text(model.teamLabel)
        .font(.cardFont(12))
        .foregroundColor(theme.onAccent)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Capsule().fill(theme.accent))
    }
  }

  @ViewBuilder private var headline: some View {
    // staleDate는 상태만 바꾼다 — 앱이 강제 종료돼 stop이 오지 않으면 마지막 값이 정상처럼 남으므로
    // 여기서 직접 숨긴다.
    if model.isStale {
      Text(model.gameOverLabel)
        .font(theme.timerFont)
        .foregroundColor(theme.primary)
    } else {
      // 라벨을 위에 두고 타이머를 크게 — 타이머 Text는 가능한 최대 폭을 차지해, 옆에 두면 라벨이 카드 가운데로 밀린다.
      VStack(alignment: .leading, spacing: 0) {
        Text(model.remainingTimeLabel)
          .font(.cardFont(13))
          .foregroundColor(theme.secondary)
        CountdownText(until: model.endAt)
          .font(theme.timerFont)
          .foregroundColor(theme.primary)
      }
    }
  }

  private var detail: some View {
    HStack(spacing: 10) {
      if let alive = model.aliveRobbers, let total = model.totalRobbers {
        labeled(model.remainingRobbersLabel) {
          Text("\(alive)/\(total)")
        }
      }
      if let reveal = model.nextRevealAt {
        labeled(model.locationRevealLabel) {
          CountdownText(until: reveal)
        }
      }
    }
  }

  private func labeled<V: View>(_ label: String, @ViewBuilder value: () -> V) -> some View {
    HStack(spacing: 4) {
      Text(label)
        .foregroundColor(theme.secondary)
      value()
        .monospacedDigit()
        .foregroundColor(theme.value)
    }
    .font(.cardFont(13))
    .lineLimit(1)
  }
}
