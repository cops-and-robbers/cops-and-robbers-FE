import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/data/datasources/community_remote_datasource.dart';
import 'package:cops_and_robbers/features/community/data/models/community_comment_model.dart';
import 'package:cops_and_robbers/features/community/data/repositories/community_comment_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 시스템 경계(HTTP)만 대역으로 세운다 — Repository는 진짜 코드가 돈다.
class _FakeCommunityRemoteDataSource implements CommunityRemoteDataSource {
  _FakeCommunityRemoteDataSource({this.pages = const [], this.createdToReturn});

  /// 커서 순서대로 돌려줄 페이지들.
  final List<CommunityCommentListResponseModel> pages;
  final CommunityCommentResponseModel? createdToReturn;

  final List<int?> requestedCursors = [];
  CommunityCommentCreateRequestModel? lastCreateRequest;
  int? lastCreatePostId;
  int? deletedCommentId;
  Object? errorToThrow;

  @override
  Future<CommunityCommentListResponseModel> getComments(
    int postId, {
    int? cursor,
    int? size,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    requestedCursors.add(cursor);
    return pages[requestedCursors.length - 1];
  }

  @override
  Future<CommunityCommentResponseModel> createComment(
    int postId,
    CommunityCommentCreateRequestModel body,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastCreatePostId = postId;
    lastCreateRequest = body;
    return createdToReturn!;
  }

  @override
  Future<void> deleteComment(int commentId) async {
    if (errorToThrow != null) throw errorToThrow!;
    deletedCommentId = commentId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _dioError(int statusCode) => DioException(
  requestOptions: RequestOptions(path: '/api/community-posts/1/comments'),
  response: Response(
    requestOptions: RequestOptions(path: '/api/community-posts/1/comments'),
    statusCode: statusCode,
    data: {
      'title': 'error',
      'status': statusCode,
      'detail': 'msg',
      'instance': '/api/community-posts/1/comments',
    },
  ),
  type: DioExceptionType.badResponse,
);

CommunityCommentResponseModel _comment(int id, {int? parentId}) =>
    CommunityCommentResponseModel(
      id: id,
      parentId: parentId,
      writerId: 7,
      writerNickname: '날쌘도둑',
      writerProfileIcon: 2,
      content: '댓글 $id',
      createdAt: DateTime.utc(2026, 8, 27, 1, id),
    );

void main() {
  group('CommunityCommentRepositoryImpl.getComments', () {
    // 서버는 한 번에 최대 50건만 준다. 화면에는 "더 보기"가 없고 댓글 수 라벨이
    // 받은 만큼만 세므로, 끝까지 따라가지 않으면 라벨이 조용히 거짓말을 한다.
    test('hasNext가 false가 될 때까지 커서를 따라가며 모은다', () async {
      final fake = _FakeCommunityRemoteDataSource(
        pages: [
          CommunityCommentListResponseModel(
            content: [_comment(1), _comment(2)],
            nextCursor: 2,
            hasNext: true,
          ),
          CommunityCommentListResponseModel(
            content: [_comment(3)],
            nextCursor: null,
            hasNext: false,
          ),
        ],
      );
      final repo = CommunityCommentRepositoryImpl(fake);

      final comments = await repo.getComments(42);

      expect(comments.map((c) => c.id), [1, 2, 3]);
      expect(fake.requestedCursors, [null, 2], reason: '첫 페이지는 커서 없이 요청한다');
    });
  });

  // 게시글은 Entity 변환에서 toLocal()을 하는데 댓글만 빠져 있었다 — 서버가
  // 오프셋을 붙여 보내면 Dart가 UTC로 정규화해, 한국에서 9시간 이르게 보인다.
  group('CommunityCommentRepositoryImpl 시간대', () {
    test('작성 시각을 기기 시간대로 맞춰 돌려준다', () async {
      final utc = DateTime.utc(2026, 8, 27, 1);
      final fake = _FakeCommunityRemoteDataSource(
        pages: [
          CommunityCommentListResponseModel(
            content: [
              CommunityCommentResponseModel(
                id: 1,
                content: '댓글',
                createdAt: utc,
              ),
            ],
            hasNext: false,
          ),
        ],
      );
      final repo = CommunityCommentRepositoryImpl(fake);

      final comments = await repo.getComments(42);

      expect(comments.single.createdAt.isUtc, isFalse);
      expect(comments.single.createdAt, utc.toLocal());
    });
  });

  group('CommunityCommentRepositoryImpl.addComment', () {
    test('답글이면 parentId를 실어 보내고 생성된 댓글을 돌려준다', () async {
      final fake = _FakeCommunityRemoteDataSource(
        createdToReturn: _comment(10, parentId: 1),
      );
      final repo = CommunityCommentRepositoryImpl(fake);

      final created = await repo.addComment(
        postId: 42,
        content: '답글이에요',
        parentId: 1,
      );

      expect(fake.lastCreatePostId, 42);
      expect(fake.lastCreateRequest?.parentId, 1);
      expect(fake.lastCreateRequest?.content, '답글이에요');
      expect(created.id, 10);
      expect(created.parentId, 1);
    });
  });

  group('CommunityCommentRepositoryImpl.deleteComment', () {
    test('받은 댓글 id로 삭제를 호출한다', () async {
      final fake = _FakeCommunityRemoteDataSource();
      final repo = CommunityCommentRepositoryImpl(fake);

      await repo.deleteComment(10);

      expect(fake.deletedCommentId, 10);
    });
  });

  // 화면은 `error is AppException`을 가정하고 문구를 고른다. raw DioException이
  // 새어 나가면 사용자는 서버가 준 사유 대신 일반 문구만 보게 된다.
  test('세 경로 모두 DioException을 AppException으로 바꾼다', () async {
    final repo = CommunityCommentRepositoryImpl(
      _FakeCommunityRemoteDataSource()..errorToThrow = _dioError(400),
    );

    expect(() => repo.getComments(42), throwsA(isA<AppException>()));
    expect(
      () => repo.addComment(postId: 42, content: '댓글'),
      throwsA(isA<AppException>()),
    );
    expect(() => repo.deleteComment(10), throwsA(isA<AppException>()));
  });
}
