/// 대기·설명 장면에서 멀어지는 캐릭터의 원근.
///
/// 같은 속도로 멀어지면 크기, 지평선과의 발 거리, 소실점과의 좌우 거리가 모두
/// 1/거리로 준다 → 처음엔 빨리, 멀수록 천천히 작아진다. 좌표는 300×652 목업 기준.
library;

/// 배경 그림의 지평선 높이(목업 y). 멀어지는 캐릭터의 발은 늘 이보다 아래.
const double startHorizonY = 400;

class RecedeSpec {
  const RecedeSpec({
    required this.startWidth,
    required this.endWidth,
    required this.startFeetY,
    required this.startCenterX,
    required this.vanishX,
    required this.aspect,
  });

  final double startWidth;
  final double endWidth;
  final double startFeetY;
  final double startCenterX;

  /// 캐릭터가 향하는 소실점의 x
  final double vanishX;

  /// SVG 높이 / 폭
  final double aspect;
}

class RecedePose {
  const RecedePose({
    required this.width,
    required this.height,
    required this.left,
    required this.top,
  });

  final double width;
  final double height;
  final double left;
  final double top;

  double get feetY => top + height;
}

/// [p]는 대기 진행 비율(0~1, 넘으면 잘라 낸다).
RecedePose recede(double p, RecedeSpec spec) {
  final f = 1 / (1 + (spec.startWidth / spec.endWidth - 1) * p.clamp(0.0, 1.0));
  final width = spec.startWidth * f;
  final height = width * spec.aspect;
  final feetY = startHorizonY + (spec.startFeetY - startHorizonY) * f;
  final centerX = spec.vanishX + (spec.startCenterX - spec.vanishX) * f;
  return RecedePose(
    width: width,
    height: height,
    left: centerX - width / 2,
    top: feetY - height,
  );
}

/// 경찰 대기 화면에서 멀어지는 쥐 (robber/start/default/chase.svg, 248×243)
const policeWaitRecede = RecedeSpec(
  startWidth: 96,
  endWidth: 30,
  startFeetY: 464.7, // 그림자 뺀 그림의 발 — 예전 그림(그림자 포함 바닥 480)의 발과 같은 자리
  startCenterX: 168,
  vanishX: 295,
  aspect: 243 / 248,
);

/// 도둑 설명 화면에서 멀어지는 고양이 (police/start/default/chase.svg, 272×323)
const robberWaitRecede = RecedeSpec(
  startWidth: 92,
  endWidth: 30,
  startFeetY: 485.6, // 예전 그림(그림자 포함 바닥 494)의 발과 같은 자리
  startCenterX: 70,
  vanishX: 77,
  aspect: 323 / 272,
);
