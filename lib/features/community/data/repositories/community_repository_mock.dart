import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/community_address_entity.dart';
import '../../domain/entities/community_post_entity.dart';
import '../../domain/entities/community_post_status.dart';
import '../../domain/entities/community_scope.dart';
import '../../domain/repositories/community_repository.dart';

/// 모집글 Repository의 임시 구현 (메모리)
///
/// ponytail: 실서버에 볼 만한 글이 쌓이기 전까지 화면을 확인하려는 대역이다.
/// 목록·상세·수정·삭제·상태 변경이 한 목록 위에서 일관되게 동작한다 — 목록만
/// 목이고 상세는 실서버면 카드를 눌렀을 때 없는 글이라 404가 난다.
///
/// 끄는 법: `communityRepositoryProvider`의 [kUseMockCommunityPosts]를 false로.
/// 그러면 목록·상세 전부 실서버를 탄다. 이 파일과 플래그만 지우면 흔적이 없다.
class CommunityRepositoryMock implements CommunityRepository {
  /// 실서버 왕복처럼 보이게 하는 지연. 0이면 로딩 UI가 그려지는지 확인할 수 없다.
  static const _latency = Duration(milliseconds: 300);

  /// 한 페이지 크기. 커서 페이지네이션 흉내에만 쓴다.
  static const _pageSize = 10;

  /// 목 데이터가 전부 국내라 국가 판별 결과도 고정이다.
  static const _countryCode = 'KR';

  /// 현재 목록. 삭제·수정이 이 리스트를 바꾼다.
  late final List<CommunityPostEntity> _posts = List.generate(40, (i) {
    final template = _templates[i % _templates.length];
    return template.copyWith(id: i + 1, title: '${template.title} (${i + 1})');
  });

  @override
  Future<CommunityPostPageEntity> getPosts({
    String? cursor,
    required int size,
    CommunityScope scope = CommunityScope.all,
    String? countryCode,
    double? latitude,
    double? longitude,
  }) async {
    await Future.delayed(_latency);

    // 백엔드가 scope=NEARBY/MINE에 아직 400을 주므로 목도 빈 목록으로 맞춘다.
    if (scope != CommunityScope.all) {
      return const CommunityPostPageEntity(
        items: [],
        nextCursor: null,
        hasNext: false,
        countryCode: _countryCode,
      );
    }

    // 커서는 "여기까지 봤다"는 offset을 문자열로 흉내 낸다. 실제 서버 커서는
    // 불투명한 문자열이라 파싱하지 않지만, 목에서는 자리를 알아야 잘라 준다.
    final start = int.tryParse(cursor ?? '') ?? 0;
    final end = (start + _pageSize).clamp(0, _posts.length);
    final hasNext = end < _posts.length;

    return CommunityPostPageEntity(
      items: _posts.sublist(start, end),
      nextCursor: hasNext ? '$end' : null,
      hasNext: hasNext,
      countryCode: _countryCode,
    );
  }

  @override
  Future<CommunityAddressEntity> getAddress({
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(_latency);
    // 실제 역지오코딩은 못 하므로 좌표를 그대로 노출한다 — 핀을 옮길 때마다 값이
    // 바뀌어야 화면이 갱신되는지 눈으로 확인할 수 있다.
    final coords =
        '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    return CommunityAddressEntity(
      region: '서울특별시 광진구 화양동',
      address: '서울특별시 광진구 화양동 ($coords)',
      countryCode: _countryCode,
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
  }) async {
    await Future.delayed(_latency);
    final created = CommunityPostEntity(
      // 실서버는 id를 서버가 채운다. 목에서는 현재 최대 id + 1로 충돌만 피한다.
      id: _posts.fold(0, (max, p) => p.id > max ? p.id : max) + 1,
      // 작성자 메뉴(수정·삭제·상태 변경)를 바로 확인할 수 있게 "내 글"로 만든다.
      writerId: 0,
      title: title,
      content: content,
      meetingAt: meetingAt,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      region: '서울특별시 광진구 화양동',
      maxParticipants: maxParticipants,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime.now(),
      currentParticipants: 1,
      likeCount: 0,
      bookmarkCount: 0,
    );
    _posts.insert(0, created);
    return created;
  }

