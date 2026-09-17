// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameResultApiHash() => r'c4da19a6ab7db474966d1672034ab0540403f995';

/// GameResultApi Retrofit 인스턴스 Provider
///
/// Copied from [gameResultApi].
@ProviderFor(gameResultApi)
final gameResultApiProvider = AutoDisposeProvider<GameResultApi>.internal(
  gameResultApi,
  name: r'gameResultApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameResultApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameResultApiRef = AutoDisposeProviderRef<GameResultApi>;
String _$gameResultHash() => r'3b37621cd7c99e21ebf388e2130c63ccc2f3c513';

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

/// 게임 결과 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
/// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
/// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
///
/// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
/// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
///
/// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
/// UI 쪽에서 AsyncValue.error로 분기됩니다.
/// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
///
/// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
/// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
/// 세션당 gameResultId는 소수라 메모리 영향 미미.
///
/// Copied from [gameResult].
@ProviderFor(gameResult)
const gameResultProvider = GameResultFamily();

/// 게임 결과 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
/// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
/// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
///
/// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
/// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
///
/// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
/// UI 쪽에서 AsyncValue.error로 분기됩니다.
/// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
///
/// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
/// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
/// 세션당 gameResultId는 소수라 메모리 영향 미미.
///
/// Copied from [gameResult].
class GameResultFamily extends Family<AsyncValue<GameResultEntity>> {
  /// 게임 결과 조회 FutureProvider (family by gameResultId)
  ///
  /// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
  /// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
  /// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
  ///
  /// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
  /// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
  ///
  /// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
  /// UI 쪽에서 AsyncValue.error로 분기됩니다.
  /// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
  ///
  /// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
  /// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
  /// 세션당 gameResultId는 소수라 메모리 영향 미미.
  ///
  /// Copied from [gameResult].
  const GameResultFamily();

  /// 게임 결과 조회 FutureProvider (family by gameResultId)
  ///
  /// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
  /// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
  /// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
  ///
  /// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
  /// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
  ///
  /// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
  /// UI 쪽에서 AsyncValue.error로 분기됩니다.
  /// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
  ///
  /// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
  /// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
  /// 세션당 gameResultId는 소수라 메모리 영향 미미.
  ///
  /// Copied from [gameResult].
  GameResultProvider call(int gameResultId) {
    return GameResultProvider(gameResultId);
  }

  @override
  GameResultProvider getProviderOverride(
    covariant GameResultProvider provider,
  ) {
    return call(provider.gameResultId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameResultProvider';
}

/// 게임 결과 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
/// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
/// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
///
/// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
/// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
///
/// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
/// UI 쪽에서 AsyncValue.error로 분기됩니다.
/// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
///
/// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
/// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
/// 세션당 gameResultId는 소수라 메모리 영향 미미.
///
/// Copied from [gameResult].
class GameResultProvider extends FutureProvider<GameResultEntity> {
  /// 게임 결과 조회 FutureProvider (family by gameResultId)
  ///
  /// `GET /api/game-results/{gameResultId}` 응답을 캐시합니다.
  /// GAME_OVER 이벤트 수신 직후 `ref.read(gameResultProvider(id).future)`로
  /// 사전 트리거하여, 결과 다이얼로그가 뜰 때는 이미 데이터가 준비되도록 합니다.
  ///
  /// DTO → Entity 변환은 Provider 내부에서 직접 수행합니다
  /// (프로젝트 Entity 컨벤션 — Entity는 Data Layer에 의존하지 않음).
  ///
  /// 실패 시 `DioExceptionHandler.handle`로 AppException 변환 후 던져,
  /// UI 쪽에서 AsyncValue.error로 분기됩니다.
  /// (로깅은 `DioExceptionHandler` 내부에서 수행하므로 여기서는 별도 출력 없음)
  ///
  /// `keepAlive: true` — GAME_OVER 직후 pre-trigger 후 1단계 AppPopup(3초)이 떠있는 동안
  /// provider 구독자가 없어 autoDispose가 발동하면 다이얼로그 열릴 때 재요청이 발생한다.
  /// 세션당 gameResultId는 소수라 메모리 영향 미미.
  ///
  /// Copied from [gameResult].
  GameResultProvider(int gameResultId)
    : this._internal(
        (ref) => gameResult(ref as GameResultRef, gameResultId),
        from: gameResultProvider,
        name: r'gameResultProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameResultHash,
        dependencies: GameResultFamily._dependencies,
        allTransitiveDependencies: GameResultFamily._allTransitiveDependencies,
        gameResultId: gameResultId,
      );

  GameResultProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameResultId,
  }) : super.internal();

  final int gameResultId;

  @override
  Override overrideWith(
    FutureOr<GameResultEntity> Function(GameResultRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameResultProvider._internal(
        (ref) => create(ref as GameResultRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameResultId: gameResultId,
      ),
    );
  }

  @override
  FutureProviderElement<GameResultEntity> createElement() {
    return _GameResultProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameResultProvider && other.gameResultId == gameResultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameResultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameResultRef on FutureProviderRef<GameResultEntity> {
  /// The parameter `gameResultId` of this provider.
  int get gameResultId;
}

class _GameResultProviderElement extends FutureProviderElement<GameResultEntity>
    with GameResultRef {
  _GameResultProviderElement(super.provider);

  @override
  int get gameResultId => (origin as GameResultProvider).gameResultId;
}

String _$myGameRecordHash() => r'0cdec9274762f344063f3189fa6f99885a8a89db';

/// 내 개인 기록 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}/me` 응답을 캐시합니다.
/// [gameResult]와 같은 이유로 `keepAlive: true`이며, GAME_OVER 직후 같이 사전 트리거해
/// 결과 다이얼로그의 「개인」 탭이 열릴 때 재요청이 없게 합니다.
///
/// 실패는 [gameResult]와 독립이다 — 이 provider가 error여도 「전체」 탭은 그대로 뜬다.
///
/// Copied from [myGameRecord].
@ProviderFor(myGameRecord)
const myGameRecordProvider = MyGameRecordFamily();

/// 내 개인 기록 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}/me` 응답을 캐시합니다.
/// [gameResult]와 같은 이유로 `keepAlive: true`이며, GAME_OVER 직후 같이 사전 트리거해
/// 결과 다이얼로그의 「개인」 탭이 열릴 때 재요청이 없게 합니다.
///
/// 실패는 [gameResult]와 독립이다 — 이 provider가 error여도 「전체」 탭은 그대로 뜬다.
///
/// Copied from [myGameRecord].
class MyGameRecordFamily extends Family<AsyncValue<MyGameRecordEntity>> {
  /// 내 개인 기록 조회 FutureProvider (family by gameResultId)
  ///
  /// `GET /api/game-results/{gameResultId}/me` 응답을 캐시합니다.
  /// [gameResult]와 같은 이유로 `keepAlive: true`이며, GAME_OVER 직후 같이 사전 트리거해
  /// 결과 다이얼로그의 「개인」 탭이 열릴 때 재요청이 없게 합니다.
  ///
  /// 실패는 [gameResult]와 독립이다 — 이 provider가 error여도 「전체」 탭은 그대로 뜬다.
  ///
  /// Copied from [myGameRecord].
  const MyGameRecordFamily();

  /// 내 개인 기록 조회 FutureProvider (family by gameResultId)
  ///
  /// `GET /api/game-results/{gameResultId}/me` 응답을 캐시합니다.
  /// [gameResult]와 같은 이유로 `keepAlive: true`이며, GAME_OVER 직후 같이 사전 트리거해
  /// 결과 다이얼로그의 「개인」 탭이 열릴 때 재요청이 없게 합니다.
  ///
  /// 실패는 [gameResult]와 독립이다 — 이 provider가 error여도 「전체」 탭은 그대로 뜬다.
  ///
  /// Copied from [myGameRecord].
  MyGameRecordProvider call(int gameResultId) {
    return MyGameRecordProvider(gameResultId);
  }

  @override
  MyGameRecordProvider getProviderOverride(
    covariant MyGameRecordProvider provider,
  ) {
    return call(provider.gameResultId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myGameRecordProvider';
}

/// 내 개인 기록 조회 FutureProvider (family by gameResultId)
///
/// `GET /api/game-results/{gameResultId}/me` 응답을 캐시합니다.
/// [gameResult]와 같은 이유로 `keepAlive: true`이며, GAME_OVER 직후 같이 사전 트리거해
/// 결과 다이얼로그의 「개인」 탭이 열릴 때 재요청이 없게 합니다.
///
/// 실패는 [gameResult]와 독립이다 — 이 provider가 error여도 「전체」 탭은 그대로 뜬다.
///
/// Copied from [myGameRecord].
class MyGameRecordProvider extends FutureProvider<MyGameRecordEntity> {
  /// 내 개인 기록 조회 FutureProvider (family by gameResultId)
  ///
  /// `GET /api/game-results/{gameResultId}/me` 응답을 캐시합니다.
  /// [gameResult]와 같은 이유로 `keepAlive: true`이며, GAME_OVER 직후 같이 사전 트리거해
  /// 결과 다이얼로그의 「개인」 탭이 열릴 때 재요청이 없게 합니다.
  ///
  /// 실패는 [gameResult]와 독립이다 — 이 provider가 error여도 「전체」 탭은 그대로 뜬다.
  ///
  /// Copied from [myGameRecord].
  MyGameRecordProvider(int gameResultId)
    : this._internal(
        (ref) => myGameRecord(ref as MyGameRecordRef, gameResultId),
        from: myGameRecordProvider,
        name: r'myGameRecordProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myGameRecordHash,
        dependencies: MyGameRecordFamily._dependencies,
        allTransitiveDependencies:
            MyGameRecordFamily._allTransitiveDependencies,
        gameResultId: gameResultId,
      );

  MyGameRecordProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameResultId,
  }) : super.internal();

  final int gameResultId;

  @override
  Override overrideWith(
    FutureOr<MyGameRecordEntity> Function(MyGameRecordRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MyGameRecordProvider._internal(
        (ref) => create(ref as MyGameRecordRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameResultId: gameResultId,
      ),
    );
  }

  @override
  FutureProviderElement<MyGameRecordEntity> createElement() {
    return _MyGameRecordProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyGameRecordProvider && other.gameResultId == gameResultId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameResultId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyGameRecordRef on FutureProviderRef<MyGameRecordEntity> {
  /// The parameter `gameResultId` of this provider.
  int get gameResultId;
}

class _MyGameRecordProviderElement
    extends FutureProviderElement<MyGameRecordEntity>
    with MyGameRecordRef {
  _MyGameRecordProviderElement(super.provider);

  @override
  int get gameResultId => (origin as MyGameRecordProvider).gameResultId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
