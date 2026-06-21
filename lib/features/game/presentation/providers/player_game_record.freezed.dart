// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_game_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PlayerGameRecord {
  /// 누적 이동 경로 (2m 미만 이동은 노이즈로 제외)
  List<LatLngModel> get route => throw _privateConstructorUsedError;

  /// 누적 이동 거리(미터)
  double get distanceMeters => throw _privateConstructorUsedError;

  /// 경찰: 내가 잡은 도둑 수 (STOMP 확정 기준)
  int get myArrestCount => throw _privateConstructorUsedError;

  /// 도둑: 내가 탈옥한 횟수 (STOMP 확정 기준)
  int get myEscapeCount => throw _privateConstructorUsedError;

  /// 경찰: 내가 도둑을 잡은 위치들 (체포 확정 순간의 내 위치)
  List<LatLngModel> get arrestLocations => throw _privateConstructorUsedError;

  /// 도둑: 내가 잡힌 위치들 (내가 체포 확정된 순간의 내 위치)
  List<LatLngModel> get caughtLocations => throw _privateConstructorUsedError;

  /// 게임 종료 시각 (날짜·시간 헤더용)
  DateTime? get endedAt => throw _privateConstructorUsedError;

  /// Create a copy of PlayerGameRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerGameRecordCopyWith<PlayerGameRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerGameRecordCopyWith<$Res> {
  factory $PlayerGameRecordCopyWith(
    PlayerGameRecord value,
    $Res Function(PlayerGameRecord) then,
  ) = _$PlayerGameRecordCopyWithImpl<$Res, PlayerGameRecord>;
  @useResult
  $Res call({
    List<LatLngModel> route,
    double distanceMeters,
    int myArrestCount,
    int myEscapeCount,
    List<LatLngModel> arrestLocations,
    List<LatLngModel> caughtLocations,
    DateTime? endedAt,
  });
}

/// @nodoc
class _$PlayerGameRecordCopyWithImpl<$Res, $Val extends PlayerGameRecord>
    implements $PlayerGameRecordCopyWith<$Res> {
  _$PlayerGameRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerGameRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? route = null,
    Object? distanceMeters = null,
    Object? myArrestCount = null,
    Object? myEscapeCount = null,
    Object? arrestLocations = null,
    Object? caughtLocations = null,
    Object? endedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as List<LatLngModel>,
            distanceMeters: null == distanceMeters
                ? _value.distanceMeters
                : distanceMeters // ignore: cast_nullable_to_non_nullable
                      as double,
            myArrestCount: null == myArrestCount
                ? _value.myArrestCount
                : myArrestCount // ignore: cast_nullable_to_non_nullable
                      as int,
            myEscapeCount: null == myEscapeCount
                ? _value.myEscapeCount
                : myEscapeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            arrestLocations: null == arrestLocations
                ? _value.arrestLocations
                : arrestLocations // ignore: cast_nullable_to_non_nullable
                      as List<LatLngModel>,
            caughtLocations: null == caughtLocations
                ? _value.caughtLocations
                : caughtLocations // ignore: cast_nullable_to_non_nullable
                      as List<LatLngModel>,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerGameRecordImplCopyWith<$Res>
    implements $PlayerGameRecordCopyWith<$Res> {
  factory _$$PlayerGameRecordImplCopyWith(
    _$PlayerGameRecordImpl value,
    $Res Function(_$PlayerGameRecordImpl) then,
  ) = __$$PlayerGameRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<LatLngModel> route,
    double distanceMeters,
    int myArrestCount,
    int myEscapeCount,
    List<LatLngModel> arrestLocations,
    List<LatLngModel> caughtLocations,
    DateTime? endedAt,
  });
}

