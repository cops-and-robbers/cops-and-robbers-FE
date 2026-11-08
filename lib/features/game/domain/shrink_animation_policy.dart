/// 구역이 줄어드는 순간의 연출 (#668)
enum ShrinkAnimation {
  /// 원만 바뀐다
  none,

  /// 기울여 넓게 본 뒤 줄어들고 원래 카메라로 (1~4차 모두)
  tilt,
}

/// 모든 폰에서 동시에 화면을 잠깐 뺏으므로, 하던 일을 끊는 상황이면 연출하지 않는다.
/// 체포 QR(스캐너·내 QR)·채팅·참가자 목록이 열려 있거나 앱이 보이지 않으면 원만 바꾼다.
ShrinkAnimation shrinkAnimationFor({
  required int stage,
  required bool appVisible,
  required bool qrOpen,
  required bool chatOpen,
  required bool participantsOpen,
}) {
  if (!appVisible || qrOpen || chatOpen || participantsOpen) {
    return ShrinkAnimation.none;
  }
  // 4차에 하던 한 바퀴 회전은 뺐다 — 구글 지도 animateCamera가 끝나기 전에 돌아와 90°씩 나눈
  // 명령이 복귀 명령에 덮였다(실기기). 모든 차수를 1~3차와 같게 둔다
  return ShrinkAnimation.tilt;
}
