/// Bug Repository 인터페이스
///
/// 도메인 레이어에서 버그 제보 기능의 계약을 정의합니다.
abstract class BugRepository {
  /// 버그 제보
  ///
  /// JWT 필수. 서버 스펙: [content] 최대 1000자(빈 문자열 허용).
  /// UI 단에서는 빈 입력을 차단하므로 호출 측 정책에 따라 0자 호출은 발생하지 않는다.
  ///
  /// Throws:
  /// - [AppException]: API 에러 (네트워크/인증/서버 등)
  Future<void> reportBug({required String content});
}
