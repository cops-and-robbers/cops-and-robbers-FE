// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lifecycle_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LifecycleLog {
  AppLifecycleState get state => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Create a copy of LifecycleLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LifecycleLogCopyWith<LifecycleLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LifecycleLogCopyWith<$Res> {
  factory $LifecycleLogCopyWith(
    LifecycleLog value,
    $Res Function(LifecycleLog) then,
  ) = _$LifecycleLogCopyWithImpl<$Res, LifecycleLog>;
  @useResult
  $Res call({AppLifecycleState state, DateTime timestamp});
}

/// @nodoc
class _$LifecycleLogCopyWithImpl<$Res, $Val extends LifecycleLog>
    implements $LifecycleLogCopyWith<$Res> {
  _$LifecycleLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LifecycleLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? state = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as AppLifecycleState,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LifecycleLogImplCopyWith<$Res>
    implements $LifecycleLogCopyWith<$Res> {
  factory _$$LifecycleLogImplCopyWith(
    _$LifecycleLogImpl value,
    $Res Function(_$LifecycleLogImpl) then,
  ) = __$$LifecycleLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppLifecycleState state, DateTime timestamp});
}

/// @nodoc
class __$$LifecycleLogImplCopyWithImpl<$Res>
    extends _$LifecycleLogCopyWithImpl<$Res, _$LifecycleLogImpl>
    implements _$$LifecycleLogImplCopyWith<$Res> {
  __$$LifecycleLogImplCopyWithImpl(
    _$LifecycleLogImpl _value,
    $Res Function(_$LifecycleLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LifecycleLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? state = null, Object? timestamp = null}) {
    return _then(
      _$LifecycleLogImpl(
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as AppLifecycleState,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$LifecycleLogImpl extends _LifecycleLog {
  const _$LifecycleLogImpl({required this.state, required this.timestamp})
    : super._();

  @override
  final AppLifecycleState state;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'LifecycleLog(state: $state, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LifecycleLogImpl &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, state, timestamp);

  /// Create a copy of LifecycleLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LifecycleLogImplCopyWith<_$LifecycleLogImpl> get copyWith =>
      __$$LifecycleLogImplCopyWithImpl<_$LifecycleLogImpl>(this, _$identity);
}

abstract class _LifecycleLog extends LifecycleLog {
  const factory _LifecycleLog({
    required final AppLifecycleState state,
    required final DateTime timestamp,
  }) = _$LifecycleLogImpl;
  const _LifecycleLog._() : super._();

  @override
  AppLifecycleState get state;
  @override
  DateTime get timestamp;

  /// Create a copy of LifecycleLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LifecycleLogImplCopyWith<_$LifecycleLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
