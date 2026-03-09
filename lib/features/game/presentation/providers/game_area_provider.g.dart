// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_area_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameAreaHash() => r'4bbe03329d51b172385f0800f54efdd74923b44d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 게임 맵 영역 FutureProvider
///
/// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
/// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
///
/// Copied from [gameArea].
@ProviderFor(gameArea)
const gameAreaProvider = GameAreaFamily();

/// 게임 맵 영역 FutureProvider
///
/// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
/// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
///
/// Copied from [gameArea].
class GameAreaFamily extends Family<AsyncValue<GameAreaModel>> {
  /// 게임 맵 영역 FutureProvider
  ///
  /// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
  /// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
  ///
  /// Copied from [gameArea].
  const GameAreaFamily();

  /// 게임 맵 영역 FutureProvider
  ///
  /// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
  /// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
  ///
  /// Copied from [gameArea].
  GameAreaProvider call(int gameId) {
    return GameAreaProvider(gameId);
  }

  @override
  GameAreaProvider getProviderOverride(covariant GameAreaProvider provider) {
    return call(provider.gameId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameAreaProvider';
}

/// 게임 맵 영역 FutureProvider
///
/// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
/// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
///
/// Copied from [gameArea].
class GameAreaProvider extends AutoDisposeFutureProvider<GameAreaModel> {
  /// 게임 맵 영역 FutureProvider
  ///
  /// `GET /api/games/{gameId}/area` 응답을 캐시합니다.
  /// GamePage 진입 시 트리거하여 플레이그라운드·감옥 원을 지도에 표시합니다.
  ///
  /// Copied from [gameArea].
  GameAreaProvider(int gameId)
    : this._internal(
        (ref) => gameArea(ref as GameAreaRef, gameId),
        from: gameAreaProvider,
        name: r'gameAreaProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameAreaHash,
        dependencies: GameAreaFamily._dependencies,
        allTransitiveDependencies: GameAreaFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  GameAreaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
  }) : super.internal();

  final int gameId;

  @override
  Override overrideWith(
    FutureOr<GameAreaModel> Function(GameAreaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameAreaProvider._internal(
        (ref) => create(ref as GameAreaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GameAreaModel> createElement() {
    return _GameAreaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameAreaProvider && other.gameId == gameId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameAreaRef on AutoDisposeFutureProviderRef<GameAreaModel> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _GameAreaProviderElement
    extends AutoDisposeFutureProviderElement<GameAreaModel>
    with GameAreaRef {
  _GameAreaProviderElement(super.provider);

  @override
  int get gameId => (origin as GameAreaProvider).gameId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
