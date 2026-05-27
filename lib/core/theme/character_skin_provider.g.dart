// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_skin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$characterSkinHash() => r'55983440378313d9172f734a814964757d900214';

/// 글로벌 캐릭터 스킨 상태.
///
/// - `'default'` (초기값) — PR #376 신규 캐릭터
/// - `'classic'` — 이스터에그로 발견하는 클래식 캐릭터
///
/// `keepAlive: true` 로 앱 프로세스 라이프타임 동안 유지된다.
/// 영속 저장은 하지 않으므로 앱 재시작 시 자연스럽게 default 로 복귀.
///
/// ```dart
/// final skinId = ref.watch(characterSkinProvider);
/// ref.read(characterSkinProvider.notifier).toggle();
/// ```
///
/// Copied from [CharacterSkin].
@ProviderFor(CharacterSkin)
final characterSkinProvider = NotifierProvider<CharacterSkin, String>.internal(
  CharacterSkin.new,
  name: r'characterSkinProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$characterSkinHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CharacterSkin = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
