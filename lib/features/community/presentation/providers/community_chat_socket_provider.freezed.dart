// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_chat_socket_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CommunityChatSocketState {
  CommunityChatConnectionState get connection =>
      throw _privateConstructorUsedError;

  /// 자동 재연결 5회 실패 — 띠에 "다시 연결" 버튼을 준다.
  bool get reconnectExhausted => throw _privateConstructorUsedError;

  /// Create a copy of CommunityChatSocketState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommunityChatSocketStateCopyWith<CommunityChatSocketState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityChatSocketStateCopyWith<$Res> {
  factory $CommunityChatSocketStateCopyWith(
    CommunityChatSocketState value,
    $Res Function(CommunityChatSocketState) then,
  ) = _$CommunityChatSocketStateCopyWithImpl<$Res, CommunityChatSocketState>;
  @useResult
  $Res call({CommunityChatConnectionState connection, bool reconnectExhausted});
}

/// @nodoc
class _$CommunityChatSocketStateCopyWithImpl<
  $Res,
  $Val extends CommunityChatSocketState
>
    implements $CommunityChatSocketStateCopyWith<$Res> {
  _$CommunityChatSocketStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommunityChatSocketState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? connection = null, Object? reconnectExhausted = null}) {
    return _then(
      _value.copyWith(
            connection: null == connection
                ? _value.connection
                : connection // ignore: cast_nullable_to_non_nullable
                      as CommunityChatConnectionState,
            reconnectExhausted: null == reconnectExhausted
                ? _value.reconnectExhausted
                : reconnectExhausted // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommunityChatSocketStateImplCopyWith<$Res>
    implements $CommunityChatSocketStateCopyWith<$Res> {
  factory _$$CommunityChatSocketStateImplCopyWith(
    _$CommunityChatSocketStateImpl value,
    $Res Function(_$CommunityChatSocketStateImpl) then,
  ) = __$$CommunityChatSocketStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CommunityChatConnectionState connection, bool reconnectExhausted});
}

/// @nodoc
class __$$CommunityChatSocketStateImplCopyWithImpl<$Res>
    extends
        _$CommunityChatSocketStateCopyWithImpl<
          $Res,
          _$CommunityChatSocketStateImpl
        >
    implements _$$CommunityChatSocketStateImplCopyWith<$Res> {
  __$$CommunityChatSocketStateImplCopyWithImpl(
    _$CommunityChatSocketStateImpl _value,
    $Res Function(_$CommunityChatSocketStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommunityChatSocketState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? connection = null, Object? reconnectExhausted = null}) {
    return _then(
      _$CommunityChatSocketStateImpl(
        connection: null == connection
            ? _value.connection
            : connection // ignore: cast_nullable_to_non_nullable
                  as CommunityChatConnectionState,
        reconnectExhausted: null == reconnectExhausted
            ? _value.reconnectExhausted
            : reconnectExhausted // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CommunityChatSocketStateImpl
    with DiagnosticableTreeMixin
    implements _CommunityChatSocketState {
  const _$CommunityChatSocketStateImpl({
    this.connection = CommunityChatConnectionState.disconnected,
    this.reconnectExhausted = false,
  });

  @override
  @JsonKey()
  final CommunityChatConnectionState connection;

  /// 자동 재연결 5회 실패 — 띠에 "다시 연결" 버튼을 준다.
  @override
  @JsonKey()
  final bool reconnectExhausted;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommunityChatSocketState(connection: $connection, reconnectExhausted: $reconnectExhausted)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CommunityChatSocketState'))
      ..add(DiagnosticsProperty('connection', connection))
      ..add(DiagnosticsProperty('reconnectExhausted', reconnectExhausted));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityChatSocketStateImpl &&
            (identical(other.connection, connection) ||
                other.connection == connection) &&
            (identical(other.reconnectExhausted, reconnectExhausted) ||
                other.reconnectExhausted == reconnectExhausted));
  }

  @override
  int get hashCode => Object.hash(runtimeType, connection, reconnectExhausted);

  /// Create a copy of CommunityChatSocketState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityChatSocketStateImplCopyWith<_$CommunityChatSocketStateImpl>
  get copyWith =>
      __$$CommunityChatSocketStateImplCopyWithImpl<
        _$CommunityChatSocketStateImpl
      >(this, _$identity);
}

abstract class _CommunityChatSocketState implements CommunityChatSocketState {
  const factory _CommunityChatSocketState({
    final CommunityChatConnectionState connection,
    final bool reconnectExhausted,
  }) = _$CommunityChatSocketStateImpl;

  @override
  CommunityChatConnectionState get connection;

  /// 자동 재연결 5회 실패 — 띠에 "다시 연결" 버튼을 준다.
  @override
  bool get reconnectExhausted;

  /// Create a copy of CommunityChatSocketState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommunityChatSocketStateImplCopyWith<_$CommunityChatSocketStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