/// @nodoc
class __$$PlayerGameRecordImplCopyWithImpl<$Res>
    extends _$PlayerGameRecordCopyWithImpl<$Res, _$PlayerGameRecordImpl>
    implements _$$PlayerGameRecordImplCopyWith<$Res> {
  __$$PlayerGameRecordImplCopyWithImpl(
    _$PlayerGameRecordImpl _value,
    $Res Function(_$PlayerGameRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerGameRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? route = null,
    Object? distanceMeters = null,
    Object? myArrestCount = null,
    Object? myEscapeCount = null,
    Object? arrestLocations = null,
    Object? caughtLocations = null,
    Object? endedAt = freezed,
  }) {
    return _then(
      _$PlayerGameRecordImpl(
        route: null == route
            ? _value._route
            : route // ignore: cast_nullable_to_non_nullable
                  as List<LatLngModel>,
        distanceMeters: null == distanceMeters
            ? _value.distanceMeters
            : distanceMeters // ignore: cast_nullable_to_non_nullable
                  as double,
        myArrestCount: null == myArrestCount
            ? _value.myArrestCount
            : myArrestCount // ignore: cast_nullable_to_non_nullable
                  as int,
        myEscapeCount: null == myEscapeCount
            ? _value.myEscapeCount
            : myEscapeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        arrestLocations: null == arrestLocations
            ? _value._arrestLocations
            : arrestLocations // ignore: cast_nullable_to_non_nullable
                  as List<LatLngModel>,
        caughtLocations: null == caughtLocations
            ? _value._caughtLocations
            : caughtLocations // ignore: cast_nullable_to_non_nullable
                  as List<LatLngModel>,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$PlayerGameRecordImpl implements _PlayerGameRecord {
  const _$PlayerGameRecordImpl({
    final List<LatLngModel> route = const <LatLngModel>[],
    this.distanceMeters = 0.0,
    this.myArrestCount = 0,
    this.myEscapeCount = 0,
    final List<LatLngModel> arrestLocations = const <LatLngModel>[],
    final List<LatLngModel> caughtLocations = const <LatLngModel>[],
    this.endedAt,
  }) : _route = route,
       _arrestLocations = arrestLocations,
       _caughtLocations = caughtLocations;

  /// 누적 이동 경로 (2m 미만 이동은 노이즈로 제외)
  final List<LatLngModel> _route;

  /// 누적 이동 경로 (2m 미만 이동은 노이즈로 제외)
  @override
  @JsonKey()
  List<LatLngModel> get route {
    if (_route is EqualUnmodifiableListView) return _route;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_route);
  }

  /// 누적 이동 거리(미터)
  @override
  @JsonKey()
  final double distanceMeters;

  /// 경찰: 내가 잡은 도둑 수 (STOMP 확정 기준)
  @override
  @JsonKey()
  final int myArrestCount;

  /// 도둑: 내가 탈옥한 횟수 (STOMP 확정 기준)
  @override
  @JsonKey()
  final int myEscapeCount;

  /// 경찰: 내가 도둑을 잡은 위치들 (체포 확정 순간의 내 위치)
  final List<LatLngModel> _arrestLocations;

  /// 경찰: 내가 도둑을 잡은 위치들 (체포 확정 순간의 내 위치)
  @override
  @JsonKey()
  List<LatLngModel> get arrestLocations {
    if (_arrestLocations is EqualUnmodifiableListView) return _arrestLocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_arrestLocations);
  }

  /// 도둑: 내가 잡힌 위치들 (내가 체포 확정된 순간의 내 위치)
  final List<LatLngModel> _caughtLocations;

  /// 도둑: 내가 잡힌 위치들 (내가 체포 확정된 순간의 내 위치)
  @override
  @JsonKey()
  List<LatLngModel> get caughtLocations {
    if (_caughtLocations is EqualUnmodifiableListView) return _caughtLocations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_caughtLocations);
  }

  /// 게임 종료 시각 (날짜·시간 헤더용)
  @override
  final DateTime? endedAt;

  @override
  String toString() {
    return 'PlayerGameRecord(route: $route, distanceMeters: $distanceMeters, myArrestCount: $myArrestCount, myEscapeCount: $myEscapeCount, arrestLocations: $arrestLocations, caughtLocations: $caughtLocations, endedAt: $endedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerGameRecordImpl &&
            const DeepCollectionEquality().equals(other._route, _route) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.myArrestCount, myArrestCount) ||
                other.myArrestCount == myArrestCount) &&
            (identical(other.myEscapeCount, myEscapeCount) ||
                other.myEscapeCount == myEscapeCount) &&
            const DeepCollectionEquality().equals(
              other._arrestLocations,
              _arrestLocations,
            ) &&
            const DeepCollectionEquality().equals(
              other._caughtLocations,
              _caughtLocations,
            ) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_route),
    distanceMeters,
    myArrestCount,
    myEscapeCount,
    const DeepCollectionEquality().hash(_arrestLocations),
    const DeepCollectionEquality().hash(_caughtLocations),
    endedAt,
  );

  /// Create a copy of PlayerGameRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerGameRecordImplCopyWith<_$PlayerGameRecordImpl> get copyWith =>
      __$$PlayerGameRecordImplCopyWithImpl<_$PlayerGameRecordImpl>(
        this,
        _$identity,
      );
}

abstract class _PlayerGameRecord implements PlayerGameRecord {
  const factory _PlayerGameRecord({
    final List<LatLngModel> route,
    final double distanceMeters,
    final int myArrestCount,
    final int myEscapeCount,
    final List<LatLngModel> arrestLocations,
    final List<LatLngModel> caughtLocations,
    final DateTime? endedAt,
  }) = _$PlayerGameRecordImpl;

  /// 누적 이동 경로 (2m 미만 이동은 노이즈로 제외)
  @override
  List<LatLngModel> get route;

  /// 누적 이동 거리(미터)
  @override
  double get distanceMeters;

  /// 경찰: 내가 잡은 도둑 수 (STOMP 확정 기준)
  @override
  int get myArrestCount;

  /// 도둑: 내가 탈옥한 횟수 (STOMP 확정 기준)
  @override
  int get myEscapeCount;

  /// 경찰: 내가 도둑을 잡은 위치들 (체포 확정 순간의 내 위치)
  @override
  List<LatLngModel> get arrestLocations;

  /// 도둑: 내가 잡힌 위치들 (내가 체포 확정된 순간의 내 위치)
  @override
  List<LatLngModel> get caughtLocations;

  /// 게임 종료 시각 (날짜·시간 헤더용)
  @override
  DateTime? get endedAt;

  /// Create a copy of PlayerGameRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerGameRecordImplCopyWith<_$PlayerGameRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
