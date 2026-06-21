import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../deeplink/deeplink_constants.dart';

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

/// 초대 코드를 방 참가 딥링크 URL 로 변환.
///
/// `https://{host}/join/{code}` 형태이며, 공유 메시지와 대기방 QR 이 같은 형식을
/// 쓰도록 단일 소스로 둔다. host 는 딥링크 파서/스캐너와 [DeeplinkConstants.host]
/// 를 공유하므로 항상 일치한다.
String buildInviteDeeplink(String code) =>
    'https://${DeeplinkConstants.host}/join/$code';

/// 초대 코드를 딥링크 URL 과 함께 공유.
///
/// `"{shareMessage}\nhttps://copsnro66ers.site/join/{code}"` 형태로 OS 공유 시트 호출.
/// 받은 사람이 링크 클릭 → OS 가로채기 → 앱 자동 실행 (백엔드 .well-known/* 호스팅 전제).
///
/// 호출 측이 i18n 메시지를 전달해서 ARB 키를 한 곳에서 관리하지 않아도 되게 함.
Future<void> shareInviteCode(String code, String shareMessage) async {
  await shareText('$shareMessage\n${buildInviteDeeplink(code)}');
}

/// PNG 바이트를 임시 파일로 저장한 뒤 네이티브 공유 시트로 공유.
///
/// 플랫폼 예외 발생 시 디버그 로그를 남기고 무시한다(기존 [shareText] 패턴).
Future<void> shareImageBytes(
  Uint8List bytes, {
  String filename = 'cops_record.png',
}) async {
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  } catch (e) {
    debugPrint('이미지 공유 실패: $e');
  }
}

/// PNG 바이트를 사진 갤러리에 저장. 성공 여부를 반환한다(호출 측 스낵바 분기용).
Future<bool> saveImageBytesToGallery(
  Uint8List bytes, {
  String name = 'cops_record',
}) async {
  try {
    await Gal.putImageBytes(bytes, name: name);
    return true;
  } catch (e) {
    debugPrint('갤러리 저장 실패: $e');
    return false;
  }
}
