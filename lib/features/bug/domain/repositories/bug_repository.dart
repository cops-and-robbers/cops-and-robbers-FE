/// Bug Repository 인터페이스
///
/// 도메인 레이어에서 버그 제보 기능의 계약을 정의합니다.
abstract class BugRepository {
  /// 버그 제보 (JWT 필수, 1~1000자)
  ///
  /// [content] 버그 내용
  ///
  /// Throws:
  /// - [AppException]: API 에러 (네트워크/인증/서버 등)
  Future<void> reportBug({required String content});
}
