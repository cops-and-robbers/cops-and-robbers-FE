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
String _$noticesNotifierHash() => r'c40ecd535922c0195c51fdd5eef3f80f29999194';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
