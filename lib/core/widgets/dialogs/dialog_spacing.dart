import 'package:flutter/material.dart';

/// 다이얼로그 내부 섹션 간 간격 오버라이드
///
/// 각 필드가 null이면 AppDialog의 기본값을 사용합니다.
/// 특정 다이얼로그에서만 간격을 조절할 때 사용합니다.
///
/// **사용 예시:**
/// ```dart
/// AppDialog.show(
///   context: context,
///   title: '게임 규칙',
///   spacing: DialogSpacing(toContent: AppSpacing.vertical12),
///   customContent: Column(...),
/// );
/// ```
@immutable
class DialogSpacing {
  const DialogSpacing({
    this.avatarToTitle,
    this.titleToMessage,
    this.toContent,
    this.toButtons,
  });

  /// 아바타 <-> 타이틀 간격 (기본: AppSpacing.vertical16)
  final double? avatarToTitle;

  /// 타이틀 <-> 메시지 간격 (기본: AppSpacing.vertical12)
  final double? titleToMessage;

  /// 메시지/타이틀 <-> 커스텀 콘텐츠 간격
  /// (기본: message 있으면 AppSpacing.vertical12, 없으면 AppSpacing.vertical20)
  final double? toContent;

  /// 콘텐츠/메시지 <-> 버튼 간격 (기본: AppSpacing.vertical20)
  final double? toButtons;
}
