// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'zone_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ZoneInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get radiusMeters => throw _privateConstructorUsedError;

  /// Create a copy of ZoneInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ZoneInfoCopyWith<ZoneInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ZoneInfoCopyWith<$Res> {
  factory $ZoneInfoCopyWith(ZoneInfo value, $Res Function(ZoneInfo) then) =
      _$ZoneInfoCopyWithImpl<$Res, ZoneInfo>;
  @useResult
  $Res call({String id, String name, int radiusMeters});
}

/// @nodoc
class _$ZoneInfoCopyWithImpl<$Res, $Val extends ZoneInfo>
    implements $ZoneInfoCopyWith<$Res> {
  _$ZoneInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ZoneInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? radiusMeters = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            radiusMeters: null == radiusMeters
                ? _value.radiusMeters
                : radiusMeters // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ZoneInfoImplCopyWith<$Res>
    implements $ZoneInfoCopyWith<$Res> {
  factory _$$ZoneInfoImplCopyWith(
    _$ZoneInfoImpl value,
    $Res Function(_$ZoneInfoImpl) then,
  ) = __$$ZoneInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int radiusMeters});
}

/// @nodoc
class __$$ZoneInfoImplCopyWithImpl<$Res>
    extends _$ZoneInfoCopyWithImpl<$Res, _$ZoneInfoImpl>
    implements _$$ZoneInfoImplCopyWith<$Res> {
  __$$ZoneInfoImplCopyWithImpl(
    _$ZoneInfoImpl _value,
    $Res Function(_$ZoneInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ZoneInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? radiusMeters = null,
  }) {
    return _then(
      _$ZoneInfoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        radiusMeters: null == radiusMeters
            ? _value.radiusMeters
            : radiusMeters // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ZoneInfoImpl extends _ZoneInfo {
  const _$ZoneInfoImpl({
    required this.id,
    required this.name,
    required this.radiusMeters,
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final int radiusMeters;

  @override
  String toString() {
    return 'ZoneInfo(id: $id, name: $name, radiusMeters: $radiusMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ZoneInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.radiusMeters, radiusMeters) ||
                other.radiusMeters == radiusMeters));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, radiusMeters);

  /// Create a copy of ZoneInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ZoneInfoImplCopyWith<_$ZoneInfoImpl> get copyWith =>
      __$$ZoneInfoImplCopyWithImpl<_$ZoneInfoImpl>(this, _$identity);
}

abstract class _ZoneInfo extends ZoneInfo {
  const factory _ZoneInfo({
    required final String id,
    required final String name,
    required final int radiusMeters,
  }) = _$ZoneInfoImpl;
  const _ZoneInfo._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  int get radiusMeters;

  /// Create a copy of ZoneInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ZoneInfoImplCopyWith<_$ZoneInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
