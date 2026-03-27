/// 채팅 메시지 비속어 필터링 유틸리티
///
/// 부적절한 단어를 감지하고 마스킹 처리합니다.
/// 필터링 단어 목록은 추후 서버에서 동적으로 받아올 수 있습니다.
class ProfanityFilter {
  ProfanityFilter._();

  /// 필터링 대상 단어 목록
  ///
  /// TODO: 서버에서 필터링 단어 목록을 동적으로 로드하는 기능 추가
  static const List<String> _blockedWords = [
    // 욕설/비하
    '시발', '씨발', 'ㅅㅂ', 'ㅆㅂ', '씹', '병신', 'ㅂㅅ',
    '지랄', 'ㅈㄹ', '개새끼', '새끼', 'ㅅㅋ',
    '꺼져', '닥쳐', '죽어',
    // 비하/차별
    '장애인', '찐따', '쪼다',
    // 스팸 키워드
    '돈벌기', '부업추천', '카톡추가',
  ];

  /// 메시지에서 비속어를 '***'로 마스킹
  ///
  /// [message] 원본 메시지
  /// Returns 필터링된 메시지
  static String filter(String message) {
    var filtered = message;
    for (final word in _blockedWords) {
      if (filtered.contains(word)) {
        filtered = filtered.replaceAll(word, '***');
      }
    }
    return filtered;
  }
}
