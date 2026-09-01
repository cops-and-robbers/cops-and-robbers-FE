/// 모집글 반응(좋아요·스크랩) Repository 인터페이스
///
/// 카운트와 내 반응은 게시글 응답에 실려 오므로 조회 메서드가 없다. 여기가
/// 맡는 것은 쓰기뿐이다.
///
/// 네 메서드 모두 "이미 그 상태였다"는 실패(409·404)를 던지지 않는다 —
/// 사용자가 원한 최종 상태가 이미 그것이라 성공과 구분할 이유가 없다.
/// 자세한 근거는 구현체 주석 참조.
abstract class CommunityReactionRepository {
  Future<void> like(int postId);
  Future<void> unlike(int postId);
  Future<void> scrap(int postId);
  Future<void> unscrap(int postId);
}
