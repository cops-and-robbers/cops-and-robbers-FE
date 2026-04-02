import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 채팅 알림 on/off — 게임당 1회성 인메모리 상태
///
/// true: 진동 + 프리뷰 카드 표시 (기본값)
/// false: 진동 X, 프리뷰 X (unread count만 증가)
/// 게임 종료 시 invalidate → 자동 true 복귀
final chatNotificationEnabledProvider = StateProvider<bool>((ref) => true);
