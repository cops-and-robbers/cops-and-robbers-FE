import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 외부 URL을 브라우저에서 여는 유틸리티
///
/// [urlString]을 외부 브라우저에서 엽니다.
/// 열 수 없는 URL인 경우 디버그 로그를 남기고 `false`를 반환합니다.
Future<bool> launchExternalUrl(String urlString) async {
  final uri = Uri.parse(urlString);
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  debugPrint('Cannot launch URL: $urlString');
  return false;
}
