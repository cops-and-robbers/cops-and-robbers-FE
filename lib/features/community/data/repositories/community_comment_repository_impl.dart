import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/community_interaction_entity.dart';
import '../../domain/repositories/community_comment_repository.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/community_comment_model.dart';

/// `CommunityCommentRepository` 구현체
class CommunityCommentRepositoryImpl implements CommunityCommentRepository {
  CommunityCommentRepositoryImpl(this._dataSource);

  final CommunityRemoteDataSource _dataSource;

  @override
  Future<List<CommunityCommentEntity>> getComments(int postId) => _guard(
    () async {
      final all = <CommunityCommentEntity>[];
      int? cursor;

      while (true) {
        final page = await _dataSource.getComments(postId, cursor: cursor);
        all.addAll(page.content.map(_toEntity));

        final next = page.nextCursor;
        // 커서가 안 움직이는데 hasNext만 참인 응답이 오면 여기서 영원히 돈다.
        if (!page.hasNext || next == null || next == cursor) break;
        cursor = next;
      }

      return all;
    },
    message: '댓글을 불러오는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityCommentsLoadGeneric',
  );

  CommunityCommentEntity _toEntity(CommunityCommentResponseModel m) =>
      CommunityCommentEntity(
        id: m.id,
        parentId: m.parentId,
        writerId: m.writerId,
        writerNickname: m.writerNickname,
        writerProfileIconId: m.writerProfileIcon,
        content: m.content,
        deleted: m.deleted,
        // 게시글과 같이 기기 시간대로 맞춘다 — 안 하면 UTC로 파싱된 값이
        // 그대로 떠서 한국 시간보다 9시간 이르게 보인다.
        createdAt: m.createdAt.toLocal(),
        replies: m.replies.map(_toEntity).toList(),
      );

  @override
  Future<CommunityCommentEntity> addComment({
    required int postId,
    required String content,
    int? parentId,
  }) => _guard(
    () async {
      final created = await _dataSource.createComment(
        postId,
        CommunityCommentCreateRequestModel(
          parentId: parentId,
          content: content,
        ),
      );
      return _toEntity(created);
    },
    message: '댓글을 등록하는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityCommentCreateGeneric',
  );

  @override
  Future<void> deleteComment(int commentId) => _guard(
    () => _dataSource.deleteComment(commentId),
    message: '댓글을 삭제하는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityCommentDeleteGeneric',
  );

  /// DataSource 호출을 감싸 예외를 `AppException` 계열로 통일한다.
  ///
  /// 화면은 `error is AppException`을 가정하므로 raw 예외가 새어나가지 않게 한다.
  Future<T> _guard<T>(
    Future<T> Function() call, {
    required String message,
    required String messageKey,
  }) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(
        message: message,
        messageKey: messageKey,
        originalException: e,
      );
    }
  }
}
