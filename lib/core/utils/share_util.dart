import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// 텍스트를 네이티브 공유 시트로 공유하는 유틸리티
///
/// OS 기본 공유 시트를 열어 [text]를 다른 앱으로 공유합니다.
/// [subject]는 이메일 등에서 제목으로 사용됩니다.
/// 플랫폼 예외 발생 시 디버그 로그를 남기고 무시합니다.
Future<void> shareText(String text, {String? subject}) async {
  try {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  } catch (e) {
    debugPrint('공유 실패: $e');
  }
}
