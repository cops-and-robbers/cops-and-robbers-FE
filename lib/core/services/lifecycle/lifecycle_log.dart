import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lifecycle_log.freezed.dart';

/// 생명주기 상태 변화 로그
///
/// 앱의 생명주기 상태가 변경될 때마다 생성되며,
/// 상태와 변경 시각을 기록합니다.
@freezed
class LifecycleLog with _$LifecycleLog {
  const LifecycleLog._();

  /// 생명주기 로그 생성
  ///
  /// [state]: 생명주기 상태 (resumed, inactive, paused, detached)
  /// [timestamp]: 상태 변경 시각
  const factory LifecycleLog({
    required AppLifecycleState state,
    required DateTime timestamp,
  }) = _LifecycleLog;

  /// 상태에 대한 한글 설명
  ///
  /// UI에 표시할 때 사용합니다.
  String get stateDescription {
    switch (state) {
      case AppLifecycleState.resumed:
        return '포그라운드 (화면에 보임)';
      case AppLifecycleState.inactive:
        return '전환 중 (잠깐)';
      case AppLifecycleState.hidden:
        return '숨김 상태 (백그라운드 전환)';
      case AppLifecycleState.paused:
        return '백그라운드 진입';
      case AppLifecycleState.detached:
        return '앱 종료 직전';
    }
  }

  /// 상태에 대한 색상
  ///
  /// UI에서 상태를 시각적으로 구분할 때 사용합니다.
  Color get stateColor {
    switch (state) {
      case AppLifecycleState.resumed:
        return Colors.green;
      case AppLifecycleState.inactive:
        return Colors.orange;
      case AppLifecycleState.hidden:
        return Colors.blue;
      case AppLifecycleState.paused:
        return Colors.grey;
      case AppLifecycleState.detached:
        return Colors.red;
    }
  }

  /// 상태에 대한 아이콘
  ///
  /// UI에서 상태를 시각적으로 표현할 때 사용합니다.
  IconData get stateIcon {
    switch (state) {
      case AppLifecycleState.resumed:
        return Icons.check_circle;
      case AppLifecycleState.inactive:
        return Icons.change_circle;
      case AppLifecycleState.hidden:
        return Icons.visibility_off;
      case AppLifecycleState.paused:
        return Icons.pause_circle;
      case AppLifecycleState.detached:
        return Icons.cancel;
    }
  }

  /// 시간을 HH:MM:SS 형식으로 포맷
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
