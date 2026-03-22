// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionRemoteDataSourceHash() =>
    r'b0ce1a8d497f9d71b63a25c700cf5e0a2bffceba';

/// SessionRemoteDataSource Provider (Retrofit)
///
/// Copied from [sessionRemoteDataSource].
@ProviderFor(sessionRemoteDataSource)
final sessionRemoteDataSourceProvider =
    AutoDisposeProvider<SessionRemoteDataSource>.internal(
      sessionRemoteDataSource,
      name: r'sessionRemoteDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionRemoteDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRemoteDataSourceRef =
    AutoDisposeProviderRef<SessionRemoteDataSource>;
String _$sessionRepositoryHash() => r'6037c53ad58d576c9aee1eaacd13646101e2fa03';

/// SessionRepository Provider
///
/// Copied from [sessionRepository].
@ProviderFor(sessionRepository)
final sessionRepositoryProvider =
    AutoDisposeProvider<SessionRepository>.internal(
      sessionRepository,
      name: r'sessionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRepositoryRef = AutoDisposeProviderRef<SessionRepository>;
String _$getMyActiveGameUsecaseHash() =>
    r'3d3eb93d35009ced66ae7f303ae358b276e7f731';

/// GetMyActiveGameUsecase Provider
///
/// Copied from [getMyActiveGameUsecase].
@ProviderFor(getMyActiveGameUsecase)
final getMyActiveGameUsecaseProvider =
    AutoDisposeProvider<GetMyActiveGameUsecase>.internal(
      getMyActiveGameUsecase,
      name: r'getMyActiveGameUsecaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getMyActiveGameUsecaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetMyActiveGameUsecaseRef =
    AutoDisposeProviderRef<GetMyActiveGameUsecase>;
String _$leaveGameHash() => r'9b80aaeda230ae5777cea0ae3d301b6470310dc3';

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

/// 게임 방 퇴장 기능
///
/// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [leaveGame].
@ProviderFor(leaveGame)
const leaveGameProvider = LeaveGameFamily();

/// 게임 방 퇴장 기능
///
/// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [leaveGame].
class LeaveGameFamily extends Family<AsyncValue<LeaveGameResponse>> {
  /// 게임 방 퇴장 기능
  ///
  /// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [leaveGame].
  const LeaveGameFamily();

  /// 게임 방 퇴장 기능
  ///
  /// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [leaveGame].
  LeaveGameProvider call(int gameId) {
    return LeaveGameProvider(gameId);
  }

  @override
  LeaveGameProvider getProviderOverride(covariant LeaveGameProvider provider) {
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
  String? get name => r'leaveGameProvider';
}

/// 게임 방 퇴장 기능
///
/// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [leaveGame].
class LeaveGameProvider extends AutoDisposeFutureProvider<LeaveGameResponse> {
  /// 게임 방 퇴장 기능
  ///
  /// 대기실/게임 화면에서 나갈 때 서버에 퇴장을 알립니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [leaveGame].
  LeaveGameProvider(int gameId)
    : this._internal(
        (ref) => leaveGame(ref as LeaveGameRef, gameId),
        from: leaveGameProvider,
        name: r'leaveGameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$leaveGameHash,
        dependencies: LeaveGameFamily._dependencies,
        allTransitiveDependencies: LeaveGameFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  LeaveGameProvider._internal(
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
    FutureOr<LeaveGameResponse> Function(LeaveGameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LeaveGameProvider._internal(
        (ref) => create(ref as LeaveGameRef),
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
  AutoDisposeFutureProviderElement<LeaveGameResponse> createElement() {
    return _LeaveGameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LeaveGameProvider && other.gameId == gameId;
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
mixin LeaveGameRef on AutoDisposeFutureProviderRef<LeaveGameResponse> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _LeaveGameProviderElement
    extends AutoDisposeFutureProviderElement<LeaveGameResponse>
    with LeaveGameRef {
  _LeaveGameProviderElement(super.provider);

  @override
  int get gameId => (origin as LeaveGameProvider).gameId;
}

String _$startGameHash() => r'088563a5006ad0f7e429592f6a2845617b447e3f';

/// 게임 시작 기능
///
/// 방장이 게임을 시작합니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [startGame].
@ProviderFor(startGame)
const startGameProvider = StartGameFamily();

/// 게임 시작 기능
///
/// 방장이 게임을 시작합니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [startGame].
class StartGameFamily extends Family<AsyncValue<void>> {
  /// 게임 시작 기능
  ///
  /// 방장이 게임을 시작합니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [startGame].
  const StartGameFamily();

  /// 게임 시작 기능
  ///
  /// 방장이 게임을 시작합니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [startGame].
  StartGameProvider call(int gameId) {
    return StartGameProvider(gameId);
  }

  @override
  StartGameProvider getProviderOverride(covariant StartGameProvider provider) {
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
  String? get name => r'startGameProvider';
}

/// 게임 시작 기능
///
/// 방장이 게임을 시작합니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [startGame].
class StartGameProvider extends AutoDisposeFutureProvider<void> {
  /// 게임 시작 기능
  ///
  /// 방장이 게임을 시작합니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [startGame].
  StartGameProvider(int gameId)
    : this._internal(
        (ref) => startGame(ref as StartGameRef, gameId),
        from: startGameProvider,
        name: r'startGameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$startGameHash,
        dependencies: StartGameFamily._dependencies,
        allTransitiveDependencies: StartGameFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  StartGameProvider._internal(
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
  Override overrideWith(FutureOr<void> Function(StartGameRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: StartGameProvider._internal(
        (ref) => create(ref as StartGameRef),
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
  AutoDisposeFutureProviderElement<void> createElement() {
    return _StartGameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StartGameProvider && other.gameId == gameId;
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
mixin StartGameRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _StartGameProviderElement extends AutoDisposeFutureProviderElement<void>
    with StartGameRef {
  _StartGameProviderElement(super.provider);

  @override
  int get gameId => (origin as StartGameProvider).gameId;
}

String _$updateReadyHash() => r'079ee77b3942105dd6e3dfd49a5e76f949543d99';

/// 준비 상태 변경 기능
///
/// 대기실에서 준비 상태를 변경합니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [updateReady].
@ProviderFor(updateReady)
const updateReadyProvider = UpdateReadyFamily();

/// 준비 상태 변경 기능
///
/// 대기실에서 준비 상태를 변경합니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [updateReady].
class UpdateReadyFamily extends Family<AsyncValue<void>> {
  /// 준비 상태 변경 기능
  ///
  /// 대기실에서 준비 상태를 변경합니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [updateReady].
  const UpdateReadyFamily();

  /// 준비 상태 변경 기능
  ///
  /// 대기실에서 준비 상태를 변경합니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [updateReady].
  UpdateReadyProvider call(int gameId, {required bool isReady}) {
    return UpdateReadyProvider(gameId, isReady: isReady);
  }

  @override
  UpdateReadyProvider getProviderOverride(
    covariant UpdateReadyProvider provider,
  ) {
    return call(provider.gameId, isReady: provider.isReady);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateReadyProvider';
}

/// 준비 상태 변경 기능
///
/// 대기실에서 준비 상태를 변경합니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [updateReady].
class UpdateReadyProvider extends AutoDisposeFutureProvider<void> {
  /// 준비 상태 변경 기능
  ///
  /// 대기실에서 준비 상태를 변경합니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [updateReady].
  UpdateReadyProvider(int gameId, {required bool isReady})
    : this._internal(
        (ref) => updateReady(ref as UpdateReadyRef, gameId, isReady: isReady),
        from: updateReadyProvider,
        name: r'updateReadyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$updateReadyHash,
        dependencies: UpdateReadyFamily._dependencies,
        allTransitiveDependencies: UpdateReadyFamily._allTransitiveDependencies,
        gameId: gameId,
        isReady: isReady,
      );

  UpdateReadyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
    required this.isReady,
  }) : super.internal();

  final int gameId;
  final bool isReady;

  @override
  Override overrideWith(
    FutureOr<void> Function(UpdateReadyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateReadyProvider._internal(
        (ref) => create(ref as UpdateReadyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
        isReady: isReady,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _UpdateReadyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateReadyProvider &&
        other.gameId == gameId &&
        other.isReady == isReady;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);
    hash = _SystemHash.combine(hash, isReady.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateReadyRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `gameId` of this provider.
  int get gameId;

  /// The parameter `isReady` of this provider.
  bool get isReady;
}

class _UpdateReadyProviderElement extends AutoDisposeFutureProviderElement<void>
    with UpdateReadyRef {
  _UpdateReadyProviderElement(super.provider);

  @override
  int get gameId => (origin as UpdateReadyProvider).gameId;
  @override
  bool get isReady => (origin as UpdateReadyProvider).isReady;
}

String _$changeTeamHash() => r'2bd0e191c99c031ab98a34d63aa840fe6c19f39d';

/// 팀 변경 기능
///
/// 대기실에서 팀을 변경합니다.
/// 팀 변경 시 준비 상태가 해제됩니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [changeTeam].
@ProviderFor(changeTeam)
const changeTeamProvider = ChangeTeamFamily();

/// 팀 변경 기능
///
/// 대기실에서 팀을 변경합니다.
/// 팀 변경 시 준비 상태가 해제됩니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [changeTeam].
class ChangeTeamFamily extends Family<AsyncValue<void>> {
  /// 팀 변경 기능
  ///
  /// 대기실에서 팀을 변경합니다.
  /// 팀 변경 시 준비 상태가 해제됩니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [changeTeam].
  const ChangeTeamFamily();

  /// 팀 변경 기능
  ///
  /// 대기실에서 팀을 변경합니다.
  /// 팀 변경 시 준비 상태가 해제됩니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [changeTeam].
  ChangeTeamProvider call(int gameId, {required String targetTeam}) {
    return ChangeTeamProvider(gameId, targetTeam: targetTeam);
  }

  @override
  ChangeTeamProvider getProviderOverride(
    covariant ChangeTeamProvider provider,
  ) {
    return call(provider.gameId, targetTeam: provider.targetTeam);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'changeTeamProvider';
}

/// 팀 변경 기능
///
/// 대기실에서 팀을 변경합니다.
/// 팀 변경 시 준비 상태가 해제됩니다.
/// 실패 시 DioException을 rethrow합니다.
///
/// Copied from [changeTeam].
class ChangeTeamProvider extends AutoDisposeFutureProvider<void> {
  /// 팀 변경 기능
  ///
  /// 대기실에서 팀을 변경합니다.
  /// 팀 변경 시 준비 상태가 해제됩니다.
  /// 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [changeTeam].
  ChangeTeamProvider(int gameId, {required String targetTeam})
    : this._internal(
        (ref) =>
            changeTeam(ref as ChangeTeamRef, gameId, targetTeam: targetTeam),
        from: changeTeamProvider,
        name: r'changeTeamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$changeTeamHash,
        dependencies: ChangeTeamFamily._dependencies,
        allTransitiveDependencies: ChangeTeamFamily._allTransitiveDependencies,
        gameId: gameId,
        targetTeam: targetTeam,
      );

  ChangeTeamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
    required this.targetTeam,
  }) : super.internal();

  final int gameId;
  final String targetTeam;

  @override
  Override overrideWith(
    FutureOr<void> Function(ChangeTeamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChangeTeamProvider._internal(
        (ref) => create(ref as ChangeTeamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
        targetTeam: targetTeam,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _ChangeTeamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChangeTeamProvider &&
        other.gameId == gameId &&
        other.targetTeam == targetTeam;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);
    hash = _SystemHash.combine(hash, targetTeam.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChangeTeamRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `gameId` of this provider.
  int get gameId;

  /// The parameter `targetTeam` of this provider.
  String get targetTeam;
}

class _ChangeTeamProviderElement extends AutoDisposeFutureProviderElement<void>
    with ChangeTeamRef {
  _ChangeTeamProviderElement(super.provider);

  @override
  int get gameId => (origin as ChangeTeamProvider).gameId;
  @override
  String get targetTeam => (origin as ChangeTeamProvider).targetTeam;
}

String _$joinGameHash() => r'db8d682e07b47b40a727368e54342c43cf946a9f';

/// 게임 방 참여 기능
///
/// 초대 코드를 사용하여 게임 방에 참여합니다.
/// 성공 시 JoinGameResponse를 반환하고, 실패 시 DioException을 rethrow합니다.
///
/// Copied from [joinGame].
@ProviderFor(joinGame)
const joinGameProvider = JoinGameFamily();

/// 게임 방 참여 기능
///
/// 초대 코드를 사용하여 게임 방에 참여합니다.
/// 성공 시 JoinGameResponse를 반환하고, 실패 시 DioException을 rethrow합니다.
///
/// Copied from [joinGame].
class JoinGameFamily extends Family<AsyncValue<JoinGameResponse?>> {
  /// 게임 방 참여 기능
  ///
  /// 초대 코드를 사용하여 게임 방에 참여합니다.
  /// 성공 시 JoinGameResponse를 반환하고, 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [joinGame].
  const JoinGameFamily();

  /// 게임 방 참여 기능
  ///
  /// 초대 코드를 사용하여 게임 방에 참여합니다.
  /// 성공 시 JoinGameResponse를 반환하고, 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [joinGame].
  JoinGameProvider call({required String inviteCode}) {
    return JoinGameProvider(inviteCode: inviteCode);
  }

  @override
  JoinGameProvider getProviderOverride(covariant JoinGameProvider provider) {
    return call(inviteCode: provider.inviteCode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'joinGameProvider';
}

/// 게임 방 참여 기능
///
/// 초대 코드를 사용하여 게임 방에 참여합니다.
/// 성공 시 JoinGameResponse를 반환하고, 실패 시 DioException을 rethrow합니다.
///
/// Copied from [joinGame].
class JoinGameProvider extends AutoDisposeFutureProvider<JoinGameResponse?> {
  /// 게임 방 참여 기능
  ///
  /// 초대 코드를 사용하여 게임 방에 참여합니다.
  /// 성공 시 JoinGameResponse를 반환하고, 실패 시 DioException을 rethrow합니다.
  ///
  /// Copied from [joinGame].
  JoinGameProvider({required String inviteCode})
    : this._internal(
        (ref) => joinGame(ref as JoinGameRef, inviteCode: inviteCode),
        from: joinGameProvider,
        name: r'joinGameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$joinGameHash,
        dependencies: JoinGameFamily._dependencies,
        allTransitiveDependencies: JoinGameFamily._allTransitiveDependencies,
        inviteCode: inviteCode,
      );

  JoinGameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inviteCode,
  }) : super.internal();

  final String inviteCode;

  @override
  Override overrideWith(
    FutureOr<JoinGameResponse?> Function(JoinGameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JoinGameProvider._internal(
        (ref) => create(ref as JoinGameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inviteCode: inviteCode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<JoinGameResponse?> createElement() {
    return _JoinGameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JoinGameProvider && other.inviteCode == inviteCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inviteCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JoinGameRef on AutoDisposeFutureProviderRef<JoinGameResponse?> {
  /// The parameter `inviteCode` of this provider.
  String get inviteCode;
}

class _JoinGameProviderElement
    extends AutoDisposeFutureProviderElement<JoinGameResponse?>
    with JoinGameRef {
  _JoinGameProviderElement(super.provider);

  @override
  String get inviteCode => (origin as JoinGameProvider).inviteCode;
}

String _$fetchLobbyInfoHash() => r'78f09cd112324656cc77abd8cf20c9bee73df0e6';

/// 로비 조회
///
/// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
///
/// Copied from [fetchLobbyInfo].
@ProviderFor(fetchLobbyInfo)
const fetchLobbyInfoProvider = FetchLobbyInfoFamily();

/// 로비 조회
///
/// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
///
/// Copied from [fetchLobbyInfo].
class FetchLobbyInfoFamily extends Family<AsyncValue<LobbyInfoResponse>> {
  /// 로비 조회
  ///
  /// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
  ///
  /// Copied from [fetchLobbyInfo].
  const FetchLobbyInfoFamily();

  /// 로비 조회
  ///
  /// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
  ///
  /// Copied from [fetchLobbyInfo].
  FetchLobbyInfoProvider call(int gameId) {
    return FetchLobbyInfoProvider(gameId);
  }

  @override
  FetchLobbyInfoProvider getProviderOverride(
    covariant FetchLobbyInfoProvider provider,
  ) {
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
  String? get name => r'fetchLobbyInfoProvider';
}

/// 로비 조회
///
/// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
///
/// Copied from [fetchLobbyInfo].
class FetchLobbyInfoProvider
    extends AutoDisposeFutureProvider<LobbyInfoResponse> {
  /// 로비 조회
  ///
  /// 대기실 초기 상태(참가자 목록, myParticipantId, 게임 설정)를 반환합니다.
  ///
  /// Copied from [fetchLobbyInfo].
  FetchLobbyInfoProvider(int gameId)
    : this._internal(
        (ref) => fetchLobbyInfo(ref as FetchLobbyInfoRef, gameId),
        from: fetchLobbyInfoProvider,
        name: r'fetchLobbyInfoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchLobbyInfoHash,
        dependencies: FetchLobbyInfoFamily._dependencies,
        allTransitiveDependencies:
            FetchLobbyInfoFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  FetchLobbyInfoProvider._internal(
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
    FutureOr<LobbyInfoResponse> Function(FetchLobbyInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchLobbyInfoProvider._internal(
        (ref) => create(ref as FetchLobbyInfoRef),
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
  AutoDisposeFutureProviderElement<LobbyInfoResponse> createElement() {
    return _FetchLobbyInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchLobbyInfoProvider && other.gameId == gameId;
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
mixin FetchLobbyInfoRef on AutoDisposeFutureProviderRef<LobbyInfoResponse> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _FetchLobbyInfoProviderElement
    extends AutoDisposeFutureProviderElement<LobbyInfoResponse>
    with FetchLobbyInfoRef {
  _FetchLobbyInfoProviderElement(super.provider);

  @override
  int get gameId => (origin as FetchLobbyInfoProvider).gameId;
}

String _$fetchGameSettingsHash() => r'3c2bf3cdecc828730224d794d1ecbe20c626de9c';

/// 게임 설정 조회
///
/// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
///
/// Copied from [fetchGameSettings].
@ProviderFor(fetchGameSettings)
const fetchGameSettingsProvider = FetchGameSettingsFamily();

/// 게임 설정 조회
///
/// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
///
/// Copied from [fetchGameSettings].
class FetchGameSettingsFamily extends Family<AsyncValue<GameSettingsResponse>> {
  /// 게임 설정 조회
  ///
  /// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
  ///
  /// Copied from [fetchGameSettings].
  const FetchGameSettingsFamily();

  /// 게임 설정 조회
  ///
  /// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
  ///
  /// Copied from [fetchGameSettings].
  FetchGameSettingsProvider call(int gameId) {
    return FetchGameSettingsProvider(gameId);
  }

  @override
  FetchGameSettingsProvider getProviderOverride(
    covariant FetchGameSettingsProvider provider,
  ) {
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
  String? get name => r'fetchGameSettingsProvider';
}

/// 게임 설정 조회
///
/// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
///
/// Copied from [fetchGameSettings].
class FetchGameSettingsProvider
    extends AutoDisposeFutureProvider<GameSettingsResponse> {
  /// 게임 설정 조회
  ///
  /// 게임 방의 기본 설정(라운드 시간, 위치 공개 주기 등)을 반환합니다.
  ///
  /// Copied from [fetchGameSettings].
  FetchGameSettingsProvider(int gameId)
    : this._internal(
        (ref) => fetchGameSettings(ref as FetchGameSettingsRef, gameId),
        from: fetchGameSettingsProvider,
        name: r'fetchGameSettingsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchGameSettingsHash,
        dependencies: FetchGameSettingsFamily._dependencies,
        allTransitiveDependencies:
            FetchGameSettingsFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  FetchGameSettingsProvider._internal(
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
    FutureOr<GameSettingsResponse> Function(FetchGameSettingsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchGameSettingsProvider._internal(
        (ref) => create(ref as FetchGameSettingsRef),
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
  AutoDisposeFutureProviderElement<GameSettingsResponse> createElement() {
    return _FetchGameSettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchGameSettingsProvider && other.gameId == gameId;
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
mixin FetchGameSettingsRef
    on AutoDisposeFutureProviderRef<GameSettingsResponse> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _FetchGameSettingsProviderElement
    extends AutoDisposeFutureProviderElement<GameSettingsResponse>
    with FetchGameSettingsRef {
  _FetchGameSettingsProviderElement(super.provider);

  @override
  int get gameId => (origin as FetchGameSettingsProvider).gameId;
}

String _$fetchGameParticipantsHash() =>
    r'cd7001f98986bfde873eee5705b1f611070460b2';

/// 인게임 참가자 목록 조회
///
/// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
///
/// Copied from [fetchGameParticipants].
@ProviderFor(fetchGameParticipants)
const fetchGameParticipantsProvider = FetchGameParticipantsFamily();

/// 인게임 참가자 목록 조회
///
/// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
///
/// Copied from [fetchGameParticipants].
class FetchGameParticipantsFamily
    extends Family<AsyncValue<InGameParticipantsResponse>> {
  /// 인게임 참가자 목록 조회
  ///
  /// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
  ///
  /// Copied from [fetchGameParticipants].
  const FetchGameParticipantsFamily();

  /// 인게임 참가자 목록 조회
  ///
  /// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
  ///
  /// Copied from [fetchGameParticipants].
  FetchGameParticipantsProvider call(int gameId) {
    return FetchGameParticipantsProvider(gameId);
  }

  @override
  FetchGameParticipantsProvider getProviderOverride(
    covariant FetchGameParticipantsProvider provider,
  ) {
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
  String? get name => r'fetchGameParticipantsProvider';
}

/// 인게임 참가자 목록 조회
///
/// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
///
/// Copied from [fetchGameParticipants].
class FetchGameParticipantsProvider
    extends AutoDisposeFutureProvider<InGameParticipantsResponse> {
  /// 인게임 참가자 목록 조회
  ///
  /// 게임 진행 중 경찰/도둑 참가자 목록과 상태를 반환합니다.
  ///
  /// Copied from [fetchGameParticipants].
  FetchGameParticipantsProvider(int gameId)
    : this._internal(
        (ref) => fetchGameParticipants(ref as FetchGameParticipantsRef, gameId),
        from: fetchGameParticipantsProvider,
        name: r'fetchGameParticipantsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchGameParticipantsHash,
        dependencies: FetchGameParticipantsFamily._dependencies,
        allTransitiveDependencies:
            FetchGameParticipantsFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  FetchGameParticipantsProvider._internal(
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
    FutureOr<InGameParticipantsResponse> Function(
      FetchGameParticipantsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchGameParticipantsProvider._internal(
        (ref) => create(ref as FetchGameParticipantsRef),
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
  AutoDisposeFutureProviderElement<InGameParticipantsResponse> createElement() {
    return _FetchGameParticipantsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchGameParticipantsProvider && other.gameId == gameId;
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
mixin FetchGameParticipantsRef
    on AutoDisposeFutureProviderRef<InGameParticipantsResponse> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _FetchGameParticipantsProviderElement
    extends AutoDisposeFutureProviderElement<InGameParticipantsResponse>
    with FetchGameParticipantsRef {
  _FetchGameParticipantsProviderElement(super.provider);

  @override
  int get gameId => (origin as FetchGameParticipantsProvider).gameId;
}

String _$fetchGameAreaHash() => r'8729a1f2480e35f20d05aa88ecd8cb32c79597cd';

/// 게임 영역 조회
///
/// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
///
/// Copied from [fetchGameArea].
@ProviderFor(fetchGameArea)
const fetchGameAreaProvider = FetchGameAreaFamily();

/// 게임 영역 조회
///
/// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
///
/// Copied from [fetchGameArea].
class FetchGameAreaFamily extends Family<AsyncValue<GameAreaModel>> {
  /// 게임 영역 조회
  ///
  /// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
  ///
  /// Copied from [fetchGameArea].
  const FetchGameAreaFamily();

  /// 게임 영역 조회
  ///
  /// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
  ///
  /// Copied from [fetchGameArea].
  FetchGameAreaProvider call(int gameId) {
    return FetchGameAreaProvider(gameId);
  }

  @override
  FetchGameAreaProvider getProviderOverride(
    covariant FetchGameAreaProvider provider,
  ) {
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
  String? get name => r'fetchGameAreaProvider';
}

/// 게임 영역 조회
///
/// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
///
/// Copied from [fetchGameArea].
class FetchGameAreaProvider extends AutoDisposeFutureProvider<GameAreaModel> {
  /// 게임 영역 조회
  ///
  /// 플레이그라운드·감옥 중심 좌표 및 반경을 반환합니다.
  ///
  /// Copied from [fetchGameArea].
  FetchGameAreaProvider(int gameId)
    : this._internal(
        (ref) => fetchGameArea(ref as FetchGameAreaRef, gameId),
        from: fetchGameAreaProvider,
        name: r'fetchGameAreaProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchGameAreaHash,
        dependencies: FetchGameAreaFamily._dependencies,
        allTransitiveDependencies:
            FetchGameAreaFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  FetchGameAreaProvider._internal(
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
    FutureOr<GameAreaModel> Function(FetchGameAreaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchGameAreaProvider._internal(
        (ref) => create(ref as FetchGameAreaRef),
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
    return _FetchGameAreaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchGameAreaProvider && other.gameId == gameId;
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
mixin FetchGameAreaRef on AutoDisposeFutureProviderRef<GameAreaModel> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _FetchGameAreaProviderElement
    extends AutoDisposeFutureProviderElement<GameAreaModel>
    with FetchGameAreaRef {
  _FetchGameAreaProviderElement(super.provider);

  @override
  int get gameId => (origin as FetchGameAreaProvider).gameId;
}

String _$updateGameSettingsHash() =>
    r'fc8a363c99872fa74f42041899ad2e3bc60d6b0d';

/// 게임 설정 수정
///
/// 성공 시 갱신된 [GameSettingsResponse]를 반환합니다.
///
/// Copied from [updateGameSettings].
@ProviderFor(updateGameSettings)
const updateGameSettingsProvider = UpdateGameSettingsFamily();

/// 게임 설정 수정
///
/// 성공 시 갱신된 [GameSettingsResponse]를 반환합니다.
///
/// Copied from [updateGameSettings].
class UpdateGameSettingsFamily
    extends Family<AsyncValue<GameSettingsResponse>> {
  /// 게임 설정 수정
  ///
  /// 성공 시 갱신된 [GameSettingsResponse]를 반환합니다.
  ///
  /// Copied from [updateGameSettings].
  const UpdateGameSettingsFamily();

  /// 게임 설정 수정
  ///
  /// 성공 시 갱신된 [GameSettingsResponse]를 반환합니다.
  ///
  /// Copied from [updateGameSettings].
  UpdateGameSettingsProvider call(
    int gameId, {
    required GameSettingsRequestModel request,
  }) {
    return UpdateGameSettingsProvider(gameId, request: request);
  }

  @override
  UpdateGameSettingsProvider getProviderOverride(
    covariant UpdateGameSettingsProvider provider,
  ) {
    return call(provider.gameId, request: provider.request);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateGameSettingsProvider';
}

/// 게임 설정 수정
///
/// 성공 시 갱신된 [GameSettingsResponse]를 반환합니다.
///
/// Copied from [updateGameSettings].
class UpdateGameSettingsProvider
    extends AutoDisposeFutureProvider<GameSettingsResponse> {
  /// 게임 설정 수정
  ///
  /// 성공 시 갱신된 [GameSettingsResponse]를 반환합니다.
  ///
  /// Copied from [updateGameSettings].
  UpdateGameSettingsProvider(
    int gameId, {
    required GameSettingsRequestModel request,
  }) : this._internal(
         (ref) => updateGameSettings(
           ref as UpdateGameSettingsRef,
           gameId,
           request: request,
         ),
         from: updateGameSettingsProvider,
         name: r'updateGameSettingsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$updateGameSettingsHash,
         dependencies: UpdateGameSettingsFamily._dependencies,
         allTransitiveDependencies:
             UpdateGameSettingsFamily._allTransitiveDependencies,
         gameId: gameId,
         request: request,
       );

  UpdateGameSettingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
    required this.request,
  }) : super.internal();

  final int gameId;
  final GameSettingsRequestModel request;

  @override
  Override overrideWith(
    FutureOr<GameSettingsResponse> Function(UpdateGameSettingsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateGameSettingsProvider._internal(
        (ref) => create(ref as UpdateGameSettingsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
        request: request,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GameSettingsResponse> createElement() {
    return _UpdateGameSettingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateGameSettingsProvider &&
        other.gameId == gameId &&
        other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateGameSettingsRef
    on AutoDisposeFutureProviderRef<GameSettingsResponse> {
  /// The parameter `gameId` of this provider.
  int get gameId;

  /// The parameter `request` of this provider.
  GameSettingsRequestModel get request;
}

class _UpdateGameSettingsProviderElement
    extends AutoDisposeFutureProviderElement<GameSettingsResponse>
    with UpdateGameSettingsRef {
  _UpdateGameSettingsProviderElement(super.provider);

  @override
  int get gameId => (origin as UpdateGameSettingsProvider).gameId;
  @override
  GameSettingsRequestModel get request =>
      (origin as UpdateGameSettingsProvider).request;
}

String _$updateGameAreaHash() => r'aa2152158972c2dab5cc25babc3ec5b8a444a5a2';

/// 게임 영역 수정
///
/// 성공 시 갱신된 [GameAreaModel]을 반환합니다.
///
/// Copied from [updateGameArea].
@ProviderFor(updateGameArea)
const updateGameAreaProvider = UpdateGameAreaFamily();

/// 게임 영역 수정
///
/// 성공 시 갱신된 [GameAreaModel]을 반환합니다.
///
/// Copied from [updateGameArea].
class UpdateGameAreaFamily extends Family<AsyncValue<GameAreaModel>> {
  /// 게임 영역 수정
  ///
  /// 성공 시 갱신된 [GameAreaModel]을 반환합니다.
  ///
  /// Copied from [updateGameArea].
  const UpdateGameAreaFamily();

  /// 게임 영역 수정
  ///
  /// 성공 시 갱신된 [GameAreaModel]을 반환합니다.
  ///
  /// Copied from [updateGameArea].
  UpdateGameAreaProvider call(int gameId, {required AreaRequestModel request}) {
    return UpdateGameAreaProvider(gameId, request: request);
  }

  @override
  UpdateGameAreaProvider getProviderOverride(
    covariant UpdateGameAreaProvider provider,
  ) {
    return call(provider.gameId, request: provider.request);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateGameAreaProvider';
}

/// 게임 영역 수정
///
/// 성공 시 갱신된 [GameAreaModel]을 반환합니다.
///
/// Copied from [updateGameArea].
class UpdateGameAreaProvider extends AutoDisposeFutureProvider<GameAreaModel> {
  /// 게임 영역 수정
  ///
  /// 성공 시 갱신된 [GameAreaModel]을 반환합니다.
  ///
  /// Copied from [updateGameArea].
  UpdateGameAreaProvider(int gameId, {required AreaRequestModel request})
    : this._internal(
        (ref) =>
            updateGameArea(ref as UpdateGameAreaRef, gameId, request: request),
        from: updateGameAreaProvider,
        name: r'updateGameAreaProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$updateGameAreaHash,
        dependencies: UpdateGameAreaFamily._dependencies,
        allTransitiveDependencies:
            UpdateGameAreaFamily._allTransitiveDependencies,
        gameId: gameId,
        request: request,
      );

  UpdateGameAreaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
    required this.request,
  }) : super.internal();

  final int gameId;
  final AreaRequestModel request;

  @override
  Override overrideWith(
    FutureOr<GameAreaModel> Function(UpdateGameAreaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateGameAreaProvider._internal(
        (ref) => create(ref as UpdateGameAreaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
        request: request,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GameAreaModel> createElement() {
    return _UpdateGameAreaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateGameAreaProvider &&
        other.gameId == gameId &&
        other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateGameAreaRef on AutoDisposeFutureProviderRef<GameAreaModel> {
  /// The parameter `gameId` of this provider.
  int get gameId;

  /// The parameter `request` of this provider.
  AreaRequestModel get request;
}

class _UpdateGameAreaProviderElement
    extends AutoDisposeFutureProviderElement<GameAreaModel>
    with UpdateGameAreaRef {
  _UpdateGameAreaProviderElement(super.provider);

  @override
  int get gameId => (origin as UpdateGameAreaProvider).gameId;
  @override
  AreaRequestModel get request => (origin as UpdateGameAreaProvider).request;
}

String _$sessionCreationNotifierHash() =>
    r'371323e1f00197619d881ff5dfd62103f3f7b80b';

/// 세션 생성 상태 관리 Notifier
///
/// 게임 방 생성 API 호출 및 결과 상태를 관리합니다.
/// `AsyncValue<CreateSessionResult?>` 상태를 통해 로딩/성공/에러를 표현합니다.
///
/// Copied from [SessionCreationNotifier].
@ProviderFor(SessionCreationNotifier)
final sessionCreationNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SessionCreationNotifier,
      CreateSessionResult?
    >.internal(
      SessionCreationNotifier.new,
      name: r'sessionCreationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionCreationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SessionCreationNotifier =
    AutoDisposeAsyncNotifier<CreateSessionResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
