// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_game_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameRecordDirHash() => r'35a7e9c924ad1bc7111a532a17b23d61691e6ed5';

/// 진행 중 게임 기록 파일을 두는 디렉터리 (테스트에서 임시 디렉터리로 교체).
///
/// Copied from [gameRecordDir].
@ProviderFor(gameRecordDir)
final gameRecordDirProvider = FutureProvider<Directory>.internal(
  gameRecordDir,
  name: r'gameRecordDirProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameRecordDirHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameRecordDirRef = FutureProviderRef<Directory>;
String _$playerGameRecordNotifierHash() =>
    r'7cb0478039baaee75632de8d686e04c76edd2ae2';

/// 게임 중 내 활동(경로·거리)을 누적하는 Notifier.
///
/// `keepAlive: true` — 게임 종료 정리 시 위치 스트림이 결과 다이얼로그보다 먼저
/// 종료되므로(game_page `_prepareGameOverPresentation`), 누적값을 이 provider에
/// 담아 다이얼로그가 읽을 수 있게 한다.
///
/// 누적과 동시에 기기 파일에도 남겨, 앱이 죽었다가 같은 게임에 재진입하면 [begin]이 복원한다.
///
/// Copied from [PlayerGameRecordNotifier].
@ProviderFor(PlayerGameRecordNotifier)
final playerGameRecordNotifierProvider =
    NotifierProvider<PlayerGameRecordNotifier, PlayerGameRecord>.internal(
      PlayerGameRecordNotifier.new,
      name: r'playerGameRecordNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerGameRecordNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayerGameRecordNotifier = Notifier<PlayerGameRecord>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
