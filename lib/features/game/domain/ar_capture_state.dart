import 'dart:math';

/// 가속도 값으로 구한 후면 카메라의 위아래 각도 (라디안, 수평 0, 위쪽 양수)
///
/// 폰을 세우면 중력이 y축, 눕히면 z축으로 쏠리는 것을 이용한다.
double cameraElevation({required double y, required double z}) => atan2(-z, y);

/// AR 포착 판정 상태 (회전 각도는 라디안, 왼쪽·위쪽이 양수)
///
/// 그림을 현실에 고정하지 않으므로 나침반이나 ARCore 없이
/// 화면을 연 순간의 방향을 기준으로 자이로 회전만 누적한다.
class ArCaptureState {
  const ArCaptureState({
    required this.targetYaw,
    required this.targetPitch,
    this.yaw = 0,
    this.pitch = 0,
    this.heldSeconds = 0,
    this.hasEntered = false,
  });

  /// 실기기에서 조정할 값: 틀 안으로 인정하는 반경과 유지 시간
  static const double frameRadius = 0.14;
  static const double holdDuration = 3;

  /// 실기기에서 조정할 값: 틀을 벗어났을 때 게이지가 줄어드는 속도 (유지 1초당 0.5초)
  static const double holdDecayRate = 0.5;

  /// 움직이는 그림이 폰을 세운 높이에서 벗어나는 한계 (약 8도)
  static const double targetPitchLimit = 0.14;

  /// 카메라가 수평보다 이만큼 아래면 폰을 세우라고 안내한다 (약 30도)
  static const double loweredElevation = -0.52;

  final double targetYaw;
  final double targetPitch;
  final double yaw;
  final double pitch;
  final double heldSeconds;

  /// 한 번이라도 틀에 들어왔는지. 그 전까지 그림은 멈춰 있다.
  final bool hasEntered;

  /// 화면 가운데 기준 그림의 좌우 각도 (음수면 왼쪽에 보임)
  ///
  /// 한 바퀴 넘게 돌아도 가까운 쪽으로 보이도록 -π~π로 접는다.
  double get yawOffset {
    final wrapped = (yaw - targetYaw + pi) % (2 * pi);
    return wrapped - pi;
  }

  /// 화면 가운데 기준 그림의 위아래 각도 (음수면 위에 보임)
  double get pitchOffset => pitch - targetPitch;

  bool get inFrame =>
      sqrt(yawOffset * yawOffset + pitchOffset * pitchOffset) < frameRadius;

  bool get isCaptured => heldSeconds >= holdDuration;

  bool get isPhoneLowered => pitch < loweredElevation;

  /// 누적된 자이로 오차를 실제 카메라 각도 쪽으로 조금씩 되돌린 새 상태를 돌려준다.
  /// 걸을 때의 흔들림이 그대로 튀지 않도록 한 번에 2%만 반영한다.
  ArCaptureState correctPitch(double elevation) => ArCaptureState(
    targetYaw: targetYaw,
    targetPitch: targetPitch,
    yaw: yaw,
    pitch: pitch + (elevation - pitch) * 0.02,
    heldSeconds: heldSeconds,
    hasEntered: hasEntered,
  );

  /// 자이로 이벤트 하나만큼 진행한 새 상태를 돌려준다.
  ///
  /// 그림은 처음 틀에 들어온 뒤부터 움직인다. 틀을 벗어나면 게이지가
  /// 서서히 줄어서, 손이 한 번 흔들렸다고 처음부터 다시 하지 않는다.
  ArCaptureState advance({
    required double yawRate,
    required double pitchRate,
    required double dt,
    double targetYawRate = 0,
    double targetPitchRate = 0,
  }) {
    if (isCaptured) return this;

    final next = ArCaptureState(
      targetYaw: hasEntered ? targetYaw + targetYawRate * dt : targetYaw,
      targetPitch: hasEntered
          ? (targetPitch + targetPitchRate * dt).clamp(
              -targetPitchLimit,
              targetPitchLimit,
            )
          : targetPitch,
      yaw: yaw + yawRate * dt,
      pitch: pitch + pitchRate * dt,
    );
    return ArCaptureState(
      targetYaw: next.targetYaw,
      targetPitch: next.targetPitch,
      yaw: next.yaw,
      pitch: next.pitch,
      heldSeconds: next.inFrame
          ? heldSeconds + dt
          : max(0, heldSeconds - dt * holdDecayRate),
      hasEntered: hasEntered || next.inFrame,
    );
  }
}
