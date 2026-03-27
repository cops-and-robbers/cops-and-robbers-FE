/// 채팅 신고 카테고리
enum ReportCategory {
  bait('낚시/놀람/도배'),
  abuse('욕설/비하'),
  impersonation('사칭/사기'),
  spam('광고/스팸'),
  exploit('부정 행위/버그 악용'),
  teamSabotage('팀 사기 저하'),
  other('기타(직접 작성)');

  const ReportCategory(this.label);

  /// UI에 표시할 한글 라벨
  final String label;
}
