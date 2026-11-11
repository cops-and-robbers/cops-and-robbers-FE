// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$radioApiHash() => r'8b406b54977d1b1787c5b61c4acdf11567f5bbd3';

/// See also [radioApi].
@ProviderFor(radioApi)
final radioApiProvider = AutoDisposeProvider<RadioApi>.internal(
  radioApi,
  name: r'radioApiProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$radioApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RadioApiRef = AutoDisposeProviderRef<RadioApi>;
String _$radioRoomFactoryHash() => r'99f8caeffa231f346263e8410ce86db4ed3e2196';

/// 연결이 끊기면 방 객체를 새로 만든다 — LiveKit Room은 끊긴 뒤 다시 쓰지 않는다
///
/// Copied from [radioRoomFactory].
@ProviderFor(radioRoomFactory)
final radioRoomFactoryProvider =
    AutoDisposeProvider<RadioRoomPort Function()>.internal(
      radioRoomFactory,
      name: r'radioRoomFactoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$radioRoomFactoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RadioRoomFactoryRef = AutoDisposeProviderRef<RadioRoomPort Function()>;
String _$radioRandomHash() => r'fe55088f9cf6ef99a50ddd7dc8c7c2bbe5a28842';

/// See also [radioRandom].
@ProviderFor(radioRandom)
final radioRandomProvider = AutoDisposeProvider<Random>.internal(
  radioRandom,
  name: r'radioRandomProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$radioRandomHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RadioRandomRef = AutoDisposeProviderRef<Random>;
String _$radioBeepHash() => r'cf080b406970a5a59d14f56d93628475115ee7e4';

/// 다른 경찰이 말을 시작·끝낼 때 울리는 삑 소리
///
/// Copied from [radioBeep].
@ProviderFor(radioBeep)
final radioBeepProvider = AutoDisposeProvider<void Function()>.internal(
  radioBeep,
  name: r'radioBeepProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$radioBeepHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RadioBeepRef = AutoDisposeProviderRef<void Function()>;
String _$radioAppInForegroundHash() =>
    r'c475f316e132d0969807d572c03768631c0c7b18';

/// 앱이 화면에 떠 있는지 — 백그라운드에서는 마이크와 microphone 서비스를 열 수 없다(Android 14+)
///
/// Copied from [radioAppInForeground].
@ProviderFor(radioAppInForeground)
final radioAppInForegroundProvider =
    AutoDisposeProvider<bool Function()>.internal(
      radioAppInForeground,
      name: r'radioAppInForegroundProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$radioAppInForegroundHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RadioAppInForegroundRef = AutoDisposeProviderRef<bool Function()>;
String _$radioMicMemoryHash() => r'fdd0cdb6156d64406d96b3ae30044bbe55ac5558';

/// See also [radioMicMemory].
@ProviderFor(radioMicMemory)
final radioMicMemoryProvider = AutoDisposeProvider<RadioMicMemory>.internal(
  radioMicMemory,
  name: r'radioMicMemoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$radioMicMemoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RadioMicMemoryRef = AutoDisposeProviderRef<RadioMicMemory>;
String _$radioSessionHash() => r'dec18a7b870c605d4783626b4b64361d67b7fa4c';

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

abstract class _$RadioSession
    extends BuildlessAutoDisposeNotifier<RadioSessionState> {
  late final int gameId;

  RadioSessionState build(int gameId);
}

/// 경찰 팀 무전 연결 수명 (#697)
///
/// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
/// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
///
/// Copied from [RadioSession].
@ProviderFor(RadioSession)
const radioSessionProvider = RadioSessionFamily();

/// 경찰 팀 무전 연결 수명 (#697)
///
/// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
/// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
///
/// Copied from [RadioSession].
class RadioSessionFamily extends Family<RadioSessionState> {
  /// 경찰 팀 무전 연결 수명 (#697)
  ///
  /// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
  /// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
  ///
  /// Copied from [RadioSession].
  const RadioSessionFamily();

  /// 경찰 팀 무전 연결 수명 (#697)
  ///
  /// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
  /// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
  ///
  /// Copied from [RadioSession].
  RadioSessionProvider call(int gameId) {
    return RadioSessionProvider(gameId);
  }

  @override
  RadioSessionProvider getProviderOverride(
    covariant RadioSessionProvider provider,
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
  String? get name => r'radioSessionProvider';
}

/// 경찰 팀 무전 연결 수명 (#697)
///
/// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
/// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
///
/// Copied from [RadioSession].
class RadioSessionProvider
    extends AutoDisposeNotifierProviderImpl<RadioSession, RadioSessionState> {
  /// 경찰 팀 무전 연결 수명 (#697)
  ///
  /// 출동 시각에 토큰을 받아 방에 들어가 마이크를 mute 상태로 올려 두고, 누르는 동안만 mute를 푼다.
  /// 토큰은 수명의 70~90% 지점에서 다시 받는다 — 서버는 이 요청으로 자격을 다시 보고 사용 시간을 센다.
  ///
  /// Copied from [RadioSession].
  RadioSessionProvider(int gameId)
    : this._internal(
        () => RadioSession()..gameId = gameId,
        from: radioSessionProvider,
        name: r'radioSessionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$radioSessionHash,
        dependencies: RadioSessionFamily._dependencies,
        allTransitiveDependencies:
            RadioSessionFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  RadioSessionProvider._internal(
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
  RadioSessionState runNotifierBuild(covariant RadioSession notifier) {
    return notifier.build(gameId);
  }

  @override
  Override overrideWith(RadioSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: RadioSessionProvider._internal(
        () => create()..gameId = gameId,
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
  AutoDisposeNotifierProviderElement<RadioSession, RadioSessionState>
  createElement() {
    return _RadioSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RadioSessionProvider && other.gameId == gameId;
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
mixin RadioSessionRef on AutoDisposeNotifierProviderRef<RadioSessionState> {
  /// The parameter `gameId` of this provider.
  int get gameId;
}

class _RadioSessionProviderElement
    extends AutoDisposeNotifierProviderElement<RadioSession, RadioSessionState>
    with RadioSessionRef {
  _RadioSessionProviderElement(super.provider);

  @override
  int get gameId => (origin as RadioSessionProvider).gameId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
