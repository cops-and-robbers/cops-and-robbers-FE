import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/community_post_model.dart';
import '../models/community_wire.dart';

/// `CommunityRepository` 구현체
///
/// DataSource 호출 → DTO를 도메인 Entity로 변환.
/// `DioException`은 `DioExceptionHandler`로 일괄 변환한다.
class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource _dataSource;

  CommunityRepositoryImpl(this._dataSource);

  @override
  Future<CommunityPostPageEntity> getPosts({
    required int page,
    required int size,
    CommunityScope scope = CommunityScope.all,
  }) async {
    try {
      final res = await _dataSource.getPosts(
        page: page,
        size: size,
        scope: scope.queryValue,
      );
      return CommunityPostPageEntity(
        items: res.content.map(_toEntity).toList(),
        currentPage: res.page.number,
        totalPages: res.page.totalPages,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    } catch (e) {
      // Dio 외 예외(JSON 파싱 실패, 알 수 없는 status 문자열 등) → AppException으로 통일.
      // UI는 `error is AppException`을 가정하므로 raw 예외가 새어나가지 않게 차단.
      throw ServerException(
        message: '모집글을 불러오는 중 오류가 발생했습니다',
        messageKey: 'errorCommunityPostsLoadGeneric',
        originalException: e,
      );
    }
  }

  CommunityPostEntity _toEntity(CommunityPostResponseModel m) =>
      CommunityPostEntity(
        id: m.id,
        writerId: m.writerId,
        title: m.title,
        content: m.content,
        // 백엔드가 timezone suffix(+09:00)를 포함해 직렬화하므로 json_serializable이
        // UTC DateTime으로 파싱한다. UI는 단말 local 기준 표기를 기대하므로
        // Entity 경계에서 local로 정규화한다.
        meetingAt: m.meetingAt.toLocal(),
        createdAt: m.createdAt.toLocal(),
        latitude: m.location.latitude,
        longitude: m.location.longitude,
        address: m.location.address,
        maxParticipants: m.maxParticipants,
        currentParticipants: m.currentParticipants,
        likeCount: m.likeCount,
        bookmarkCount: m.bookmarkCount,
        status: communityPostStatusFromWire(m.status),
      );
}
