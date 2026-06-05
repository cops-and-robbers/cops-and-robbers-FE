// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ping.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Ping {
  /// 로컬 임시 id (마커/타이머 식별용, 'ping_<counter>').
  /// 서버 핑 API 도입 시 서버가 부여하는 id로 대체된다.
  String get id => throw _privateConstructorUsedError;
  PingType get type => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of Ping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PingCopyWith<Ping> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PingCopyWith<$Res> {
  factory $PingCopyWith(Ping value, $Res Function(Ping) then) =
      _$PingCopyWithImpl<$Res, Ping>;
  @useResult
  $Res call({
    String id,
    PingType type,
    double latitude,
    double longitude,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PingCopyWithImpl<$Res, $Val extends Ping>
    implements $PingCopyWith<$Res> {
  _$PingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PingType,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PingImplCopyWith<$Res> implements $PingCopyWith<$Res> {
  factory _$$PingImplCopyWith(
    _$PingImpl value,
    $Res Function(_$PingImpl) then,
  ) = __$$PingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    PingType type,
    double latitude,
    double longitude,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PingImplCopyWithImpl<$Res>
    extends _$PingCopyWithImpl<$Res, _$PingImpl>
    implements _$$PingImplCopyWith<$Res> {
  __$$PingImplCopyWithImpl(_$PingImpl _value, $Res Function(_$PingImpl) _then)
    : super(_value, _then);

  /// Create a copy of Ping
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PingType,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$PingImpl implements _Ping {
  const _$PingImpl({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  /// 로컬 임시 id (마커/타이머 식별용, 'ping_<counter>').
  /// 서버 핑 API 도입 시 서버가 부여하는 id로 대체된다.
  @override
  final String id;
  @override
  final PingType type;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Ping(id: $id, type: $type, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, latitude, longitude, createdAt);

  /// Create a copy of Ping
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PingImplCopyWith<_$PingImpl> get copyWith =>
      __$$PingImplCopyWithImpl<_$PingImpl>(this, _$identity);
}

abstract class _Ping implements Ping {
  const factory _Ping({
    required final String id,
    required final PingType type,
    required final double latitude,
    required final double longitude,
    required final DateTime createdAt,
  }) = _$PingImpl;

  /// 로컬 임시 id (마커/타이머 식별용, 'ping_<counter>').
  /// 서버 핑 API 도입 시 서버가 부여하는 id로 대체된다.
  @override
  String get id;
  @override
  PingType get type;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get createdAt;

  /// Create a copy of Ping
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PingImplCopyWith<_$PingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
