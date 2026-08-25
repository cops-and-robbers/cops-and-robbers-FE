/// 법적 문서 4종
///
/// 문서 하나에 웹 주소 하나가 대응합니다. 예전에는 호출부가 JSON 경로와 외부 링크
/// 주소를 따로 넘겨서, 짝이 어긋나도 아무도 못 잡는 구조였습니다. 이제 이 값 하나에서
/// 주소를 만듭니다.
enum LegalDoc {
  /// 서비스 이용약관
  terms('terms'),

  /// 개인정보 처리방침
  privacy('privacy'),

  /// 위치정보 이용약관
  location('location'),

  /// 마케팅 정보 수신 동의
  marketing('marketing');

  const LegalDoc(this.slug);

  /// 웹 주소에 들어가는 조각
  ///
  /// dongsim-web 의 `content/legal/<로케일>/<slug>.json` 과 같은 값입니다.
  /// 바꾸면 웹 쪽 라우트도 같이 바뀌어야 합니다.
  final String slug;
}
