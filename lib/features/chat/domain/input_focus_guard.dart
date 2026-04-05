import 'package:flutter/foundation.dart';

/// 입력 필드 포커스 가드
///
/// 사용자가 직접 탭한 포커스와 프로그래매틱 포커스 복원을 구분합니다.
/// 다이얼로그 닫힘 등으로 포커스가 자동 복원될 때 시트가
/// 의도치 않게 확장되는 것을 방지합니다.
class InputFocusGuard {
  InputFocusGuard({required this.onAllowFocus, required this.onRejectFocus});

  /// 사용자 탭에 의한 정상 포커스 시 호출
  final VoidCallback onAllowFocus;

  /// 프로그래매틱 포커스 복원 감지 시 호출
  final VoidCallback onRejectFocus;

  bool _userTapped = false;
  bool get isUserTapped => _userTapped;

  /// 사용자가 입력 필드를 직접 탭했을 때 호출
  void markUserTapped() {
    _userTapped = true;
  }

  /// 포커스 획득 시 호출 — 탭 여부에 따라 허용/거부 판단
  void handleFocusGained() {
    if (_userTapped) {
      onAllowFocus();
    } else {
      onRejectFocus();
    }
  }

  /// 포커스 상실 시 호출 — 탭 플래그 리셋
  void handleFocusLost() {
    _userTapped = false;
  }
}
