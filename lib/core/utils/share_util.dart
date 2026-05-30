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

/// 초대 코드를 딥링크 URL 과 함께 공유.
///
/// `"{shareMessage}\nhttps://copsnro66ers.site/join/{code}"` 형태로 OS 공유 시트 호출.
/// 받은 사람이 링크 클릭 → OS 가로채기 → 앱 자동 실행 (백엔드 .well-known/* 호스팅 전제).
///
/// 호출 측이 i18n 메시지를 전달해서 ARB 키를 한 곳에서 관리하지 않아도 되게 함.
Future<void> shareInviteCode(String code, String shareMessage) async {
  final url = 'https://copsnro66ers.site/join/$code';
  await shareText('$shareMessage\n$url');
}
