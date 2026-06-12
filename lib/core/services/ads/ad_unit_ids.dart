import 'dart:io';

import 'package:flutter/foundation.dart';

/// AdMob 광고 단위 ID 모음
///
/// 디버그 빌드에서는 반드시 구글 공식 테스트 ID를 사용한다.
/// (실제 ID로 개발 중 노출/클릭 시 무효 트래픽 → AdMob 계정 정지 사유)
/// ID는 비밀이 아니므로(출시 바이너리에서 추출 가능한 공개 식별자) 코드에 직접 둔다.
class AdUnitIds {
  AdUnitIds._();

  /// 게임 종료 전면 광고
  static String get gameEndInterstitial {
    if (kDebugMode) {
      // 구글 공식 테스트 전면 광고 ID (https://developers.google.com/admob/android/test-ads, /ios/test-ads)
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    return Platform.isIOS
        ? 'ca-app-pub-7675755123462739/9546763667'
        : 'ca-app-pub-7675755123462739/6466138906';
  }
}
