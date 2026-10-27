import 'package:cops_and_robbers/core/network/models/page_info_model.dart';
import 'package:cops_and_robbers/features/notice/data/datasources/notice_remote_datasource.dart';
import 'package:cops_and_robbers/features/notice/data/models/notice_response_model.dart';
import 'package:cops_and_robbers/features/notice/domain/entities/notice_entity.dart';
import 'package:cops_and_robbers/features/notice/presentation/providers/notice_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lastSeenKey = 'notice_last_seen_id';

/// HTTP 경계만 가짜로 둔다 — 저장소·매핑은 실제 코드를 탄다.
class _FakeNoticeRemoteDataSource implements NoticeRemoteDataSource {
  _FakeNoticeRemoteDataSource({
    this.ids = const [],
    this.pinnedIds = const {},
    this.error,
  });

  final List<int> ids;
  final Set<int> pinnedIds;
  final Object? error;

  @override
  Future<NoticeListResponseModel> getNotices({
    required int page,
    required int size,
    required String language,
    String? category,
  }) async {
    if (error != null) throw error!;
    final items = [
      for (final id in ids)
        NoticeResponseModel.fromJson({
          'id': id,
          'title': '공지 $id',
          'content': '본문',
          'pinned': pinnedIds.contains(id),
          'createdAt': '2026-10-27T10:00:00+09:00',
          'updatedAt': '2026-10-27T10:00:00+09:00',
        }),
    ];
    return NoticeListResponseModel(
      content: items,
      page: PageInfoModel(
        size: size,
        number: page,
        totalElements: items.length,
        totalPages: 1,
      ),
    );
  }
}

NoticeEntity _notice(int id, {bool pinned = false}) => NoticeEntity(
  id: id,
  title: '공지 $id',
  content: '본문',
  pinned: pinned,
  createdAt: DateTime(2026, 10, 27),
);

ProviderContainer _container(_FakeNoticeRemoteDataSource fake) {
  final container = ProviderContainer(
    overrides: [noticeRemoteDataSourceProvider.overrideWithValue(fake)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 첫 페이지 모양: 오래된 고정 공지(3)가 맨 위, 그 아래 새 행사 공지(12)와 지난 공지(11).
  final firstPage = _FakeNoticeRemoteDataSource(
    ids: [3, 12, 11],
    pinnedIds: {3},
  );

  test(
    'hasNewNotice_is_true_when_new_notice_posted_under_pinned_notice_since_last_visit',
    () async {
      SharedPreferences.setMockInitialValues({_lastSeenKey: 11});
      final container = _container(firstPage);

      expect(await container.read(hasNewNoticeProvider.future), isTrue);
    },
  );

  test('hasNewNotice_is_false_after_markSeen_with_first_page', () async {
    SharedPreferences.setMockInitialValues({_lastSeenKey: 11});
    final container = _container(firstPage);
    await container.read(hasNewNoticeProvider.future);

    await container.read(hasNewNoticeProvider.notifier).markSeen([
      _notice(3, pinned: true),
      _notice(12),
      _notice(11),
    ]);

    expect(container.read(hasNewNoticeProvider).valueOrNull, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(_lastSeenKey), 12);
  });

  // 운영자가 이미 본 최신 공지(12)를 지워 목록에 11까지만 남았다 — 본 기록은 내리지 않는다.
  test(
    'markSeen_keeps_higher_saved_id_when_newest_notice_was_deleted',
    () async {
      SharedPreferences.setMockInitialValues({_lastSeenKey: 12});
      final container = _container(
        _FakeNoticeRemoteDataSource(ids: [3, 11], pinnedIds: {3}),
      );
      await container.read(hasNewNoticeProvider.future);

      await container.read(hasNewNoticeProvider.notifier).markSeen([
        _notice(3, pinned: true),
        _notice(11),
      ]);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(_lastSeenKey), 12);
    },
  );

  // 지하철 안처럼 연결이 끊긴 상태로 홈에 들어왔다 — 배지를 지어내지 않는다.
  test('hasNewNotice_is_not_true_when_notice_request_fails_offline', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _container(
      _FakeNoticeRemoteDataSource(
        error: DioException(
          requestOptions: RequestOptions(path: '/api/notices'),
          type: DioExceptionType.connectionError,
        ),
      ),
    );

    await expectLater(
      container.read(hasNewNoticeProvider.future),
      throwsA(anything),
    );
    expect(container.read(hasNewNoticeProvider).valueOrNull, isNot(isTrue));
  });
}
