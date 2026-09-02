import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_exception_handler.dart';
import '../../domain/entities/community_address_entity.dart';
import '../../domain/entities/community_notification_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/entities/community_sort_option.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/community_notification_model.dart';
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
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    required String countryCode,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? keyword,
    double? latitude,
    double? longitude,
  }) {
    // 거리순이 아닌데 좌표를 실으면 400이다 — 호출자가 항상 넘기더라도
    // 여기서 걸러 낸다 (DEC-0021 조항 주석: 좌표는 DISTANCE에 한해 허용).
    final isDistance = sort == CommunitySortOption.distance;

    return _guard(
      () async {
        final res = await _dataSource.getPosts(
          cursor: cursor,
          size: size,
          scope: scope.queryValue,
          countryCode: countryCode,
          sort: sort.wireValue,
          keyword: keyword,
          latitude: isDistance ? latitude : null,
          longitude: isDistance ? longitude : null,
        );
        return CommunityPostPageEntity(
          items: res.content.map(_toEntity).toList(),
          nextCursor: res.cursor.nextCursor,
          hasNext: res.cursor.hasNext,
        );
      },
      message: '모집글을 불러오는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostsLoadGeneric',
    );
  }

  @override
  Future<String?> getCountryCode({
    required double latitude,
    required double longitude,
  }) {
    return _guard(
      () async {
        final res = await _dataSource.getCountry(
          latitude: latitude,
          longitude: longitude,
        );
        return res.countryCode;
      },
      message: '국가를 확인하는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostsLoadGeneric',
    );
  }

  @override
  Future<CommunityAddressEntity> getAddress({
    required double latitude,
    required double longitude,
  }) {
    return _guard(
      () async {
        final res = await _dataSource.getAddress(
          latitude: latitude,
          longitude: longitude,
        );
        return CommunityAddressEntity(
          region: res.region,
          address: res.address,
          countryCode: res.countryCode,
        );
      },
      message: '주소를 불러오는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityAddressLoadGeneric',
    );
  }

  @override
  Future<CommunityPostEntity> createPost({
    required String title,
    required String content,
    required DateTime meetingAt,
    required double latitude,
    required double longitude,
    required String placeName,
    required int maxParticipants,
  }) {
    return _guard(
      () async => _toEntity(
        await _dataSource.createPost(
          CommunityPostWriteRequestModel(
            title: title,
            content: content,
            meetingAt: meetingAt,
            location: CommunityLocationRequestModel(
              latitude: latitude,
              longitude: longitude,
              placeName: placeName,
            ),
            maxParticipants: maxParticipants,
          ),
        ),
      ),
      message: '모집글을 등록하는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostCreateGeneric',
    );
  }

  @override
  Future<CommunityPostEntity> getPost(int postId) {
    return _guard(
      () async => _toEntity(await _dataSource.getPost(postId)),
      message: '모집글을 불러오는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostsLoadGeneric',
    );
  }

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
  }) {
    return _guard(
      () async => _toEntity(
        await _dataSource.updatePost(
          postId,
          CommunityPostWriteRequestModel(
            title: title,
            content: content,
            meetingAt: meetingAt,
            location: CommunityLocationRequestModel(
              latitude: latitude,
              longitude: longitude,
              placeName: placeName,
            ),
            maxParticipants: maxParticipants,
          ),
        ),
      ),
      message: '모집글을 수정하는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostUpdateGeneric',
    );
  }

  @override
  Future<void> deletePost(int postId) {
    return _guard(
      () => _dataSource.deletePost(postId),
      message: '모집글을 삭제하는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostDeleteGeneric',
    );
  }

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) {
    return _guard(
      () async => _toEntity(
        await _dataSource.updateStatus(
          postId,
          CommunityPostStatusRequestModel(status: status.wireValue),
        ),
      ),
      message: '모집 상태를 바꾸는 중 오류가 발생했습니다',
      messageKey: 'errorCommunityPostStatusGeneric',
    );
  }

  @override
  Future<CommunityScrapPageEntity> getScraps({
    int? cursor,
    required int size,
  }) => _guard(
    () async {
      final page = await _dataSource.getScraps(cursor: cursor, size: size);
      return CommunityScrapPageEntity(
        items: page.content.map(_toEntity).toList(),
        nextCursor: page.nextCursor,
        hasNext: page.hasNext,
      );
    },
    message: '스크랩 목록을 불러오는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityScrapsLoadGeneric',
  );

  @override
  Future<CommunityNotificationPageEntity> getNotifications({
    int? cursor,
    required int size,
  }) => _guard(
    () async {
      final page = await _dataSource.getNotifications(
        cursor: cursor,
        size: size,
      );
      return CommunityNotificationPageEntity(
        items: page.content.map(_toNotificationEntity).toList(),
        nextCursor: page.nextCursor,
        hasNext: page.hasNext,
      );
    },
    message: '알림 목록을 불러오는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityNotificationsLoadGeneric',
  );

  @override
  Future<int> getUnreadNotificationCount() => _guard(
    () async => (await _dataSource.getUnreadNotificationCount()).unreadCount,
    message: '안 읽은 알림 개수를 불러오는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityNotificationUnreadCountLoadGeneric',
  );

  @override
  Future<void> readNotifications() => _guard(
    () => _dataSource.readNotifications(),
    message: '알림 읽음 처리 중 오류가 발생했습니다',
    messageKey: 'errorCommunityNotificationReadGeneric',
  );

  @override
  Future<void> updateNotificationSetting({
    required int postId,
    required bool commentNotificationsEnabled,
    required bool replyNotificationsEnabled,
  }) => _guard(
    () => _dataSource.updateNotificationSetting(
      postId,
      CommunityPostNotificationSettingRequestModel(
        commentNotificationsEnabled: commentNotificationsEnabled,
        replyNotificationsEnabled: replyNotificationsEnabled,
      ),
    ),
    message: '게시글 알림 설정을 바꾸는 중 오류가 발생했습니다',
    messageKey: 'errorCommunityPostNotificationUpdateGeneric',
  );

  CommunityNotificationEntity _toNotificationEntity(
    CommunityNotificationResponseModel m,
  ) => CommunityNotificationEntity(
    id: m.id,
    type: communityNotificationTypeFromWire(m.type),
    communityPostId: m.communityPostId,
    postTitle: m.postTitle,
    content: m.content,
    read: m.read,
    createdAt: m.createdAt.toLocal(),
  );

  /// DataSource 호출을 감싸 예외를 `AppException` 계열로 통일한다.
  ///
  /// `DioException`은 상태코드별 예외로, 그 외(JSON 파싱 실패, 알 수 없는 status
  /// 문자열 등)는 [messageKey]를 단 `ServerException`으로 바꾼다. UI는
  /// `error is AppException`을 가정하므로 raw 예외가 새어나가지 않게 차단한다.
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
        // 접지 않고 둘 다 넘긴다 — 화면이 "장소명 + 지역"으로 병기한다(DEC-0015).
        placeName: m.location.placeName,
        region: m.location.region,
        address: m.location.address,
        maxParticipants: m.maxParticipants,
        currentParticipants: m.currentParticipants,
        likeCount: m.likeCount,
        isLiked: m.liked,
        scrapCount: m.scrapCount,
        isScrapped: m.scrapped,
        chatJoined: m.chatJoined ?? false,
        notificationSetting: _toNotificationSetting(m.notificationSettings),
        status: communityPostStatusFromWire(m.status),
      );

  CommunityPostNotificationSetting? _toNotificationSetting(
    CommunityPostNotificationSettingModel? m,
  ) => m == null
      ? null
      : CommunityPostNotificationSetting(
          commentNotificationsEnabled: m.commentNotificationsEnabled,
          replyNotificationsEnabled: m.replyNotificationsEnabled,
        );
}
