import 'dart:math' as math;

/// 결과 보드에서 증거 사진을 놓는 방식.
enum EventEvidenceArrangement { single, sideBySide, stacked, twoOverOne }

/// 이벤트 결과 보드의 증거 사진 배치.
///
/// 한 보드의 칸은 모두 같은 크기다. 크기가 다르면 큰 사진만 중요해 보인다.
/// 잠긴 칸도 같은 크기로 그려 사진이 열려도 배치가 움직이지 않는다.
class EventEvidenceLayout {
  const EventEvidenceLayout({
    required this.arrangement,
    required this.slotWidth,
    required this.slotHeight,
    required this.tiltRadians,
  });

  /// 세로로 길어도, 가로로 길어도 이 범위를 넘으면 칸 안에 맞춰 보여 준다.
  static const double minAspectRatio = 9 / 16;
  static const double maxAspectRatio = 16 / 9;

  /// 지금 앱의 나란한 사진 기울기. 폭을 다 쓰는 배치는 크게 기울이면 사진끼리 닿아 줄인다.
  static const double sideBySideTilt = 0.05;
  static const double fullWidthTilt = 0.02;

  final EventEvidenceArrangement arrangement;
  final double slotWidth;
  final double slotHeight;

  /// 첫 칸은 이 값의 반대 방향, 마지막 칸은 이 방향으로 기운다. 가운데 칸은 곧다.
  final double tiltRadians;

  /// [aspectRatio]는 가로/세로. [count]는 사진 수(1~3).
  factory EventEvidenceLayout.resolve({
    required double aspectRatio,
    required int count,
    required double maxWidth,
    required double maxHeight,
    required double horizontalGap,
    required double verticalGap,
  }) {
    final ratio = aspectRatio.clamp(minAspectRatio, maxAspectRatio);

    if (count <= 1) {
      final width = math.min(maxWidth, maxHeight * ratio);
      return EventEvidenceLayout(
        arrangement: EventEvidenceArrangement.single,
        slotWidth: width,
        slotHeight: width / ratio,
        tiltRadians: fullWidthTilt,
      );
    }

    if (ratio < 1) {
      final width = (maxWidth - horizontalGap * (count - 1)) / count;
      final height = math.min(width / ratio, maxHeight);
      return EventEvidenceLayout(
        arrangement: EventEvidenceArrangement.sideBySide,
        slotWidth: height * ratio,
        slotHeight: height,
        tiltRadians: sideBySideTilt,
      );
    }

    if (count >= 3) {
      // 3장을 위아래로 놓으면 너무 길고, 한 줄로 놓으면 너무 작다
      final width = (maxWidth - horizontalGap) / 2;
      final height = math.min(width / ratio, (maxHeight - verticalGap) / 2);
      return EventEvidenceLayout(
        arrangement: EventEvidenceArrangement.twoOverOne,
        slotWidth: height * ratio,
        slotHeight: height,
        tiltRadians: sideBySideTilt,
      );
    }

    final height = math.min(maxWidth / ratio, (maxHeight - verticalGap) / 2);
    return EventEvidenceLayout(
      arrangement: EventEvidenceArrangement.stacked,
      slotWidth: height * ratio,
      slotHeight: height,
      tiltRadians: fullWidthTilt,
    );
  }

  /// [index]번째 칸(1부터)의 기울기.
  double tiltFor(int index, int count) {
    if (index == 1) return -tiltRadians;
    return index == count ? tiltRadians : 0;
  }
}
