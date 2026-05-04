import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/notice_remote_datasource.dart';
import '../../data/repositories/notice_repository_impl.dart';
import '../../domain/entities/notice_entity.dart';
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
    // fetchPage(액션 메서드)에서는 read 사용 — Riverpod 표준.
    return ref
        .watch(noticeRepositoryProvider)
        .getNotices(page: 0, size: _pageSize);
  }

  /// 지정 페이지로 이동.
  ///
  /// [page]는 0-based.
  /// 호출 측에서 로딩 팝업/스낵바를 트리거한다(`ref.listen` 패턴).
  Future<void> fetchPage(int page) async {
    state = AsyncValue<NoticePageEntity>.loading().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref
          .read(noticeRepositoryProvider)
          .getNotices(page: page, size: _pageSize),
    );
  }
}
