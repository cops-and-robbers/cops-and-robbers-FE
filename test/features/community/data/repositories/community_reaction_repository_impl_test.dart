import 'package:cops_and_robbers/core/errors/app_exception.dart';
import 'package:cops_and_robbers/features/community/data/datasources/community_remote_datasource.dart';
import 'package:cops_and_robbers/features/community/data/repositories/community_reaction_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 토글 4종은 응답 본문이 없다. 확인할 것은 "어떤 실패를 성공으로 삼키는가"다.
void main() {
  late _RecordingDataSource dataSource;
  late CommunityReactionRepositoryImpl repository;

  setUp(() {
    dataSource = _RecordingDataSource();
    repository = CommunityReactionRepositoryImpl(dataSource);
  });

  DioException http(int status, String code) => DioException(
    requestOptions: RequestOptions(path: '/'),
    response: Response(
      requestOptions: RequestOptions(path: '/'),
      statusCode: status,
      data: {'errorCode': code, 'message': 'x'},
    ),
    type: DioExceptionType.badResponse,
  );

  test('swallows_409_when_post_is_already_liked', () async {
    dataSource.error = http(409, 'ALREADY_LIKED');

    // 사용자가 원한 최종 상태가 이미 그것이다 — 실패로 올리면 화면이 하트를
    // 되돌리는데 서버에는 좋아요가 남아 어긋난다.
    await expectLater(repository.like(1), completes);
  });

  test('swallows_404_when_like_was_not_there', () async {
    dataSource.error = http(404, 'LIKE_NOT_FOUND');

    await expectLater(repository.unlike(1), completes);
  });

  test('swallows_409_when_post_is_already_scrapped', () async {
    dataSource.error = http(409, 'ALREADY_SCRAPPED');

    await expectLater(repository.scrap(1), completes);
  });

  test('swallows_404_when_scrap_was_not_there', () async {
    dataSource.error = http(404, 'SCRAP_NOT_FOUND');

    await expectLater(repository.unscrap(1), completes);
  });

  test('rethrows_other_failures_as_app_exception', () async {
    dataSource.error = http(404, 'POST_NOT_FOUND');

    await expectLater(repository.like(1), throwsA(isA<AppException>()));
  });

  test('does_not_swallow_a_mismatched_code_on_the_same_status', () async {
    // 409인데 스크랩 코드가 오면 좋아요 요청의 정답이 아니다. 흡수 조건은
    // 상태 코드가 아니라 errorCode다.
    dataSource.error = http(409, 'ALREADY_SCRAPPED');

    await expectLater(repository.like(1), throwsA(isA<AppException>()));
  });
}

/// 토글 4종만 덮는 스텁. [error]가 있으면 던지고 없으면 성공한다.
class _RecordingDataSource implements CommunityRemoteDataSource {
  DioException? error;
  final calls = <String>[];

  Future<void> _run(String name) {
    calls.add(name);
    if (error != null) return Future.error(error!);
    return Future.value();
  }

  @override
  Future<void> likePost(int postId) => _run('like');
  @override
  Future<void> unlikePost(int postId) => _run('unlike');
  @override
  Future<void> scrapPost(int postId) => _run('scrap');
  @override
  Future<void> unscrapPost(int postId) => _run('unscrap');

  // 이 테스트가 안 쓰는 나머지 엔드포인트. 실수로 불리면 NoSuchMethodError로
  // 드러나는 편이 조용히 null을 돌려주는 것보다 낫다.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
