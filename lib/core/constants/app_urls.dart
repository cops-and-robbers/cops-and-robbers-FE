import 'dart:io';

import 'legal_doc.dart';

/// 앱 외부 링크 URL 상수
///
/// 스토어 다운로드, 법적 문서 등 웹 주소를 관리합니다.
class AppUrls {
  AppUrls._();

  /// 스토어 다운로드 URL (플랫폼별 분기)
  static String get storeUrl {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.elipair.copsandrobbers';
    }
    return 'https://apps.apple.com/us/app/id6756843948';
  }

  /// 공식 사이트
  static const String site = 'https://copsandrobbers.app';

  /// 사이트의 게임 소개 페이지
  ///
  /// 온보딩 마지막 장에서 "더 자세히"로 연결한다. 로케일 접두사 규칙은
  /// [legalDocument] 와 같다 — ko 는 접두사 없음, 그 밖은 `/<언어>`.
  static String gameGuide(String languageCode) {
    final language = _legalLanguages.contains(languageCode)
        ? languageCode
        : 'ko';
    final prefix = language == 'ko' ? '' : '/$language';
    return '$site$prefix/game';
  }

  /// 사이트가 법적 문서를 제공하는 언어
  ///
  /// 앱 지원 언어와 3:3으로 맞습니다. 그 밖의 로케일이 들어오면 한국어로 떨어뜨립니다.
  static const Set<String> _legalLanguages = {'ko', 'ja', 'en'};

  /// 앱 웹뷰가 여는 법적 문서 주소
  ///
  /// 사이트에 노출되는 `/terms` 와 경로가 다릅니다. 앱 화면과 붙어야 해서 헤더·푸터
  /// 없는 별도 뷰를 쓰고, 그래서 주소도 갈라 두었습니다. 사이트 쪽 robots.txt 가
  /// 이 경로를 색인에서 막습니다.
  static String legalDocument(LegalDoc doc, String languageCode) {
    final language = _legalLanguages.contains(languageCode)
        ? languageCode
        : 'ko';
    final prefix = language == 'ko' ? '' : '/$language';
    return '$site$prefix/legal/${doc.slug}/embed';
  }
}
