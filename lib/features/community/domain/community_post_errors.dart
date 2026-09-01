import '../../../core/errors/app_exception.dart';

/// 서버가 "그 글 없다"(404 `POST_NOT_FOUND`)고 답했는지.
///
/// 다른 사용자가 먼저 지운 글을 열거나 만졌을 때의 신호다. 백엔드는 조회·수정·
/// 상태 변경·삭제 **모든** 경로에서 같은 코드를 주므로(api-docs.json), 화면은 이
/// 하나만 보고 판단하면 된다.
///
/// 이 경우 재시도는 영원히 실패한다 — 화면은 "다시 시도" 대신 그 글을 목록에서
/// 걷어내고 사용자를 목록으로 돌려보내야 한다. 사용자에게 보일 문구는
/// `error_message_mapper`가 같은 코드로 이미 매핑해 둔
/// `errorCodePostNotFound`("이미 삭제된 모집글이에요")다.
bool isCommunityPostGone(Object error) =>
    error is AppException && error.code == 'POST_NOT_FOUND';
