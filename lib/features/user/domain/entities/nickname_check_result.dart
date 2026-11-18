/// 닉네임 중복 확인 결과
///
/// 서버 응답의 `code`를 앱이 쓰는 세 갈래로 좁힌 값이다.
enum NicknameCheckResult {
  /// 사용 가능
  available,

  /// 이미 사용 중
  duplicated,

  /// 금칙어 포함
  bannedWord,
}
