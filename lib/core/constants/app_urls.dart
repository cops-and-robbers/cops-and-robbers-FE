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

  /// 앱 웹뷰가 여는 크레딧(만든 사람들) 주소
  ///
  /// 법적 문서와 같은 임베드 방식이지만 화면에 문장이 거의 없어(이름·역할)
  /// 언어를 나누지 않은 단일 주소입니다. 인원이 바뀌면 웹 배포만으로 갱신됩니다.
  static const String credits = '$site/credits/embed';
}
