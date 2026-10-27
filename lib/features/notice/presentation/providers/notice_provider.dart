import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/i18n/locale_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notice_remote_datasource.dart';
import '../../data/repositories/notice_repository_impl.dart';
import '../../domain/entities/notice_category.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/new_notice.dart';
import '../../domain/repositories/notice_repository.dart';

part 'notice_provider.g.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// `NoticeRemoteDataSource` Provider (Retrofit)
@riverpod
NoticeRemoteDataSource noticeRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return NoticeRemoteDataSource(dio);
}

// ============================================================================
// Domain Layer Providers
// ============================================================================

/// `NoticeRepository` Provider
@riverpod
NoticeRepository noticeRepository(Ref ref) {
  return NoticeRepositoryImpl(ref.watch(noticeRemoteDataSourceProvider));
}

// ============================================================================
// Presentation Layer Providers
// ============================================================================

/// 현재 선택된 카테고리 필터
///
/// `NoticesNotifier.build()`가 이 값을 watch 하므로, 값이 바뀌면 build가
/// 재실행되며 자동으로 0페이지부터 다시 조회된다 — 페이지 리셋 로직이 따로 없다.
/// 칩 UI는 이 provider를 직접 watch 해서 네트워크 응답을 기다리지 않고
/// 탭 즉시 선택 표시를 바꾼다.
@riverpod
class SelectedNoticeCategory extends _$SelectedNoticeCategory {
  @override
  NoticeCategory build() => NoticeCategory.all;

  void select(NoticeCategory category) => state = category;
}

/// 공지사항 목록 페이지 상태 관리 Notifier
///
/// 페이지 사이즈는 10으로 고정. 페이지 변경 시 `copyWithPrevious`로 이전
/// 데이터를 보존해 화면 깜빡임을 방지한다.
@riverpod
class NoticesNotifier extends _$NoticesNotifier {
  static const _pageSize = 10;

  @override
  FutureOr<NoticePageEntity> build() {
    // build() 안에서는 watch 사용 (선언적 의존성).
    // 카테고리나 앱 언어가 바뀌면 이 build가 재실행되어 0페이지부터 다시 조회된다.
    // fetchPage(액션 메서드)에서는 read 사용 — Riverpod 표준.
    final category = ref.watch(selectedNoticeCategoryProvider);
    final language = ref.watch(
      appLocaleProvider.select((s) => s.locale.languageCode),
    );
    return ref
        .watch(noticeRepositoryProvider)
        .getNotices(
          page: 0,
          size: _pageSize,
          language: language,
          category: category,
        );
  }

  /// 지정 페이지로 이동.
  ///
  /// [page]는 0-based. 카테고리는 현재 선택값을 그대로 유지한다.
  /// 호출 측에서 로딩 팝업/스낵바를 트리거한다(`ref.listen` 패턴).
  Future<void> fetchPage(int page) async {
    state = AsyncValue<NoticePageEntity>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref
          .read(noticeRepositoryProvider)
          .getNotices(
            page: page,
            size: _pageSize,
            language: ref.read(appLocaleProvider).locale.languageCode,
            category: ref.read(selectedNoticeCategoryProvider),
          ),
    );
  }
}

/// 홈 공지 아이콘의 "새 공지" 배지
///
/// 서버는 읽음 상태를 들지 않는다 — 공지는 전원에게 같은 내용이라 앱이 마지막으로
/// 본 공지 id만 기기에 저장해 비교한다(브레인 DEC-0038). 재설치하면 저장값이 사라져
/// 옛 공지에 배지가 한 번 뜨는 것은 감수한다.
///
/// 홈이 셸에서 계속 watch하므로 `keepAlive`를 쓰지 않는다. 다시 받는 시점은 홈이
/// 정한다(탭 복귀·앱 복귀).
@riverpod
class HasNewNotice extends _$HasNewNotice {
  static const _lastSeenKey = 'notice_last_seen_id';
  static const _pageSize = 10;

  @override
  Future<bool> build() async {
    // 언어는 read — id는 언어와 무관해 언어를 바꿨다고 다시 받을 이유가 없다.
    final page = await ref
        .watch(noticeRepositoryProvider)
        .getNotices(
          page: 0,
          size: _pageSize,
          language: ref.read(appLocaleProvider).locale.languageCode,
        );
    final prefs = await SharedPreferences.getInstance();
    return isNewerNotice(
      newestId: newestNoticeId(page.items),
      lastSeenId: prefs.getInt(_lastSeenKey),
    );
  }

  /// 공지 첫 페이지(카테고리 전체)를 봤을 때 부른다.
  ///
  /// 저장값은 내리지 않는다 — 최신 공지가 삭제돼 목록의 최대 id가 작아져도 이미 본
  /// 기록은 그대로다.
  Future<void> markSeen(List<NoticeEntity> items) async {
    final newestId = newestNoticeId(items);
    if (newestId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final lastSeenId = prefs.getInt(_lastSeenKey);
    if (lastSeenId == null || newestId > lastSeenId) {
      await prefs.setInt(_lastSeenKey, newestId);
    }
    state = const AsyncData(false);
  }
}
