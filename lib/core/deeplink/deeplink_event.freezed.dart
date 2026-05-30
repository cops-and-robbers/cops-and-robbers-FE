// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deeplink_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DeeplinkEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String inviteCode) inviteJoin,
    required TResult Function(Uri uri) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String inviteCode)? inviteJoin,
    TResult? Function(Uri uri)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String inviteCode)? inviteJoin,
    TResult Function(Uri uri)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InviteJoinEvent value) inviteJoin,
    required TResult Function(UnknownEvent value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InviteJoinEvent value)? inviteJoin,
    TResult? Function(UnknownEvent value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InviteJoinEvent value)? inviteJoin,
    TResult Function(UnknownEvent value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeeplinkEventCopyWith<$Res> {
  factory $DeeplinkEventCopyWith(
    DeeplinkEvent value,
    $Res Function(DeeplinkEvent) then,
  ) = _$DeeplinkEventCopyWithImpl<$Res, DeeplinkEvent>;
}

/// @nodoc
class _$DeeplinkEventCopyWithImpl<$Res, $Val extends DeeplinkEvent>
    implements $DeeplinkEventCopyWith<$Res> {
  _$DeeplinkEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InviteJoinEventImplCopyWith<$Res> {
  factory _$$InviteJoinEventImplCopyWith(
    _$InviteJoinEventImpl value,
    $Res Function(_$InviteJoinEventImpl) then,
  ) = __$$InviteJoinEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String inviteCode});
}

/// @nodoc
class __$$InviteJoinEventImplCopyWithImpl<$Res>
    extends _$DeeplinkEventCopyWithImpl<$Res, _$InviteJoinEventImpl>
    implements _$$InviteJoinEventImplCopyWith<$Res> {
  __$$InviteJoinEventImplCopyWithImpl(
    _$InviteJoinEventImpl _value,
    $Res Function(_$InviteJoinEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? inviteCode = null}) {
    return _then(
      _$InviteJoinEventImpl(
        inviteCode: null == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$InviteJoinEventImpl implements InviteJoinEvent {
  const _$InviteJoinEventImpl({required this.inviteCode});

  @override
  final String inviteCode;

  @override
  String toString() {
    return 'DeeplinkEvent.inviteJoin(inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InviteJoinEventImpl &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, inviteCode);

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InviteJoinEventImplCopyWith<_$InviteJoinEventImpl> get copyWith =>
      __$$InviteJoinEventImplCopyWithImpl<_$InviteJoinEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String inviteCode) inviteJoin,
    required TResult Function(Uri uri) unknown,
  }) {
    return inviteJoin(inviteCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String inviteCode)? inviteJoin,
    TResult? Function(Uri uri)? unknown,
  }) {
    return inviteJoin?.call(inviteCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String inviteCode)? inviteJoin,
    TResult Function(Uri uri)? unknown,
    required TResult orElse(),
  }) {
    if (inviteJoin != null) {
      return inviteJoin(inviteCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InviteJoinEvent value) inviteJoin,
    required TResult Function(UnknownEvent value) unknown,
  }) {
    return inviteJoin(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InviteJoinEvent value)? inviteJoin,
    TResult? Function(UnknownEvent value)? unknown,
  }) {
    return inviteJoin?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InviteJoinEvent value)? inviteJoin,
    TResult Function(UnknownEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (inviteJoin != null) {
      return inviteJoin(this);
    }
    return orElse();
  }
}

abstract class InviteJoinEvent implements DeeplinkEvent {
  const factory InviteJoinEvent({required final String inviteCode}) =
      _$InviteJoinEventImpl;

  String get inviteCode;

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InviteJoinEventImplCopyWith<_$InviteJoinEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownEventImplCopyWith<$Res> {
  factory _$$UnknownEventImplCopyWith(
    _$UnknownEventImpl value,
    $Res Function(_$UnknownEventImpl) then,
  ) = __$$UnknownEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Uri uri});
}

/// @nodoc
class __$$UnknownEventImplCopyWithImpl<$Res>
    extends _$DeeplinkEventCopyWithImpl<$Res, _$UnknownEventImpl>
    implements _$$UnknownEventImplCopyWith<$Res> {
  __$$UnknownEventImplCopyWithImpl(
    _$UnknownEventImpl _value,
    $Res Function(_$UnknownEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? uri = null}) {
    return _then(
      _$UnknownEventImpl(
        uri: null == uri
            ? _value.uri
            : uri // ignore: cast_nullable_to_non_nullable
                  as Uri,
      ),
    );
  }
}

/// @nodoc

class _$UnknownEventImpl implements UnknownEvent {
  const _$UnknownEventImpl({required this.uri});

  @override
  final Uri uri;

  @override
  String toString() {
    return 'DeeplinkEvent.unknown(uri: $uri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownEventImpl &&
            (identical(other.uri, uri) || other.uri == uri));
  }

  @override
  int get hashCode => Object.hash(runtimeType, uri);

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownEventImplCopyWith<_$UnknownEventImpl> get copyWith =>
      __$$UnknownEventImplCopyWithImpl<_$UnknownEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String inviteCode) inviteJoin,
    required TResult Function(Uri uri) unknown,
  }) {
    return unknown(uri);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String inviteCode)? inviteJoin,
    TResult? Function(Uri uri)? unknown,
  }) {
    return unknown?.call(uri);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String inviteCode)? inviteJoin,
    TResult Function(Uri uri)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(uri);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InviteJoinEvent value) inviteJoin,
    required TResult Function(UnknownEvent value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(InviteJoinEvent value)? inviteJoin,
    TResult? Function(UnknownEvent value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InviteJoinEvent value)? inviteJoin,
    TResult Function(UnknownEvent value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownEvent implements DeeplinkEvent {
  const factory UnknownEvent({required final Uri uri}) = _$UnknownEventImpl;

  Uri get uri;

  /// Create a copy of DeeplinkEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownEventImplCopyWith<_$UnknownEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
