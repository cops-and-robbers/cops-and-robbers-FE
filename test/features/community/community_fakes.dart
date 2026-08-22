import 'package:cops_and_robbers/features/community/domain/entities/community_address_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_entity.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_post_status.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_scope.dart';
import 'package:cops_and_robbers/features/community/domain/entities/community_sort_option.dart';
import 'package:cops_and_robbers/features/community/domain/repositories/community_repository.dart';

/// 목록만 검증하는 가짜 Repository가 상세·작성·수정·삭제·상태변경·주소조회까지
/// 구현하지 않아도 되게 하는 스텁.
///
/// 호출되면 예외를 던진다 — 목록 테스트가 상세 API를 건드리면 조용히 통과하는
/// 대신 그 자리에서 드러나야 한다.
///
/// 사용: `class _Fake with CommunityRepositoryDetailStubs implements CommunityRepository`
/// 반대 방향 스텁 — 목록을 쓰지 않는 테스트(장소 선택 등)를 위한 것.
///
/// 사용: `class _Fake with CommunityRepositoryListStubs, CommunityRepositoryDetailStubs`
mixin CommunityRepositoryListStubs implements CommunityRepository {
  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) => throw UnimplementedError('이 테스트는 목록 조회를 쓰지 않는다');
}

mixin CommunityRepositoryDetailStubs implements CommunityRepository {
  @override
  Future<CommunityPostEntity> getPost(int postId) =>
      throw UnimplementedError('이 테스트는 상세 조회를 쓰지 않는다');

  @override
  Future<CommunityPostEntity> updatePost({
    required int postId,
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  }) => throw UnimplementedError('이 테스트는 수정을 쓰지 않는다');

  @override
  Future<CommunityPostEntity> createPost({
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  }) => throw UnimplementedError('이 테스트는 작성을 쓰지 않는다');

  @override
  Future<CommunityAddressEntity> getAddress({
    required double latitude,
    required double longitude,
  }) => throw UnimplementedError('이 테스트는 주소 조회를 쓰지 않는다');

  @override
  Future<String?> getCountryCode({
    required double latitude,
    required double longitude,
  }) => throw UnimplementedError('이 테스트는 국가 조회를 쓰지 않는다');

  @override
  Future<void> deletePost(int postId) =>
      throw UnimplementedError('이 테스트는 삭제를 쓰지 않는다');

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) => throw UnimplementedError('이 테스트는 상태 변경을 쓰지 않는다');
}
