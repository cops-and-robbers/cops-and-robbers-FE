// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_branch_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBranchIndexHash() =>
    r'94d1bab05b98646610bd120e50551a60f2109bd1';

/// 현재 선택된 바텀 네비 브랜치 인덱스.
///
/// `MainScaffold`가 브랜치 전환을 감지해 발행하고, 탭 화면이 "내가 다시 보이게
/// 됐다"를 판정하는 데 쓴다. 상세·검색처럼 셸 **위에** 뜨는 화면은 이 값을
/// 바꾸지 않으므로, 그런 이동에는 반응하지 않는다 — 글 하나를 오래 읽고 나와도
/// 목록이 초기화되지 않는 것이 이 신호를 고른 이유다.
///
/// 앱 셸이 살아 있는 동안 유지된다. 셸이 쓰고 탭 화면이 읽는 값이라 그 사이
/// 리스너가 잠깐 비어도 0으로 되돌아가면 안 된다.
///
/// Copied from [CurrentBranchIndex].
@ProviderFor(CurrentBranchIndex)
final currentBranchIndexProvider =
    NotifierProvider<CurrentBranchIndex, int>.internal(
      CurrentBranchIndex.new,
      name: r'currentBranchIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentBranchIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentBranchIndex = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
