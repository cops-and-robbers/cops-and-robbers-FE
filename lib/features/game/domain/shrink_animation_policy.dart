/// 구역이 줄어드는 순간의 연출 (#668)
enum ShrinkAnimation {
  /// 원만 바뀐다
  none,

  /// 기울여 넓게 본 뒤 줄어들고 원래 카메라로 (1~3차)
  tilt,

  /// tilt + 구역 중심을 축으로 한 바퀴 (4차·최종)
  tiltSpin,
}

/// 모든 폰에서 동시에 화면을 잠깐 뺏으므로, 하던 일을 끊는 상황이면 연출하지 않는다.
/// 체포 QR(스캐너·내 QR)·채팅·참가자 목록이 열려 있거나 앱이 보이지 않으면 원만 바꾼다.
/// OS "동작 줄이기"를 켠 사람은 어지럽지 않게 돌리지 않는다.
ShrinkAnimation shrinkAnimationFor({
  required int stage,
  required bool appVisible,
  required bool qrOpen,
  required bool chatOpen,
  required bool participantsOpen,
  required bool reduceMotion,
}) {
  if (!appVisible || qrOpen || chatOpen || participantsOpen) {
    return ShrinkAnimation.none;
  }
  return stage >= 4 && !reduceMotion
      ? ShrinkAnimation.tiltSpin
      : ShrinkAnimation.tilt;
}
