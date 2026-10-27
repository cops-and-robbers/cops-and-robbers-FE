// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noticeRemoteDataSourceHash() =>
    r'e042c7ab2dedefb61a1f06c1b07ac9e074dd3989';

/// `NoticeRemoteDataSource` Provider (Retrofit)
///
/// Copied from [noticeRemoteDataSource].
@ProviderFor(noticeRemoteDataSource)
final noticeRemoteDataSourceProvider =
    AutoDisposeProvider<NoticeRemoteDataSource>.internal(
      noticeRemoteDataSource,
      name: r'noticeRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$noticeRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoticeRemoteDataSourceRef =
    AutoDisposeProviderRef<NoticeRemoteDataSource>;
String _$noticeRepositoryHash() => r'b8e881aab7fde51dece5f7c05cf60fe46b0261b3';

/// `NoticeRepository` Provider
///
/// Copied from [noticeRepository].
@ProviderFor(noticeRepository)
final noticeRepositoryProvider = AutoDisposeProvider<NoticeRepository>.internal(
  noticeRepository,
  name: r'noticeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$noticeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoticeRepositoryRef = AutoDisposeProviderRef<NoticeRepository>;
String _$selectedNoticeCategoryHash() =>
    r'6b749d9d3f2fadacf45391e181dae73bbf197f8f';

/// 현재 선택된 카테고리 필터
///
/// `NoticesNotifier.build()`가 이 값을 watch 하므로, 값이 바뀌면 build가
/// 재실행되며 자동으로 0페이지부터 다시 조회된다 — 페이지 리셋 로직이 따로 없다.
/// 칩 UI는 이 provider를 직접 watch 해서 네트워크 응답을 기다리지 않고
/// 탭 즉시 선택 표시를 바꾼다.
///
/// Copied from [SelectedNoticeCategory].
@ProviderFor(SelectedNoticeCategory)
final selectedNoticeCategoryProvider =
    AutoDisposeNotifierProvider<
      SelectedNoticeCategory,
      NoticeCategory
    >.internal(
      SelectedNoticeCategory.new,
      name: r'selectedNoticeCategoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedNoticeCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedNoticeCategory = AutoDisposeNotifier<NoticeCategory>;
String _$noticesNotifierHash() => r'e42d1d2ab4705cc5c5a37ce106507b139a12c15a';

/// 공지사항 목록 페이지 상태 관리 Notifier
///
/// 페이지 사이즈는 10으로 고정. 페이지 변경 시 `copyWithPrevious`로 이전
/// 데이터를 보존해 화면 깜빡임을 방지한다.
///
/// Copied from [NoticesNotifier].
@ProviderFor(NoticesNotifier)
final noticesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NoticesNotifier,
      NoticePageEntity
    >.internal(
      NoticesNotifier.new,
      name: r'noticesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$noticesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NoticesNotifier = AutoDisposeAsyncNotifier<NoticePageEntity>;
String _$hasNewNoticeHash() => r'977b8a799690162e735fe8f1d1d86d3e34098b33';

/// 홈 공지 아이콘의 "새 공지" 배지
///
/// 서버는 읽음 상태를 들지 않는다 — 공지는 전원에게 같은 내용이라 앱이 마지막으로
/// 본 공지 id만 기기에 저장해 비교한다(브레인 DEC-0038). 재설치하면 저장값이 사라져
/// 옛 공지에 배지가 한 번 뜨는 것은 감수한다.
///
/// 홈이 셸에서 계속 watch하므로 `keepAlive`를 쓰지 않는다. 다시 받는 시점은 홈이
/// 정한다(탭 복귀·앱 복귀).
///
/// Copied from [HasNewNotice].
@ProviderFor(HasNewNotice)
final hasNewNoticeProvider =
    AutoDisposeAsyncNotifierProvider<HasNewNotice, bool>.internal(
      HasNewNotice.new,
      name: r'hasNewNoticeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$hasNewNoticeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HasNewNotice = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
