import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/repositories/community_reaction_repository.dart';
import '../datasources/community_remote_datasource.dart';

/// `CommunityReactionRepository` 구현체
///
/// 댓글을 `CommunityCommentRepositoryImpl`로 분리한 것과 같은 이유로 게시글
/// CRUD와 갈라 둔다 — 응답 계약도 실패 처리도 다르다.
class CommunityReactionRepositoryImpl implements CommunityReactionRepository {
  CommunityReactionRepositoryImpl(this._dataSource);

  final CommunityRemoteDataSource _dataSource;

  @override
  Future<void> like(int postId) => _toggle(
    () => _dataSource.likePost(postId),
    alreadyInDesiredState: 'ALREADY_LIKED',
    message: '좋아요를 등록하는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityReactionGeneric',
  );

  @override
  Future<void> unlike(int postId) => _toggle(
    () => _dataSource.unlikePost(postId),
    alreadyInDesiredState: 'LIKE_NOT_FOUND',
    message: '좋아요를 취소하는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityReactionGeneric',
  );

  @override
  Future<void> scrap(int postId) => _toggle(
    () => _dataSource.scrapPost(postId),
    alreadyInDesiredState: 'ALREADY_SCRAPPED',
    message: '스크랩을 등록하는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityReactionGeneric',
  );

  @override
  Future<void> unscrap(int postId) => _toggle(
    () => _dataSource.unscrapPost(postId),
    alreadyInDesiredState: 'SCRAP_NOT_FOUND',
    message: '스크랩을 취소하는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityReactionGeneric',
  );

  /// 토글 한 번. [alreadyInDesiredState] 코드만 성공으로 삼킨다.
  ///
  /// 삼키는 이유: 그 코드가 온다는 것은 서버가 이미 사용자가 원한 상태라는
  /// 뜻이다. 실패로 올리면 화면이 하트를 되돌리며 "실패했어요"를 띄우는데
  /// 서버에는 반응이 남아 있다 — 화면과 서버가 어긋난 채로 사용자에게
  /// 거짓말하는 최악의 조합이다.
  ///
  /// 상태 코드가 아니라 errorCode로 판정한다. 409·404는 다른 이유로도 오고
  /// (예: `POST_NOT_FOUND`), 그건 삼키면 안 된다.
  ///
  /// 카운트는 여기서 알 수 없다 — 토글 응답에 본문이 없다. 낙관적 갱신이 해 둔
  /// ±1을 그대로 두고 정확한 값은 다음 조회에서 맞춘다.
  Future<void> _toggle(
    Future<void> Function() call, {
    required String alreadyInDesiredState,
    required String message,
    required String messageKey,
  }) async {
    try {
      await call();
    } on DioException catch (e) {
      final mapped = DioExceptionHandler.handle(e);
      if (mapped.code == alreadyInDesiredState) return;
      throw mapped;
    } catch (e) {
      throw ServerException(
        message: message,
        messageKey: messageKey,
        originalException: e,
      );
    }
  }
}