  @override
  Future<CommunityPostEntity> getPost(int postId) async {
    await Future.delayed(_latency);
    final found = _posts.where((p) => p.id == postId);
    if (found.isEmpty) {
      throw const ServerException(
        message: '모집글을 찾을 수 없습니다',
        messageKey: 'errorCommunityPostsLoadFailed',
      );
    }
    return found.first;
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
  }) async {
    await Future.delayed(_latency);
    final index = _indexOf(postId);
    final updated = _posts[index].copyWith(
      title: title,
      content: content,
      meetingAt: meetingAt,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      maxParticipants: maxParticipants,
    );
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePost(int postId) async {
    await Future.delayed(_latency);
    _posts.removeAt(_indexOf(postId));
  }

  @override
  Future<CommunityPostEntity> updateStatus({
    required int postId,
    required CommunityPostStatus status,
  }) async {
    await Future.delayed(_latency);
    final index = _indexOf(postId);
    final updated = _posts[index].copyWith(status: status);
    _posts[index] = updated;
    return updated;
  }

  int _indexOf(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) {
      throw const ServerException(
        message: '모집글을 찾을 수 없습니다',
        messageKey: 'errorCommunityPostsLoadFailed',
      );
    }
    return index;
  }

  /// 요일 라벨은 meetingAt에서 계산된다 — 2026년이라 9/8=화, 9/10=목, 9/12=토로
  /// 시안과 맞는다.
  ///
  /// `writerId: 0`인 글이 하나 있어야 "내 글" 메뉴(수정·삭제·상태 변경)를 눈으로
  /// 확인할 수 있다. 로그인 사용자 id와 겹칠 일이 없는 값이면 전부 남의 글로만
  /// 보인다.
  static final List<CommunityPostEntity> _templates = [
    CommunityPostEntity(
      id: 1,
      writerId: 1,
      title: '나랑 경도하자!!!!dadsasdasdasdasdasdasd!',
      content: '세종대 정문 앞에서 만나요. 처음이어도 규칙은 현장에서 알려드립니다.',
      meetingAt: DateTime(2026, 9, 10, 18, 0),
      latitude: 37.55,
      longitude: 127.07,
      maxParticipants: 10,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime(2026, 8, 16),
      placeName: '세종대학교 정문',
      region: '서울특별시 광진구 군자동',
      currentParticipants: 2,
      likeCount: 6000,
      bookmarkCount: 3,
    ),
    CommunityPostEntity(
      id: 2,
      writerId: 2,
      title: '초보도 환영. 웰컴. 누구나',
      content: '백운호수 한 바퀴 돌면서 가볍게 할 거예요. 편한 신발 신고 오세요.',
      meetingAt: DateTime(2026, 9, 12, 19, 30),
      latitude: 37.35,
      longitude: 126.98,
      maxParticipants: 10,
      status: CommunityPostStatus.recruiting,
      createdAt: DateTime(2026, 8, 16),
      placeName: '백운호수 무민공원',
      region: '경기도 의왕시 학의동',
      currentParticipants: 6,
      likeCount: 5,
      bookmarkCount: 2,
    ),
    CommunityPostEntity(
      id: 3,
      writerId: 3,
      title: '번개로 경도하실 분',
      content: '어린이대공원 정문에서 봐요. 인원 다 차면 마감합니다.',
      meetingAt: DateTime(2026, 9, 12, 20, 0),
      latitude: 37.55,
      longitude: 127.08,
      maxParticipants: 15,
      status: CommunityPostStatus.completed,
      createdAt: DateTime(2026, 8, 10),
      placeName: '어린이대공원 정문',
      region: '서울특별시 광진구 능동',
      currentParticipants: 15,
      likeCount: 13,
      bookmarkCount: 20,
    ),
    CommunityPostEntity(
      id: 4,
      writerId: 0,
      title: '세종대생 모여라~',
      content: '점심시간에 짧게 한 판. 학생회관 앞에서 모입니다.',
      meetingAt: DateTime(2026, 9, 8, 12, 0),
      latitude: 37.55,
      longitude: 127.07,
      maxParticipants: 15,
      status: CommunityPostStatus.completed,
      createdAt: DateTime(2026, 8, 5),
      placeName: '세종대 학생회관 앞',
      region: '서울특별시 광진구 군자동',
      currentParticipants: 15,
      likeCount: 13,
      bookmarkCount: 20,
    ),
  ];
}
